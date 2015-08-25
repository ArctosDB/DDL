/* release notes:

SpecimenSearch ajaxed up.
SpecimenSearch documentation coming from AK Documentation Server
SpecimenResults offers option to change preferences for sort order and rows/page
editIdentification has one submit button, no onchange handling, and is continuously checked for required values.
	Submission is not possible with missing required values.
editIdentification documentation coming from AK Documentation Server
browseBulk + SQL abilities (patched into v2.2.4)

*/

ALTER TABLE cf_users ADD specsrchprefs VARCHAR2(4000);
ALTER TABLE cf_users ADD fancyCOID NUMBER(1);

ALTER TABLE cf_users ADD result_sort varchar2(255);
-- speed up suggest, maybe
CREATE INDEX i_part_name ON ctspecimen_part_name(part_name);


-- see TABLES/identification_agent:
    
-- 4/7/08 DLM - needs the pkey
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