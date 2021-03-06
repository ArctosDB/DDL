select trigger_name from all_triggers where table_name='CONTAINER';


select trigger_name from all_triggers where table_name='COLL_OBJ_CONT_HIST';

select trigger_name from all_triggers where table_name='COLL_OBJECT';

select trigger_name from all_triggers where table_name='COLL_OBJ_REMARK';

coll_object_remark

drop trigger trg_cont_bdelt;

CREATE OR REPLACE TRIGGER trg_cont_bdelt BEFORE delete ON CONTAINER 
FOR EACH ROW
declare
	c number;
begin
	select count(*) into c from container where parent_container_id=:OLD.container_id;
	if c>0 then
			raise_application_error(-20000, 'Parent containers may not be deleted.');
	end if;
end;
/




CREATE OR REPLACE TRIGGER trg_cont_defdate BEFORE UPDATE OR INSERT ON CONTAINER 
FOR EACH ROW
begin
	:NEW.PARENT_INSTALL_DATE:=sysdate;
	
	if :NEW.number_rows is not null or :NEW.number_columns is not null or :NEW.orientation is not null or :NEW.POSITIONS_HOLD_CONTAINER_TYPE is not null then
		-- if any, require all
		if :NEW.number_rows is null or :NEW.number_columns is null or :NEW.orientation is null or :NEW.POSITIONS_HOLD_CONTAINER_TYPE is null then
			raise_application_error(-20000, 'FAIL: (number_rows,number_columns,orientation,POSITIONS_HOLD_CONTAINER_TYPE) must be given together');
		end if;
		if :NEW.orientation not in ('vertical','horizontal') then
			raise_application_error(-20000, 'FAIL: invalid orientation');
		end if;
	end if;
end;
/



-- reconstitute this for absolute rules
CREATE OR REPLACE TRIGGER trg_container_bupins before UPDATE OR INSERT ON CONTAINER
FOR EACH ROW
DECLARE
    msg varchar2(4000);
BEGIN
	if :NEW.container_type='collection object' and :NEW.barcode is not null then
		raise_application_error(-20000, 'FAIL: collection objects may not have barcodes');
	end if;
end;
/







CREATE OR REPLACE TRIGGER 

deprecated use procedures







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






MOVE_CONTAINER
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


CREATE OR REPLACE TRIGGER GET_CONTAINER_HISTORY stale_see_container_positions.sql
AFTER UPDATE or insert ON CONTAINER
FOR EACH ROW
BEGIN
	-- ignore if nothing we're logging has changed
	if updating then
		if :OLD.parent_container_id != :NEW.parent_container_id then
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
		end if;
	else
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
	end if;
END get_container_history;
/


select count(*) from container_history;