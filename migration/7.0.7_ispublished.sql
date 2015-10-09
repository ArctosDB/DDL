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

----------- accn datatype change
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

CREATE OR REPLACE TRIGGER trg_TRANS_datecheck
before INSERT or update ON TRANS
FOR EACH ROW
	declare status varchar2(255);
BEGIN
	status:=is_iso8601(:NEW.TRANS_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'TRANS_DATE: ' || status);
    END IF;
END;
/
sho err

commit;

lock table accn in exclusive mode nowait;
alter table accn add RECEIVED_DATE_iso varchar2(22);
update accn set RECEIVED_DATE_iso=to_char(RECEIVED_DATE,'yyyy-mm-dd');
alter table accn rename column RECEIVED_DATE to RECEIVED_DATE_date;
alter table accn rename column RECEIVED_DATE_iso to RECEIVED_DATE;

-- see /triggers/uam_triggers/accn.sql for authoritative trigger DDL


CREATE OR REPLACE TRIGGER trg_accn_datecheck
before INSERT or update ON accn
FOR EACH ROW
	declare status varchar2(255);
BEGIN
	status:=is_iso8601(:NEW.RECEIVED_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'RECEIVED_DATE: ' || status);
    END IF;
END;
/
sho err


commit;





 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TRANSACTION_ID 						   NOT NULL NUMBER
 ACCN_TYPE							   NOT NULL VARCHAR2(35)
 ACCN_NUM_PREFIX							    VARCHAR2(10)
 ACCN_NUM								    NUMBER
 ACCN_NUM_SUFFIX							    VARCHAR2(4)
 ACCN_STATUS							   NOT NULL VARCHAR2(20)
 ACCN_NUMBER							   NOT NULL VARCHAR2(60)
 RECEIVED_DATE								    DATE
 ESTIMATED_COUNT							    NUMBER




--------------- container-related trigger changes


 	drop trigger move_container;
 	
 	alter table container modify locked_position null;
 	
  exec refresh_filtered_flat;
select ispublished, count(*) from flat group by ispublished;
select ispublished, count(*) from filtered_flat group by ispublished;


CREATE OR REPLACE procedure containerContentCheck (....

CREATE OR REPLACE procedure updateContainer (....

CREATE OR REPLACE procedure moveContainerByBarcode (.....


CREATE OR REPLACE TRIGGER trg_cmpd_specimenpart...


drop trigger MAKE_PART_COLL_OBJ_CONT;
drop trigger TR_SPECIMENPART_AD;
drop trigger SPECIMEN_PART_CT_CHECK;



CREATE OR REPLACE TRIGGER MAKE_PART_COLL_OBJ_CONT





