create table cf_relations_cache (
	COLL_OBJ_OTHER_ID_NUM_ID number not null,
	term varchar2(60) not null,
	value varchar2(4000) not null,
	cachedate date default sysdate not null
);

create or replace public synonym cf_relations_cache for cf_relations_cache;
grant select on cf_relations_cache to public;
grant all on cf_relations_cache to uam; -- redundant, but nobody else really needs access

-- don't want keys on this table - it should not try to prevent people from deleting/updating/whatever
-- but create some indexes to hopefully help performance

CREATE INDEX ix_cf_reln_cache_coidid ON cf_relations_cache(COLL_OBJ_OTHER_ID_NUM_ID) TABLESPACE uam_idx_1;



CREATE OR REPLACE TRIGGER tiu_redirect_cid 
before INSERT OR UPDATE ON redirect 
FOR EACH ROW
BEGIN
	-- attempt to add some control to this thing
	-- mostly just get the "full path isn't needed" thing across
	if SUBSTR(:NEW.old_path, 1, 1) != '/' then
		Raise_application_error(-20001, 'old_path must start with /');
	end if;
	if SUBSTR(:NEW.new_path, 1, 1) != '/' and SUBSTR(:NEW.new_path, 1, 7) != 'http://' then
		Raise_application_error(-20001, 'new_path must start with / (local redirect) or http:// (remote redirect).');
	end if;
END;
/
show err




 set permissions for
 -- /tools/BulkloadRedirect.cfm