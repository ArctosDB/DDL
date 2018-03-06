


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










-- delay flat updates


 exec DBMS_SCHEDULER.DROP_JOB (JOB_NAME => 'check_flat_stale', FORCE => TRUE);



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



UAM@ARCTOSTE> desc specimen_event
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 SPECIMEN_EVENT_ID						   NOT NULL NUMBER
 COLLECTION_OBJECT_ID						   NOT NULL NUMBER
 COLLECTING_EVENT_ID						   NOT NULL NUMBER
 ASSIGNED_BY_AGENT_ID						   NOT NULL NUMBER
 ASSIGNED_DATE							   NOT NULL DATE
 SPECIMEN_EVENT_REMARK							    VARCHAR2(4000)
 SPECIMEN_EVENT_TYPE						   NOT NULL VARCHAR2(60)
 COLLECTING_METHOD							    VARCHAR2(4000)
 COLLECTING_SOURCE							    VARCHAR2(60)
 VERIFICATIONSTATUS						   NOT NULL VARCHAR2(60)
 HABITAT								    VARCHAR2(4000)
 VERIFIED_BY_AGENT_ID							    NUMBER
 VERIFIED_DATE								    VARCHAR2(30)

 select * from ctverification_status;
 

 
 select count(*) from specimen_event where VERIFICATIONSTATUS='unaccepted';
 select count(*) from specimen_event where VERIFICATIONSTATUS='accepted';
 select count(*) from specimen_event where VERIFICATIONSTATUS='checked by curator';
 
 
 select distinct SPECIMEN_EVENT_REMARK from specimen_event where VERIFICATIONSTATUS='accepted' order by SPECIMEN_EVENT_REMARK;
 


 update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by curator.')
 where VERIFICATIONSTATUS='checked by curator';
 
 
 
  update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by curator.')
 where VERIFICATIONSTATUS='checked by curator';
 
   update specimen_event set VERIFICATIONSTATUS='accepted', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: checked by collector.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: checked by collector.')
 where VERIFICATIONSTATUS='checked by collector';
 
 
 
    update specimen_event set VERIFICATIONSTATUS='verified and locked', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: verified by collector.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: verified by collector.')
 where VERIFICATIONSTATUS='verified by collector';
 
   update specimen_event set VERIFICATIONSTATUS='verified and locked', 
 SPECIMEN_EVENT_REMARK=decode(SPECIMEN_EVENT_REMARK,
 	null,'Former verification status: verified by curator.',
 	SPECIMEN_EVENT_REMARK || '; Former verification status: verified by curator.')
 where VERIFICATIONSTATUS='verified by curator';

 
 
 

    
 -- turn flat updates back on
 
    BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name           =>  'check_flat_stale',
    job_type           =>  'STORED_PROCEDURE',
	job_action         =>  'IS_FLAT_STALE',
	start_date         =>  SYSTIMESTAMP,
	repeat_interval    =>  'freq=minutely; interval=1',
	enabled            =>  TRUE,
	end_date           =>  NULL,
	comments           =>  'check flat for records marked as stale and update them');
END;
/






