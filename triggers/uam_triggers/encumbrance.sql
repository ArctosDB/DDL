CREATE OR REPLACE TRIGGER tr_encumbrance_expire
BEFORE UPDATE OR INSERT ON encumbrance
FOR EACH ROW
BEGIN
    IF (:new.EXPIRATION_DATE IS NULL AND :new.EXPIRATION_EVENT IS NULL) OR
       (:new.EXPIRATION_DATE IS NOT NULL AND :new.EXPIRATION_EVENT IS NOT NULL) THEN
        raise_application_error(
            -20001,
            'Encumbrances must have either an expiration event or an expiration date, but may not have both.');
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_ENCUMBRANCE_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON encumbrance
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting
        THEN id := :OLD.encumbrance_id;
        ELSE id := :NEW.encumbrance_id;
    END IF;

    UPDATE flat
    SET stale_flag = 1,
    lastuser = sys_context('USERENV', 'SESSION_USER'),
    lastdate = SYSDATE
    WHERE collection_object_id in (select collection_object_id from coll_object_encumbrance where encumbrance_id = id);
END;

