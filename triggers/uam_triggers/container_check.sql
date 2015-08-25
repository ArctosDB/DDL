CREATE OR REPLACE TRIGGER TR_CONTAINER_CHECK_BI_SQ
BEFORE INSERT ON CONTAINER_CHECK
FOR EACH ROW
BEGIN
    IF :NEW.container_check_id IS NULL THEN
        SELECT sq_container_check_id.nextval
        INTO :new.container_check_id
        FROM dual;
    END IF;
        
    IF :NEW.check_date IS NULL THEN
        :NEW.check_date:= sysdate;
    END IF;
END;
