--CREATE OR REPLACE TRIGGER cf_temp_id_key
CREATE OR REPLACE TRIGGER tr_cf_temp_id_key_sq
BEFORE INSERT ON cf_temp_id
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval INTO :new.key FROM DUAL;
    END IF;
END;
