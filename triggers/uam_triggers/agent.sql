
CREATE OR REPLACE TRIGGER trg_agent_biu
     BEFORE update or insert ON agent
 FOR EACH ROW 
     BEGIN
     IF :NEW.preferred_agent_name != trim(:NEW.preferred_agent_name)  or :NEW.preferred_agent_name like '%  %' THEN
           RAISE_APPLICATION_ERROR(-20001,'Extraneous spaces detected.');
      END IF;
     IF :NEW.agent_type='person' and 
     	:NEW.preferred_agent_name like '%,%' and
     	:NEW.preferred_agent_name not like '% III' and
		:NEW.preferred_agent_name not like '% Sr.' and
		:NEW.preferred_agent_name not like '% II' and
		:NEW.preferred_agent_name not like '% Jr.' and
		:NEW.preferred_agent_name not like '% PhD' and
		:NEW.preferred_agent_name not like '% IV' and
		:NEW.preferred_agent_name not like '% MD' then
		 RAISE_APPLICATION_ERROR(-20001,'Format "Last, First" is disallowed for persons. Preferred name of persons may only contain commas when it ends with ", Jr.", ", Sr.", ", II", ", III", ", IV", ", PhD", or ", MD".');
	end if;
	if regexp_like(:NEW.preferred_agent_name,'[A-Z]\.[^ ]') then
		RAISE_APPLICATION_ERROR(-20001,'Periods must be followed by spaces in preferred name.');
	end if;
	IF :NEW.agent_type='person' and regexp_like(:NEW.preferred_agent_name,'[A-Z][ ]') then
		RAISE_APPLICATION_ERROR(-20001,'Person agents may not have a space after uppercase letters in preferred name.');
	end if;
	
 END;
 /
         
/* 
 
         -- SQL to find SR Guy
         -- haven't quite figured out how to trigerify this yet
                 
select preferred_agent_name from agent where 
agent_type='person' and 
preferred_agent_name not like '% III' and
preferred_agent_name not like '% Sr.' and
preferred_agent_name not like '% II' and
preferred_agent_name not like '% Jr.' and
preferred_agent_name not like '% PhD' and
preferred_agent_name not like '% IV' and
preferred_agent_name not like '% MD' and
		regexp_like(preferred_agent_name,'[A-Z]{2}');
         
   
*/
 
CREATE OR REPLACE TRIGGER trg_agent_aiu
    after update or insert ON agent
    FOR EACH ROW 
    declare
    	c number;
    BEGIN
        -- maintain preferred name in agent names to simplify searching
		delete from agent_name where agent_name_type='preferred' and agent_id=:NEW.agent_id;
	   	insert into agent_name (AGENT_NAME_ID,AGENT_ID,AGENT_NAME_TYPE,AGENT_NAME) values (sq_agent_name_id.nextval,:NEW.agent_id,'preferred',:NEW.preferred_agent_name);
	end;
/
         
         
         
         
         
CREATE OR REPLACE TRIGGER TR_AGENT_AIU_FLAT
AFTER UPDATE ON agent
FOR EACH ROW
BEGIN
	IF :NEW.preferred_agent_name  != :OLD.preferred_agent_name THEN
    	 UPDATE flat
    	    SET stale_flag = 1,
        	lastuser=sys_context('USERENV', 'SESSION_USER'),
        	lastdate=SYSDATE
    	    WHERE collection_object_id in (
    	    	SELECT collection_object_id 
            	FROM collector 
            	WHERE agent_id = :NEW.agent_id
        	)
        ;
	END IF;
END;
/



 

CREATE OR REPLACE TRIGGER trg_agent_bi
    BEFORE INSERT ON agent
    FOR EACH ROW  
    BEGIN
	    :new.created_date := sysdate;
        select agent_id into :new.created_by_agent_id from agent_name where agent_name_type='login' and upper(agent_name)=sys_context('USERENV', 'SESSION_USER');
    end;
/

CREATE OR REPLACE TRIGGER trg_agent_bu
    BEFORE update ON agent
    FOR EACH ROW 
    declare
    	c number;
    BEGIN
	    if :new.agent_type != :old.agent_type then
		    --- disallow orphaning group members
			if :new.agent_type != 'group' and :old.agent_type='group' then
				select count(*) into c from group_member where GROUP_AGENT_ID=:new.agent_id;
				if c > 0 then
					raise_application_error(-20001,'You cannot change this agent to a non-group while there are group members.');
				end if;
			end if;
			if :new.agent_type != 'person' then
				select count(*) into c from agent_name where agent_id=:new.agent_id and agent_name_type in ('first name','middle name','last name');
				if c > 0 then
					raise_application_error(-20001,'Non-person agents cannot have first name, middle name, or last name');
				end if;
			end if;
		end if;
    end;
/




