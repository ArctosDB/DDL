--UAM jobs
UAM.SCH_ALA_PROCEDURES
FREQ=DAILY
24-MAR-10 07.00.00.396352 PM -09:00
25-MAR-10 07.00.00.400000 PM -09:00

UAM.BUILD_CCTS
FREQ=DAILY
25-MAR-10 01.00.00.819267 AM -08:00
26-MAR-10 01.00.00.800000 AM -08:00

UAM.BULKLOAD
freq=hourly; byminute=0,30;
25-MAR-10 03.00.02.224417 PM -08:00
25-MAR-10 03.30.02.300000 PM -08:00

UAM.VPD_COLL_LOC_STALE
freq=hourly; byminute=10,40;

01-JAN-95 12.10.00.000000 AM -09:00

UAM.ARCTOS_AUDIT_JOB
freq=hourly; byminute=10; bysecond=0
25-MAR-10 02.10.00.519533 PM -09:00
25-MAR-10 03.10.00.500000 PM -09:00

UAM.CHECK_FLAT_STALE
freq=minutely; interval=1
25-MAR-10 02.20.07.615220 PM -09:00
25-MAR-10 02.21.07.600000 PM -09:00

--System jobs
EXFSYS.RLM$EVTCLEANUP
FREQ = HOURLY; INTERVAL = 1
25-MAR-10 01.57.58.207313 PM -09:00
25-MAR-10 02.57.58.200000 PM -09:00

EXFSYS.RLM$SCHDNEGACTION
FREQ=MINUTELY;INTERVAL=60
25-MAR-10 02.43.11.233691 PM -08:00
25-MAR-10 03.40.48.000000 PM -08:00

ORACLE_OCM.MGMT_STATS_CONFIG_JOB
freq=monthly;interval=1;bymonthday=1;byhour=01;byminute=01;bysecond=01
01-MAR-10 01.01.02.101498 AM -09:00
01-APR-10 01.01.01.100000 AM -09:00

ORACLE_OCM.MGMT_CONFIG_JOB

24-MAR-10 10.00.03.610398 PM EST5EDT

SYS.DROPTABS_GETSTATS_JOB
freq=minutely; interval=15;
25-MAR-10 03.28.00.092930 PM -08:00
25-MAR-10 03.43.00.000000 PM -08:00


BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_set_media_flat',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_media_flat',
		start_date		=> to_timestamp_tz('26-APR-2011 00:00:00', 'DD-MON-YYYY HH24:MI:SS'),
		repeat_interval	=> 'freq=MINUTELY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'update flattened media metadata');
END;
/ 
BEGIN
	DBMS_SCHEDULER.CREATE_JOB (
		job_name		=> 'j_set_browse',
		job_type		=> 'STORED_PROCEDURE',
		job_action		=> 'set_browse',
		start_date		=> systimestamp,
		repeat_interval	=> 'freq=HOURLY;interval=1',
		enabled			=> TRUE,
		end_date		=> NULL,
		comments		=> 'grab a random sample of the good stuff for the TSR widget');
END;
/ 
