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
		parent_position_count number;
		parent_notposition_count number;
		
		
   msg varchar2(4000);
     
    begin
        
	    -- pass off to containercheck EVERY old/new isntance, but change them all at once here if that works
        -- the only changes to the child is parent_container_id
        -- the parent doesn't change
        select * into parent from container where container_id=v_new_parent_container_id;
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
        		
        
    end;
   /
   sho err;
   
   
   
    
CREATE OR REPLACE PUBLIC SYNONYM updateAllChildrenContainer FOR updateAllChildrenContainer;
GRANT EXECUTE ON updateAllChildrenContainer TO manage_container;

   
   
   
   
   
   
   
   
   

CREATE OR REPLACE procedure containerContentCheck (
	old_child IN container%rowtype,
	new_child IN container%rowtype,
	parent IN container%rowtype,
	parent_position_count IN number,
	parent_notposition_count IN number,
	msg_out OUT varchar2
	
	
        
    
        select * into new_child from container where container_id=v_container_id;



        dbms_output.put_line('v_container_type: ' || v_container_type);
        dbms_output.put_line('v_barcode: ' || v_barcode);
        dbms_output.put_line('p_holds_posn_cnt: ' || p_holds_posn_cnt);
        dbms_output.put_line('p_holds_notposn_cnt: ' || p_holds_notposn_cnt);
        dbms_output.put_line('c.barcode: ' || c.barcode);

        if v_container_type='position' and p_holds_notposn_cnt > 0 then
            msg := msg || sep || 'Parent contains not-positions and cannot contain position containers';
            sep := '; ';
        end if;
        if v_container_type != 'position' and p_holds_posn_cnt > 0 then
            msg := msg || sep || 'Parent contains positions and cannot contain not-position containers';
            sep := '; ';
        end if;
        if v_barcode != c.barcode then
            msg := msg || sep || 'Changing barcode is not allowed';
            sep := '; ';
        end if;
        if v_container_type = p.container_type then
            msg := msg || sep || 'Parent and child may not be of the same container_type';
            sep := '; ';
        end if;

        if v_institution_acronym != c.institution_acronym then
            msg := msg || sep || 'Changing institution_acronym is not allowed';
            sep := '; ';
        end if;
        select count(*) into c from collection where institution_acronym=v_institution_acronym;
        if c=0 then
            msg := msg || sep || 'You do not have access to child container';
            sep := '; ';
        end if;
        select count(*) into c from collection where institution_acronym=p.institution_acronym;
        if c=0 then
            msg := msg || sep || 'You do not have access to parent container';
            sep := '; ';
        end if;


        if c.container_type = 'position' and v_parent_container_id != c.parent_container_id then
            msg := msg || sep || 'Positions may not be moved.';
            sep := '; ';
        END IF;


        if (c.container_type = 'position' and v_container_type != 'position') or (c.container_type != 'position' and v_container_type = 'position') then
            msg := msg || sep || 'Positions may not be changed to other container types.';
            sep := '; ';
        END IF;
        if v_container_id=v_parent_container_id then
            msg := msg || sep || 'A container may not be in itself.';
            sep := '; ';
        END IF;
        if p.container_type='collection object' then
            msg := msg || sep || 'You cannot put anything in a collection object.';
            sep := '; ';
        END IF; 
        if p.container_type like '%label%' then
            msg := msg || sep || 'You cannot put anything in a label.';
            sep := '; ';
        END IF;
        if v_container_type like '%label%' and v_parent_container_id != 0 then
           msg := msg || sep || 'A label cannot have a parent.';
           sep := '; ';
        END IF;  
        if p.container_type like '%label%' then
           msg := msg || sep || 'A label cannot be a parent.';
           sep := '; ';
        END IF;
         if (v_height>=p.height) OR (v_width>=p.width) OR (v_length>=p.length) then
          msg := msg || sep || 'The child will not fit into the parent.';
           sep:='; ';
        END IF;
        
        if v_container_type = 'herbarium sheet' p.container_type != 'herbarium folder' and  then
            msg := msg || sep || 'Herbarium sheets may only be in herbarium folders';
            sep:='; ';
        END IF;

        if v_parent_container_id != 0 and (
            v_container_type = 'legacy container' or 
            v_container_type='legacy container' or 
            v_container_type='unknown' or 
            v_container_type='unknown'
            ) then
                msg := msg || sep || '"unknown" and "legacy container" may not be moved.';
                sep:='; ';
        END IF;

        if p.container_type = v_container_type then
            msg := msg || sep || 'A container and parent container may not share container type';
            sep:='; ';
        END IF;

        if v_container_type='position' and p.container_type not in ('freezer','freezer box','freezer rack','microplate','shelf','slide box') then
            msg := msg || sep || 'Positions are not allowed in ' || p.container_type;
            sep:='; ';
        END IF;




        if p_container_type = 'herbarium sheet' and v_container_type != 'collection object'   then
            msg := msg || sep || 'Herbarium sheets may contain only collection objects';
            sep:='; ';
        END IF;
    
        if msg is not null then
            raise_application_error(-20000, 'FAIL: ' || msg);
        else
            dbms_output.put_line('update container set .....');
        end if;
      end;
/
sho err;
    

exec updateContainer (-
    41206,-
    41205,-
    'box',-
    'labeltest',-
    'descr',-
    '',-
    'ZXYT',-
    '',-
    '',-
    '',-
    '',-
    0,-
    'UAM');



select min(container_id) from container where container_type='freezer box';











