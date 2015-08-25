CREATE OR REPLACE TRIGGER TR_CTJOURNAL_NAME_UD
BEFORE UPDATE OR DELETE ON ctjournal_name
FOR EACH ROW
BEGIN
    FOR r IN (
        SELECT COUNT(*) c
        FROM publication_attributes
        WHERE publication_attribute = 'journal name'
        AND pub_att_value = :old.journal_name
    ) LOOP
        IF r.c > 0 THEN
             raise_application_error(
                -20001,
                :OLD.journal_name || ' is used.');
        END IF;
    END LOOP;
END;
