Ref: https://github.com/ArctosDB/arctos/issues/808

Doc: http://arctosdb.org/documentation/encumbrance/


an expiration date and/or event 
an expiration date 

This agent must have the authority to nullify the encumbrance.
This agent may act in an advisory role; final authority to remove encumbrances rests with the collection.


Specimens under encumbrances which no one has the authority to remove should be considered for de-accession. 
Encumbrances assigned by persons who cannot be contacted should be removed.
- strike completely -

Expiration Date and/or Event:....
- new paragraph:

Expiration Date: All encumbrances should be temporary. 
De-accession should be considered for permanently-encumbered specimens. 
Expiration date may occur no more than 5 years from the current date. 
Yearly email notifications are provided to 
collection staff, and encumbrances may be extended (in 5-year increments) indefinitely.
Expiration date is a triggering event - encumbrances are automaticaly retracted when expiration_date is reached.

-- send an email to everyone with encumbrances expiring in the next year
select distinct get_address(collection_contacts.contact_agent_id,'email') address
	from
collection_contacts,
encumbrance,
	coll_object_encumbrance,
	cataloged_item,
	collection
where
		collection_contacts.collection_id=collection.collection_id and
		encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and 
	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and
	EXPIRATION_DATE < add_months(sysdate,12)
	;
			
			
			
			
select distinct guid_prefix from (
select 
	ENCUMBRANCE,
	getPreferredAgentName(ENCUMBERING_AGENT_ID) encumberer,
	EXPIRATION_DATE,
	guid_prefix
from
	encumbrance,
	coll_object_encumbrance,
	cataloged_item,
	collection
where
	encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and 
	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and
	EXPIRATION_DATE < add_months(sysdate,12)
group by
	ENCUMBRANCE,
	getPreferredAgentName(ENCUMBERING_AGENT_ID),
	EXPIRATION_DATE,
	guid_prefix
);


GUID_PREFIX
------------------------------------------------------------
UAM:ES
MSB:Bird
UAMb:Herb
UAM:Herb
DGR:Mamm
MSB:Para
DMNS:Bird
DGR:Bird
MSB:Mamm
UWBM:Herp
MSB:Herp




create table temp_expyr_enc as
select 
	ENCUMBRANCE,
	getPreferredAgentName(ENCUMBERING_AGENT_ID) encumberer,
	EXPIRATION_DATE,
	guid_prefix,
	REMARKS,
	ENCUMBRANCE_ACTION,
	'http://arctos.database.museum/Encumbrances.cfm?action=listEncumbrances\&encumbrance_id=' || encumbrance.encumbrance_id link
from
	encumbrance,
	coll_object_encumbrance,
	cataloged_item,
	collection
where
	encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and 
	coll_object_encumbrance.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and
	EXPIRATION_DATE < add_months(sysdate,12)
group by
	ENCUMBRANCE,
	getPreferredAgentName(ENCUMBERING_AGENT_ID),
	EXPIRATION_DATE,
	guid_prefix,
	encumbrance.encumbrance_id,
	REMARKS,
	ENCUMBRANCE_ACTION
;

UAM@ARCTEST> desc encumbrance;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 ENCUMBRANCE_ID 						   NOT NULL NUMBER
 ENCUMBERING_AGENT_ID						   NOT NULL NUMBER
 EXPIRATION_DATE							    DATE
 EXPIRATION_EVENT							    VARCHAR2(60)
 ENCUMBRANCE							   NOT NULL VARCHAR2(60)
 MADE_DATE								    DATE
 REMARKS								    VARCHAR2(255)
 ENCUMBRANCE_ACTION						   NOT NULL VARCHAR2(30)

 
select
	REMARKS,
	EXPIRATION_EVENT,
	decode(REMARKS,
		null,EXPIRATION_EVENT,
		REMARKS || '; Expiration Event: ' || EXPIRATION_EVENT)
	from encumbrance where EXPIRATION_EVENT is not null;
	
alter table encumbrance modify remarks varchar2(4000);

drop trigger tr_encumbrance_expire;


update encumbrance set REMARKS=
	decode(REMARKS,
		null,EXPIRATION_EVENT,
		REMARKS || '; Expiration Event: ' || EXPIRATION_EVENT)
where EXPIRATION_EVENT is not null;


update encumbrance set EXPIRATION_DATE=add_months(sysdate,60) where EXPIRATION_DATE is null;

-- anybody being optimistic?
select EXPIRATION_DATE from encumbrance where EXPIRATION_DATE>add_months(sysdate,60);

update encumbrance set EXPIRATION_DATE=add_months(sysdate,60) where EXPIRATION_DATE>add_months(sysdate,60);


alter table encumbrance modify EXPIRATION_DATE not null;


