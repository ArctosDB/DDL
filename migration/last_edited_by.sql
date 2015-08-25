ALTER TABLE flat ADD lastuser varchar2(38);
ALTER TABLE flat ADD lastdate DATE;

-- REPLACE DDL/flat/flat_triggers.sql WITH DDL/flat/flat_triggers_lastedit.sql, and rebuilt the triggers to that specification.

-- rebuild is_flat_stale as follows, and update DDL/flat/flat_procedures.sql with the new code

CREATE OR REPLACE PROCEDURE is_flat_stale IS 
    aid NUMBER;
BEGIN
	FOR r IN (
		SELECT 
		    collection_object_id,
		    lastuser,
		    lastdate 
		FROM 
		    flat 
		WHERE 
		    stale_flag = 1 AND 
		    ROWNUM < 5000
	) LOOP
		update_flat(r.collection_object_id);
		BEGIN
		    IF r.lastuser='UAM' THEN
		        aid:=0;
		    ELSE
		        SELECT agent_id INTO aid FROM agent_name WHERE agent_name_type='login' AND upper(agent_name)=upper(r.lastuser);
		    END IF;
		    UPDATE coll_object SET 
		        LAST_EDITED_PERSON_ID=aid,
		        LAST_EDIT_DATE=r.lastdate
		    WHERE
		        collection_object_id = r.collection_object_id;
		EXCEPTION
		    WHEN OTHERS THEN
		        NULL;
		END;
		UPDATE flat 
		SET stale_flag = 0 
		WHERE collection_object_id = r.collection_object_id;
	END LOOP;
END;
/
sho err;