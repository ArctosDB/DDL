CREATE OR REPLACE TRIGGER MEDIA_RELATIONS_CT
BEFORE INSERT OR UPDATE ON ctmedia_relationship
FOR EACH ROW
DECLARE
    numrows number := 0;
    tabl VARCHAR2(38);
    colName VARCHAR2(38);
    fkname VARCHAR2(38);
    sqlstr VARCHAR2(4000);
BEGIN
    tabl := upper(SUBSTR(:NEW.media_relationship,instr(:NEW.media_relationship,' ',-1) + 1));

    SELECT COUNT(*) INTO numrows
    FROM user_tables
    WHERE upper(table_name) = upper(tabl);

    IF numrows = 0 THEN
        raise_application_error(
            -20001,
            'Invalid media_relationship');
    END IF;

    SELECT COUNT(column_name) INTO numrows
    FROM user_constraints, user_cons_columns
    WHERE user_constraints.constraint_name = user_cons_columns.constraint_name
    AND user_constraints.constraint_type = 'P'
    AND user_constraints.table_name = tabl;

    IF numrows = 0 THEN
        raise_application_error(
            -20001,
            'Primary key or related table not found.');
    END IF;

    SELECT column_name INTO colName
    FROM user_constraints, user_cons_columns
    WHERE user_constraints.constraint_name = user_cons_columns.constraint_name
    AND user_constraints.constraint_type = 'P'
    AND user_constraints.table_name = tabl;

    -- check if this relationship is handled
    fkname := 'CFK_' || tabl;

    SELECT COUNT(*) INTO numrows
    FROM all_tab_cols
    WHERE table_name = 'TAB_MEDIA_REL_FKEY'
    AND column_name = fkname;

    IF numrows = 0 THEN
        -- add referencing column using a procedure to avoid the commit-in-trigger error
        init_media_fkeys(tabl,colName);
    END IF;
END;
