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
        	:new.specimen_event_type:='accepted place of collection';
        end if;
        status:=is_iso8601(:NEW.verified_date);
    	IF status != 'valid' THEN
        	raise_application_error(-20001,'Verified Date: ' || status);
    	END IF;
    end;
/



insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('collection','Specimen was collected. For biological specimens, the specimen was killed or found dead at the event.');

update CTSPECIMEN_EVENT_TYPE set 
	DESCRIPTION='Specimen was encountered alive and not killed. Samples or recordings may have been taken; see parts and media for more information.' 
	where SPECIMEN_EVENT_TYPE='encounter';


insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('','Specimen was encountered alive and not killed. Samples or recordings may have been taken; see parts and media for more information.');

insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('manufacture','Specimen was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.');

insert into CTSPECIMEN_EVENT_TYPE (SPECIMEN_EVENT_TYPE,DESCRIPTION) values 
	('use','Specimen was used. Generally refers to human use of cultural items.');
	
	

	
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




update specimen_event set verificationstatus='unaccepted' where specimen_event_type='unaccepted place of collection';
update specimen_event set verificationstatus='unaccepted' where specimen_event_type='unaccepted place of collection';

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
Migration Path: “Accepted place of collection” plus “unaccepted place of collection” merge here.
“unaccepted place of collection” will first change verificationstatus to “unaccepted.”

encounter
Definition: Specimen was encountered alive and not killed. Samples or recordings may have been taken; see parts and media for more information.
Migration Path: “Encounter” and “observation” merge here.

manufacture
Definition: Specimen was manufactured. Generally refers to human manufacture of cultural items, but could be extended to e.g., nests.
Migration Path: Vocabulary change only, from “place of manufacture.”

use
Definition: Specimen was used. Generally refers to human use of cultural items.
Migration Path: Vocabulary change only, from “place of use.”


Proposed vocabulary for verification status:

(Currently: http://arctos.database.museum/info/ctDocumentation.cfm?table=CTVERIFICATIONSTATUS)

unverified
Definition: No assertion regarding the accuracy of the place and time information is made.
Migration Path: No changes.

unaccepted
Definition: The place and time information as entered was reviewed and determined to be incorrect, or less correct or complete than other available data.
Migration Path: New concept, will be assigned to all specimen events which are currently of type “unaccepted place of collection.”

accepted
Definition: The place and time information as entered was checked and determined to be correct against the information available from Arctos; original data were not consulted, and transcription or omission errors are possible.
Migration Path: “Checked by curator” and “checked by collector” merge here. See “new fields” below.

verified and locked
Definition: The place and time information as entered was checked against all available data, including labels, fieldnotes, collector itineraries, and associated digital data, and determined to be correct. Changes should only be made in the extremely unlikely event of more authoritative data surfacing. This value LOCKS linked Locality and Event data.
Migration Path: “Verified by curator” and “verified by collector” merge here. See “new fields” below.







