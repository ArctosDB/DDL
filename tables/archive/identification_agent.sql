ALTER TABLE identification_agent
add CONSTRAINT fk_identification_id
  FOREIGN KEY (identification_id)
  REFERENCES identification(identification_id);

ALTER TABLE identification_agent
add CONSTRAINT fk_id_agent_id
  FOREIGN KEY (agent_id)
  REFERENCES agent(agent_id);

create index id_agnt_agnt_id on identification_agent(agent_id);
create index id_agnt_ident_id on identification_agent(identification_id);
    
    
ALTER TABLE identification_agent ADD identification_agent_id NUMBER;
CREATE SEQUENCE identification_agent_seq;
 
alter trigger UP_FLAT_AGNT_ID disable;   

BEGIN
    FOR r IN (SELECT ROWID FROM identification_agent) LOOP
        UPDATE identification_agent SET identification_agent_id=identification_agent_seq.nextval WHERE ROWID=r.rowid;
    END LOOP;
END;
/
    
ALTER TABLE identification_agent
add CONSTRAINT pk_identification_agent
  PRIMARY KEY (identification_agent_id);
    

 
   
 CREATE OR REPLACE TRIGGER identification_agent_trg                                         
 before insert  ON identification_agent  
 for each row 
    begin     
    	if :NEW.identification_agent_id is null then                                                                                      
    		select identification_agent_seq.nextval into :new.identification_agent_id from dual;
    	end if;                       
    end;                                                                                            
/
sho err
      
alter trigger UP_FLAT_AGNT_ID ENABLE;