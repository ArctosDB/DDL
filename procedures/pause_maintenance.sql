/*
 * 
 temporarily pause all the stuff that usually stomps all over each other
 and plugs up teh toobs when something, especially something big,
 is being updated
 
 IGNORED
 	
 * ARCTOS_AUDIT_JOB
 * BUILD_CCTS
 * DROP_OLDTABS
 * 
*/


CREATE OR REPLACE procedure pause_maintenance (onoff IN varchar2) is 
   	begin
	   	if onoff not in ('on','off') then
	   		raise_application_error(-20001,'bad call: parameters are "on" (start all jobs) and "off" (stop all jobs).');
	   	end if;
	   	
	   	if onoff='off' then
	   		dbms_scheduler.disable('CHECK_FLAT_STALE',force=>true);
	   		dbms_scheduler.disable('CHECK_UPDATE_FLAT_TAXONOMY',force=>true);
	   		dbms_scheduler.disable('J_AUTO_MERGE_COLLECTING_EVENT',force=>true);
	   		dbms_scheduler.disable('J_AUTO_MERGE_LOCALITY',force=>true);
	   		dbms_scheduler.disable('J_BULKLOAD',force=>true);
	   		dbms_scheduler.disable('J_BULKLOADER_AUTODELETE',force=>true);
	   		dbms_scheduler.disable('J_CF_REPORT_CACHE',force=>true);
	   		dbms_scheduler.disable('J_FAKE_COORDINATE_ERROR_STALE',force=>true);
	   		dbms_scheduler.disable('J_IS_FILTERED_FLAT_STALE',force=>true);
	   		dbms_scheduler.disable('J_PRE_BULK_CHK',force=>true);
	   		dbms_scheduler.disable('J_PRE_BULK_CHK_ALL',force=>true);
	   		dbms_scheduler.disable('J_PRE_BULK_REPATRIATE',force=>true);
	   		dbms_scheduler.disable('J_PROC_AUTOGEN_TAXONTERMS',force=>true);
	   		dbms_scheduler.disable('J_PROC_HIERAC_TAX',force=>true);
	   		dbms_scheduler.disable('J_PROC_HIERAC_TAX_DELETEFAMI',force=>true);
	   		dbms_scheduler.disable('J_PROC_HIERAC_TAX_EXPORT',force=>true);
	   		dbms_scheduler.disable('J_PROC_HIERAC_TAX_NC',force=>true);
	   		dbms_scheduler.disable('J_PROC_REF_TAXON_RELATIONS',force=>true);
	   		dbms_scheduler.disable('J_REMOVE_EXPIRED_ENCUMBRANCE',force=>true);
	   		dbms_scheduler.disable('J_SET_BROWSE',force=>true);
	   		dbms_scheduler.disable('J_SET_CONTAINER_HISTORY_STACK',force=>true);
	   		dbms_scheduler.disable('J_SET_MEDIA_FLAT',force=>true);
	   		--dbms_scheduler.disable('J_UPDATE_CACHE_ANYGEOG',force=>true);
	   		dbms_scheduler.disable('SCH_ALA_PROCEDURES',force=>true);
	   		dbms_scheduler.disable('J_FIND_TAX_VARS',force=>true);
	   		dbms_scheduler.disable('J_PROC_CACHE_STATS',force=>true);
	   		dbms_scheduler.disable('J_CACHE_GEOREF_STATS',force=>true);
	   		
	   		
	   	end if;
	   	
	   	
	   	if onoff='on' then
	   		dbms_scheduler.enable('CHECK_FLAT_STALE');
	   		dbms_scheduler.enable('CHECK_UPDATE_FLAT_TAXONOMY');
	   		--dbms_scheduler.enable('J_AUTO_MERGE_COLLECTING_EVENT');
	   		--dbms_scheduler.enable('J_AUTO_MERGE_LOCALITY');
	   		dbms_scheduler.enable('J_BULKLOAD');
	   		dbms_scheduler.enable('J_BULKLOADER_AUTODELETE');
	   		dbms_scheduler.enable('J_CF_REPORT_CACHE');
	   		dbms_scheduler.enable('J_FAKE_COORDINATE_ERROR_STALE');
	   		dbms_scheduler.enable('J_IS_FILTERED_FLAT_STALE');
	   		--dbms_scheduler.enable('J_PRE_BULK_CHK');
	   		--dbms_scheduler.enable('J_PRE_BULK_CHK_ALL');
	   		--dbms_scheduler.enable('J_PRE_BULK_REPATRIATE');
	   		--dbms_scheduler.enable('J_PROC_AUTOGEN_TAXONTERMS');
	   		--dbms_scheduler.enable('J_PROC_HIERAC_TAX');
	   		--dbms_scheduler.enable('J_PROC_HIERAC_TAX_DELETEFAMI');
	   		--dbms_scheduler.enable('J_PROC_HIERAC_TAX_EXPORT');
	   		--dbms_scheduler.enable('J_PROC_HIERAC_TAX_NC');
	   		--dbms_scheduler.enable('J_PROC_REF_TAXON_RELATIONS');
	   		dbms_scheduler.enable('J_REMOVE_EXPIRED_ENCUMBRANCE');
	   		--dbms_scheduler.enable('J_SET_BROWSE');
	   		dbms_scheduler.enable('J_SET_CONTAINER_HISTORY_STACK');
	   		dbms_scheduler.enable('J_SET_MEDIA_FLAT');
	   		--dbms_scheduler.enable('J_UPDATE_CACHE_ANYGEOG');
	   		--dbms_scheduler.enable('SCH_ALA_PROCEDURES');
	   		--dbms_scheduler.enable('J_FIND_TAX_VARS');
	   		dbms_scheduler.enable('J_PROC_CACHE_STATS');
	   		dbms_scheduler.enable('J_CACHE_GEOREF_STATS');
	   		
	   	end if;
	   	
	    dbms_output.put_line('');
	   	dbms_output.put_line('-------------------------------------------------------------------------------------');
	   	dbms_output.put_line('The procedure is complete, but running jobs may continue their current run');
	   	dbms_output.put_line('You may call this with the same on/off flag until everything below is happy');
	   	dbms_output.put_line('-------------------------------------------------------------------------------------');
	    dbms_output.put_line('');
	   	for x in (
	   		select
	   			STATE,
	   			job_name
	   		from 
	   			all_scheduler_jobs 
	   		where 
	   			job_name IN (
	   				'CHECK_FLAT_STALE',
	   				'CHECK_UPDATE_FLAT_TAXONOMY',
	   				'J_AUTO_MERGE_COLLECTING_EVENT',
	   				'J_AUTO_MERGE_LOCALITY',
	   				'J_BULKLOAD',
	   				'J_BULKLOADER_AUTODELETE',
	   				'J_CF_REPORT_CACHE',
	   				'J_FAKE_COORDINATE_ERROR_STALE',
	   				'J_IS_FILTERED_FLAT_STALE',
	   				'J_PRE_BULK_CHK',
	   				'J_PRE_BULK_CHK_ALL',
	   				'J_PRE_BULK_REPATRIATE',
	   				'J_PROC_AUTOGEN_TAXONTERMS',
	   				'J_PROC_HIERAC_TAX',
	   				'J_PROC_HIERAC_TAX_DELETEFAMI',
	   				'J_PROC_HIERAC_TAX_EXPORT',
	   				'J_PROC_HIERAC_TAX_NC',
	   				'J_PROC_REF_TAXON_RELATIONS',
	   				'J_REMOVE_EXPIRED_ENCUMBRANCE',
	   				'J_SET_BROWSE',
	   				'J_SET_CONTAINER_HISTORY_STACK',
	   				'J_SET_MEDIA_FLAT',
	   				--'J_UPDATE_CACHE_ANYGEOG',
	   				'SCH_ALA_PROCEDURES',
	   				'J_FIND_TAX_VARS',
	   				'J_PROC_CACHE_STATS',
	   				'J_CACHE_GEOREF_STATS'
	   			)
	   	) loop
	   		dbms_output.put_line(rpad(x.job_name,60,' ') || ' ==> ' || x.state);
	   	end loop;
	   	
	    dbms_output.put_line('');
	   	dbms_output.put_line('-------------------------------------------------------------------------------------');
		dbms_output.put_line('jobs like %temp% that may be doing something crazy; these need dealt with manually.');
	   	dbms_output.put_line('-------------------------------------------------------------------------------------');
	    dbms_output.put_line('');
	   	for xt in (
	   		select
	   			STATE,
	   			job_name
	   		from 
	   			all_scheduler_jobs 
	   		where 
	   			job_name like '%TEMP%'
	   	) loop
	   		dbms_output.put_line(rpad(xt.job_name,60,' ') || ' ==> ' || xt.state);
	   	end loop;
	   		
	   dbms_output.put_line('');
	   	
	end;
/
sho err;

exec pause_maintenance('on');
