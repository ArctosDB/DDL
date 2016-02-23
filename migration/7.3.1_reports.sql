-- ref: https://github.com/ArctosDB/arctos/issues/809

 
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



 mkdir /corral-tacc/tacc/arctos/20160222
 mkdir /corral-tacc/tacc/arctos/20160222/reporttemplates/
cp -r Reports/templates/ /corral-tacc/tacc/arctos/20160222/reporttemplates/
ls /corral-tacc/tacc/arctos/20160216/reporttemplates/templates
ls Reports/templates

rm copied
rm lcl




git fetch --all

git branch

git checkout v7.3.1



