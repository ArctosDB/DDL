-- taxon rank: https://github.com/ArctosDB/arctos/issues/1338#

CREATE OR REPLACE function getTaxonRank(collobjid IN number)...

alter table flat add taxon_rank varchar2(255);
alter table filtered_flat add taxon_rank number;

CREATE or replace view pre_filtered_flat AS....




alter table flat drop column date_ended_date;
alter table flat drop column DATE_BEGAN_DATE;


CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS....

-- prime

create table temp_taxon_rank as select collection_object_id,taxon_rank, ' ' status from flat;

update temp_taxon_rank set status = null;

ALTER TABLE temp_taxon_rank MODIFY STATUS VARCHAR2(222);

CREATE OR REPLACE PROCEDURE temp_update_tr IS
begin
  update temp_taxon_rank set taxon_rank=getTaxonRank(collection_object_id),status='checked' where status is null and rownum<100000;
end;
/


SELECT TAXON_RANK, COUNT(*) FROM temp_taxon_rank GROUP BY TAXON_RANK;

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_TR',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_tr',
    enabled     => TRUE,
    start_date => systimestamp,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=1'
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_TR';










-- specimen event links: https://github.com/ArctosDB/arctos/issues/1545

create table specimen_event_links (
	specimen_event_link_id number not null,
	specimen_event_id number not null,
	part_id number
);
delete from specimen_event_links;

alter table specimen_event_links add collection_object_id number not null;

CREATE SEQUENCE sq_specimen_event_link_id;
CREATE public SYNONYM sq_specimen_event_link_id FOR sq_specimen_event_link_id;
GRANT SELECT ON sq_specimen_event_link_id TO PUBLIC;


CREATE OR REPLACE TRIGGER trg_specimen_event_links_BI
    BEFORE INSERT ON specimen_event_links
    FOR EACH ROW
    BEGIN
        if :new.specimen_event_link_id is null then
        	select sq_specimen_event_link_id.nextval into :new.specimen_event_link_id from dual;
        end if;
    end;
/

alter table specimen_event_links add constraint PK_specimen_event_link_id PRIMARY KEY (specimen_event_link_id) using index TABLESPACE UAM_IDX_1;
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_seid FOREIGN KEY (specimen_event_id) REFERENCES specimen_event(specimen_event_id);
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_pid FOREIGN KEY (part_id) REFERENCES specimen_part(collection_object_id);
ALTER TABLE specimen_event_links ADD CONSTRAINT pk_spec_evt_lnk_cid FOREIGN KEY (collection_object_id) REFERENCES cataloged_item(collection_object_id);


create public synonym specimen_event_links for specimen_event_links;
grant select on specimen_event_links to public;
grant all on specimen_event_links to manage_specimens;



insert into cf_form_permissions (FORM_PATH,ROLE_NAME) values ('/picks/linkSpecimenEvent.cfm','manage_specimens');

-- see if we can find some stuff
-- only care about things with multiple not-unaccpeted events
create table temp_mevt as select collection_object_id from specimen_event where verificationstatus!='unaccepted' having count(*) > 1 group by collection_object_id

select count(*) from temp_mevt;

>40306

-- can only deal with parts, so...
drop table temp_mevt_pt;
create table temp_mevt_pt as select
specimen_part.collection_object_id partID,
temp_mevt.collection_object_id,
COLL_OBJECT_REMARKS from
coll_object_remark,specimen_part,temp_mevt 
where temp_mevt.collection_object_id=specimen_part.DERIVED_FROM_CAT_ITEM and 
specimen_part.collection_object_id=coll_object_remark.collection_object_id and
COLL_OBJECT_REMARKS is not null
;
select count(*) from temp_mevt_pt;


UAM@ARCTOSTE> select count(*) from temp_mevt_pt;

  COUNT(*)
