-- import via CSV - suck CSV into arctos, rename, then....

create table ssrch_field_doc as select * from dlm.my_temp_cf ;

alter table ssrch_field_doc rename column ssrch_field_doc_id to temp;
alter table ssrch_field_doc add ssrch_field_doc_id number;
update ssrch_field_doc set ssrch_field_doc_id=temp;
alter table ssrch_field_doc drop column temp;

alter table ssrch_field_doc drop constraint PK_ssrch_field_doc;
alter table ssrch_field_doc add constraint PK_ssrch_field_doc PRIMARY KEY (ssrch_field_doc_id) using index TABLESPACE UAM_IDX_1;

alter sequence sq_ssrch_field_doc_id increment by 1000;
select sq_ssrch_field_doc_id.nextval from dual;
alter sequence sq_ssrch_field_doc_id increment by 1;




alter table ssrch_field_doc rename column SPECIMEN_RESULTS_COL to temp;
alter table ssrch_field_doc add SPECIMEN_RESULTS_COL number;
update ssrch_field_doc set temp='1' where temp is not null;
update ssrch_field_doc set temp='0' where temp is null;
update ssrch_field_doc set SPECIMEN_RESULTS_COL=to_number(temp);
alter table ssrch_field_doc drop column temp;
alter table ssrch_field_doc modify SPECIMEN_RESULTS_COL not null;
ALTER TABLE ssrch_field_doc ADD CONSTRAINT ch_bool_issres CHECK (SPECIMEN_RESULTS_COL IN (0,1));

  
  

alter table ssrch_field_doc rename column DISP_ORDER to temp;
alter table ssrch_field_doc add DISP_ORDER number;


select temp from ssrch_field_doc where is_number(temp) != 1;

update ssrch_field_doc set temp=null where  is_number(temp) != 1;

update ssrch_field_doc set DISP_ORDER=to_number(temp);

select DISP_ORDER from ssrch_field_doc having count(*)> 1 group by DISP_ORDER;

update ssrch_field_doc set DISP_ORDER=9999990 where DISP_ORDER=999999;

select rowid from ssrch_field_doc where DISP_ORDER=9999990;
update ssrch_field_doc set DISP_ORDER=9999991 where rowid='AABAULAAAAAKIoTAAu';


create unique index iu_ssflddoc_dispord on ssrch_field_doc (DISP_ORDER) tablespace uam_idx_1;


-- now increment nicely


declare 
	n number;

	begin
		n:=1;
		for r in (select disp_order from ssrch_field_doc where DISP_ORDER is not null order by DISP_ORDER) loop
			update ssrch_field_doc set disp_order=n where disp_order=r.disp_order;
			n:=n+1;
		end loop;
	end;
/

drop trigger TRG_BEF_ssrch_field_doc;

alter table ssrch_field_doc rename column SPECIMEN_RESULTS_COL to temp;


update ssrch_field_doc set temp='0' where temp is null;
update ssrch_field_doc set SPECIMEN_RESULTS_COL=to_number(temp);
alter table ssrch_field_doc drop column temp;
alter table ssrch_field_doc modify SPECIMEN_RESULTS_COL not null;


ALTER TABLE ssrch_field_doc drop CONSTRAINT ch_bool_issres;
ALTER TABLE ssrch_field_doc ADD CONSTRAINT ch_bool_issres CHECK (SPECIMEN_RESULTS_COL IN (0,1));
  



alter table ssrch_field_doc rename column specimen_query_term to temp;
alter table ssrch_field_doc add specimen_query_term number;
update ssrch_field_doc set specimen_query_term=temp;

alter table ssrch_field_doc drop column temp;



alter table ssrch_field_doc modify specimen_query_term not null;
ALTER TABLE ssrch_field_doc ADD CONSTRAINT ch_bool_ssterm CHECK (specimen_query_term IN (0,1));


