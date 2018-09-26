
CREATE OR REPLACE TRIGGER project_agent_key                                         
 before insert  ON project_agent
 for each row 
    begin     
    	if :NEW.project_agent_id is null then                                                                                      
    		select sq_project_agent_id.nextval into :new.project_agent_id from dual;
    	end if;                                
    end;                                                                                            
/
sho err


CREATE OR REPLACE TRIGGER trg_project_agent_biu                                         
 before insert or update  ON project_agent
 for each row 
    begin     
    	if :NEW.award_number is not null and :NEW.PROJECT_AGENT_ROLE != 'Sponsor' then  
        	raise_application_error(-20001,'Award Number may only be associated with role Sponsor.');
    	end if;                                
    end;                                                                                            
/
sho err

