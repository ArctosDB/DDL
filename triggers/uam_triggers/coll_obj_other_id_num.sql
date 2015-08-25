CREATE OR REPLACE TRIGGER TR_COLL_OBJ_OTHER_ID_NUM_SQ
BEFORE INSERT ON COLL_OBJ_OTHER_ID_NUM
FOR EACH ROW
BEGIN
    IF :NEW.COLL_OBJ_OTHER_ID_NUM_ID IS NULL THEN
    	SELECT SQ_COLL_OBJ_OTHER_ID_NUM_ID.NEXTVAL
		INTO :NEW.COLL_OBJ_OTHER_ID_NUM_ID
    	FROM dual;
    END IF;
END;

CREATE OR REPLACE TRIGGER COLL_OBJ_DISP_VAL
BEFORE INSERT or UPDATE ON COLL_OBJ_OTHER_ID_NUm
FOR EACH ROW
BEGIN
    :NEW.display_value := 
        :NEW.OTHER_ID_PREFIX || 
        :NEW.OTHER_ID_NUMBER || 
        :NEW.OTHER_ID_SUFFIX;
    if :new.ID_REFERENCES is null then
    	:new.ID_REFERENCES:='self';
    end if;
END;

CREATE OR REPLACE TRIGGER COLL_OBJ_DATA_CHECK
BEFORE INSERT OR UPDATE ON COLL_OBJ_OTHER_ID_NUM
FOR EACH ROW
BEGIN
    if :new.other_id_type = 'AF' then
    	IF :NEW.OTHER_ID_PREFIX IS NOT NULL OR :NEW.OTHER_ID_SUFFIX IS NOT NULL THEN
            raise_application_error(
                -20000,
                'AF must be numeric!');
        end if;
    end if;
        
    if :new.other_id_type = 'NK' then
    	IF :NEW.OTHER_ID_PREFIX IS NOT NULL OR :NEW.OTHER_ID_SUFFIX IS NOT NULL THEN
            raise_application_error(
                -20000,'
                NK must be numeric!');
        end if;
    end if;
END;

-- dropped, replaced with keys
CREATE OR REPLACE TRIGGER OTHER_ID_CT_CHECK
BEFORE INSERT OR UPDATE ON COLL_OBJ_OTHER_ID_NUM
REFERENCING OLD AS OLD NEW AS NEW
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
    SELECT COUNT(*) INTO numrows
	FROM ctcoll_other_id_type
	WHERE other_id_type = :NEW.other_id_type ;
	
    IF (numrows = 0) THEN
        raise_application_error(
            -20001,
			'Invalid other ID type (' || :NEW.other_id_type || ').');
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_COLLOBJOIDNUM_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON COLL_OBJ_OTHER_ID_NUM
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.collection_object_id;
    ELSE 
        id := :NEW.collection_object_id;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
		lastdate = SYSDATE
    WHERE collection_object_id = id;
END;
