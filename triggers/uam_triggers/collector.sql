CREATE OR REPLACE TRIGGER TR_COLLECTOR_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON COLLECTOR
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

CREATE OR REPLACE TRIGGER tr_collector_sq
BEFORE INSERT ON collector
FOR EACH ROW
BEGIN
    IF :new.collector_id IS NULL THEN
        SELECT sq_collector_id.nextval
        INTO :new.collector_id
        FROM dual;
    END IF;
END;

