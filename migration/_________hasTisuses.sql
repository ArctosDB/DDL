-- https://github.com/ArctosDB/arctos/issues/1447

alter table flat add has_tissues number;

-- move this to functions

CREATE  or replace FUNCTION getIfTissues ( collobjid in integer)
return number
as
result number :=0;
tmp number;
begin
	select 
		count(*) 
	into 
		tmp 
	from 
		specimen_part, 
		ctspecimen_part_name
	where
		specimen_part.part_name=ctspecimen_part_name.part_name and
		ctspecimen_part_name.IS_TISSUE=1 and
		specimen_part.derived_from_cat_item=collobjid;
	if tmp>0 then
		result:=1;
	end if;
	return result;	
end;
/
sho err;

CREATE or replace PUBLIC SYNONYM getIfTissues FOR getIfTissues;
GRANT EXECUTE ON getIfTissues TO PUBLIC;





-- rebuild flat_procedures/UPDATE_FLAT

CREATE OR REPLACE PROCEDURE UPDATE_FLAT (collobjid IN NUMBER) IS....


-- update/prime flat



CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update flat set has_tissues=getIfTissues(collection_object_id);
end;
/


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';




alter table filtered_flat add has_tissues number;


CREATE or replace view pre_filtered_flat AS....


CREATE INDEX ix_flat_hastissues ON flat(has_tissues) TABLESPACE uam_idx_1;

CREATE INDEX ix_f_flat_hastissues ON filtered_flat(has_tissues) TABLESPACE uam_idx_1;

select count(*) from flat where has_tissues=1;


select count(*) from filtered_flat where has_tissues=1;


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'REFRESH_FILTERED_FLAT',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

-- reset the normal job

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'e',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'refresh_filtered_flat',
	repeat_interval    =>  'freq=daily; byhour=2',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'synchronize filtered_flat');
END;
/




