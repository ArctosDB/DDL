-- disallow direct insert, update, delete
--revoke update on container from manage_container;



CREATE OR REPLACE procedure updateAllChildrenContainer (
    v_new_parent_container_id in number,
    v_current_parent_container_id in number
   ) is 
   		-- move all of a container's children to a new parent container
		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		old_parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
   		msg varchar2(4000);
   		n number;
    begin
	    
	    -- pass off to containercheck EVERY old/new isntance, but change them all at once here if that works
        -- the only changes to the child is parent_container_id
        -- the parent doesn't change
        
	  
        select * into parent from container where container_id=v_new_parent_container_id;
        select * into old_parent from container where container_id=v_current_parent_container_id;
        -- check positions; only allow this if everything is the same
		if 
			(nvl(parent.NUMBER_ROWS,-1)  != nvl(old_parent.NUMBER_ROWS,-1)) or
			(nvl(parent.NUMBER_COLUMNS,-1)  != nvl(old_parent.NUMBER_COLUMNS,-1)) or
			(nvl(parent.ORIENTATION,'dFLT')  != nvl(old_parent.ORIENTATION,'dFLT') ) or
			(nvl(parent.POSITIONS_HOLD_CONTAINER_TYPE,'dFLT')  != nvl(old_parent.POSITIONS_HOLD_CONTAINER_TYPE,'dFLT'))
		then
        	raise_application_error(-20000, 'FAIL: old/new Parent position conflict.');
        end if;
        
        -- count of positions and not-positions already in the new parent
 		select count(*) into parent_position_count from container where container_type='position' and parent_container_id=v_new_parent_container_id;
        select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=v_new_parent_container_id;
        -- and once for each of the children of the current parent
        for r in (select container_id from container where parent_container_id=v_current_parent_container_id) loop
        	select * into old_child from container where container_id=r.container_id;
        	-- no changes to child
        	new_child := old_child;
      		containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
    		if msg is not null then
            	raise_application_error(-20000, 'FAIL: ' || msg);
            end if;
        end loop;
        -- made it here, it'll all fit
       update container set parent_container_id=v_new_parent_container_id where parent_container_id=v_current_parent_container_id;
       
       -- position count doesn't always work properly due to transactions, so re-check here
       select count(*)  into n from container where parent_container_id=v_new_parent_container_id;
      -- dbms_output.put_line('n: ' || n);
       if n > (parent.number_rows * parent.number_columns) then
       	raise_application_error(-20000, 'FAIL: Too many positions.');
       end if;
    end;
   /
   sho err;
   
   
   
    
CREATE OR REPLACE PUBLIC SYNONYM updateAllChildrenContainer FOR updateAllChildrenContainer;
GRANT EXECUTE ON updateAllChildrenContainer TO manage_container;

   
   
   
   






