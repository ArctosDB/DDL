CREATE OR REPLACE TRIGGER CF_PW_CHANGE
BEFORE update OR INSERT ON cf_users
FOR EACH ROW
BEGIN
    IF :NEW.password != :old.password THEN
        :NEW.pw_change_date := SYSDATE;
    END IF;
END;
