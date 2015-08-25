create or replace PROCEDURE bulkloader_stage_check 
is
 thisError varchar2(4000);
  BEGIN
	FOR rec IN (SELECT * FROM bulkloader_stage) LOOP
		SELECT bulk_stage_check_one(rec.collection_object_id) INTO thisError FROM dual;
		if length(thisError) > 224 then
			thisError := substr(thisError,1,200) || ' {snip...}';
		end if;
		rollback;
		update bulkloader_stage set loaded = thisError where collection_object_id = rec.collection_object_id;
		commit;
		--- dbms_output.put_line (rec.collection_object_id ||': ' || thisError);
	END LOOP;
END;
/
sho err
create OR REPLACE public synonym bulkloader_stage_check for bulkloader_stage_check;
grant execute on bulkloader_stage_check to public;