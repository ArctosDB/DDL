CREATE OR REPLACE TRIGGER trg_taxon_name_biu
BEFORE UPDATE OR INSERT ON taxon_name
FOR EACH ROW
BEGIN
    :new.scientific_name := trim(:new.scientific_name);
    IF :NEW.SCIENTIFIC_NAME=LOWER(:NEW.SCIENTIFIC_NAME) THEN
    	Raise_application_error(-20013,:NEW.SCIENTIFIC_NAME || ' does not look like a valid name; use the contact form if it is.');
    END IF;

END;
/