CREATE OR REPLACE TRIGGER tr_ssrch_field_doc before insert or update ON ssrch_field_doc for each row
	begin    
		IF :new.ssrch_field_doc_id IS NULL THEN
			select sq_ssrch_field_doc_id.nextval into :new.ssrch_field_doc_id from dual;
		END IF;
		:NEW.cf_variable := lower(:NEW.cf_variable);
		
		if (
			:new.CATEGORY is not null or 
			:new.DISP_ORDER is not null or 
			:new.SPECIMEN_RESULTS_COL=1 or 
			:new.SQL_ELEMENT is not null) and 
			(:new.CATEGORY is null or :new.DISP_ORDER is null or :new.SPECIMEN_RESULTS_COL=0 or :new.SQL_ELEMENT is null) then
  				raise_application_error(-20001,'CATEGORY, DISP_ORDER, SPECIMEN_RESULTS_COL, and SQL_ELEMENT must be given together; provide something for all, or none.');
		end if;
		if 
			:new.SQL_ELEMENT is not null and :new.SQL_ELEMENT not like '%flatTableName.%' then
			-- allow mycustomidtype and mycustomidtype
			if :NEW.cf_variable != 'mycustomidtype' and :new.cf_variable != 'mycustomidtype' then
  				raise_application_error(-20001,'SQL_ELEMENT must contain "flatTableName." (case-sensitive) as a placeholder for flat or filtered_flat.');
  			end if;
  		end if;
   end;                                                                                           
/
sho err


alter table ssrch_field_doc modify display_text not null;
alter table ssrch_field_doc modify CF_VARIABLE not null;



-- init below, probably won't need it again...
create table ssrch_field_doc as select * from cf_spec_res_cols;

alter table ssrch_field_doc rename column COLUMN_NAME to cf_variable;
alter table ssrch_field_doc rename column cf_variable_id to ssrch_field_doc_id;
alter table ssrch_field_doc add specimen_results_col number;
update ssrch_field_doc set specimen_results_col=1;
alter table ssrch_field_doc add SEARCH_HINT VARCHAR2(4000);
alter table ssrch_field_doc add DEFINITION VARCHAR2(4000);
alter table ssrch_field_doc add documentation_link VARCHAR2(4000);
alter table ssrch_field_doc add data_type VARCHAR2(40);
alter table ssrch_field_doc add placeholder_text VARCHAR2(50);
alter table ssrch_field_doc add code_table VARCHAR2(50);

alter table ssrch_field_doc add display_text VARCHAR2(150);



delete from ssrch_field_doc where CF_VARIABLE is null;

alter table ssrch_field_doc modify CF_VARIABLE not null;
alter table ssrch_field_doc modify DISP_ORDER null;

create unique index iu_ssrch_field_doc_cfvar on ssrch_field_doc(CF_VARIABLE) tablespace uam_idx_1;

create sequence sq_ssrch_field_doc_id;

CREATE PUBLIC SYNONYM sq_ssrch_field_doc_id FOR sq_ssrch_field_doc_id;
GRANT SELECT ON sq_ssrch_field_doc_id TO PUBLIC;



alter table ssrch_field_doc add constraint PK_ssrch_field_doc PRIMARY KEY (ssrch_field_doc_id) using index TABLESPACE UAM_IDX_1;



 
declare
	n number;
begin
	for r in (select * from cf_search_terms) loop
		select count(*) into n from ssrch_field_doc where cf_variable=lower(r.term);
		if n=0 then
			insert into ssrch_field_doc (CF_VARIABLE,display_text,DEFINITION,CODE_TABLE) values (lower(r.term),r.DISPLAY,r.DEFINITION,r.CODE_TABLE);
		else
			update ssrch_field_doc set
			display_text=r.DISPLAY,
			DEFINITION=r.DEFINITION,
			CODE_TABLE=r.CODE_TABLE
			where CF_VARIABLE=lower(r.term);
		end if;
	end loop;
end;
/

create or replace public synonym ssrch_field_doc for ssrch_field_doc;
grant select on ssrch_field_doc to public;
grant all on ssrch_field_doc to MANAGE_DOCUMENTATION;

declare
	n number;
begin
	for r in (select * from short_doc) loop
		select count(*) into n from ssrch_field_doc where cf_variable=lower(r.COLNAME);
		if n=0 then
			insert into ssrch_field_doc (CF_VARIABLE,display_text,DEFINITION,SEARCH_HINT,DOCUMENTATION_LINK) values (lower(r.COLNAME),r.DISPLAY_NAME,r.DEFINITION,r.SEARCH_HINT,r.MORE_INFO);
		else
			update ssrch_field_doc set
			display_text=r.DISPLAY_NAME,
			DEFINITION=r.DEFINITION,
			SEARCH_HINT=r.SEARCH_HINT,
			DOCUMENTATION_LINK=r.MORE_INFO
			where CF_VARIABLE=lower(r.COLNAME);
		end if;
	end loop;
end;
/

