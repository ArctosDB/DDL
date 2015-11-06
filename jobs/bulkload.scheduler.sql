
select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_BULKLOAD';

exec dbms_scheduler.disable('J_BULKLOAD');

exec dbms_scheduler.enable('J_BULKLOAD');

BEGIN
DBMS_SCHEDULER.DROP_JOB('J_BULKLOAD');
END;
/

BEGIN
DBMS_SCHEDULER.DROP_JOB('j_bulkloader_stage_check');
END;
/


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



BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_is_flat_stale',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'is_flat_stale',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=MINUTELY;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'update flat with changes');
END;
/
