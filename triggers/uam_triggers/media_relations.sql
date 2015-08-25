CREATE OR REPLACE TRIGGER TR_MEDIA_RELATIONS_SQ
BEFORE INSERT ON MEDIA_RELATIONS
FOR EACH ROW
BEGIN
    IF :new.media_relations_id IS NULL THEN
	    SELECT sq_media_relations_id.nextval
		INTO :new.media_relations_id
		FROM dual;
	END IF;
	    
	IF :NEW.created_by_agent_id IS NULL THEN
		SELECT agent_name.agent_id
		INTO :NEW.created_by_agent_id
		FROM agent_name
		WHERE agent_name_type = 'login'
		AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    END IF;
END;

CREATE OR REPLACE TRIGGER MEDIA_RELATIONS_CHK
BEFORE INSERT OR UPDATE ON MEDIA_RELATIONS
FOR EACH ROW
DECLARE
    numrows number := 0;
    tabl VARCHAR2(38);
    colName VARCHAR2(38);
BEGIN
	-- makes sure that the string after the last space 
	-- in media_relationship resolves to a valid table name
	tabl := upper(SUBSTR(:NEW.media_relationship, 
	    instr(:NEW.media_relationship, ' ', -1) + 1));
	
    SELECT COUNT(*) INTO numrows 
    FROM user_tables
    WHERE upper(table_name) = upper(tabl);
    
    IF numrows = 0 THEN
        raise_application_error(
		    -20001,
			'Invalid media_relationship');
    END IF;
        
    SELECT COUNT(column_name) INTO numrows
    FROM
        user_constraints,
        user_cons_columns
	WHERE user_constraints.constraint_name = user_cons_columns.constraint_name
	AND user_constraints.constraint_type = 'P'
	AND user_constraints.table_name = tabl;
	
	IF numrows = 0 THEN
        raise_application_error(
    		-20001,
			'Primary key not found.');
    END IF;
        
    SELECT COLUMN_NAME INTO colName
    FROM
        user_constraints,
        user_cons_columns
	WHERE user_constraints.CONSTRAINT_NAME = user_cons_columns.CONSTRAINT_NAME
	AND user_constraints.CONSTRAINT_TYPE = 'P'
	AND user_constraints.TABLE_NAME = tabl;
	
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || tabl || 
        ' WHERE ' || colName || ' = ' || :NEW.related_primary_key INTO numrows;
        
    IF numrows = 0 THEN
        raise_application_error(
    		-20001,
    		'Related record not found.');
    END IF;
END;

CREATE OR REPLACE TRIGGER MEDIA_RELATIONS_AFTER
AFTER INSERT OR UPDATE OR DELETE ON MEDIA_RELATIONS
FOR EACH ROW
DECLARE
    numrows number := 0;
	tabl VARCHAR2(38);
	colName VARCHAR2(38);
    fkname VARCHAR2(38);
    sqlstr VARCHAR2(4000);
BEGIN
    IF inserting THEN
        tabl := upper(SUBSTR(:NEW.media_relationship,
            instr(:NEW.media_relationship, ' ', -1) + 1));
            
        fkname:= 'CFK_' || tabl;
        
        sqlstr:= 'INSERT INTO tab_media_rel_fkey (
        	media_relations_id,' || fkname || ') VALUES (';
        	
        sqlstr:= sqlstr || :NEW.media_relations_id || ',' || 
            :NEW.related_primary_key || ')';
            
        EXECUTE IMMEDIATE sqlstr;
    ELSIF updating THEN
        IF :NEW.related_primary_key != :OLD.related_primary_key THEN
            tabl := upper(SUBSTR(:NEW.media_relationship,
                instr(:NEW.media_relationship, ' ', -1) + 1));
                
            fkname:= 'CFK_' || tabl;
            
            DELETE FROM tab_media_rel_fkey 
            WHERE media_relations_id = :NEW.media_relations_id;
            
            sqlstr:= 'INSERT INTO tab_media_rel_fkey (
            	media_relations_id,' || fkname || ') VALUES (';
            	
            sqlstr:= sqlstr || :NEW.media_relations_id || ',' || 
                :NEW.related_primary_key || ')';
                
            EXECUTE IMMEDIATE sqlstr;
        END IF;
	ELSIF deleting THEN
        DELETE FROM tab_media_rel_fkey 
        WHERE media_relations_id = :OLD.media_relations_id;
    END IF;
END;