alter table ssrch_field_doc rename column CODE_TABLE to controlled_vocabulary;
 
 
select
		COLUMN_NAME cf_variable,
	from
		cf_spec_res_cols
	union
	select
		TERM cf_variable,
	from
		cf_search_terms
	union
	select
		COLNAME cf_variable,
		DISPLAY_NAME display_term
	from
		short_doc

uam@ARCTOSNEW> desc cf_search_terms;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 								   NOT NULL VARCHAR2(60)
 DISPLAY							   NOT NULL VARCHAR2(60)
 CODE_TABLE								    VARCHAR2(60)
 DEFINITION								    VARCHAR2(255)

uam@ARCTOSNEW> desc short_doc'
SP2-0565: Illegal identifier.
uam@ARCTOSNEW> desc short_doc;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 SHORT_DOC_ID							   NOT NULL NUMBER
 							   NOT NULL VARCHAR2(76)
 								    VARCHAR2(60)
 							   NOT NULL VARCHAR2(4000)
 SEARCH_HINT								    VARCHAR2(4000)
 MORE_INFO								    VARCHAR2(255)

uam@ARCTOSNEW> desc cf_spec_res_cols_exp;
ERROR:
ORA-04043: object cf_spec_res_cols_exp does not exist


uam@ARCTOSNEW> desc cf_spec_res_cols;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 								    VARCHAR2(38)
 SQL_ELEMENT								    VARCHAR2(255)
 CATEGORY								    VARCHAR2(255)
 						   NOT NULL NUMBER
 DISP_ORDER							   NOT NULL NUMBER




 alter table media_flat add earliest_date varchar2(30);
 alter table media_flat add latest_date varchar2(30);
alter table media_flat add location varchar2(4000);

set escape "\"
-- moved to procedures

CREATE OR REPLACE PROCEDURE set_media_flat
is
    tabl varchar2(255);
    kw VARCHAR2(4000);
    kwt VARCHAR2(4000);
    lbl VARCHAR2(4000);
    lblt VARCHAR2(4000);
    rel VARCHAR2(4000);
    relt VARCHAR2(4000);
    rsep VARCHAR2(4);
    ksep VARCHAR2(4);
    lsep VARCHAR2(4);
    csep varchar2(4);
    tn number;
    ct varchar2(4000);
    coords varchar2(4000);
    numtags NUMBER;
    mindate varchar2(30);
    maxdate varchar2(30);
    
    minmindate varchar2(30);
    maxmaxdate varchar2(30);
    
    tloc varchar2(4000);
    clocation varchar2(4000);
    losep  VARCHAR2(4);
