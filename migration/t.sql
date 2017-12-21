
CREATE OR REPLACE TRIGGER TR_SP_ATTRIBUTES_CT_BUI
BEFORE UPDATE OR INSERT ON specimen_part_attribute
FOR EACH ROW
DECLARE
    numrows NUMBER := 0;
	collectionCode collection.collection_cde%TYPE;
	sqlString VARCHAR2(4000);
	vct VARCHAR2(255);
	uct VARCHAR2(255);
	ctctColname VARCHAR2(255);
	ctctCollCde NUMBER := 0;
    status varchar2(255);
	no_problem_go_away EXCEPTION;
	v VARCHAR2(4000);
BEGIN
	-- is controlled attribute?
	SELECT 
		COUNT(*) 
	INTO 
		numrows
	FROM 
		CTSPEC_PART_ATT_ATT
	WHERE 
		attribute_type = :NEW.attribute_type;
	
    IF numrows = 0 THEN
        IF :new.attribute_units IS NOT NULL THEN
            raise_application_error(
                -20001,
                'This attribute cannot have units'
            );
        END IF;
	else
  		-- one or the other is controlled
    	SELECT 
    		upper(VALUE_CODE_TABLE), 
    		upper(UNITS_CODE_TABLE) 
    	INTO 
    		vct, 
    		uct
    	FROM 
    		CTSPEC_PART_ATT_ATT
   		WHERE 
   			attribute_type = :NEW.attribute_type;
    
   		IF (vct IS NOT NULL) THEN
    		-- value is controlled
    		SELECT 
    			column_name 
    		INTO 
    			ctctColname
			FROM 
				user_tab_columns
			WHERE 
				upper(table_name) = vct AND 
				upper(column_name) != 'COLLECTION_CDE' AND 
				upper(column_name) != 'DESCRIPTION';
			
			v:=replace(:NEW.ATTRIBUTE_VALUE,'''','''''');

            sqlString := 'SELECT count(*) FROM ' || vct || 
                ' WHERE ' || ctctColname || ' = ''' || 
                v || ''' and collection_cde= ''' || 
                collectionCode || '''';
                
            EXECUTE IMMEDIATE sqlstring INTO numrows;
            
            IF (numrows = 0) THEN
                raise_application_error(
                    -20001,
                    'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE ');
            END IF;
		
		ELSIF (uct is not null) THEN
    		-- attributes with units must be numeric
			SELECT IS_number(:new.attribute_value) INTO numrows FROM dual;
		
	        IF numrows = 0 THEN
	            raise_application_error(
	                -20001,
	                'Attributes with units must be numeric');
	        END IF;
            SELECT column_name INTO ctctColname
		    	FROM user_tab_columns
				WHERE upper(table_name) = uct
				AND upper(column_name) <>'COLLECTION_CDE'
				AND upper(column_name) <>'DESCRIPTION';
		
			sqlString := 'SELECT count(*) FROM ' || uct || 
			    ' WHERE ' || ctctColname || ' = ''' || 
			    :NEW.ATTRIBUTE_UNITS || '''';
			    
       	 	EXECUTE IMMEDIATE sqlstring INTO numrows;
        
	        IF (numrows = 0) THEN
	            raise_application_error(
	                -20001,
	                'Invalid ATTRIBUTE_UNITS');
	        END IF;
		END IF;
	END IF; 	
END;
/


