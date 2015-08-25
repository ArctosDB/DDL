/*	hourly job to execute sp_drop_oldjobs, owned by uam_query
*/
exec DBMS_SCHEDULER.DROP_JOB('DROP_OLDTABS');

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'drop_oldtabs',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'sp_drop_oldtabs',
		start_date		=> to_timestamp_tz('07-AUG-2007 15:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=hourly; byminute=0;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'drop taxaresults and searchresults tables when > 4 hrs');
END;
/ 

/* 09/17/2007 see sp_dropjobs_getstats*/
exec dbms_scheduler.disable('DROP_OLDTABS');