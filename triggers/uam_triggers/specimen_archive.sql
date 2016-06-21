create or replace trigger trg_spec_archive_biu  BEFORE update or insert or delete ON specimen_archive for each row
declare
	lockd number;
	unme archive_name.CREATOR%TYPE;
begin
	select is_locked into lockd from archive_name where archive_id=:OLD.archive_id;
	if lockd = 1 then
		RAISE_APPLICATION_ERROR(-20001,'This Archive is locked and may not be altered. Contact ' || unme || ' for help.');
	end if;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		-- inserting as transaction
		return;
end;
/