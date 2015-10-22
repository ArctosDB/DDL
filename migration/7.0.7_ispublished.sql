20151001 - implemented in production

alter table flat add ispublished varchar2(10);

CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS....

CREATE or replace view pre_filtered_flat AS....



 update flat set ispublished='yes' where typestatus is not null;
  update flat set ispublished='no' where typestatus is null;
  
  
  

alter table filtered_flat drop column ispublished;

alter table filtered_flat add ispublished varchar2(10);

exec DBMS_COMPARISON.DROP_COMPARISON('compare_filtered_flat');

	BEGIN
		DBMS_COMPARISON.CREATE_COMPARISON ( 
			comparison_name => 'compare_filtered_flat'
  			, schema_name     => 'UAM'
  			, object_name     => 'pre_filtered_flat'
  			, dblink_name     => null
  			, remote_schema_name=>'UAM'
  			, remote_object_name=>'filtered_flat'
  		);
	END;
 	/
 	
-------------------------- end already implemented

----------- accn datatype change ---------------

delete from cf_temp_accn;

alter table cf_temp_accn modify TRANS_DATE VARCHAR2(22);
alter table cf_temp_accn modify RECEIVED_DATE VARCHAR2(22);


CREATE OR REPLACE TRIGGER trg_cf_temp_accn_date
copied to /triggers/uam_cf_triggers/cf_temp_accn.sql
BEFORE INSERT OR UPDATE ON cf_temp_accn
FOR EACH ROW
	declare status varchar2(255);
BEGIN
    status:=is_iso8601(:NEW.TRANS_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'TRANS_DATE: ' || status);
    END IF;
     status:=is_iso8601(:NEW.RECEIVED_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'RECEIVED_DATE: ' || status);
    END IF;
END;
/


create table trans201510088 as select * from trans;
create table accn201510088 as select * from accn;

lock table trans in exclusive mode nowait;

alter table trans add TRANS_DATE_iso varchar2(22);
update trans set TRANS_DATE_iso=to_char(TRANS_DATE,'yyyy-mm-dd');
alter table trans rename column TRANS_DATE to TRANS_DATE_date;
alter table trans rename column TRANS_DATE_iso to TRANS_DATE;


-- see /triggers/uam_triggers/trans.sql for authoritative trigger DDL

CREATE OR REPLACE TRIGGER trg_TRANS_datecheck...
commit;

lock table accn in exclusive mode nowait;
alter table accn add RECEIVED_DATE_iso varchar2(22);
update accn set RECEIVED_DATE_iso=to_char(RECEIVED_DATE,'yyyy-mm-dd');
alter table accn rename column RECEIVED_DATE to RECEIVED_DATE_date;
alter table accn rename column RECEIVED_DATE_iso to RECEIVED_DATE;

-- see /triggers/uam_triggers/accn.sql for authoritative trigger DDL


CREATE OR REPLACE TRIGGER trg_accn_datecheck....


commit;












--------------- container-related trigger changes


alter table container modify locked_position null;

CREATE OR REPLACE procedure containerContentCheck (....

CREATE OR REPLACE procedure updateContainer (....

drop function moveContainerByBarcode;

CREATE OR REPLACE procedure moveContainerByBarcode (.....

CREATE OR REPLACE procedure createContainer ...

CREATE OR REPLACE procedure updateAllChildrenContainer (

CREATE OR REPLACE procedure bulkUpdateContainer is 


CREATE OR REPLACE procedure batchCreateContainer is 


CREATE OR REPLACE procedure movePartToContainer (


CREATE OR REPLACE TRIGGER trg_cmpd_specimenpart...
CREATE OR REPLACE TRIGGER tr_specpart_sampfr_biupa....
CREATE OR REPLACE TRIGGER TR_SPECPART_AIUD_FLAT...


CREATE OR REPLACE TRIGGER trg_cont_defdate BEFORE UPDATE OR INSERT ON CONTAINER ...


CREATE OR REPLACE TRIGGER GET_CONTAINER_HISTORY...



drop trigger MAKE_PART_COLL_OBJ_CONT;
drop trigger TR_SPECIMENPART_AD;
drop trigger SPECIMEN_PART_CT_CHECK;
drop TRIGGER MAKE_PART_COLL_OBJ_CONT




revoke update on container from manage_container;
revoke insert on container from manage_container;
revoke delete on container from manage_container;

drop trigger move_container;

