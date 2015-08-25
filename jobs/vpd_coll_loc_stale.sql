--exec DBMS_SCHEDULER.DROP_JOB('VPD_COLL_LOC_STALE');
--exec DBMS_SCHEDULER.RUN_JOB('VPD_COLL_LOC_STALE');
--exec DBMS_SCHEDULER.RUN_JOB('VPD_COLL_LOC_STALE', USE_CURRENT_SESSION=>TRUE);
--ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'vpd_coll_loc_stale',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'vpd_collection_locality_stale',
		start_date		=> to_timestamp_tz(sysdate || ' 01:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=hourly; byminute=10,40;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'maintains stale records in vpd_collection_locality table');
END;
/ 