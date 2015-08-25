alter table project add iso_start_date VARCHAR2(22);
alter table project add iso_end_date VARCHAR2(22);

lock table project in exclusive mode nowait;


update project set iso_start_date=to_char(start_date,'YYYY-MM-DD');
update project set iso_end_date=to_char(end_date,'YYYY-MM-DD');


ALTER TABLE project RENAME COLUMN start_date TO date_start_date;
ALTER TABLE project RENAME COLUMN end_date TO date_end_date;

ALTER TABLE project RENAME COLUMN iso_start_date TO start_date;
ALTER TABLE project RENAME COLUMN iso_end_date TO end_date;

CREATE OR REPLACE TRIGGER TR_PROJECT_BIU
BEFORE UPDATE OR INSERT ON PROJECT
FOR EACH ROW
BEGIN
	IF is_iso8601(:NEW.start_date) != 'valid' then
		raise_application_error(-20001,'start_date: ' || is_iso8601(:NEW.start_date));
	end if;
	IF is_iso8601(:NEW.end_date) != 'valid' then
		raise_application_error(-20001,'end_date: ' || is_iso8601(:NEW.end_date));
	end if;
END;
/

/*
	CLEANUP - run once this is all proven
	alter table identification drop column date_made_date;
	alter table flat drop column date_made_date


*/
DROP TRIGGER IDENTIFICATION_CT_CHECK;
ALTER TRIGGER TR_IDENTIFICATION_AIU_FLAT DISABLE;
    

ALTER TABLE identification ADD iso_made_date VARCHAR2(22);
UPDATE identification SET iso_made_date=to_char(made_date,'YYYY-MM-DD');
ALTER TABLE identification RENAME COLUMN made_date TO date_made_date;
ALTER TABLE identification RENAME COLUMN iso_made_date TO made_date;

ALTER TABLE flat ADD iso_made_date VARCHAR2(22);
UPDATE flat SET iso_made_date=to_char(made_date,'YYYY-MM-DD');
ALTER TABLE flat RENAME COLUMN made_date TO date_made_date;
ALTER TABLE flat RENAME COLUMN iso_made_date TO made_date;

--- copy to ddl file
CREATE OR REPLACE TRIGGER IDENTIFICATION_CT_CHECK
BEFORE UPDATE OR INSERT ON IDENTIFICATION
FOR EACH ROW
DECLARE 
    numrows NUMBER;
    status varchar2(255);
BEGIN
	SELECT COUNT(*) INTO numrows 
	FROM ctnature_of_id 
	WHERE nature_of_id = :NEW.nature_of_id;
	
	IF (numrows = 0) THEN
		raise_application_error(
		    -20001,
		    'Invalid nature_of_id');
	END IF;
	IF :NEW.made_date IS NOT NULL THEN
    	status:=is_iso8601(:NEW.made_date);
        IF status != 'valid' THEN
            raise_application_error(-20001,'ID Made Date: ' || status);
        END IF;
    END IF;
END;
/

ALTER TRIGGER TR_IDENTIFICATION_AIU_FLAT ENABLE;





ALTER TRIGGER TR_ATTRIBUTES_AIUD_FLAT DISABLE;
DROP TRIGGER TR_ATTRIBUTES_CT_BUI;

ALTER TABLE attributes ADD iso_determined_date VARCHAR2(22);
UPDATE attributes SET iso_determined_date=to_char(determined_date,'YYYY-MM-DD');
ALTER TABLE attributes RENAME COLUMN determined_date TO date_determined_date;
ALTER TABLE attributes RENAME COLUMN iso_determined_date TO determined_date;




-- copy to DDL file
CREATE OR REPLACE TRIGGER TR_ATTRIBUTES_CT_BUI
BEFORE UPDATE OR INSERT ON ATTRIBUTES
FOR EACH ROW
DECLARE
    numrows NUMBER := 0;
	collectionCode VARCHAR2(4);
	sqlString VARCHAR2(4000);
	vct VARCHAR2(255);
	uct VARCHAR2(255);
	ctctColname VARCHAR2(255);
	ctctCollCde NUMBER := 0;
    status varchar2(255);
	no_problem_go_away EXCEPTION;
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
            'Invalid attribute_type');
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
            sqlString := 'SELECT count(*) FROM ' || vct || 
                ' WHERE ' || ctctColname || ' = ''' || 
                :NEW.ATTRIBUTE_VALUE || ''' and collection_cde= ''' || 
                collectionCode || '''';
                
            EXECUTE IMMEDIATE sqlstring INTO numrows;
            
            IF (numrows = 0) THEN
                raise_application_error(
                    -20001,
                    'Invalid ATTRIBUTE_VALUE for ATTRIBUTE_TYPE in this collection');
            END IF;
        ELSE
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







ALTER TRIGGER TR_ATTRIBUTES_AIUD_FLAT ENABLE;







