-- disallow direct insert, update, delete
--revoke update on container from manage_container;


CREATE OR REPLACE procedure updateContainer (
    v_container_id in number,
    v_parent_container_id in number,
    v_container_type in varchar2,
    v_label in varchar2,
    v_description in varchar2,
    v_container_remarks in varchar2,
    v_barcode in varchar2,
    v_width in number,
    v_height in number,
    v_length in number,
    v_number_positions in number,
    v_locked_position IN number,
    v_institution_acronym in varchar2
   ) is 
		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		
		
   msg varchar2(4000);
        sep varchar2(10);
        p_holds_posn_cnt number;
        p_holds_notposn_cnt number;
        p  container%ROWTYPE;
        c container%ROWTYPE; -- current/old stuff
    begin
        -- pass off to containercheck
        ---- child, as it exists now
        ---- child, as it will exist if this works
        ---- parent
        -- No updates except through this
        -- revoke update on container from manage_container;
        -- so all of the logic/business rules can live here.
        select * into parent from container where container_id=v_parent_container_id;
        select * into old_child from container where container_id=v_container_id;
        new_child.container_id := v_container_id;
        new_child.parent_container_id := v_parent_container_id;
        new_child.container_type := v_container_type;
        new_child.label := v_label;
        new_child.description := v_description;
        new_child.container_remarks := v_container_remarks;
        new_child.barcode := v_barcode;
        new_child.width := v_width;
        new_child.height := v_height;
        new_child.length := v_length;
        new_child.locked_position := v_locked_position;
        new_child.number_positions := v_number_positions;
        new_child.institution_acronym := v_institution_acronym;
        select count(*) into parent_position_count from container where container_type='position' and parent_container_id=v_parent_container_id;
        select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=v_parent_container_id;
    	containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
    	
    	dbms_output.put_line('got back ' || msg);
    	
    	  if msg is not null then
            raise_application_error(-20000, 'FAIL: ' || msg);
        else
        	update 
        		container 
        	set
        		PARENT_CONTAINER_ID=v_parent_container_id,
        		CONTAINER_TYPE=v_container_type,
        		LABEL=v_label,
        		DESCRIPTION=v_description,
        		PARENT_INSTALL_DATE=sysdate,
        		CONTAINER_REMARKS=v_container_remarks,
        		BARCODE=v_barcode,
        		WIDTH=v_width,
        		HEIGHT=v_height,
        		LENGTH=v_length,
        		NUMBER_POSITIONS=v_number_positions,
        		LOCKED_POSITION=v_locked_position,
        		INSTITUTION_ACRONYM=v_institution_acronym
        	where
        		CONTAINER_ID=v_container_id;
        	
        	
            dbms_output.put_line('update container set .....');
        end if;
        
        
    end;
   /
   sho err;
   
   
   

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




    
CREATE OR REPLACE PUBLIC SYNONYM updateContainer FOR updateContainer;
GRANT EXECUTE ON updateContainer TO manage_container;








