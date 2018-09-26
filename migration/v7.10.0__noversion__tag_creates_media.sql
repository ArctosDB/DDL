CREATE OR REPLACE TRIGGER tag_seq after insert or update ON tag for each row...

select count(*) from tag where collection_object_id is not null;

select
	MEDIA_ID,
	COLLECTION_OBJECT_ID
from
	tag
where
	collection_object_id is not null and
	media_id not in (
		select 
			media_id 
		from 
			media_relations
		where
			media_relationship='shows cataloged_item'
	);
	
insert into media_relations (
	MEDIA_RELATIONS_ID,
	MEDIA_ID,
	MEDIA_RELATIONSHIP,
	CREATED_BY_AGENT_ID,
	RELATED_PRIMARY_KEY
) (
	select
		sq_MEDIA_RELATIONS_ID.nextval,
		media_id,
		'shows cataloged_item',
		0,
		collection_object_id
	from
		tag
	where
		collection_object_id is not null and
		media_id not in (
			select 
				media_id 
			from 
				media_relations
			where
				media_relationship='shows cataloged_item'
		)
);


select count(*) from tag where COLLECTING_EVENT_ID is not null;

select
	MEDIA_ID,
	COLLECTING_EVENT_ID
from
	tag
where
	COLLECTING_EVENT_ID is not null and
	media_id not in (
		select 
			media_id 
		from 
			media_relations
		where
			media_relationship='created from collecting_event'
	);
	
select count(*) from tag where AGENT_ID is not null;

select
	MEDIA_ID,
	AGENT_ID
from
	tag
where
	AGENT_ID is not null and
	media_id not in (
		select 
			media_id 
		from 
			media_relations
		where
			media_relationship='shows agent'
	);
		
-- bah dups
begin
	for r in (select distinct
		MEDIA_ID,
		AGENT_ID
	from
		tag
	where
		AGENT_ID is not null and
		media_id not in (
			select 
				media_id 
			from 
				media_relations
			where
				media_relationship='shows agent'
		)) loop
		
			dbms_output.put_line(r.media_id);
			dbms_output.put_line(r.AGENT_ID);
			
			insert into media_relations (
				MEDIA_RELATIONS_ID,
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY
			) values (
				sq_MEDIA_RELATIONS_ID.nextval,
					r.media_id,
					'shows agent',
					0,
					r.AGENT_ID
				);
			
	 end loop;
	end;
	/
	
	
	
insert into media_relations (
	MEDIA_RELATIONS_ID,
	MEDIA_ID,
	MEDIA_RELATIONSHIP,
	CREATED_BY_AGENT_ID,
	RELATED_PRIMARY_KEY
) (
	select distinct
		sq_MEDIA_RELATIONS_ID.nextval,
		media_id,
		'shows agent',
		0,
		AGENT_ID
	from
		tag
	where
		AGENT_ID is not null and
		media_id not in (
			select 
				media_id 
			from 
				media_relations
			where
				media_relationship='shows agent'
		)
);




	UAM@ARCTOSTE> desc tag
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 TAG_ID 							   NOT NULL NUMBER
 							   NOT NULL NUMBER
 REMARK 								    VARCHAR2(4000)
 REFTOP 								    NUMBER
 REFLEFT								    NUMBER
 REFH									    NUMBER
 REFW									    NUMBER
 IMGH									    NUMBER
 IMGW									    NUMBER
 							    NUMBER
 COLLECTING_EVENT_ID							    NUMBER
 LOCALITY_ID								    NUMBER
 AGENT_ID								    NUMBER

UAM@ARCTOSTE> 

	if :NEW.COLLECTION_OBJECT_ID is not null then
			kval:=:NEW.COLLECTION_OBJECT_ID;
			mr:='shows cataloged_item';
		elsif :NEW.COLLECTING_EVENT_ID is not null then
			kval:=:NEW.COLLECTING_EVENT_ID;
			mr:='created from collecting_event';
		elsif :NEW.AGENT_ID is not null then
			kval:=:NEW.AGENT_ID;
			mr:='shows agent';
		else
			return;
		end if;
		
		select count(*) into c from media_relations where 
			media_relationship=mr and
			MEDIA_ID=:NEW.media_id and
			RELATED_PRIMARY_KEY = kval
		;
		if c=0 then
			-- create a relationship to make things searchable
			insert into media_relations (
				MEDIA_RELATIONS_ID,
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY
			) values (
				sq_MEDIA_RELATIONS_ID.nextval,
				:NEW.MEDIA_ID,
				mr,
				0,
				kval
			);
		end if;

