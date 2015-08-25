rebuild 

functions/bulk_check_one

functions/bulk_stage_check_one


 FUNCTION "UAM"."CONCATCOLL
 
  FUNCTION CONCATPREP
  
  ala_ddl.sql
  
  is_is08601
  
  
create sequence sq_collector_id start with 1 increment by 1 nocache;
  create public synonym sq_collector_id for sq_collector_id;
  grant select on sq_collector_id to public;
  
  
  alter table collector add collector_id number;
  
  
    lock table collector in exclusive mode nowait;


alter trigger TR_COLLECTOR_AIUD_FLAT disable;

update collector set collector_id = sq_collector_id.nextval;


CREATE OR REPLACE TRIGGER tr_collector_sq
BEFORE INSERT ON collector
FOR EACH ROW
BEGIN
    IF :new.collector_id IS NULL THEN
        SELECT sq_collector_id.nextval
        INTO :new.collector_id
        FROM dual;
    END IF;
END;
/

alter trigger TR_COLLECTOR_AIUD_FLAT enable;



alter table collector drop constraint PK_COLLECTOR keep index;

alter index PK_COLLECTOR rename to IX_COLLECTOR_COID_AID_ROLE;

alter table collector
add constraint PK_COLLECTOR
primary key (collector_id)
using index tablespace uam_idx_1;

commit;




  lock table collector in exclusive mode nowait;

  
  
  


alter table collector drop constraint COLL_ROLE_CHECK;
alter table collector drop constraint FK_CTCOLLECTOR_ROLE;

  alter table CTCOLLECTOR_ROLE modify COLLECTOR_ROLE varchar2(30) ;

 ALTER TABLE log_CTCOLLECTOR_ROLE MODIFY N_COLLECTOR_ROLE varchar2(30);
  ALTER TABLE log_CTCOLLECTOR_ROLE MODIFY O_COLLECTOR_ROLE varchar2(30) ;

  
   UPDATE CTCOLLECTOR_ROLE SET COLLECTOR_ROLE='collector' where collector_role='c';
   UPDATE CTCOLLECTOR_ROLE SET COLLECTOR_ROLE='preparator' where collector_role='p';
   insert into CTCOLLECTOR_ROLE (COLLECTOR_ROLE,description) values ('maker','agent responsible for manufacturing a specimen');
   
   
     alter table collector modify COLLECTOR_ROLE varchar2(30) ;

     
     
lock table collector in exclusive mode nowait;

alter trigger TR_COLLECTOR_AIUD_FLAT disable;

UPDATE collector SET COLLECTOR_ROLE='collector' where collector_role='c';
        
UPDATE collector SET COLLECTOR_ROLE='preparator' where collector_role='p';

alter trigger TR_COLLECTOR_AIUD_FLAT enable;

ALTER TABLE collector ADD CONSTRAINT FK_CTCOLLECTOR_ROLE FOREIGN KEY (COLLECTOR_ROLE) REFERENCES CTCOLLECTOR_ROLE(COLLECTOR_ROLE);


  alter trigger TR_COLLECTOR_AIUD_FLAT enable;

  
  
  
commit;
 
     
update bulkloader set COLLECTOR_ROLE_1='collector' where COLLECTOR_ROLE_1='c';
update bulkloader set COLLECTOR_ROLE_2='collector' where COLLECTOR_ROLE_2='c';
update bulkloader set COLLECTOR_ROLE_3='collector' where COLLECTOR_ROLE_3='c';
update bulkloader set COLLECTOR_ROLE_4='collector' where COLLECTOR_ROLE_4='c';
update bulkloader set COLLECTOR_ROLE_5='collector' where COLLECTOR_ROLE_5='c';
update bulkloader set COLLECTOR_ROLE_6='collector' where COLLECTOR_ROLE_6='c';
update bulkloader set COLLECTOR_ROLE_7='collector' where COLLECTOR_ROLE_7='c';
update bulkloader set COLLECTOR_ROLE_8='collector' where COLLECTOR_ROLE_8='c';     



update bulkloader set COLLECTOR_ROLE_1='preparator' where COLLECTOR_ROLE_1='p';
update bulkloader set COLLECTOR_ROLE_2='preparator' where COLLECTOR_ROLE_2='p';
update bulkloader set COLLECTOR_ROLE_3='preparator' where COLLECTOR_ROLE_3='p';
update bulkloader set COLLECTOR_ROLE_4='preparator' where COLLECTOR_ROLE_4='p';
update bulkloader set COLLECTOR_ROLE_5='preparator' where COLLECTOR_ROLE_5='p';
update bulkloader set COLLECTOR_ROLE_6='preparator' where COLLECTOR_ROLE_6='p';
update bulkloader set COLLECTOR_ROLE_7='preparator' where COLLECTOR_ROLE_7='p';
update bulkloader set COLLECTOR_ROLE_8='preparator' where COLLECTOR_ROLE_8='p';     
     


     
alter table cf_global_settings add gmap_api_key varchar2(255);

update cf_global_settings set gmap_api_key='AIzaSyCcu8ZKOhPYjFVfi7M1B9XQuQni_dzesTw';


alter table cf_global_settings add google_uacct varchar2(255);
update cf_global_settings set google_uacct='UA-315170-1';


alter table cf_global_settings add bug_report_email varchar2(4000);
update cf_global_settings set bug_report_email='dlmcdonald@alaska.edu,ccicero@berkeley.edu,gordon.jarrell@gmail.com,amgunderson@alaska.edu';
-- test only!!
-- update cf_global_settings set bug_report_email='dlmcdonald@alaska.edu';


alter table cf_global_settings add data_report_email varchar2(4000);
update cf_global_settings set data_report_email='dlmcdonald@alaska.edu,ccicero@berkeley.edu,gordon.jarrell@gmail.com,amgunderson@alaska.edu';
-- test only!!
-- update cf_global_settings set data_report_email='dlmcdonald@alaska.edu';


alter table cf_global_settings add genbank_prid varchar2(255);
update cf_global_settings set genbank_prid='3849';


alter table cf_global_settings add genbank_password varchar2(255);
update cf_global_settings set genbank_password='PASSWORD';


alter table cf_global_settings add genbank_username varchar2(255);
update cf_global_settings set genbank_username='uam';





		
		

form settings for /Admin/global_settings.cfm
