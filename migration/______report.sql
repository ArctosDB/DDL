-- ref: https://github.com/ArctosDB/arctos/issues/809


	create table cf_report_status (
			cfr varchar2(255),
			last_action_date date,
			last_action varchar2(255)
		);
		


		
		

UAM@ARCTEST> desc cf_report_sql
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 REPORT_ID							   NOT NULL NUMBER
 REPORT_NAME							   NOT NULL VARCHAR2(38)
 REPORT_TEMPLATE						   NOT NULL VARCHAR2(38)
 SQL_TEXT								    VARCHAR2(4000)
 PRE_FUNCTION								    VARCHAR2(50)
 REPORT_FORMAT							   NOT NULL VARCHAR2(50)

 
 
 alter table cf_report_sql add last_access date;

 -- seed everything to NOW
 update cf_report_sql set last_access=sysdate;
 
  alter table cf_report_sql modify last_access not null;
  
  
  
 -- trigger to monitor DML events; monitor SELECT in the report_printer code and send lots of alerts before doing anything
CREATE OR REPLACE TRIGGER tiu_cf_report_sql before INSERT OR UPDATE ON cf_report_sql 
FOR EACH ROW
BEGIN
	:NEW.last_access:=sysdate;
END;
/
show err

-- for testing drop the trigger
drop trigger tiu_cf_report_sql;

update cf_report_sql set last_access=sysdate-30 where report_id=5601052;
update cf_report_sql set last_access=sysdate-60 where report_id=5600963;
update cf_report_sql set last_access=sysdate-90 where report_id=5600964;
update cf_report_sql set last_access=sysdate-120 where report_id=5600968;
update cf_report_sql set last_access=sysdate-180 where report_id=5600975;
update cf_report_sql set last_access=sysdate-365 where report_id=5600971;
update cf_report_sql set last_access=sysdate-30 where REPORT_NAME like '%bird_label_front%';

    
select

select last_access,round(sysdate-last_access) from cf_report_sql where report_id=5280464;

