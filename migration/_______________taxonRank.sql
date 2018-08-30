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





