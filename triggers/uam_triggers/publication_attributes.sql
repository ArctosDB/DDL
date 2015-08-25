CREATE OR REPLACE TRIGGER PUBLICATION_ATTRIBUTES_KEY
BEFORE INSERT ON PUBLICATION_ATTRIBUTES
FOR EACH ROW
BEGIN
    IF :NEW.publication_attribute_id IS NULL THEN
        SELECT sq_publication_attribute_id.nextval 
        INTO :new.publication_attribute_id 
        FROM dual;
    END IF;
END;

CREATE OR REPLACE TRIGGER CHCHK_PUBLICATION_ATTRIBUTES
BEFORE UPDATE OR INSERT ON PUBLICATION_ATTRIBUTES
FOR EACH ROW
DECLARE numrows number;
BEGIN
    IF :NEW.publication_attribute = 'journal name' THEN
        SELECT COUNT(*) INTO numrows
        FROM ctjournal_name 
        WHERE journal_name = :NEW.pub_att_value;
        
        IF (numrows = 0) THEN
            raise_application_error(
                -20001,
                'Invalid journal_name ' || :NEW.pub_att_value);
        END IF;
    END IF;
END;
