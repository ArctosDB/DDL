CREATE OR REPLACE TRIGGER tr_attributes_sq
BEFORE INSERT ON attributes
FOR EACH ROW
BEGIN
    IF :new.attribute_id IS NULL THEN
        SELECT sq_attribute_id.nextval
        INTO :new.attribute_id
        FROM dual;
    END IF;
END;
/



CREATE OR REPLACE TRIGGER TR_ATTRIBUTES_CT_BUI
BEFORE UPDATE OR INSERT ON ATTRIBUTES
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
	IF :NEW.determined_date IS NOT NULL THEN
    	status:=is_iso8601(:NEW.determined_date);
        IF status != 'valid' THEN
            raise_application_error(-20001,'Attribute Date: ' || status);
        END IF;
    END IF;
	SELECT collection.collection_cde INTO CollectionCode
	FROM collection, cataloged_item
	WHERE collection.collection_id = cataloged_item.collection_id
	AND cataloged_item.collection_object_id = :NEW.collection_object_id;
	
    SELECT COUNT(*) INTO numrows
	FROM ctattribute_type
	WHERE attribute_type = :NEW.attribute_type
	AND collection_cde = collectionCode;
	
    IF (numrows = 0) THEN
        raise_application_error(
            -20001,
            'Invalid attribute_type: ' || :NEW.attribute_type || ' (' || CollectionCode || ')');
    END IF;
        
    SELECT COUNT(*) INTO numrows
	FROM ctattribute_code_tables
	WHERE attribute_type = :NEW.attribute_type;
	
    IF (numrows = 0) THEN
        IF :new.attribute_units IS NOT NULL THEN
            raise_application_error(
                -20001,
                'This attribute cannot have units');
        ELSE
            RAISE no_problem_go_away;
        END IF;
    END IF;
        
    SELECT upper(VALUE_CODE_TABLE), upper(UNITS_CODE_TABLE) INTO vct, uct
    FROM ctattribute_code_tables
    WHERE attribute_type = :NEW.attribute_type;
    
    IF (vct IS NOT NULL) THEN
	    SELECT column_name INTO ctctColname
		FROM user_tab_columns
		WHERE upper(table_name) = vct
		AND upper(column_name) <> 'COLLECTION_CDE'
		AND upper(column_name) <> 'DESCRIPTION';
		
    	SELECT COUNT(*) INTO ctctCollCde
		FROM user_tab_columns
		WHERE upper(table_name) = vct
		AND column_name = 'COLLECTION_CDE';
		
        IF (ctctCollCde = 1) THEN
	    	v:=replace(:NEW.ATTRIBUTE_VALUE,'''','''''');

            sqlString := 'SELECT count(*) FROM ' || vct || 
                ' WHERE ' || ctctColname || ' = ''' || 
                v || ''' and collection_cde= ''' || 
                collectionCode || '''';
                
            EXECUTE IMMEDIATE sqlstring INTO numrows;
            
            IF (numrows = 0) THEN
                raise_application_error(
                    -20001,
                    'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection');
            END IF;
        ELSE
			-- deal with CF mucking up boolean
			if (vct='CTYES_NO') then
				if :NEW.ATTRIBUTE_VALUE='true' then
					:NEW.ATTRIBUTE_VALUE:='yes';
				end if;
				if :NEW.ATTRIBUTE_VALUE='false' then
					:NEW.ATTRIBUTE_VALUE:='no';
				end if;
			end if;
            
        	sqlString := 'SELECT count(*) FROM ' || vct || 
                ' WHERE ' || ctctColname || ' = ''' || 
                :NEW.ATTRIBUTE_VALUE || '''';
                
            EXECUTE IMMEDIATE sqlstring INTO numrows;
            
            IF (numrows = 0) THEN
                raise_application_error(
                    -20001,
                    'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection');
            END IF;
        END IF;
    ELSIF (uct is not null) THEN
    	-- attributes with units must be numeric
		SELECT IS_number(:new.attribute_value) INTO numrows 
		FROM dual;
		
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
EXCEPTION
    WHEN no_problem_go_away THEN
    	NULL;
END;



CREATE OR REPLACE TRIGGER TR_ATTRIBUTES_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON ATTRIBUTES
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.collection_object_id;
    ELSE
        id := :NEW.collection_object_id;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE collection_object_id = id;
END;


CREATE OR REPLACE TRIGGER TR_ATTRIBUTES_nochangeused
before UPDATE OR DELETE ON ctattribute_type
FOR EACH ROW
DECLARE c NUMBER;
BEGIN
	if :NEW.COLLECTION_CDE != :OLD.COLLECTION_CDE or :NEW.attribute_type != :OLD.attribute_type then
	   	select 
	   		count(*) into c 
	   	from 
	   		attributes,
	   		cataloged_item,
	   		collection 
	   	where 
	   		cataloged_item.collection_id=collection.collection_id and 
	   		cataloged_item.collection_object_id=attributes.collection_object_id and
	    	collection.collection_cde=:OLD.collection_cde and 
	    	attributes.attribute_type=:OLD.attribute_type;
		if c>0 then
	   		raise_application_error(
	                -20001,
	                'Used attribtues may not be changed or deleted.');
	    END IF;
	end if;
END;
/