----------
     17486

     select COLL_OBJECT_REMARKS from temp_mevt_pt order by COLL_OBJECT_REMARKS;
     
      select COLL_OBJECT_REMARKS from temp_mevt_pt where COLL_OBJECT_REMARKS not like '%Coll:%' and 
      COLL_OBJECT_REMARKS not like '%Prep:%' order by COLL_OBJECT_REMARKS ;
      
      -- pretty close, I think
      
      alter table temp_mevt_pt add rawdate varchar2(255);
      
      
      update temp_mevt_pt set rawdate= substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Coll:')) where COLL_OBJECT_REMARKS like '%Coll:%';
      
        update temp_mevt_pt set rawdate= substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Prep:')) where COLL_OBJECT_REMARKS like '%Prep:%';

      update temp_mevt_pt set rawdate=replace(rawdate,'Prep:');
            update temp_mevt_pt set rawdate=replace(rawdate,'Coll:');

      
      select COLL_OBJECT_REMARKS,
      substr(COLL_OBJECT_REMARKS,instr(COLL_OBJECT_REMARKS,'Coll:'))
      from temp_mevt_pt where COLL_OBJECT_REMARKS like '%Coll:%'
       order by COLL_OBJECT_REMARKS ;
       
    select distinct rawdate,
        SUBSTR(rawdate, 0,INSTR(rawdate, ';') -1)
        from temp_mevt_pt order by rawdate;

       update temp_mevt_pt set rawdate= SUBSTR(rawdate, 0,INSTR(rawdate, ';') -1) where rawdate like '%;%';
       
       update temp_mevt_pt set rawdate=trim(rawdate);
       
              update temp_mevt_pt set rawdate=replace(rawdate,'.');

   
       CREATE OR REPLACE FUNCTION temp_funky_isdate
( p_string in varchar2)
return integer
as
l_date date;
begin
l_date := to_date(p_string,'DD MON YYYY');
   return 1;
exception
when others then
return 0;
end;


       
         select distinct rawdate || '::' || temp_funky_isdate(rawdate)
        from temp_mevt_pt ;
        
        'DD MON YYYY')
        
        update temp_mevt_pt set thedate=to_date(rawdate,'DD MON YYYY') where  temp_funky_isdate(rawdate)=1;
        
        
        alter table temp_mevt_pt add specimen_event_id number;
        alter table temp_mevt_pt add status varchar2(255);
        
        -- pulls multiples, of course
        update temp_mevt_pt set specimen_event_id=(
        select specimen_event_id
        from specimen_event,collecting_event where
        temp_mevt_pt.collection_object_id=specimen_event.collection_object_id and
        specimen_event.collecting_event_id=collecting_event.collecting_event_id and
        collecting_event.began_date=to_char(temp_mevt_pt.thedate,'YYYY-MM-DD')
        );
        
        declare
        	c number;
        	seid number;
        begin
	        for r in (select * from temp_mevt_pt where thedate is not null) loop
		        select count(*) into c from specimen_event,collecting_event where
	        		specimen_event.collection_object_id=r.collection_object_id and
	        		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	        		collecting_event.began_date=to_char(r.thedate,'YYYY-MM-DD')
	        		;
	        	if c=1 then
	        	 select specimen_event.specimen_event_id into seid from specimen_event,collecting_event where
	        		specimen_event.collection_object_id=r.collection_object_id and
	        		specimen_event.collecting_event_id=collecting_event.collecting_event_id and
	        		collecting_event.began_date=to_char(r.thedate,'YYYY-MM-DD')
	        		;
	        		        	update temp_mevt_pt set specimen_event_id=seid where partid=r.partid;
	
	        	else
	        	
	        	update temp_mevt_pt set status='evtct: ' || c where partid=r.partid;
	        	end if;
	        end loop;
        end ;
        /
        
        select count(*) from temp_mevt_pt where specimen_event_id is not null;
        
        
        
        select status,rawdate from temp_mevt_pt where status is not null;
    
        
  delete from     specimen_event_links;  
  
  insert into specimen_event_links (collection_object_id,specimen_event_id,part_id) (select collection_object_id,specimen_event_id,partid from temp_mevt_pt where specimen_event_id is not null);
  
  
  select guid from flat where collection_object_id in (select collection_object_id from specimen_event_links) group by guid order by guid;
        
create table specimen_event_links (
	specimen_event_link_id number not null,
	specimen_event_id number not null,
	part_id number
);
        
        thedate
        alter table temp_mevt_pt add thedate date;
        
        
        select raw
        
      or 
      COLL_OBJECT_REMARKS like '%Prep:%' order by COLL_OBJECT_REMARKS ;
    
Coll: 16 Aug 2011
Accession 2011.043.Mamm, NK 108348, Coll: 16 Aug 2011

