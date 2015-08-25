BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'mia_media_keywords_job',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_media_keywords',
		start_date		=> to_timestamp_tz('25-MAR-2010 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily; byhour=3',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'insert missing media_id into media_keywords table');
END;
/ 