alter table encumbrance drop column EXPIRATION_EVENT;


CREATE OR REPLACE TRIGGER tr_encumbrance_biu
BEFORE UPDATE OR INSERT ON encumbrance
FOR EACH ROW
BEGIN
    IF :new.EXPIRATION_DATE > add_months(sysdate,60) THEN
        raise_application_error(
            -20001,
            'EXPIRATION_DATE may be more more than 5 years in the future.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER TR_ENCUMBRANCE_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON encumbrance
FOR EACH ROW
DECLARE id NUMBER;
BEGIN

    IF deleting
        THEN id := :OLD.encumbrance_id;
        ELSE id := :NEW.encumbrance_id;
    END IF;
	
    -- no need to fire if we're just changing remarks etc.
    if :NEW.EXPIRATION_DATE != :OLD.EXPIRATION_DATE or :NEW.ENCUMBRANCE_ACTION != :OLD.ENCUMBRANCE_ACTION then
	    UPDATE flat
	    SET stale_flag = 1,
	    lastuser = sys_context('USERENV', 'SESSION_USER'),
	    lastdate = SYSDATE
	    WHERE collection_object_id in (select collection_object_id from coll_object_encumbrance where encumbrance_id = id);
	end if;
END;

-- encumbrances in FILTERED_FLAT are based on concatEncumbrances
-- rewrite it to only pull current encumbrances

CREATE OR REPLACE function concatEncumbrances(p_key_val  in number )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);

       l_cur    rc;
   begin
      open l_cur for 'select encumbrance_action
                         from encumbrance, coll_object_encumbrance
                        where encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id
						AND EXPIRATION_DATE > sysdate
                        AND coll_object_encumbrance.collection_object_id  = :x '
                          using p_key_val;
       loop
           fetch l_cur into l_val;
           exit when l_cur%notfound;
           l_str := l_str || l_sep || l_val;
           l_sep := '; ';
       end loop;
       close l_cur;
       return l_str;
  end;
/



-- procedure to un-encumber specimens from expired encumbrances
-- runs nightly

CREATE OR REPLACE PROCEDURE remove_expired_encumbrance IS 
BEGIN
	-- find encumbrances which have expired
	-- and which hold specimens that are encumbered in flat
	-- this will ignore encumbrances which don't mess with data (eg "restrict usage")
	-- and those which have already been expired
	FOR r IN (
		SELECT DISTINCT 
		    encumbrance.encumbrance_id
		from
			encumbrance,
			coll_object_encumbrance,
			flat
		where
			-- expired
			encumbrance.EXPIRATION_DATE < sysdate and
			encumbrance.encumbrance_id=coll_object_encumbrance.encumbrance_id and
			coll_object_encumbrance.collection_object_id=flat.collection_object_id and
			-- doing something
			flat.encumbrances is not null
	) loop		
		update flat set stale_flag=1 where collection_object_id in (
			select collection_object_id from coll_object_encumbrance where encumbrance_id=r.encumbrance_id
		);
	END LOOP;
END;
/
sho err;


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_remove_expired_encumbrance',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'remove_expired_encumbrance',
		start_date		=> to_timestamp_tz('30-APR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily; byhour=1; byminute=23',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'remove expired encumbrances from flat');
END;
/ 


set heading off;
set echo off;
Set pages 999;
set long 90000;

spool ddl_list.sql
select dbms_metadata.get_ddl('FUNCTION','CONCATENCUMBRANCEDETAILS') from dual;
spool off;





CREATE OR REPLACE FUNCTION concatEncumbranceDetails (p_key_val  in varchar2 )
	return varchar2 as
		type rc is ref cursor;
		l_str varchar2(4000);
		l_sep varchar2(30);
		l_val varchar2(4000);
 		l_cur rc;
   begin
      open l_cur for 'select encumbrance_action
  						|| '' by '' ||agent_name || '' on ''
  						|| to_char(made_date,''yyyy-mm-dd'') || ''.''
  						|| '' Expires '' || to_char(expiration_date,''yyyy-mm-dd''
						|| ''.'')
				 		from 
							encumbrance,
							coll_object_encumbrance,
							preferred_agent_name
						where
							encumbrance.EXPIRATION_DATE > sysdate and
							encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and 
							encumbrance.encumbering_agent_id=preferred_agent_name.agent_id AND 
							coll_object_encumbrance.collection_object_id = :x '
					  using p_key_val;
	loop
		fetch l_cur into l_val;
   		exit when l_cur%notfound;
   		l_str := l_str || l_sep || l_val;
   		l_sep := '; ';
    end loop;
   	close l_cur;
	return l_str;
  end;
 /
 sho err;
 
 
 select UAM.CONCATENCUMBRANCEDETAILS(12) from dual;