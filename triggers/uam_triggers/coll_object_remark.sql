CREATE OR REPLACE TRIGGER TR_COLLOBJREM_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON COLL_OBJECT_REMARK
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
