TODO::



-- add info/collectingEventArchive.cfm to form control
-- add /ScheduledTasks/collectingEventChangeAlert.cfm to form control
-- create scheduled task for /ScheduledTasks/collectingEventChangeAlert.cfm




-------------

-- address https://github.com/ArctosDB/arctos/issues/1017
-- first step: create a collecting event archive, write to it with triggers

 -- exclude the service-derived stuff and "verbatim pieces"
 -- add who/when
 drop table collecting_event_archive;
 
create table collecting_event_archive (
	collecting_event_archive_id number not null,
	COLLECTING_EVENT_ID number,
	LOCALITY_ID number,
	VERBATIM_DATE varchar2(4000),
	VERBATIM_LOCALITY varchar2(4000),
	COLL_EVENT_REMARKS varchar2(4000),
	BEGAN_DATE varchar2(4000),
	ENDED_DATE varchar2(4000),
	COLLECTING_EVENT_NAME varchar2(4000),
	VERBATIM_COORDINATES varchar2(4000),
 	whodunit varchar2(255),
 	changedate date 	
	);
	
create sequence sq_collecting_event_archive_id;
CREATE PUBLIC SYNONYM sq_collecting_event_archive_id FOR sq_collecting_event_archive_id;
GRANT SELECT ON sq_collecting_event_archive_id TO PUBLIC;


CREATE PUBLIC SYNONYM collecting_event_archive FOR collecting_event_archive;
-- everyone can read
-- only UAM can change (via trigger)
grant select on collecting_event_archive to public;


CREATE OR REPLACE TRIGGER trg_collecting_event_archive
	-- only care if there's been a successful change
	after UPDATE ON collecting_event
    FOR EACH ROW
    	declare nkey number;
    BEGIN
	    -- first test if we're changing anything - no reason to log
	    -- "save because there's a button" or webservice cache
	    -- actions
	    -- NULL never equals NULL so need NVL
		
	    
	    if 	
	    	:NEW.LOCALITY_ID != :OLD.LOCALITY_ID or
	    	nvl(:NEW.VERBATIM_DATE,'NULL') != nvl(:OLD.VERBATIM_DATE,'NULL') or
	    	nvl(:NEW.VERBATIM_LOCALITY,'NULL') != nvl(:OLD.VERBATIM_LOCALITY,'NULL') or
	    	nvl(:NEW.COLL_EVENT_REMARKS,'NULL') != nvl(:OLD.COLL_EVENT_REMARKS,'NULL') or
	    	nvl(:NEW.BEGAN_DATE,'NULL') != nvl(:OLD.BEGAN_DATE,'NULL') or
	    	nvl(:NEW.ENDED_DATE,'NULL') != nvl(:OLD.ENDED_DATE,'NULL') or
	    	nvl(:NEW.COLLECTING_EVENT_NAME,'NULL') != nvl(:OLD.COLLECTING_EVENT_NAME,'NULL') or
	    	nvl(:NEW.VERBATIM_COORDINATES,'NULL') != nvl(:OLD.VERBATIM_COORDINATES,'NULL') 	
	    then
			-- do not log locality mergers
				-- UAM driving
				-- locality_id changed
				-- everything else the same
	    	if 
	    		sys_context('USERENV', 'SESSION_USER')='UAM' and
	    		:NEW.LOCALITY_ID != :OLD.LOCALITY_ID and
	    		nvl(:NEW.VERBATIM_DATE,'NULL') = nvl(:OLD.VERBATIM_DATE,'NULL') and
	    		nvl(:NEW.VERBATIM_LOCALITY,'NULL') = nvl(:OLD.VERBATIM_LOCALITY,'NULL') and
	    		nvl(:NEW.COLL_EVENT_REMARKS,'NULL') = nvl(:OLD.COLL_EVENT_REMARKS,'NULL') and
	    		nvl(:NEW.BEGAN_DATE,'NULL') = nvl(:OLD.BEGAN_DATE,'NULL') and
	    		nvl(:NEW.ENDED_DATE,'NULL') = nvl(:OLD.ENDED_DATE,'NULL') and
	    		nvl(:NEW.COLLECTING_EVENT_NAME,'NULL') = nvl(:OLD.COLLECTING_EVENT_NAME,'NULL') and
	    		nvl(:NEW.VERBATIM_COORDINATES,'NULL') = nvl(:OLD.VERBATIM_COORDINATES,'NULL') 	
	    	then
	    		return;
	    	end if;
	    		
	    		dbms_output.put_line('got change');  
	    		 -- now just grab all of the :OLD values
		        -- :NEWs are current data in locality, no need to do anything with them
		
    		insert into collecting_event_archive (
			 	collecting_event_archive_id,
			 	COLLECTING_EVENT_ID,
			 	LOCALITY_ID,
			 	VERBATIM_DATE,
			 	VERBATIM_LOCALITY,
			 	COLL_EVENT_REMARKS,
				BEGAN_DATE,
				ENDED_DATE,
				COLLECTING_EVENT_NAME,
				VERBATIM_COORDINATES,
			 	whodunit,
			 	changedate
			 ) values (
			 	sq_collecting_event_archive_id.nextval,
			 	:OLD.COLLECTING_EVENT_ID,
			 	:OLD.LOCALITY_ID,
			 	:OLD.VERBATIM_DATE,
			 	:OLD.VERBATIM_LOCALITY,
			 	:OLD.COLL_EVENT_REMARKS,
			 	:OLD.BEGAN_DATE,
			 	:OLD.ENDED_DATE,
			 	:OLD.COLLECTING_EVENT_NAME,
			 	:OLD.VERBATIM_COORDINATES,
			 	sys_context('USERENV', 'SESSION_USER'),
			 	sysdate
			 );
			--dbms_output.put_line('logged OLD values');  
	    end if;
  end;
