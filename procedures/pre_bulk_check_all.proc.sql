
--	select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where lower(JOB_NAME)='J_sched_immediate_pre_bulk_check';
-- alter table pre_bulkloader add collection_cde varchar2(255);
	

create or replace PROCEDURE pre_bulk_check_all 
is
 thisError varchar2(4000);
  BEGIN
	FOR rec IN (SELECT * FROM pre_bulkloader where loaded='ready_for_checkall') LOOP
		SELECT bulk_pre_check_one(rec.collection_object_id) INTO thisError FROM dual;
		if length(thisError) > 224 then
			thisError := substr(thisError,1,200) || ' {snip...}';
		elsif thisError is null then
			thisError := 'final_check_pass';
		end if;
		update pre_bulkloader set loaded = thisError where collection_object_id = rec.collection_object_id;
		--- dbms_output.put_line (rec.collection_object_id ||': ' || thisError);
	END LOOP;
END;
/
sho err
create OR REPLACE public synonym pre_bulk_check_all for pre_bulk_check_all;
grant execute on pre_bulk_check_all to public;



BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PRE_BULK_CHK_ALL',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'pre_bulk_check_all',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=hourly; byminute=3,13,23,33,43,53;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'check everything and update loaded');
END;
/

select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PRE_BULK_CHK_ALL';

	
	
	exec DBMS_SCHEDULER.DROP_JOB('J_PRE_BULK_ALL');

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	