/*
	Geology Stuff - see migration/Geology.sql
	Strip FORM email OUT OF rolecheck.cfm
	KILL gref stuff ?
	KILL media stuff

*/

/* 
Object Condition:

need some cleanup the first time this is run

get rid of the stoopid name

DROP TRIGGER GET_HISTORY;

populate the table with cruddy defaults

UPDATE object_condition 
SET DETERMINED_AGENT_ID = 0
WHERE DETERMINED_AGENT_ID is null;

UPDATE object_condition
SET DETERMINED_DATE = sysdate
WHERE DETERMINED_DATE is null;

ALTER TABLE object_condition MODIFY determined_agent_id NOT NULL;
ALTER TABLE object_condition MODIFY determined_date NOT NULL;

CREATE PUBLIC SYNONYM objcondid FOR objcondid;
GRANT SELECT ON objcondid TO PUBLIC;
GRANT INSERT, UPDATE, DELETE ON object_condition TO manage_specimens;

-- clean up dups
declare c number;
begin
for r in (select COLLECTION_OBJECT_ID,CONDITION from OBJECT_CONDITION 
having count(*) > 1 group by COLLECTION_OBJECT_ID,CONDITION order by collection_object_id) loop
dbms_output.put_line(r.collection_object_id);
select min(OBJECT_CONDITION_ID) into c from OBJECT_CONDITION where COLLECTION_OBJECT_ID=r.COLLECTION_OBJECT_ID;
delete from OBJECT_CONDITION where OBJECT_CONDITION_ID=c;
end loop;
end;
/
drop index u_object_condition;
create unique index u_object_condition on object_condition (COLLECTION_OBJECT_ID,CONDITION);

*/

/*
create trigger trg_object_condition; 
see /DDL/trigger/trg_object_condition.sql
*/

-- permissions:

INSERT INTO cf_ctuser_roles (role_name, description)
VALUES ('public', 'allow access by any user');

-- need TO bring over everything FROM cf_form_permissions.
-- OK TO just REPLACE whatever's in QA/PROD 
/* to make ctl file:
run in dev:
SELECT key || '|' || form_path || '|' || role_name
FROM cf_form_permissions;

prepend data in newly created file, cf_form_permissions.ctl with:
LOAD DATA
INFILE *
INSERT INTO TABLE cf_form_permissions
FIELDS TERMINATED BY "|"
TRAILING NULLCOLS
(
    KEY,
    FORM_PATH,
    ROLE_NAME
)
BEGINDATA
*/

SET linesize 9999;
SELECT key || '|' || form_path || '|' || role_name
FROM cf_form_permissions;
SET linesize 80;

TRUNCATE TABLE cf_form_permissions;
run:
sqlldr uam@mvzlprod control=cf_form_perm_080401.ctl direct=TRUE
    
/* 08 Apr 2008 */
ALTER TABLE taxonomy MODIFY taxon_remarks VARCHAR2(4000);
ALTER TABLE bulkloader MODIFY identification_remarks VARCHAR2(4000);
ALTER TABLE bulkloader_deletes  MODIFY identification_remarks VARCHAR2(4000);
ALTER TABLE bulkloader_stage MODIFY identification_remarks VARCHAR2(4000);