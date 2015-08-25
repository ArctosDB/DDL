CREATE OR REPLACE TRIGGER TR_CF_REPORT_SQL_SQ
BEFORE INSERT ON cf_report_sql
FOR EACH ROW
BEGIN
    IF :NEW.report_id IS NULL THEN
        SELECT sq_report_id.nextval
        INTO :NEW.report_id
        FROM dual;
    END IF;
END;
