CREATE OR REPLACE TRIGGER tr_specpartattribute_sq
    BEFORE INSERT ON specimen_part_attribute
    FOR EACH ROW
    BEGIN
        if :new.part_attribute_id is null then
        	select sq_part_attribute_id.nextval into :new.part_attribute_id from dual;
        end if;
    end;
/


CREATE OR REPLACE TRIGGER TR_SPECPARTatt_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON specimen_part_attribute
FOR EACH ROW
DECLARE id NUMBER;
cid number;
BEGIN
	IF deleting THEN 
		id := :OLD.collection_object_id;
	ELSE 
		id := :NEW.collection_object_id;
	END IF;
	    
	select distinct derived_from_cat_item into cid from specimen_part where collection_object_id=id;
	UPDATE flat
	SET stale_flag = 1,
	lastuser=sys_context('USERENV', 'SESSION_USER'),
	lastdate=SYSDATE
	WHERE collection_object_id = cid;
END;
/
sho err;


/* supporting keys
ALTER TABLE ctspecpart_attribute_type add CONSTRAINT pk_ctspecpart_attribute_type PRIMARY KEY (ATTRIBUTE_TYPE);


alter table specimen_part_attribute add constraint FK_specpartattr_ctspattrtype FOREIGN KEY (attribute_type)
REFERENCES ctspecpart_attribute_type (attribute_type);


*/




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
