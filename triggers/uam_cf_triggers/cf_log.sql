CREATE OR REPLACE TRIGGER TR_CF_LOG_SQ
BEFORE INSERT ON cf_log
FOR EACH ROW
BEGIN
    IF :NEW.log_id IS NULL THEN
        SELECT sq_log_id.nextval
        INTO :NEW.log_id
        FROM dual;
    END IF;

    IF :NEW.access_date IS NULL THEN
        :NEW.access_date:= sysdate;
    END IF;
END;
