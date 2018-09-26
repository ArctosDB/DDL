CREATE OR REPLACE TRIGGER tag_seq after insert or update ON tag for each row
declare
	c number;
	kval number;
	mr varchar2(255);
   begin 
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
   end;                                                                                            
/
sho err