/
sho err;


-- clean up UAM stuff
delete from collecting_event_archive where whodunit='UAM';

select count(*)  from collecting_event_archive;

CREATE OR REPLACE TRIGGER TR_COLLECTINGEVENT_BUD

alter table collecting_event add last_dup_check_date date;


CREATE OR REPLACE TRIGGER TRG_COLLECTING_EVENT_BIU

-- and https://github.com/ArctosDB/arctos/issues/1491 while we're here


create table bak_collecting_event20180405 as select * from collecting_event;

-- for test only, so we can monitor this

alter table bak_collecting_event20180405 add merged_into_cid number;


CREATE OR REPLACE PROCEDURE auto_merge_collecting_event 
IS
	i number :=0;
	c number;
BEGIN
	-- run this on new stuff and recheck every month or so
	-- need to monitor and adjust the "every month or so" bits
	-- collecting_event_name is unique so those will never be duplicates
	-- but grab them anyway so we can flag them as being checked
	for r in (
		select * from collecting_event where rownum<200 and (last_dup_check_date is null or sysdate-last_dup_check_date > 30)
	) loop
			dbms_output.put_line(r.collecting_event_id);
			dbms_output.put_line(r.VERBATIM_LOCALITY);
			--dbms_output.put_line(r.last_dup_check_date);
		for dups in (
			select * from collecting_event where
				collecting_event_id != r.collecting_event_id and
				LOCALITY_ID=r.LOCALITY_ID and
				nvl(VERBATIM_DATE,'NULL')=nvl(r.VERBATIM_DATE,'NULL') and
				nvl(VERBATIM_LOCALITY,'NULL')=nvl(r.VERBATIM_LOCALITY,'NULL') and
				nvl(COLL_EVENT_REMARKS,'NULL')=nvl(r.COLL_EVENT_REMARKS,'NULL') and
				nvl(BEGAN_DATE,'NULL')=nvl(r.BEGAN_DATE,'NULL') and
				nvl(ENDED_DATE,'NULL')=nvl(r.ENDED_DATE,'NULL') and
				nvl(VERBATIM_COORDINATES,'NULL')=nvl(r.VERBATIM_COORDINATES,'NULL') and
				nvl(COLLECTING_EVENT_NAME,'NULL')=nvl(r.COLLECTING_EVENT_NAME,'NULL') 
			) loop
			BEGIN
				i:=i+1;
				--dbms_output.put_line('!!!!!!!!!!!!!!!!!!!!!!!!! FOUND DUPLICATE GONNA MERGE!!!!!!!!!! dup evt ID: ' || dups.collecting_event_id);
				-- log; probably won't go to prod
				--update bak_collecting_event20180405 set merged_into_cid = r.collecting_event_id where collecting_event_id=dups.collecting_event_id;
				--dbms_output.put_line('gonna update specimen_event');
				
				--dbms_output.put_line('update specimen_event	set	collecting_event_id=' || r.collecting_event_id || '	where collecting_event_id=' || dups.collecting_event_id);
				
				
				update 
					specimen_event 
				set 
					collecting_event_id=r.collecting_event_id
				where 
					collecting_event_id=dups.collecting_event_id;
				
				update 
					tag 
				set 
					collecting_event_id=r.collecting_event_id 
				where 
					collecting_event_id=dups.collecting_event_id;

				update 
					media_relations 
				set 
					related_primary_key=r.collecting_event_id 
				where
					media_relationship like '% collecting_event' and
					related_primary_key =dups.collecting_event_id;

				update 
					bulkloader 
				set 
					collecting_event_id=r.collecting_event_id 
				where 
					collecting_event_id=dups.collecting_event_id;


				-- and delete the duplicate locality
				--dbms_output.put_line('gonna delete collecting_event');
				delete from collecting_event where collecting_event_id=dups.collecting_event_id;
				
				--dbms_output.put_line(' deleted collecting_event');
			exception when others then
			--	null;
				-- these happen (at least) when the initial query contains the duplicate
				-- ignore, they'll get caught next time around/eventually
				dbms_output.put_line('FAIL ID: ' || dups.collecting_event_id);
				dbms_output.put_line(sqlerrm);
			end;
		end loop;
		-- now that we're merged, DELETE if unused and unnamed
		-- DO NOT delete named localities
		if r.COLLECTING_EVENT_NAME is null then
			select sum(x) into c from (
				select count(*) x from specimen_event where collecting_event_id=r.collecting_event_id
				union
				select count(*) x from tag where collecting_event_id=r.collecting_event_id
				union
				select count(*) x from media_relations where media_relationship like '% collecting_event' and related_primary_key =r.collecting_event_id
				union
				select count(*) x from bulkloader where collecting_event_id=r.collecting_event_id
			);
			if c=0 then
				--dbms_output.put_line('not used deleting');
				delete from collecting_event where collecting_event_id=r.collecting_event_id;
			end if;
		end if;

		-- log the last check
		-- pass in the admin_flag = 'proc auto_merge_locality' - we're not changing anything here
				--dbms_output.put_line('gonna log....');
		update collecting_event set admin_flag = 'proc auto_merge_locality',last_dup_check_date=sysdate where collecting_event_id=r.collecting_event_id;

		-- if there are a lot of not-so-duplicates found, this can process many per run
		-- if there are a log of duplicates, it'll get all choked up on trying to update FLAT
		-- so throttle - if we haven't merged much then keep going, if we have exit and start over next run
		if i > 100 then
			--dbms_output.put_line('i maxout: ' || i);
			return;
		--else
			--dbms_output.put_line('i stillsmall: ' || i);
		end if;
	end loop;
end;
/
sho err;

exec auto_merge_collecting_event;




BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'j_auto_merge_collecting_event',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'auto_merge_collecting_event',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  '');
END;
/

exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'j_auto_merge_collecting_event', FORCE => TRUE);

 select START_DATE,REPEAT_INTERVAL,END_DATE,ENABLED,STATE,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,NEXT_RUN_DATE from all_scheduler_jobs where lower(job_name)='j_auto_merge_collecting_event';




select to_char(last_dup_check_date,'yyyy-mm-dd'), count(*) from collecting_event group by to_char(last_dup_check_date,'yyyy-mm-dd');

select (select count(*) from bak_collecting_event20180405) - (select count(*) from collecting_event) from dual;
