CREATE OR REPLACE TRIGGER tag_seq after insert or update ON tag for each row...

select count(*) from tag where collection_object_id is not null;


begin
	for r in (select distinct
		MEDIA_ID,
		COLLECTION_OBJECT_ID
	from
		tag
	where
		COLLECTION_OBJECT_ID is not null and
		media_id not in (
			select 
				media_id 
			from 
				media_relations
			where
				media_relationship='shows cataloged_item'
		)) loop
		
			dbms_output.put_line(r.media_id);
			dbms_output.put_line(r.COLLECTION_OBJECT_ID);
			
			insert into media_relations (
				MEDIA_RELATIONS_ID,
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY
			) values (
				sq_MEDIA_RELATIONS_ID.nextval,
					r.media_id,
					'shows cataloged_item',
					0,
					r.COLLECTION_OBJECT_ID
				);
			
	 end loop;
	end;
	/
	
	
	
begin
	for r in (select distinct
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
		)) loop
		
			dbms_output.put_line(r.media_id);
			dbms_output.put_line(r.COLLECTING_EVENT_ID);
			
			insert into media_relations (
				MEDIA_RELATIONS_ID,
				MEDIA_ID,
				MEDIA_RELATIONSHIP,
				CREATED_BY_AGENT_ID,
				RELATED_PRIMARY_KEY
			) values (
				sq_MEDIA_RELATIONS_ID.nextval,
					r.media_id,
					'created from collecting_event',
					0,
					r.COLLECTING_EVENT_ID
				);
			
	 end loop;
	end;
	/
	
	
	
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
	
	
	