BEGIN
    FOR m IN (
        SELECT media_id
        FROM media_flat
        WHERE (lastdate IS NULL OR ((SYSDATE - lastdate) > 1))
        AND ROWNUM <= 20000
    ) LOOP
        begin
            kw := '';
            ksep:='';
            lsep:='';
            rsep:='';
            csep:='';
            tabl := '';
            kwt := '';
            lbl := '';
            lblt := '';
            rel := '';
            relt := '';
            rsep := '';
            ksep := '';
            lsep := '';
            csep := '';
            tn := NULL;
            ct  := '';
            coords  := '';
            numtags := NULL;
            mindate := NULL;
            maxdate := NULL;
            tloc := null;
            
            FOR r IN (
                SELECT media_relationship, related_primary_key
                from media_relations
                where media_id = m.media_id
            ) LOOP

                tabl := SUBSTR(r.media_relationship, instr(r.media_relationship, ' ', -1) + 1);
                
                               	        --dbms_output.put_line('table ' || tabl);

                case tabl
                    when 'locality' then
                        select 
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&locality_id=' || locality.locality_id || '">' || state_prov || ': ' || spec_locality || '</a>',
                            spec_locality || ';' || higher_geog,
                            dec_lat || ',' || dec_long,
                             spec_locality || ';' || higher_geog
                        into 
                            relt,
                            kwt,
                            ct,
                            tloc
                        from 
                            locality,geog_auth_rec
                        where 
                            locality.geog_auth_rec_id=geog_auth_rec.geog_auth_rec_id and 
                            locality.locality_id=r.related_primary_key;
                    when 'collecting_event' then
                        select
                            r.media_relationship || '==<a href="/showLocality.cfm?action=srch\&collecting_event_id=' || collecting_event.collecting_event_id || '">' || state_prov || ': ' || spec_locality || ' (' || verbatim_date || ')</a>',
                            verbatim_locality || '; ' || verbatim_date || '; ' ||
                            locality.spec_locality || '; ' || higher_geog,
                            locality.dec_lat || ',' || locality.dec_long,
                            BEGAN_DATE,
                            ended_date,
                            locality.spec_locality || '; ' || higher_geog
                        into
                            relt,
                            kwt,
                            ct,
                            mindate,
                            maxdate,
                            tloc
                        from
                            collecting_event, locality, geog_auth_rec
                        WHERE 
                            collecting_event.locality_id = locality.locality_id and 
                            locality.geog_auth_rec_id = geog_auth_rec.geog_auth_rec_id AND
                            collecting_event.collecting_event_id = r.related_primary_key;
                    when 'agent' then
                        select 
                            r.media_relationship || '==' || agent_name,
                            agent_name,
                            NULL
                        into
                            relt,
                            kwt,
                            ct
                        from 
                            preferred_agent_name
                        where 
                            agent_id=r.related_primary_key;
                    when 'media' then
                        select 
                            r.media_relationship || '==' || media_id,
                            NULL,
                            NULL
                        into
                            relt,
                            kwt,
                            ct
                        from 
                            media
                        where 
                            media_id=r.related_primary_key;
                    when 'cataloged_item' then
                         select
                             r.media_relationship || '==<a href="/guid/' || guid || '">' || guid  || '</a>',
                             collection || ' ' || cat_num || '; ' ||
                             GUID || '; ' ||
                             OTHERCATALOGNUMBERS || '; ' ||
                             COLLECTORS || '; ' ||
                             scientific_name || '; ' ||
                             regexp_replace(get_taxonomy(filtered_flat.collection_object_id,'display_name'),'<[^<]+>','')  || '; ' ||
                             verbatim_date || '; ' ||
                             spec_locality || '; ' ||
                             higher_geog,
                             dec_lat || ',' || dec_long,
                             BEGAN_DATE,
                            ended_date,
                            spec_locality || '; ' || higher_geog
                         into
                             relt,
                             kwt,
                             ct,
                            mindate,
                            maxdate,
                            tloc
                         from  
                             filtered_flat
                         where 
                             filtered_flat.collection_object_id=r.related_primary_key;
                    when 'project' then
                        select 
                            r.media_relationship || '==<a href="/project/' || niceURL(project_name) || '">' || project_name  || '</a>',
                            project_name
                        into
                            relt,
                            kwt
                        from 
                            project
                        where project_id=r.related_primary_key;
                    when 'accn' then
                        select 
                            r.media_relationship || '==<a href="/viewAccn.cfm?transaction_id=' || accn.transaction_id  || '">' || collection || ' ' || accn_number || '</a>',
                            collection || ' ' || accn_number
                        into 
                            relt,
                            kwt
                        from 
                            accn,trans,collection
                        where
                            accn.transaction_id=trans.transaction_id AND
                            trans.collection_id=collection.collection_id AND
                            accn.transaction_id=r.related_primary_key;
                     when 'loan' then
                        select 
                            r.media_relationship  || '==' || collection  || ' ' || loan_number,
                            collection || ' ' || loan_number
                        into 
                            relt,
                            kwt
                        from 
                            loan,trans,collection
                        where
                            loan.transaction_id=trans.transaction_id AND
                            trans.collection_id=collection.collection_id AND
                            loan.transaction_id=r.related_primary_key;
                    when 'taxonomy' then
                        select 
                            r.media_relationship || '==<a href="/name/' || scientific_name || '">' || display_name  || '</a>',
                            full_taxon_name || ' ' || display_name 
                        into 
                            relt,
                            kwt
                        from taxonomy
                        where  taxonomy.taxon_name_id=r.related_primary_key;
                    ELSE
                        NULL;
                end case;
              IF ct=',' THEN
                  ct:='';
              END IF;
              tn:=nvl(length(coords),0) + nvl(length(ct),0) + 20;
              IF length(ct) > 0 AND tn < 4000 THEN
                   coords := coords || csep || ct;
                   csep := '|';
                END IF;
               ct:='';
                tn:=nvl(length(rel),0) + nvl(length(relt),0) + 20;
                IF tn < 4000 THEN
                    rel := rel || rsep || relt;
                   rsep := '|';
                END IF;
                tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
                IF tn < 4000 THEN
                    kw := kw || ksep || kwt;
                   ksep := '|';
                END IF;
                 kwt:='';
                 
                --dbms_output.put_line('minmindate: ' ||minmindate) ;
                --dbms_output.put_line('mindate: ' ||mindate) ;
                --dbms_output.put_line('maxmaxdate: ' || maxmaxdate) ;
                --dbms_output.put_line('maxdate: ' || maxdate) ;
                
                if minmindate is null or mindate < minmindate then
       				minmindate:=mindate;
	       		end if; 
	       		if maxmaxdate is null or maxdate > maxmaxdate then
	       			  maxmaxdate:=maxdate;
	       		end if;
       			tn:=nvl(length(clocation),0) + nvl(length(tloc),0) + 20;
       			IF tn < 4000 THEN
                    clocation := clocation || ksep || tloc;
                   	losep := '|';
                END IF;
       		
    
            END LOOP;
            FOR rm IN (select 
                            media_relationship || '==' || media_id mrs
                        from 
                            media_relations
                        where 
                            media_relationship LIKE '% media' AND
                            related_primary_key=m.media_id) LOOP
                 tn:=nvl(length(rel),0) + nvl(length(rm.mrs),0) + 20;
                IF tn < 4000 THEN
                    rel := rel || rsep || rm.mrs;
                   rsep := '|';
                END IF;
            END LOOP; 
            FOR l IN (
                SELECT media_label || '==' || label_value label_value
                FROM media_labels
                WHERE media_id=m.media_id
            ) LOOP
                kwt:=regexp_replace(l.label_value, '<[^<]+>', '');
                tn:=nvl(length(kw),0) + nvl(length(kwt),0) + 20;
                IF tn < 4000 THEN
                    kw := kw || ksep || kwt;
                    ksep := '|';
                END IF;
                tn:=nvl(length(lbl),0) + nvl(length(l.label_value),0) + 20;
                IF tn < 4000 THEN
                    lbl := lbl || lsep || regexp_replace(l.label_value, '<[^<]+>', '');
                    lsep := '|';
                END IF;
            END LOOP;
            SELECT COUNT(*) INTO numtags FROM tag WHERE media_id=m.media_id;
            -- allow zero or one set of coordinates only
            IF instr(coords,'|') != 0 THEN
                coords:=NULL;
            END IF;
            
            
                 --dbms_output.put_line('final minmindate: ' ||minmindate) ;
                --dbms_output.put_line('final maxmaxdate: ' || maxmaxdate) ;
                
                
                
            UPDATE media_flat SET
                relationships=trim(rel),
                labels=trim(lbl),
                keywords=trim(kw),
                coordinates=trim(coords),
                hastags=numtags,
                lastdate = SYSDATE,
                earliest_date=minmindate,
                latest_date=maxmaxdate,
                location=clocation
            WHERE 
                media_id=m.media_id;                      
            rel:='';
            kw:='';
            lbl:='';
        exception
            when no_data_found then
                 --dbms_output.put_line('problem with ' || m.media_id);
                 -- these are usually encumbered specimens, update flat so we can ignore them for a while....
                  UPDATE media_flat SET lastdate = SYSDATE WHERE media_id=m.media_id;   
        end;
    END LOOP;   
