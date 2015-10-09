CREATE OR REPLACE TRIGGER trg_cont_defdate BEFORE UPDATE OR INSERT ON CONTAINER 
FOR EACH ROW
begin
	:NEW.PARENT_INSTALL_DATE:=sysdate;
end;
/

CREATE OR REPLACE TRIGGER MOVE_CONTAINER
before UPDATE OR INSERT ON CONTAINER
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


FOR EACH ROW
DECLARE
    cw number;
    ch number;
    cd number;
    pt varchar2(60);
    pw number;
    ph number;
    pd number;
    cl number;
  --  pragma autonomous_transaction;
BEGIN

    if :new.bypasscheck!=42 then
	    -- I'm so sorry.
	    -- see procedure moveContainer
	    IF :new.container_id = :new.parent_container_id THEN
	        raise_application_error(-20000, 'You cannot put a container into itself!');
	    END IF;
	        
	--  if :new.container_type = 'position' AND :new.LOCKED_POSITION != 1 then
	--      raise_application_error(
	--          -20000,
	--          'Positions must be locked.');
	--  end if;
	    IF :new.parent_container_id != :old.parent_container_id THEN
	
	  
	    -- they moved a container - run this trigger
	    -- get data into local vars
	        SELECT
	           container_type,
	            width,
	            height,
	            length
	        into 
	            pt,
	            pw,
	            ph,
	            pd
	        FROM container WHERE container_id = :new.parent_container_id;
	        -- see if they've done anything stoopid
	        IF pt = 'collection object' THEN
	            raise_application_error(-20000, 'You cannot put anything in a collection object!'); 
	        END IF;
	             
	        IF pt LIKE '%label%' THEN
	            raise_application_error(-20000, 'You cannot put anything in a label! (container_id:' || :NEW.container_id || '; parent_container_id: ' || :NEW.parent_container_id);
	        END IF;
	            
	        IF :new.container_type LIKE '%label%' THEN
	            raise_application_error(-20000, 'A label cannot have a parent!');
	        END IF;
	            
	        IF :new.height >= ph THEN
	            raise_application_error(-20000, 'The child cannot fit into the parent (check height)!');
	        END IF;
	        IF :new.length >= pd THEN
	            raise_application_error(-20000, 'The child won''t fit into the parent (check length)!');
	        END IF;
	            
	        IF :new.width >= pw THEN
	            raise_application_error(-20000, 'The child won''t fit into the parent (check width)!');
	        END IF;
	            
	        IF :new.locked_position = 1 THEN
	            raise_application_error(-20000, 'The position you are trying to move is locked.');
	        END IF;
	        
	        if pt = 'herbarium folder' and :new.container_type != 'herbarium sheet' then
	            raise_application_error(-20000, 'Herbarium folders may contain only herbarium sheets.');
	        END IF;
	        
	        if pt = 'herbarium sheet' and :new.container_type != 'collection object' then
	            raise_application_error(-20000, 'Herbarium sheets may contain only collection objects.');
	        END IF;
	        
	        if pt = :NEW.container_type then
	            raise_application_error(-20000, 'A container and parent container may not share container type.');
	        END IF;
	        if 
	         	pt = 'legacy container' or 
	         	:NEW.container_type='legacy container' or 
	         	pt='unknown' or 
	         	:NEW.container_type='unknown' then
	            raise_application_error(-20000, '"unknown" and "legacy container" may not be moved.');
	        END IF;
	        
	        if :NEW.container_type='position' and pt not in ('freezer','freezer box','freezer rack','microplate','shelf','slide box') then
	            raise_application_error(-20000, 'Positions are not allowed in ' || pt);
	        END IF;
	        
	      

	    END IF;
	end if;
	:new.bypasscheck:=null;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    -- ColdFusion hasn't commited yet - ignore and move right along....
        NULL;
END move_container;
/
SHO ERR;



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
