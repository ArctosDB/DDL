CREATE OR REPLACE PROCEDURE bulkloader_autodelete IS 
BEGIN
	DELETE FROM bulkloader WHERE loaded='DELETE';
END;
/
sho err;

BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_bulkloader_autodelete',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'bulkloader_autodelete',
        start_date      =>  SYSTIMESTAMP,
        repeat_interval =>  'freq=hourly; byminute=5,35;',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'Delete records with LOADED=DELETE from the bulkloader.'
	);
END;
/ 
