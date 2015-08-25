CREATE OR REPLACE TRIGGER CF_TEMP_CONT_EDIT_KEY
BEFORE INSERT ON cf_temp_cont_edit
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;
END;
