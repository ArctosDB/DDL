select trigger_name from all_triggers where table_name='SPECIMEN_PART';
select trigger_name from all_triggers where table_name='TRANS';




CREATE OR REPLACE TRIGGER trg_cmpd_specimenpart
FOR insert or update or DELETE ON SPECIMEN_PART
COMPOUND TRIGGER
	label varchar2(255);
    institution_acronym varchar2(255);
    numrows number;
	collectionCode varchar2(4);
    BEFORE EACH ROW IS BEGIN
	     if deleting then
			-- coll_obj_cont_hist has a cascade delete through the keys
			-- ditto container
		    DELETE FROM coll_object_remark WHERE collection_object_id = :OLD.collection_object_id;
		 end if;
		 
		 if inserting or updating then
			-- old trigger SPECIMEN_PART_CT_CHECK
			SELECT 
				collection.collection_cde 
			INTO 
				collectionCode
			FROM 
			    collection,
			    cataloged_item 
			WHERE 
				collection.collection_id = cataloged_item.collection_id AND 
				cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
			    
			SELECT 
				COUNT(*) 
			INTO 
				numrows 
			FROM 
				ctspecimen_part_name 
			WHERE 
				part_name = :NEW.part_name AND 
				collection_cde = collectionCode;
				
			IF (numrows = 0) THEN
		        raise_application_error(
		    		-20001,
					'Invalid part name: ' || :NEW.part_name || ' (' || collectionCode || ')');
			END IF;
			-- END old trigger SPECIMEN_PART_CT_CHECK
		 end if;
		 
	end BEFORE EACH ROW;
	AFTER EACH ROW IS BEGIN
		
		if deleting then
	 		DELETE FROM coll_object WHERE collection_object_id = :OLD.collection_object_id;
	 	end if;
	 	
	 	if inserting then
		 	dbms_output.put_line('insert');
		 	dbms_output.put_line(':NEW.part_name: ' || :NEW.part_name);
		 	-- old trigger MAKE_PART_COLL_OBJ_CONT
		 	SELECT
			    collection.institution_acronym,
				collection.GUID_PREFIX || ':' || cataloged_item.cat_num || ' ' || :NEW.part_name
		    INTO
		        institution_acronym,
		        label
		    FROM
		        collection,
		        cataloged_item
		    WHERE 
		    	collection.collection_id = cataloged_item.collection_id AND 
		    	cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
		    
		    	
		 	dbms_output.put_line('institution_acronym: ' || institution_acronym);
		 	dbms_output.put_line('label: ' || label);
		 	
		    INSERT INTO container (
			    container_id,
				parent_container_id,
				container_type,
				label,
				locked_position,
				institution_acronym)
			VALUES (
				sq_container_id.nextval,
				0,
				'collection object',
				label,
				0,
				institution_acronym);
		 	dbms_output.put_line('made container');
		    INSERT INTO coll_obj_cont_hist (
				collection_object_id,
				container_id,
				installed_date,
				current_container_fg)
			VALUES (
				:NEW.collection_object_id,
				sq_container_id.currval,
				sysdate,
				1);
			-- END old trigger MAKE_PART_COLL_OBJ_CONT
		dbms_output.put_line('made history');
		 end if;
		 
		 
    END AFTER EACH ROW;
END;
/
sho err;



--- keep the PRAGMA autonomous_transaction out of the compound trigger, because
CREATE OR REPLACE TRIGGER tr_specpart_sampfr_biupa
BEFORE INSERT OR UPDATE ON specimen_part
FOR EACH ROW
DECLARE
    numrows NUMBER;
    PRAGMA autonomous_transaction;
BEGIN
    SELECT COUNT(*) INTO numrows
    FROM specimen_part
    WHERE collection_object_id = :new.sampled_from_obj_id
    AND sampled_from_obj_id IS NOT NULL;
    
    IF numrows > 0 THEN
        raise_application_error(
            -20001,
            'You may not sample from a subsample.');
    END IF;
END;
/
sho err

-- keep the flat stuff out of the rules stuff

CREATE OR REPLACE TRIGGER TR_SPECPART_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON SPECIMEN_PART
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.derived_from_cat_item;
    ELSE
        id := :NEW.derived_from_cat_item;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE collection_object_id = id;
END;
/
sho err








------ old stuff, combined into compound trigger

CREATE OR REPLACE do not use this see compound trigger TRIGGER MAKE_PART_COLL_OBJ_CONT
AFTER INSERT ON SPECIMEN_PART
FOR EACH ROW
DECLARE
    label varchar2(255);
    institution_acronym varchar2(255);
    
BEGIN
    SELECT
	    collection.institution_acronym,
		collection.GUID_PREFIX || ':' || cataloged_item.cat_num || 
		    ' ' || :NEW.part_name
    INTO
        institution_acronym,
        label
    FROM
        collection,
        cataloged_item
    WHERE collection.collection_id = cataloged_item.collection_id
    AND cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
    
    INSERT INTO container (
	    container_id,
		parent_container_id,
		container_type,
		label,
		locked_position,
		institution_acronym)
	VALUES (
		sq_container_id.nextval,
		0,
		'collection object',
		label,
		0,
		institution_acronym);
		
    INSERT INTO coll_obj_cont_hist (
		collection_object_id,
		container_id,
		installed_date,
		current_container_fg)
	VALUES (
		:NEW.collection_object_id,
		sq_container_id.currval,
		sysdate,
		1);
EXCEPTION
    WHEN OTHERS THEN
    	raise_application_error(
    	    -20000, 
    	    'trigger problems: ' || SQLERRM);
END;



CREATE OR REPLACE do not use this see compound trigger  TRIGGER SPECIMEN_PART_CT_CHECK
BEFORE UPDATE OR INSERT ON SPECIMEN_PART
FOR EACH ROW
DECLARE
	numrows number;
	collectionCode varchar2(4);
BEGIN
	SELECT collection.collection_cde 
	INTO collectionCode
	FROM 
	    collection,
	    cataloged_item 
    WHERE collection.collection_id = cataloged_item.collection_id
    AND cataloged_item.collection_object_id = :NEW.derived_from_cat_item;
    
	SELECT COUNT(*) INTO numrows 
	FROM ctspecimen_part_name 
	WHERE part_name = :NEW.part_name 
	AND collection_cde = collectionCode;
	
	IF (numrows = 0) THEN
        raise_application_error(
    		-20001,
			'Invalid part name: ' || :NEW.part_name || ' (' || collectionCode || ')');
	END IF;
	
END;