END;
/
sho err

exec set_media_flat;
-- moved to triggers
CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_SQ
BEFORE INSERT ON MEDIA_LABELS
FOR EACH ROW
BEGIN
    IF :new.media_label_id IS NULL THEN
    	SELECT sq_media_label_id.nextval
    	INTO :new.media_label_id
    	FROM dual;
    END IF;
        
    IF :NEW.assigned_by_agent_id IS NULL THEN
    	SELECT agent_name.agent_id
		INTO :NEW.assigned_by_agent_id
		FROM agent_name
		WHERE agent_name_type = 'login'
		AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;

CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_BIU
BEFORE INSERT or UPDATE ON MEDIA_LABELS
FOR EACH ROW
DECLARE isgd VARCHAR2(255);
BEGIN
    IF :new.media_label in ('created date','begin date','begin date','end date','made date') then
    	select is_iso8601(:NEW.label_value) into isgd from dual;
    	if isgd != 'valid' then
    		 raise_application_error(-20001,'Invalid value for ' || :NEW.media_label);
    	end if;
    end if;
end;
/

select media_id, label_value from media_labels where media_label = 'made date';


--- moved to procedures

CREATE OR REPLACE PROCEDURE clone_cataloged_item (
	guid in VARCHAR2
)
IS
	oldCollectionObjectID number;
	newCatNum number;
