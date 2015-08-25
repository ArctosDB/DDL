exec DBMS_SCHEDULER.DROP_JOB('SET_MEDIA_KEYWORDS_JOB');

select JOB_NAME, START_DATE, REPEAT_INTERVAL, LAST_START_DATE, LAST_RUN_DURATION, NEXT_RUN_DATE, RUN_COUNT 
from all_scheduler_jobs where job_name = 'SET_MEDIA_KEYWORDS_JOB';

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'set_media_keywords_job',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_media_keywords',
		start_date		=> to_timestamp_tz('25-MAR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=minutely; interval=5',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'set keywords for media in media_keywords table');
END;
/ 

BEGIN
	DBMS_SCHEDULER.SET_ATTRIBUTE (
		name		=> 'set_media_keywords_job',
		attribute		=> 'repeat_interval',
		VALUE	=> 'freq=minutely; interval=1');
END;