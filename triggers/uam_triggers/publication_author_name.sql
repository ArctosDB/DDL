CREATE OR REPLACE TRIGGER SEQ_PUBLICATION_AUTHOR_NAME
BEFORE INSERT ON PUBLICATION_AUTHOR_NAME
FOR EACH ROW
BEGIN
    IF :NEW.publication_author_name_id IS NULL THEN
        SELECT sq_publication_author_name_id.nextval 
        INTO :new.publication_author_name_id 
        FROM dual;
    END IF;
END;
