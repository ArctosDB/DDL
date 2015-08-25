/*	 dailyjob to execute build_coll_code_tables, owned by uam
*/
exec DBMS_SCHEDULER.DROP_JOB('BUILD_CCTS');
exec DBMS_SCHEDULER.RUN_JOB('BUILD_CCTS');
exec DBMS_SCHEDULER.RUN_JOB('BUILD_CCTS', USE_CURRENT_SESSION=>TRUE);

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'build_ccts',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'build_coll_code_tables',
		start_date		=> to_timestamp_tz(sysdate || ' 01:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=daily;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'creates cct tables to use in institution-specific searches');
END;
/ 