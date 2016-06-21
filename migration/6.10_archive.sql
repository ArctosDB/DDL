-- create an archive table
-- include collection_object_id so that we can maintain internal referential integrity, eg, not
--   allow delete of archived specimens
-- include GUID so this works without access to internal Arctos goodies

-- normalize this so that we can enforce unique archive name


-- build functions/getGuidFromID

delete from specimen_archive;

delete from archive_name;


drop table specimen_archive;

drop table archive_name;
drop table archive_specimen;


create table archive_name (
	archive_id number not null,
	archive_name varchar2(40) not null,
	creator varchar2(40) not null,
	create_date date not null,
	is_locked number not null
);

create or replace public synonym archive_name for archive_name;
-- inserting comes with a curatorial responsibility, so restrict who can
grant insert,update on archive_name to manage_collection;

grant select,insert,delete on archive_name to public;



ALTER TABLE archive_name ADD CONSTRAINT pk_archive_name PRIMARY KEY (archive_id) USING INDEX TABLESPACE UAM_IDX_1;

CREATE UNIQUE INDEX IU_archive_archive_name ON archive_name (archive_name) TABLESPACE UAM_IDX_1;

ALTER TABLE archive_name ADD CONSTRAINT ck_bool_arch_lock CHECK (is_locked in (1,0));
	

create table specimen_archive (
	archive_id number not null,
	collection_object_id number not null,
	guid varchar2(40) not null
);


create or replace public synonym specimen_archive for specimen_archive;



-- inserting comes with a curatorial responsibility, so restrict who can
grant select,insert,delete on specimen_archive to public;



CREATE UNIQUE INDEX IU_spec_archive_arcidcoidguid ON specimen_archive (archive_id,collection_object_id,guid) TABLESPACE UAM_IDX_1;



-- prevent deletion of archived cataloged items
alter table specimen_archive add constraint FK_spec_archive_archive foreign key (archive_id) references archive_name (archive_id);
alter table specimen_archive add constraint FK_spec_archive_specimen foreign key (collection_object_id) references cataloged_item (collection_object_id);



create or 

-- see triggers 

replace trigger trg_archive_name_biu BEFORE update or insert or delete ON archive_name
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



create or replace trigger trg_spec_archive_biu 

see triggers folder

BEFORE update or insert or delete ON specimen_archive for each row
declare
	lockd number;
	unme archive_name.CREATOR%TYPE;
begin
	select is_locked,CREATOR into lockd,unme from archive_name where archive_id=:OLD.archive_id;
	if lockd = 1 then
		RAISE_APPLICATION_ERROR(-20001,'This Archive is locked and may not be altered. Contact ' || unme || ' for help.');
	end if;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- inserting as transaction
		return;
end;
/

select count(*) from specimen_archive where collection_object_id in (select collection_object_id from coll_object_encumbrance);

rebuild triggers/coll_object_encumbrance.sql



desc doi;

alter table doi add archive_id number;

alter table doi add constraint FK_doi_archive foreign key (archive_id) references archive_name (archive_id);

