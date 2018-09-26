

drop table tag;
drop sequence sq_tag_id;


create table tag (
	tag_id number not null,
	media_id number not null,
	remark varchar2(4000),
	reftop number,
	refleft number,
	refh number,
	refw number,
	imgh number,
	imgw number,
	collection_object_id number,
	collecting_event_id number
);

CREATE SEQUENCE sq_tag_id;
create OR REPLACE public synonym sq_tag_id for sq_tag_id;
grant select on sq_tag_id to public;

create or replace public synonym tag for tag;

grant select on tag to public;

grant all on tag to manage_media;


CREATE OR REPLACE TRIGGER tag_seq before insert ON tag for each row
   begin     
       IF :new.tag_id IS NULL THEN
           select sq_tag_id.nextval into :new.tag_id from dual;
       END IF;
   end;                                                                                            
/
sho err

ALTER TABLE tag
    add CONSTRAINT pk_tag
    PRIMARY  KEY (tag_id);

ALTER TABLE tag
    add CONSTRAINT fk_tag_media
    FOREIGN KEY (media_id)
    REFERENCES media(media_id);
	
ALTER TABLE tag
    add CONSTRAINT fk_tag_specimen
    FOREIGN KEY (collection_object_id)
    REFERENCES cataloged_item(collection_object_id);
	
ALTER TABLE tag
    add CONSTRAINT fk_tag_event
    FOREIGN KEY (collecting_event_id)
    REFERENCES collecting_event(collecting_event_id);
	
ALTER TABLE tag ADD locality_id NUMBER;

ALTER TABLE tag
    add CONSTRAINT fk_tag_locality
    FOREIGN KEY (locality_id)
    REFERENCES locality(locality_id);
    
-- to add a new tag type.....
ALTER TABLE tag ADD agent_id NUMBER;

ALTER TABLE tag
    add CONSTRAINT fk_tag_agent
    FOREIGN KEY (agent_id)
    REFERENCES agent(agent_id);

/*
alter TAG.cfm, to add


		d+='<option';if (reftype=='agent'){d+=' selected="selected"';}
		d+=' value="agent">Agent</option>';
		
		and
		
		<option value="agent">Agent</option>
		
		and
		
		} else if (v=='agent') {
			getAgent('RefId_' + tagID,'RefStr_' + tagID,fname){

and in the CSS
	.refPane_agent {
        background-color:orange;
        padding:3px;
        border:1px solid black;
    }
    
 and functionLib.cfm
 
 and tag.cfc			
			

*/
-- end add tag type