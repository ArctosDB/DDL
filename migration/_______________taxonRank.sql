-- taxon rank: https://github.com/ArctosDB/arctos/issues/1338#

select taxon_rank,count(*) from flat group by taxon_rank;

select taxon_rank,count(*) from filtered_flat group by taxon_rank;



CREATE OR REPLACE function getTaxonRank(collobjid IN number)...

alter table flat add taxon_rank varchar2(255);
alter table filtered_flat add taxon_rank varchar2(255);

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

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_TR';

  update temp_taxon_rank set taxon_rank=getTaxonRank(collection_object_id),status='checked' where status is null and rownum<1000;

SELECT status, COUNT(*) FROM temp_taxon_rank GROUP BY status;


CREATE OR REPLACE PROCEDURE temp_update_tr IS
begin
	for r in (select * from temp_taxon_rank where status='checked' and rownum<50000) loop
		update flat set taxon_rank=r.taxon_rank where collection_object_id=r.collection_object_id;
		update temp_taxon_rank set status='PTF' where collection_object_id=r.collection_object_id;
	end loop;
end ;
/

exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_TEMP_UPDATE_TR', FORCE => TRUE);

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


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_TR__one',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'refresh_filtered_flat',
    enabled     => TRUE,
    start_date => systimestamp
    );
END;
/ 
select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_TR__ONE';




UAM@ARCTOS> desc temp_taxon_rank
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 COLLECTION_OBJECT_ID							    NUMBER
 TAXON_RANK								    VARCHAR2(255)
 STATUS 	
 
 
 
 select 
 	guid,
 	scientific_name
 from
 	flat,temp_taxon_rank where flat.collection_object_id=temp_taxon_rank.collection_object_id and temp_taxon_rank.TAXON_RANK is null and rownum<200;
 	
 select distinct
 	scientific_name
 from
 	flat,temp_taxon_rank where flat.collection_object_id=temp_taxon_rank.collection_object_id and temp_taxon_rank.TAXON_RANK is null and rownum<2;
 	
select getTaxonRank(collection_object_id) from flat where guid='UAM:Ento:140881';

create table temp_notaxrank as
 select 
 	scientific_name, count(*) c
 from
 	flat,temp_taxon_rank where flat.collection_object_id=temp_taxon_rank.collection_object_id and temp_taxon_rank.TAXON_RANK is null group by scientific_name order by scientific_name ;
 	
CREATE OR REPLACE PROCEDURE temp_update_junk IS begin
 update flat set taxon_rank=(
 	select taxon_rank from temp_taxon_rank where flat.collection_object_id=temp_taxon_rank.collection_object_id and temp_taxon_rank.taxon_rank is not null
 );
 end;
 /
 
  update flat set taxon_rank=(
 	select taxon_rank from temp_taxon_rank where flat.collection_object_id=temp_taxon_rank.collection_object_id and temp_taxon_rank.taxon_rank ='infraclass'
 ) where taxon_rank is null;

 
 create unique index temp_ix_tr_tmp on temp_taxon_rank (collection_object_id) tablespace uam_idx_1;
 
 
BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_temp_update_junk',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATEJUNK';

