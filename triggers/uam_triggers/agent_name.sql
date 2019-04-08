
CREATE OR REPLACE TRIGGER trg_agent_name_biu
     BEFORE update or insert ON agent_name
 FOR EACH ROW 
     BEGIN
     IF :NEW.AGENT_NAME != trim(:NEW.AGENT_NAME) or :NEW.AGENT_NAME like '%  %' THEN
     	RAISE_APPLICATION_ERROR(-20001,'Extraneous spaces detected.');
     END IF;
     if instr(:new.agent_name,'¿') > 0 then
     	RAISE_APPLICATION_ERROR(-20001,'¿ is not allowed in agent names.');
     end if;
     if :NEW.agent_name_type in ('first name','last name') then
     	if regexp_instr(:new.agent_name,'[\(\)\?]') > 0 then
      		RAISE_APPLICATION_ERROR(-20001,'(, ), and ? are not allowd in first or last names.');
      	end if;
      	if :NEW.agent_name_type = 'last name' and (:new.agent_name=upper(:new.agent_name)) or (:new.agent_name=lower(:new.agent_name)) then
      		RAISE_APPLICATION_ERROR(-20001,'Last name cannot be all upper or lower case.');
      	end if;
      	      	
      	if :NEW.agent_name_type = 'first name' and
      		( not regexp_like(:new.agent_name,'^[A-Z]\.$') ) and
      		( :new.agent_name=upper(:new.agent_name)) or (:new.agent_name=lower(:new.agent_name) ) then
      			RAISE_APPLICATION_ERROR(-20001,'First name cannot be all upper or lower case.');
      	end if;
   end if;   		
 END;
 /
 
 

CREATE OR REPLACE TRIGGER PRE_UP_INS_AGENT_NAME 
BEFORE INSERT ON AGENT_NAME
FOR EACH ROW
-- DLM 1 Mar 2006
-- require ONE preferred agent name
BEGIN
	-- clear out the staging table
	DELETE FROM agent_name_pending_delete;
	
	-- grab the info already in there
	INSERT INTO AGENT_NAME_PENDING_DELETE
	SELECT
		AGENT_NAME_ID,
	 	AGENT_ID,
	 	AGENT_NAME_TYPE,
	 	AGENT_NAME
	 FROM AGENT_NAME
	 WHERE AGENT_ID = :NEW.AGENT_ID;
	 	
	 -- and the new one
	 INSERT INTO AGENT_NAME_PENDING_DELETE (
		AGENT_NAME_ID,
	 	AGENT_ID,
	 	AGENT_NAME_TYPE,
	 	AGENT_NAME)
	 VALUES (
		:NEW.AGENT_NAME_ID,
		:NEW.AGENT_ID,
		:NEW.AGENT_NAME_TYPE,
		:NEW.AGENT_NAME);
END;


CREATE OR REPLACE TRIGGER UP_INS_AGENT_NAME 
AFTER INSERT OR UPDATE ON AGENT_NAME
FOR EACH ROW
-- now that we have the data they're updating in the temp table,
DECLARE numrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO numrows
	FROM AGENT_NAME_PENDING_DELETE
	WHERE AGENT_NAME_TYPE = 'preferred' ;
	
    IF (numrows > 1) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'You may have only one preferred agent name.');
    END IF;
END;


CREATE OR REPLACE TRIGGER TR_AGENTNAME_AIU_FLAT
AFTER INSERT OR UPDATE ON AGENT_NAME
FOR EACH ROW
BEGIN
    IF :NEW.AGENT_NAME_TYPE = 'preferred' THEN
        FOR r IN (
            SELECT COLLECTION_OBJECT_ID
            FROM COLLECTOR
            WHERE AGENT_ID = :NEW.AGENT_ID
        ) LOOP
            UPDATE FLAT SET 
                STALE_FLAG = 1,
                LASTUSER = SYS_CONTEXT('USERENV', 'SESSION_USER'),
                LASTDATE = SYSDATE
            WHERE COLLECTION_OBJECT_ID = r.COLLECTION_OBJECT_ID;
        END LOOP;
    END IF;
END;


CREATE OR REPLACE TRIGGER PRE_DEL_AGENT_NAME 
BEFORE UPDATE OR DELETE ON AGENT_NAME
FOR EACH ROW
-- DLM 1 Mar 2006
-- require preferred agent name
DECLARE numrows INTEGER;
BEGIN
	-- clear out the staging table
	DELETE FROM AGENT_NAME_PENDING_DELETE;
	
	-- grab the info they're trying to modify
	INSERT INTO AGENT_NAME_PENDING_DELETE (
		AGENT_NAME_ID,
	 	AGENT_ID,
	 	AGENT_NAME_TYPE,
	 	AGENT_NAME
	) VALUES (
		:OLD.AGENT_NAME_ID,
		:OLD.AGENT_ID,
		:OLD.AGENT_NAME_TYPE,
		:OLD.AGENT_NAME);
END;

-- 09/25/2009: added to prod. lkv.
-- prevents agent names from being updated if they are used
-- in a publication or project.
CREATE OR REPLACE TRIGGER TR_AGENT_NAME_BU
BEFORE UPDATE ON AGENT_NAME
FOR EACH ROW
DECLARE numrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO numrows
	FROM PUBLICATION_AUTHOR_NAME
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a publication author.');
    end if;
    
    SELECT COUNT(*) INTO numrows
	FROM PROJECT_AGENT
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a project agent.');
    end if;
	
    SELECT COUNT(*) INTO numrows
	FROM PROJECT_SPONSOR
	WHERE AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot UPDATE an agent name used as a project sponsor.');
    end if;
END;
/

CREATE OR REPLACE TRIGGER DEL_AGENT_NAME
AFTER DELETE ON AGENT_NAME
FOR EACH ROW
-- DLM 1 Mar 2006
-- require preferred agent name
DECLARE numrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO numrows
	FROM AGENT_NAME_PENDING_DELETE
	WHERE AGENT_NAME_TYPE = 'preferred'
	AND AGENT_NAME_ID = :OLD.AGENT_NAME_ID;
	
    IF (numrows > 0) THEN
        RAISE_APPLICATION_ERROR(
    	-20001,
		'Cannot DELETE preferred agent name.');
    END IF;
END;

