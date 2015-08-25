CREATE OR REPLACE TRIGGER CF_FORM_PERMISSIONS_KEY
BEFORE UPDATE OR INSERT ON cf_form_permissions
FOR EACH ROW
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;
END;
