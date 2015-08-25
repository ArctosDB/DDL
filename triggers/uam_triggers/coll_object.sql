CREATE OR REPLACE TRIGGER COLL_OBJECT_CT_CHECK
BEFORE UPDATE OR INSERT ON COLL_OBJECT
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
	SELECT COUNT(*) INTO numrows
	FROM ctcoll_obj_disp
	WHERE coll_obj_disposition = :NEW.coll_obj_disposition;
	
	IF (numrows = 0) THEN
        raise_application_error(
            -20001,
            'Invalid coll_obj_disposition: ' || :NEW.coll_obj_disposition);
    END IF;
        
    IF :NEW.lot_count < 0 OR :new.lot_count != round(:new.lot_count) THEN
         raise_application_error(
            -20001,
            'Lot Count must be a positive integer');
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_OBJECT_CONDITION_AIU_SQ
AFTER UPDATE OR INSERT ON COLL_OBJECT
FOR EACH ROW
DECLARE
    usrid NUMBER;
    cnt NUMBER;
BEGIN
    SELECT COUNT(*) INTO cnt
	FROM agent_name
	WHERE agent_name_type = 'login'
	AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
	
    IF cnt = 1 THEN
	    SELECT agent_id INTO usrid
		FROM agent_name
		WHERE agent_name_type = 'login'
		AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    ELSE
	    usrid:= 0;
    END IF;
        
    IF inserting THEN
	    INSERT INTO object_condition (
            OBJECT_CONDITION_ID,
            COLLECTION_OBJECT_ID,
            CONDITION,
            DETERMINED_AGENT_ID,
			DETERMINED_DATE)
        VALUES(
			sq_object_condition_id.nextval,
			:NEW.COLLECTION_OBJECT_ID,
			:NEW.CONDITION,
			usrid,
			SYSDATE);
    ELSIF updating THEN
        IF :new.condition != :old.condition THEN
            INSERT INTO object_condition (
                OBJECT_CONDITION_ID,
				COLLECTION_OBJECT_ID,
				CONDITION,
				DETERMINED_AGENT_ID,
				DETERMINED_DATE)
			VALUES(
				sq_object_condition_id.nextval,
				:NEW.COLLECTION_OBJECT_ID,
				:NEW.CONDITION,
				usrid,
				SYSDATE);
        END IF;
    END IF;
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        NULL;
END;

CREATE OR REPLACE TRIGGER TR_COLLOBJECT_AIU_FLAT
AFTER INSERT OR UPDATE ON COLL_OBJECT
FOR EACH ROW
BEGIN
    FOR i IN 1 .. state_pkg.newRows.count
    LOOP
        UPDATE flat SET 
            stale_flag = 1,
            lastuser = sys_context('USERENV', 'SESSION_USER'),
            lastdate = SYSDATE
    	WHERE collection_object_id = :NEW.collection_object_id;
    END LOOP;
END;
