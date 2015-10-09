select trigger_name from all_triggers where table_name='CONTAINER';


select trigger_name from all_triggers where table_name='COLL_OBJ_CONT_HIST';

select trigger_name from all_triggers where table_name='COLL_OBJECT';

select trigger_name from all_triggers where table_name='COLL_OBJ_REMARK';

coll_object_remark

CREATE OR REPLACE TRIGGER trg_cont_defdate BEFORE UPDATE OR INSERT ON CONTAINER 
FOR EACH ROW
begin
	:NEW.PARENT_INSTALL_DATE:=sysdate;
end;
/


CREATE OR REPLACE TRIGGER trg_CONTAINER_delete
after delete ON CONTAINER
FOR EACH ROW
DECLARE


-- this trigger checks that container movements are valid. The following rules are enforced:
-- 1) a container may not be moved to itself
-- 2) positions must be locked
--    note: needs rewitten in forms so positions are simply dfined as locked;
--    then, we can get rid of the locked_position column in the table
-- 3) collection objects cannot be parent containers
-- 4) labels ( = upper(container_type) like '%LABEL%') cannot be parent or child containers
-- 5) child width,height,length must all be less than or equal to parent width,height,length, respectively
-- 6) locked containers (positions - see above comment) may not be moved to a new parent

--- copy any changes here to procedure moveContainerByBarcode
--- this is critical
-- search 42 to know why
-- I'm so sorry

CREATE OR REPLACE TRIGGER MOVE_CONTAINER
before UPDATE OR INSERT ON CONTAINER
FOR EACH ROW
DECLARE
    msg varchar2(4000);
    parent_has_positions number;
    parent_has_notpositions number;
 	pragma autonomous_transaction;
BEGIN
	dbms_output.put_line('i am triggery');
	dbms_output.put_line(':new.bypasscheck = ' ||  :new.bypasscheck);
	 if :new.bypasscheck is null or :new.bypasscheck !=42 then
	 	dbms_output.put_line('bypasscheck IS NOT 42');
	 	dbms_output.put_line('i am still triggery');
	 	select count(*) into parent_has_positions from container where container_type = 'position' and parent_container_id=:NEW.parent_container_id;
		select count(*) into parent_has_notpositions from container where container_type != 'position' and parent_container_id=:NEW.parent_container_id;

		if updating then
			-- we'll have old and new
	    	dbms_output.put_line('updating');
	    	
	    	select
	    		containerCheck(
	    			:NEW.container_id,
	    			:NEW.parent_container_id,
	    			:NEW.container_type,
	    			:NEW.barcode,
	    			:NEW.height,
	    			:NEW.length,
	    			:NEW.width,
	    			:NEW.institution_acronym,
	    			:OLD.container_type,
	    			:OLD.parent_container_id,
	    			:OLD.institution_acronym,
	    			:OLD.barcode,
	    			p.container_type,
	    			p.height,
	    			p.length,
	    			p.width,
	    			p.institution_acronym,
	    			parent_has_positions,
	    			parent_has_notpositions
	    		) into msg from container p where container_id=:NEW.parent_container_id;
	  elsif inserting then
    	dbms_output.put_line('inserting');
	  	-- no old, pass in new so we get no change
	  	select
    		containerCheck(
    			:NEW.container_id,
    			:NEW.parent_container_id,
    			:NEW.container_type,
    			:NEW.barcode,
    			:NEW.height,
    			:NEW.length,
    			:NEW.width,
    			:NEW.institution_acronym,
	    		:OLD.barcode,
    			:NEW.container_type,
    			:NEW.parent_container_id,
    			:NEW.institution_acronym,
    			p.container_type,
    			p.height,
    			p.length,
    			p.width,
    			p.institution_acronym,
    			parent_has_positions,
    			parent_has_notpositions
    		) into msg from container p where container_id=:NEW.parent_container_id;
		else
	  	   msg:='noinsertupdate - misfire';
		end if;
    	dbms_output.put_line('msg: ' || msg);
		if msg is not null then
		    raise_application_error(-20000, 'FAIL: ' || msg);
		 end if;
	end if; -- END bypasscheck-check
	:new.bypasscheck:=null;
END move_container;
/
SHO ERR;









update container set parent_container_id=1021 where container_id=41083;
update container set parent_container_id=41083 where container_id=1021;

select min(container_id) from container where institution_acronym='UAM';
select min(container_id) from container where institution_acronym='UAMb';

revoke uamb_herb from dlm;

update container set institution_acronym='ABC' where container_id=1021;


select min(container_id) from container where container_type='collection object';
select min(container_id) from container where container_type='jar';



alter table container_history add username varchar2(40);


CREATE OR REPLACE TRIGGER GET_CONTAINER_HISTORY
AFTER UPDATE or insert ON CONTAINER
FOR EACH ROW
BEGIN
	INSERT INTO container_history (
        container_id,
        parent_container_id,
        install_date,
        username
    ) VALUES (
	    :NEW.container_id,
	    :NEW.parent_container_id,
	    SYSDATE,
	    SYS_CONTEXT('USERENV', 'SESSION_USER')
	 );
END get_container_history;
/
