
create or replace trigger trg_archive_name_biu BEFORE update or insert or delete ON archive_name
	for each row declare
		c number;
		r number;
	begin
		if :OLD.is_locked = 1 then
			RAISE_APPLICATION_ERROR(-20001,'This Archive is locked and may not be altered.');
		end if;
		if :NEW.is_locked = 1 then
			-- require manage_collection
			select count(*) INTO R FROM dba_role_privs where GRANTEE=sys_context('USERENV', 'SESSION_USER') AND GRANTED_ROLE='MANAGE_COLLECTION';
			IF R<1 THEN
				RAISE_APPLICATION_ERROR(-20001,'You do not have permission to lock Archives.');
			end if;
			-- do not allow the lock of an Archive which contains encumbered specimens
			select  /*+ RESULT_CACHE */ count(*) into c from 
				specimen_archive,coll_object_encumbrance,encumbrance
				where
				specimen_archive.collection_object_id=coll_object_encumbrance.collection_object_id and
				coll_object_encumbrance.encumbrance_id=encumbrance.encumbrance_id and
				ENCUMBRANCE_ACTION='mask record' and
				specimen_archive.archive_id=:NEW.archive_id;
			if (c>0) then
				RAISE_APPLICATION_ERROR(-20001,'This Archive contains encumbered specimens and may not be locked.');
			end if;
		end if;
		-- actually nevermind - get this before inserting as there are two tables involved
		--if :NEW.archive_id is null then
		--	select someRandomSequence.nextval into :new.archive_id from dual;
		--end if;
		-- limit archive name to things that look nice in a URL
		if not regexp_like(:NEW.archive_name,'^[a-z0-9_-]+$') then
			RAISE_APPLICATION_ERROR(-20001,'Archive name may only contain lower-case letters, numbers, dash, and underbar');
		end if;
		if inserting then
			:NEW.is_locked := 0;
		end if;
	end;
/
