

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
	    		
	    		--dbms_output.put_line('got change');  
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



-- add info/collectingEventArchive.cfm to form control
-- add /ScheduledTasks/collectingEventChangeAlert.cfm to form control
-- create scheduled task for /ScheduledTasks/collectingEventChangeAlert.cfm
