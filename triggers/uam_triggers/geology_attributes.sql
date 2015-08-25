CREATE OR REPLACE TRIGGER SQ_GEOLOGY_ATTRIBUTES_SQ
BEFORE INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_id IS NULL THEN
    	SELECT sq_geology_attribute_id.nextval
    	INTO :new.geology_attribute_id
		FROM dual;
    END IF;
END;

CREATE OR REPLACE TRIGGER GEOLOGY_ATTRIBUTES_CHECK
BEFORE UPDATE OR INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
    SELECT COUNT(*) INTO numrows 
    FROM geology_attribute_hierarchy 
    WHERE attribute = :NEW.geology_attribute;
    
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
		    'Invalid geology_attribute');
	END IF;
END;