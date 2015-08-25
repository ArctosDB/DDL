/*
	--------------- 2014-11 changes --------------------
	keep who and when
	disallow 'bad dup' when ANY existing relationship
	
	alter table agent_relations add created_by_agent_id number;
	alter table agent_relations add created_on_date date;
	
	
	lock table agent_relations in exclusive mode nowait;
	
	
	update agent_relations set created_by_agent_id=0;
	update agent_relations set created_on_date=sysdate;

	alter table agent_relations modify created_by_agent_id not null;
	alter table agent_relations modify created_on_date not null;
	
	ALTER TABLE agent_relations add CONSTRAINT fk_agnt_rel_agnt FOREIGN KEY (created_by_agent_id) REFERENCES agent (agent_id);
	
	
	
	
	
	
	if inserting or updating
	IF A bdo B then
		A * * disallowed
		
	if 
	

*/

drop trigger trg_agent_relations_biu;

CREATE OR REPLACE TRIGGER trg_agent_relations_biu
BEFORE INSERT OR UPDATE ON agent_relations
FOR EACH ROW
    DECLARE
        c NUMBER;
        aid number;
        fire number;
   		PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
	  	fire:=0;
		if inserting then
			fire:=1;
		elsif updating then
			--if this is a changeless update, do nothing
			  if :old.agent_id != :new.agent_id or :old.related_agent_id != :new.related_agent_id or :old.agent_relationship != :new.agent_relationship then
			  	fire:=1;
			  end if;
		end if;
		if fire=1 then
			:NEW.created_on_date := sysdate;
			select 
				agent_id into :NEW.created_by_agent_id from
				agent_name where agent_name_type='login' and upper(agent_name)=sys_context('USERENV', 'SESSION_USER');
		
				
				
		
			IF :new.AGENT_RELATIONSHIP = 'bad duplicate of' THEN
				-- if NEW is "A bad dup of B" then
					-- there can be no other relationships to A
					-- A can be in no relationships other than this one
					
			    -- disallow the bad agent to have relationships TO other agents
				SELECT COUNT(*) INTO c FROM agent_relations WHERE agent_id=:NEW.agent_id;
			    IF c>0 THEN
		            RAISE_APPLICATION_ERROR(-20001,'"bad duplicate of" agents cannot be in other relationships. Delete all relationships to or from this agent and save before proceeding.');
			    END IF;
			    
			    
			    
			else
				-- disallow any other relationships to bad dups
				SELECT COUNT(*) INTO c FROM agent_relations WHERE agent_relationship='bad duplicate of' and (
					agent_id=:NEW.agent_id 
				);
				 IF c>0 THEN
		            RAISE_APPLICATION_ERROR(-20001,'"bad duplicate of" agents cannot be in other relationships[1]. Delete all "bad duplicate of" relationships to or from this agent and save before proceeding.');
			    END IF;
			    
			end if;
		end if;
	
END;
/
sho err;
	   
	   
CREATE OR REPLACE TRIGGER trg_agent_relations_ad
AFTER DELETE ON agent_relations
FOR EACH ROW
BEGIN
	IF :OLD.AGENT_RELATIONSHIP = 'bad duplicate of' THEN
	    DELETE FROM cf_dup_agent WHERE AGENT_ID=:old.AGENT_ID AND RELATED_AGENT_ID=:old.RELATED_AGENT_ID;
	END IF;
END;
/
sho err;
	   	   

	   
	   