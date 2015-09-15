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


CREATE OR REPLACE TRIGGER trg_taxon_name_nochangeused before update or delete ON taxon_NAME
    for each row 
      DECLARE 
        c INTEGER;
    begin     
	    select count(*) into c from identification_taxonomy where taxon_name_id=:OLD.taxon_name_id;
	     if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;
	    select count(*) into c from media_relations where media_relationship like '% taxonomy' and related_primary_key=:OLD.taxon_name_id;
	    if c > 0 then
	    	Raise_application_error(-20012,'Used names may not be altered.');
	    end if;                       
    end;                                                                                            
/
sho err


