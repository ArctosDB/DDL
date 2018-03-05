


--on hold waiting resolution of https://github.com/ArctosDB/arctos/issues/739
-- #739 is now https://github.com/ArctosDB/arctos/issues/1023
-- go go go!



/*
 * 
 
 Final event type vocabulary:
 
 
    use - Event at which an item was used. Generally refers to human use of cultural items.
    manufacture - Event at which an item was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.
    encounter - Individual Specimen was encountered and not killed or removed from context; Biological Samples were taken. Biopsies belong here.
    observation - IndividualSpecimen was detected and not killed or removed from context; No biological samples were taken. Human sightings, camera traps, and GPS telemetry data are appropriate here.
    collection - Specimen was collected. The specimen was killed, found dead, or removed from functional cultural, biological, ecological, or archeological context.



 *
 */














alter table specimen_event add verified_by_agent_id number;

ALTER TABLE SPECIMEN_EVENT add CONSTRAINT fk_SPECIMEN_EVENT_vfdby FOREIGN KEY (verified_by_agent_id) REFERENCES agent (agent_id);

alter table specimen_event add verified_date varchar2(30);

select trigger_name from all_triggers where table_name='SPECIMEN_EVENT';

CREATE OR REPLACE TRIGGER trg_SPECIMEN_EVENT_biu
    BEFORE INSERT OR UPDATE ON SPECIMEN_EVENT
    FOR EACH ROW
    declare status varchar2(255);
    BEGIN
        if :new.SPECIMEN_EVENT_ID is null then
        	select sq_specimen_event_id.nextval into :new.SPECIMEN_EVENT_ID from dual;
        end if;
        if :new.VERIFICATIONSTATUS is null then
        	:new.VERIFICATIONSTATUS:='unverified';
        end if;
        if :new.specimen_event_type is null then
        		:new.specimen_event_type:='collection';
        end if;
        status:=is_iso8601(:NEW.verified_date);
    	IF status != 'valid' THEN
        	raise_application_error(-20001,'Verified Date: ' || status);
    	END IF;
    end;
/


insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('collection','Specimen was collected. The specimen was killed, found dead, or removed from functional cultural, biological, ecological, or archeological context.');


update CTSPECIMEN_EVENT_TYPE set 
	DESCRIPTION='Specimen was encountered and not killed or removed from context; Biological Samples were taken. Biopsies belong here.' 
	where SPECIMEN_EVENT_TYPE='encounter';
	
update CTSPECIMEN_EVENT_TYPE set 
	DESCRIPTION='Specimen was detected and not killed or removed from context; No biological samples were taken. Human sightings, camera traps, and GPS telemetry data are appropriate here.' 
	where SPECIMEN_EVENT_TYPE='encounter';
	
	
	insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('use','Event at which an item was used. Generally refers to human use of cultural items.');
	
	
	

insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('manufacture','Event at which an item was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.');

	


    
    



	
update CTVERIFICATIONSTATUS set 
	DESCRIPTION='No assertion regarding the accuracy of the place and time information is made.' 
	where VERIFICATIONSTATUS='unverified';

	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('unaccepted',
	'The place and time information as entered was reviewed and determined to be incorrect, or less correct or complete than other available data.'
);
		
	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('accepted',
	'The place and time information as entered was checked and determined to be correct against the information available from Arctos; original data were not consulted, and transcription or omission errors are possible.'
);
	
insert into CTVERIFICATIONSTATUS (VERIFICATIONSTATUS,DESCRIPTION) values 
	('verified and locked',
	'The place and time information as entered was checked against all available data, including labels, fieldnotes, collector itineraries, and associated digital data, and determined to be correct. Changes should only be made in the extremely unlikely event of more authoritative data surfacing. This value LOCKS linked Locality and Event data.'
);
	


select 
	VERIFICATIONSTATUS,
	guid_prefix,
	count(*) 
from 
	specimen_event,
	cataloged_item,
	collection
where 
	specimen_event.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and	
	SPECIMEN_EVENT_TYPE='unaccepted place of collection' and
	verificationstatus!='unverified'
