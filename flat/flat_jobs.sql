-- kill the damned job or hinkiness will result
exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'check_flat_stale', FORCE => TRUE);

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'check_flat_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'IS_FLAT_STALE',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check flat for records marked as stale and update them');
END;
/

select * from all_scheduler_jobs where job_name='CHECK_FLAT_STALE';

 SElect sid,serial#,user,command,blocking_session from v$session where command>0;

 
 select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where job_name='CHECK_FLAT_STALE';
     
     
     
 -- maintain geography cache
 
 BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'J_UPDATE_CACHE_ANYGEOG',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'UPDATE_CACHE_ANYGEOG',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check cache_anygeog for records marked as stale and update them');
END;
/

 select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where job_name='J_UPDATE_CACHE_ANYGEOG';

exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'J_UPDATE_CACHE_ANYGEOG', FORCE => TRUE);
