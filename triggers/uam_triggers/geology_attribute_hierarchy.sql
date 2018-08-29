CREATE OR REPLACE TRIGGER TR_GEOL_ATTR_HIER_SQ
BEFORE INSERT ON GEOLOGY_ATTRIBUTE_HIERARCHY
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_hierarchy_id IS NULL THEN
    	SELECT sq_geology_attribute_hier_id.nextval
		INTO :new.geology_attribute_hierarchy_id
		FROM dual;
    END IF;
END;



CREATE OR REPLACE TRIGGER CTGEOLOGY_ATTRIBUTES_CHECK
	BEFORE UPDATE OR DELETE ON GEOLOGY_ATTRIBUTE_HIERARCHY
	FOR EACH ROW
	DECLARE
    	numrows number := 0;
	BEGIN
		-- is this used?
		SELECT COUNT(*) INTO numrows 
                FROM geology_attributes 
                WHERE geology_attribute = :OLD.attribute and
                GEO_ATT_VALUE = :OLD.ATTRIBUTE_VALUE;
	
		-- do not allow changing used values
		
		dbms_output.put_line(numrows);
		IF numrows > 0 THEN
			-- the attribute is used
			-- but allow changes to parentage and documentation
			if :OLD.ATTRIBUTE=:NEW.ATTRIBUTE and :OLD.ATTRIBUTE_VALUE=:NEW.ATTRIBUTE_VALUE and :NEW.USABLE_VALUE_FG=1 then
				dbms_output.put_line('rock on....');
			else
	            raise_application_error(
	                -20001,
	                'Cannot update or delete used geology_attribute.');
	        END IF;
	   end if;
	END;
/


