CREATE OR REPLACE TRIGGER TRG_CTattribtue_type_UD
BEFORE UPDATE OR DELETE ON ctattribute_type
FOR EACH ROW
BEGIN
	if :NEW.attribute_type != :OLD.attribute_type then
	    FOR r IN (
	        SELECT COUNT(*) c
	        FROM attributes
	        WHERE attribute_type = :OLD.attribute_type
	    ) LOOP
	        IF r.c > 0 THEN
	             raise_application_error(
	                -20001,
	                :OLD.attribute_type || ' is used and cannot be changed or deleted');
	        END IF;
	    END LOOP;
	end if;
END;
