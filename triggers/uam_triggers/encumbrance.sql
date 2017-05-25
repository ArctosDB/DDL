
CREATE OR REPLACE TRIGGER tr_encumbrance_biu
BEFORE UPDATE OR INSERT ON encumbrance
FOR EACH ROW
BEGIN
    IF :new.EXPIRATION_DATE > add_months(sysdate,60) THEN
        raise_application_error(
            -20001,
            'EXPIRATION_DATE may be no more more than 5 years in the future.');
    END IF;
END;
/


CREATE OR REPLACE TRIGGER TR_ENCUMBRANCE_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON encumbrance
FOR EACH ROW
DECLARE id NUMBER;
BEGIN

    IF deleting
        THEN id := :OLD.encumbrance_id;
        ELSE id := :NEW.encumbrance_id;
    END IF;
	
    -- no need to fire if we're just changing remarks etc.
    if :NEW.EXPIRATION_DATE != :OLD.EXPIRATION_DATE or :NEW.ENCUMBRANCE_ACTION != :OLD.ENCUMBRANCE_ACTION then
	    UPDATE flat
	    SET stale_flag = 1,
	    lastuser = sys_context('USERENV', 'SESSION_USER'),
	    lastdate = SYSDATE
	    WHERE collection_object_id in (select collection_object_id from coll_object_encumbrance where encumbrance_id = id);
	end if;
END;
