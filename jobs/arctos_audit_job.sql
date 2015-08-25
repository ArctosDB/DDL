/*
-- hourly job to add new fga audit records to arctos_audit table.

exec DBMS_SCHEDULER.DROP_JOB('ARCTOS_AUDIT_JOB');

exec DBMS_SCHEDULER.DISABLE_JOB('ARCTOS_AUDIT_JOB');



select JOB_NAME, START_DATE, REPEAT_INTERVAL, LAST_START_DATE, LAST_RUN_DURATION, NEXT_RUN_DATE, RUN_COUNT 
from all_scheduler_jobs where job_name like '%ARCTOS_AUDIT%';
*/

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'arctos_audit_job',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'sp_arctos_audit_insert',
		start_date		=> to_timestamp_tz('30-APR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily; byhour=1; byminute=16',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'insert daily fga audit records into arctos_audit');
END;
/ 