group by 
	guid_prefix,
	VERIFICATIONSTATUS;

select 
	guid_prefix || ':' || cat_num guid
from 
	specimen_event,
	cataloged_item,
	collection
where 
	specimen_event.collection_object_id=cataloged_item.collection_object_id and
	cataloged_item.collection_id=collection.collection_id and	
	SPECIMEN_EVENT_TYPE='unaccepted place of collection' and
	verificationstatus!='unverified'
;


-- this is super-slow so...


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set verificationstatus='unaccepted' where specimen_event_type='unaccepted place of collection';
end;
/


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='collection' where specimen_event_type='unaccepted place of collection';
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';



CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='collection' where specimen_event_type='accepted place of collection';
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';


CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='manufacture' where specimen_event_type='place of manufacture';
end;
/

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';




CREATE OR REPLACE PROCEDURE temp_update_junk IS
begin
  update specimen_event set specimen_event_type='use' where specimen_event_type='place of use';
end;
/


BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name    => 'J_TEMP_UPDATE_JUNK',
    job_type    => 'STORED_PROCEDURE',
    job_action    => 'temp_update_junk',
    enabled     => TRUE,
    end_date    => NULL
  );
END;
/ 

select STATE,LAST_START_DATE,NEXT_RUN_DATE,LAST_RUN_DURATION from all_scheduler_jobs where JOB_NAME='J_TEMP_UPDATE_JUNK';

select count(*) from specimen_event where specimen_event_type='unaccepted place of collection';

select count(*) from specimen_event where specimen_event_type='place of manufacture';

delete from ctspecimen_event_type where specimen_event_type='accepted place of collection';
delete from ctspecimen_event_type where specimen_event_type='place of manufacture';
delete from ctspecimen_event_type where specimen_event_type='place of use';


delete from ctspecimen_event_type where specimen_event_type='unaccepted place of collection';





    


select 
	specimen_event_id,
	agent_id 
from
	specimen_event,
	collector
where
	specimen_event.COLLECTION_OBJECT_ID=collector.COLLECTION_OBJECT_ID(+) and
	collector_role='collector' and
	coll_order=1 and
	verificationstatus='verified by collector'
order by agent_id desc;
	
	
	
verified_by_agent_id

Proposed vocabulary for specimen_event_type:

(Currently: http://arctos.database.museum/info/ctDocumentation.cfm?table=CTSPECIMEN_EVENT_TYPE)

collection
Definition: Specimen was collected. For biological specimens, the specimen was killed or found dead at the event.
Migration Path: �Accepted place of collection� plus �unaccepted place of collection� merge here.
�unaccepted place of collection� will first change verificationstatus to �unaccepted.�

encounter
Definition: Specimen was encountered alive and not killed. Samples or recordings may have been taken; see parts and media for more information.
Migration Path: �Encounter� and �observation� merge here.

manufacture
Definition: Specimen was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.
Migration Path: Vocabulary change only, from �place of manufacture.�

use
Definition: Specimen was used. Generally refers to human use of cultural items.
Migration Path: Vocabulary change only, from �place of use.�


Proposed vocabulary for verification status:

(Currently: http://arctos.database.museum/info/ctDocumentation.cfm?table=CTVERIFICATIONSTATUS)

unverified
Definition: No assertion regarding the accuracy of the place and time information is made.
Migration Path: No changes.

unaccepted
Definition: The place and time information as entered was reviewed and determined to be incorrect, or less correct or complete than other available data.
Migration Path: New concept, will be assigned to all specimen events which are currently of type �unaccepted place of collection.�

accepted
Definition: The place and time information as entered was checked and determined to be correct against the information available from Arctos; original data were not consulted, and transcription or omission errors are possible.
Migration Path: �Checked by curator� and �checked by collector� merge here. See �new fields� below.

verified and locked
Definition: The place and time information as entered was checked against all available data, including labels, fieldnotes, collector itineraries, and associated digital data, and determined to be correct. Changes should only be made in the extremely unlikely event of more authoritative data surfacing. This value LOCKS linked Locality and Event data.
Migration Path: �Verified by curator� and �verified by collector� merge here. See �new fields� below.