begin
	dbms_output.put_line('making ' || newCatNum);
	select 
		collection_object_id,
		collection_id
	into 
		oldCollectionObjectId,
		oldCollectionID
	from 
		flat 
	where 
		guid=guid;
	
	select max(cat_num) + 1 into newCatNum from cataloged_item where collection_id=oldCollectionID;
	
	INSERT INTO coll_object (
		COLLECTION_OBJECT_ID,
		COLL_OBJECT_TYPE,
		ENTERED_PERSON_ID,
		COLL_OBJECT_ENTERED_DATE,
		COLL_OBJ_DISPOSITION,
		LOT_COUNT,
		CONDITION,
		FLAGS
	) VALUES (
		sq_collection_object_id.nextval,
		'CI',
		sys_context('USERENV', 'SESSION_USER'),
		sysdate,
		'not applicable',
		1,
		'not applicable',
		(select flags from coll_object where collection_object_id=oldCollectionObjectId)
	);	
	
	INSERT INTO cataloged_item (
		COLLECTION_OBJECT_ID,
		CAT_NUM,
		ACCN_ID,
		COLLECTION_CDE,
		CATALOGED_ITEM_TYPE,
		COLLECTION_ID
		) (
		select
			sq_collection_object_id.currval,
			newCatNum,
			accn_id,
			collection_cde,
			CATALOGED_ITEM_TYPE,
			COLLECTION_ID
		from
			cataloged_item
		where
			collection_object_id=oldCollectionObjectID
	);
	
	for r in (select * from specimen_event where collection_object_id=oldCollectionObjectId) loop
		insert into specimen_event (
			COLLECTION_OBJECT_ID,
            COLLECTING_EVENT_ID,
            ASSIGNED_BY_AGENT_ID,
            ASSIGNED_DATE,
            SPECIMEN_EVENT_REMARK,
            SPECIMEN_EVENT_TYPE,
            COLLECTING_METHOD,
            COLLECTING_SOURCE,
            VERIFICATIONSTATUS,
            HABITAT
        ) VALUES (
            sq_collection_object_id.currval,
            r.COLLECTING_EVENT_ID,
            r.ASSIGNED_BY_AGENT_ID)),
            r.event_assigned_date,
            r.SPECIMEN_EVENT_REMARK,
            r.SPECIMEN_EVENT_TYPE,
            r.COLLECTING_METHOD,
            r.COLLECTING_SOURCE,
            r.VERIFICATIONSTATUS,
            r.HABITAT
        );
 	end loop;
    
 	for r in (select * from identification where collection_object_id=oldCollectionObjectId) loop
 		insert into identification (
			IDENTIFICATION_ID,
			COLLECTION_OBJECT_ID,
			MADE_DATE,
			NATURE_OF_ID,
			ACCEPTED_ID_FG,
			IDENTIFICATION_REMARKS,
			TAXA_FORMULA,
			SCIENTIFIC_NAME
		) values (
			sq_identification_id.nextval,
			sq_collection_object_id.currval,
			r.MADE_DATE,
			r.NATURE_OF_ID,
			r.ACCEPTED_ID_FG,
			r.IDENTIFICATION_REMARKS,
			r.TAXA_FORMULA,
			r.SCIENTIFIC_NAME
		);
		
		for x in (select * from identification_taxonomy where identification_id=r.IDENTIFICATION_ID) loop
			insert into identification_taxonomy (
				IDENTIFICATION_ID,
				TAXON_NAME_ID,
				VARIABLE
			) values (
				sq_identification_id.currval,
				x.TAXON_NAME_ID,
				x.VARIABLE
			);
		end loop;
		for x in (select * from identification_agent where identification_id=r.IDENTIFICATION_ID) loop
			insert into identification_agent (
				IDENTIFICATION_ID,
				AGENT_ID,
				IDENTIFIER_ORDER
			) values (
				sq_identification_id.currval,
				x.AGENT_ID,
				x.IDENTIFIER_ORDER
			);
		end loop;
		insert into coll_object_remark (
			COLLECTION_OBJECT_ID,
			COLL_OBJECT_REMARKS,
			ASSOCIATED_SPECIES
		)  ( select
				sq_collection_object_id.currval,
				COLL_OBJECT_REMARKS,
				ASSOCIATED_SPECIES
			from
				coll_object_remark
			where
				collection_object_id=oldCollectionObjectId				
		);
			
			
		
		
	end loop;
		
		
end;
/


alter table cf_users add ResultsBrowsePrefs number;
