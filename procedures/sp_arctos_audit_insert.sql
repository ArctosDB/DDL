CREATE OR REPLACE PROCEDURE sp_arctos_audit_insert
IS
    max_date    DATE;
BEGIN
    SELECT max(timestamp)
    INTO max_date
    FROM arctos_audit;
    
    INSERT INTO arctos_audit
    SELECT * FROM arctos_audit_vw
    WHERE TIMESTAMP > max_date;
EXCEPTION
WHEN OTHERS THEN
      raise_application_error(
          -20001,
          'An error was encountered ('|| SQLCODE || ': ' || SQLERRM);
END;
/