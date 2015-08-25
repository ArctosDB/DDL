CREATE OR REPLACE TRIGGER TR_PROJECT_SPONSOR_SQ 
BEFORE INSERT ON PROJECT_SPONSOR
FOR EACH ROW
BEGIN
    IF :NEW.project_sponsor_id IS NULL THEN
        SELECT sq_project_sponsor_id.nextval
        INTO :new.project_sponsor_id 
        FROM dual;
    END IF;
END;
