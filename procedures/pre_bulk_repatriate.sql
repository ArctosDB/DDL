CREATE OR REPLACE PROCEDURE pre_bulk_repatriate  IS
	nrec number;
	stscnt number;
	gbp number;
begin
	-- reinsert the lookup values
	-- ignore any NULLs in shouldbe; they're confusing.
	
	-- only run this if ALL records are loaded=go_go_gadget_repatriate; set loaded in this procedure.
	select count(*) into nrec from pre_bulkloader;
	select count(*) into stscnt from pre_bulkloader where loaded ='go_go_gadget_repatriate';
	if nrec = 0 or nrec != stscnt then
		dbms_output.put_line('fail go_go_gadget_repatriate');
		return;
	end if;
	
	-- don't even try to deal with funky guid_prefix
	select count(*) into gbp from pre_bulkloader where guid_prefix not in (select guid_prefix from collection);
	if gbp > 0 then
		update pre_bulkloader set loaded='funky guid_prefix detected; abort';
		dbms_output.put_line('fail guid_prefix');
		return;
	end if;
	
	-- get rid of NULL shouldbe before we do anything
	
	delete from pre_bulk_agent where shouldbe is null;
	update pre_bulkloader set COLLECTOR_agent_1=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_1)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_2=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_2)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_3=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_3)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_4=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_4)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_5=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_5)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_6=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_6)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_7=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_7)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set COLLECTOR_agent_8=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.COLLECTOR_agent_8)=trim(pre_bulk_agent.AGENT_NAME));

	update pre_bulkloader set ATTRIBUTE_DETERMINER_1=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_1)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_2=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_2)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_3=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_3)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_4=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_4)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_5=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_5)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_6=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_6)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_7=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_7)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_8=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_8)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_9=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_9)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set ATTRIBUTE_DETERMINER_10=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ATTRIBUTE_DETERMINER_10)=trim(pre_bulk_agent.AGENT_NAME));

	update pre_bulkloader set ID_MADE_BY_AGENT=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.ID_MADE_BY_AGENT)=trim(pre_bulk_agent.AGENT_NAME));
	update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT=(select trim(shouldbe) from pre_bulk_agent where trim(pre_bulkloader.EVENT_ASSIGNED_BY_AGENT)=trim(pre_bulk_agent.AGENT_NAME));

	
	/*
	
	for r in (select * from pre_bulk_agent where shouldbe is not null) loop
		update pre_bulkloader set COLLECTOR_agent_1=trim(r.shouldbe) where trim(COLLECTOR_agent_1)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_2=trim(r.shouldbe) where trim(COLLECTOR_agent_2)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_3=trim(r.shouldbe) where trim(COLLECTOR_agent_3)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_4=trim(r.shouldbe) where trim(COLLECTOR_agent_4)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_5=trim(r.shouldbe) where trim(COLLECTOR_agent_5)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_6=trim(r.shouldbe) where trim(COLLECTOR_agent_6)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_7=trim(r.shouldbe) where trim(COLLECTOR_agent_7)=trim(r.AGENT_NAME);
		update pre_bulkloader set COLLECTOR_agent_8=trim(r.shouldbe) where trim(COLLECTOR_agent_8)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_1=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_1)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_2=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_2)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_3=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_3)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_4=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_4)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_5=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_5)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_6=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_6)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_7=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_7)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_8=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_8)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_9=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_9)=trim(r.AGENT_NAME);
		update pre_bulkloader set ATTRIBUTE_DETERMINER_10=trim(r.shouldbe) where trim(ATTRIBUTE_DETERMINER_10)=trim(r.AGENT_NAME);
		update pre_bulkloader set ID_MADE_BY_AGENT=trim(r.shouldbe) where trim(ID_MADE_BY_AGENT)=trim(r.AGENT_NAME);
		update pre_bulkloader set EVENT_ASSIGNED_BY_AGENT=trim(r.shouldbe) where trim(EVENT_ASSIGNED_BY_AGENT)=trim(r.AGENT_NAME);
	end loop;

	*/
		
	for r in (select * from pre_bulk_taxa where shouldbe is not null) loop
		update pre_bulkloader set taxon_name=trim(r.shouldbe) where trim(taxon_name)=trim(r.taxon_name);
	end loop;

	
	for r in (select * from pre_bulk_attributes where shouldbe is not null) loop
	
		dbms_output.put_line(r.attribute_type || '--->' || r.shouldbe);
		update pre_bulkloader set ATTRIBUTE_1=r.shouldbe where ATTRIBUTE_1=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_2=r.shouldbe where ATTRIBUTE_2=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_3=r.shouldbe where ATTRIBUTE_3=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_4=r.shouldbe where ATTRIBUTE_4=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_5=r.shouldbe where ATTRIBUTE_5=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_6=r.shouldbe where ATTRIBUTE_6=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_7=r.shouldbe where ATTRIBUTE_7=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_8=r.shouldbe where ATTRIBUTE_8=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_9=r.shouldbe where ATTRIBUTE_9=r.attribute_type;
		update pre_bulkloader set ATTRIBUTE_10=r.shouldbe where ATTRIBUTE_10=r.attribute_type;
	end loop;

	
	for r in (select * from pre_bulk_oidt where shouldbe is not null) loop
		update pre_bulkloader set OTHER_ID_NUM_TYPE_1=r.shouldbe where OTHER_ID_NUM_TYPE_1=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_2=r.shouldbe where OTHER_ID_NUM_TYPE_2=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_3=r.shouldbe where OTHER_ID_NUM_TYPE_3=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_4=r.shouldbe where OTHER_ID_NUM_TYPE_4=r.OTHER_ID_TYPE;
		update pre_bulkloader set OTHER_ID_NUM_TYPE_5=r.shouldbe where OTHER_ID_NUM_TYPE_5=r.OTHER_ID_TYPE;
	end loop;

	
		update pre_bulkloader set MADE_DATE=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.MADE_DATE)=trim(pre_bulk_date.adate));
		update pre_bulkloader set BEGAN_DATE=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.BEGAN_DATE)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ENDED_DATE=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ENDED_DATE)=trim(pre_bulk_date.adate));
		update pre_bulkloader set EVENT_ASSIGNED_DATE=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.EVENT_ASSIGNED_DATE)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_1=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_1)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_2=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_2)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_3=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_3)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_4=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_4)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_5=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_5)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_6=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_6)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_7=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_7)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_8=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_8)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_9=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_9)=trim(pre_bulk_date.adate));
		update pre_bulkloader set ATTRIBUTE_DATE_10=(select trim(shouldbe) from pre_bulk_date where trim(pre_bulkloader.ATTRIBUTE_DATE_10)=trim(pre_bulk_date.adate));
		
		
		
	
		
		/*
	for r in (select * from pre_bulk_date where shouldbe is not null) loop
		update pre_bulkloader set MADE_DATE=r.shouldbe where MADE_DATE=r.adate;
		update pre_bulkloader set BEGAN_DATE=r.shouldbe where BEGAN_DATE=r.adate;
		update pre_bulkloader set ENDED_DATE=r.shouldbe where ENDED_DATE=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_1=r.shouldbe where ATTRIBUTE_DATE_1=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_2=r.shouldbe where ATTRIBUTE_DATE_2=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_3=r.shouldbe where ATTRIBUTE_DATE_3=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_4=r.shouldbe where ATTRIBUTE_DATE_4=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_5=r.shouldbe where ATTRIBUTE_DATE_5=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_6=r.shouldbe where ATTRIBUTE_DATE_6=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_7=r.shouldbe where ATTRIBUTE_DATE_7=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_8=r.shouldbe where ATTRIBUTE_DATE_8=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_9=r.shouldbe where ATTRIBUTE_DATE_9=r.adate;
		update pre_bulkloader set ATTRIBUTE_DATE_10=r.shouldbe where ATTRIBUTE_DATE_10=r.adate;
		update pre_bulkloader set EVENT_ASSIGNED_DATE=r.shouldbe where EVENT_ASSIGNED_DATE=r.adate;
	end loop;
*/

	for r in (select * from pre_bulk_parts where shouldbe is not null) loop
		update pre_bulkloader set part_name_1=r.shouldbe where part_name_1=r.part_name;
		update pre_bulkloader set part_name_2=r.shouldbe where part_name_2=r.part_name;
		update pre_bulkloader set part_name_3=r.shouldbe where part_name_3=r.part_name;
		update pre_bulkloader set part_name_4=r.shouldbe where part_name_4=r.part_name;
		update pre_bulkloader set part_name_5=r.shouldbe where part_name_5=r.part_name;
		update pre_bulkloader set part_name_6=r.shouldbe where part_name_6=r.part_name;
		update pre_bulkloader set part_name_7=r.shouldbe where part_name_7=r.part_name;
		update pre_bulkloader set part_name_8=r.shouldbe where part_name_8=r.part_name;
		update pre_bulkloader set part_name_9=r.shouldbe where part_name_9=r.part_name;
		update pre_bulkloader set part_name_10=r.shouldbe where part_name_10=r.part_name;
		update pre_bulkloader set part_name_11=r.shouldbe where part_name_11=r.part_name;
		update pre_bulkloader set part_name_12=r.shouldbe where part_name_12=r.part_name;
	end loop;
	
	
	for r in (select * from pre_bulk_disposition where shouldbe is not null) loop
		update pre_bulkloader set PART_DISPOSITION_1=r.shouldbe where PART_DISPOSITION_1=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_2=r.shouldbe where PART_DISPOSITION_2=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_3=r.shouldbe where PART_DISPOSITION_3=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_4=r.shouldbe where PART_DISPOSITION_4=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_5=r.shouldbe where PART_DISPOSITION_5=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_6=r.shouldbe where PART_DISPOSITION_6=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_7=r.shouldbe where PART_DISPOSITION_7=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_8=r.shouldbe where PART_DISPOSITION_8=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_9=r.shouldbe where PART_DISPOSITION_9=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_10=r.shouldbe where PART_DISPOSITION_10=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_11=r.shouldbe where PART_DISPOSITION_11=r.disposition;
		update pre_bulkloader set PART_DISPOSITION_12=r.shouldbe where PART_DISPOSITION_12=r.disposition;
	end loop;

	
	
	for r in (select * from pre_bulk_collrole where shouldbe is not null) loop
		update pre_bulkloader set collector_role_1=r.shouldbe where collector_role_1=r.collector_role;
		update pre_bulkloader set collector_role_2=r.shouldbe where collector_role_2=r.collector_role;
		update pre_bulkloader set collector_role_3=r.shouldbe where collector_role_3=r.collector_role;
		update pre_bulkloader set collector_role_4=r.shouldbe where collector_role_4=r.collector_role;
		update pre_bulkloader set collector_role_5=r.shouldbe where collector_role_5=r.collector_role;
		update pre_bulkloader set collector_role_6=r.shouldbe where collector_role_6=r.collector_role;
		update pre_bulkloader set collector_role_7=r.shouldbe where collector_role_7=r.collector_role;
		update pre_bulkloader set collector_role_8=r.shouldbe where collector_role_8=r.collector_role;
	end loop;


	for r in (select * from pre_bulk_accn where shouldbe is not null) loop
		update pre_bulkloader set accn=trim(r.shouldbe) where trim(accn)=trim(r.accn);
	end loop;
	
	for r in (select * from pre_bulk_geog where shouldbe is not null) loop
		update pre_bulkloader set HIGHER_GEOG=trim(r.shouldbe) where trim(HIGHER_GEOG)=trim(r.HIGHER_GEOG);
	end loop;
	
	for r in (select * from pre_bulk_NATURE_OF_ID where shouldbe is not null) loop
		update pre_bulkloader set NATURE_OF_ID=trim(r.shouldbe) where trim(NATURE_OF_ID)=trim(r.NATURE_OF_ID);
	end loop;
	
	for r in (select * from pre_bulk_ORIG_LAT_LONG_UNITS where shouldbe is not null) loop
		update pre_bulkloader set ORIG_LAT_LONG_UNITS=trim(r.shouldbe) where trim(ORIG_LAT_LONG_UNITS)=trim(r.ORIG_LAT_LONG_UNITS);
	end loop;
	
	for r in (select * from pre_bulk_GEOREFERENCE_PROTOCOL where shouldbe is not null) loop
		update pre_bulkloader set GEOREFERENCE_PROTOCOL=trim(r.shouldbe) where trim(GEOREFERENCE_PROTOCOL)=trim(r.GEOREFERENCE_PROTOCOL);
	end loop;
	
	for r in (select * from pre_bulk_VERIFICATIONSTATUS where shouldbe is not null) loop
		update pre_bulkloader set VERIFICATIONSTATUS=trim(r.shouldbe) where trim(VERIFICATIONSTATUS)=trim(r.VERIFICATIONSTATUS);
	end loop;
	
	for r in (select * from pre_bulk_MAX_ERROR_UNITS where shouldbe is not null) loop
		update pre_bulkloader set MAX_ERROR_UNITS=trim(r.shouldbe) where trim(MAX_ERROR_UNITS)=trim(r.MAX_ERROR_UNITS);
	end loop;
	
	for r in (select * from pre_bulk_COLLECTING_SOURCE where shouldbe is not null) loop
		update pre_bulkloader set COLLECTING_SOURCE=trim(r.shouldbe) where trim(COLLECTING_SOURCE)=trim(r.COLLECTING_SOURCE);
	end loop;
	
	for r in (select * from pre_bulk_DEPTH_UNITS where shouldbe is not null) loop
		update pre_bulkloader set DEPTH_UNITS=trim(r.shouldbe) where trim(DEPTH_UNITS)=trim(r.DEPTH_UNITS);
	end loop;
	
	for r in (select * from pre_bulk_DATUM where shouldbe is not null) loop
		update pre_bulkloader set DATUM=trim(r.shouldbe) where trim(DATUM)=trim(r.DATUM);
	end loop;
	
	update pre_bulkloader set loaded='repatriation_complete';
end;
/
sho err



BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'J_PRE_BULK_REPATRIATE',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'pre_bulk_repatriate',
   start_date         =>  SYSTIMESTAMP,
   repeat_interval    =>  'freq=hourly; byminute=7,17,27,37,47,57;',
   enabled             =>  TRUE,
   end_date           =>  NULL,
   comments           =>  'repatriate pre_bulkloader from lookup tables');
END;
/

exec DBMS_SCHEDULER.DROP_JOB('J_PRE_BULK_REPATRIATE', FORCE => TRUE);

	select STATE,LAST_START_DATE,NEXT_RUN_DATE from all_scheduler_jobs where JOB_NAME='J_PRE_BULK_REPATRIATE';
