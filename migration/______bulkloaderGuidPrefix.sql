BEGIN
DBMS_SCHEDULER.DROP_JOB('J_BULKLOAD');
END;
/

BEGIN
DBMS_SCHEDULER.DROP_JOB('j_bulkloader_stage_check');
END;
/


create table bulkloader_bak20150727 as select * from bulkloader;


lock table bulkloader in exclusive mode nowait;


alter table bulkloader add new_COLLECTION_CDE varchar2(255);

update bulkloader set new_COLLECTION_CDE=COLLECTION_CDE;

alter table bulkloader rename column COLLECTION_CDE to guid_prefix;

alter table bulkloader modify guid_prefix varchar2(40);

-- drop the triggers for the structural updates

drop trigger TI_BULK_CID;


update bulkloader set guid_prefix=institution_acronym || ':' || new_COLLECTION_CDE;


select distinct
	institution_acronym,
	new_COLLECTION_CDE,
	guid_prefix
from bulkloader;
-- looks spiffy, rock on....

-- from triggers/uam/bulkloader.sql


alter table bulkloader drop column new_COLLECTION_CDE;
alter table bulkloader drop column institution_acronym;


CREATE OR REPLACE TRIGGER ti_bulk_cid before ....


alter table bulkloader_deletes add guid_prefix varchar2(255);


CREATE OR REPLACE TRIGGER TD_BULKLOADER .....

-- rebuild functions/bulk_check_one

drop table pre_bulkloader;
create table pre_bulkloader as select * from bulkloader where 1=2;
alter table pre_bulkloader modify collection_id null;
alter table pre_bulkloader modify ENTERED_AGENT_ID null;

CREATE OR REPLACE FUNCTION bulk_pre_check_one (colobjid  in NUMBER) ....




alter table bulkloader_stage add new_COLLECTION_CDE varchar2(255);
update bulkloader_stage set new_COLLECTION_CDE=COLLECTION_CDE;
alter table bulkloader_stage rename column COLLECTION_CDE to guid_prefix;
alter table bulkloader_stage modify guid_prefix varchar2(40);
update bulkloader_stage set guid_prefix=institution_acronym || ':' || new_COLLECTION_CDE;


alter table bulkloader_stage drop column new_COLLECTION_CDE;
alter table bulkloader_stage drop column institution_acronym;

delete from bulkloader_clone;
alter table bulkloader_clone rename column collection_cde to guid_prefix;
alter table bulkloader_clone modify guid_prefix varchar2(40);
alter table bulkloader_clone drop column institution_acronym;





CREATE OR REPLACE FUNCTION bulk_stage_check_one (colobjid  in NUMBER)....


CREATE OR REPLACE PACKAGE bulk_pkg as
  PROCEDURE check_and_load;
  PROCEDURE bulkloader_check;
END;

CREATE OR REPLACE PACKAGE BODY bulk_pkg as.....

-- rebuild /DDL/ALA/ala_ddl





BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_BULKLOAD',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'bulk_pkg.check_and_load',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=hourly; byminute=0,10,20,30,40,50;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'load records in bulkloader where loaded is NULL');
END;
/


BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'j_bulkloader_stage_check',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'bulkloader_stage_check',
   start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=7',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'bulkloader_stage_check - derp');
END;
/




select distinct loaded from bulkloader order by loaded;

select distinct loaded from bulkloader where loaded like '%TEMPLATE%';



delete from bulkloader where loaded like '%TEMPLATE%'
