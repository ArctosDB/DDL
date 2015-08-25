
CREATE TABLE agent_rank (
    agent_rank_id NUMBER NOT NULL,
    agent_id NUMBER NOT NULL,
    agent_rank NUMBER NOT NULL,
    ranked_by_agent_id NUMBER NOT NULL,
    remark VARCHAR2(255)
   );

CREATE OR REPLACE PUBLIC SYNONYM agent_rank FOR agent_rank;
    
ALTER TABLE agent_rank MODIFY agent_rank VARCHAR2(50);

ALTER TABLE agent_rank ADD transaction_type VARCHAR2(18) NOT NULL;

ALTER TABLE agent_rank ADD rank_date DATE DEFAULT SYSDATE;

UPDATE agent_rank SET rank_date=SYSDATE;

ALTER TABLE agent_rank MODIFY rank_date NOT NULL;


ALTER TABLE agent_rank
add CONSTRAINT fk_ar_transtype
FOREIGN KEY (transaction_type)
REFERENCES cttransaction_type(transaction_type);   
    
CREATE SEQUENCE sq_agent_rank_id;


CREATE OR REPLACE TRIGGER trg_bef_agent_rank                                         
 before insert OR UPDATE ON agent_rank
 for each row 
    begin     
    	if :NEW.agent_rank_id is null then                                                                                      
    		select sq_agent_rank_id.nextval into :new.agent_rank_id from dual;
    	end if;
    	IF :new.agent_rank = 'unsatisfactory' AND length(:NEW.remark) < 20 THEN
    	    raise_application_error(
                -20001,
                'You must leave a >20 character comment for unsatisfactory rankings.'
              );
    	END IF;
    end;                                                                                            
/
sho err

GRANT ALL ON agent_rank TO manage_transactions;

CREATE TABLE ctagent_rank (agent_rank VARCHAR2(50),description VARCHAR2(4000));
INSERT INTO ctagent_rank (agent_rank,description) VALUES ('satisfactory','Everything went well; could not ask for more.');
INSERT INTO ctagent_rank (agent_rank,description) VALUES ('neutral','We made it through together with some coaxing.');
INSERT INTO ctagent_rank (agent_rank,description) VALUES ('unsatisfactory','There were difficulties caused by the agent.');

ALTER TABLE ctagent_rank ADD constraint pk_agent_rank PRIMARY KEY (agent_rank);


CREATE OR REPLACE PUBLIC SYNONYM ctagent_rank FOR ctagent_rank;
GRANT ALL ON ctagent_rank TO manage_codetables;
GRANT SELECT ON agent_rank TO manage_transactions;

ALTER TABLE agent_rank
add CONSTRAINT fk_ctagent_rank
FOREIGN KEY (agent_rank)
REFERENCES ctagent_rank(agent_rank);

ALTER TABLE agent_rank
add CONSTRAINT fk_ar_agent_id
FOREIGN KEY (agent_id)
REFERENCES agent(agent_id);

ALTER TABLE agent_rank
add CONSTRAINT fk_ar_ranker_agent_id
FOREIGN KEY (ranked_by_agent_id)
REFERENCES agent(agent_id);  