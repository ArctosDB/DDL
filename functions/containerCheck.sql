-- move all check container code here; call it from the various places it's used.
-- yea its sorta clunky. Sorray.
-- c_field_name is passed-in :NEW values for the container being updated
-- o_field_name is passed-in :OLD values for the container being updates
-- p_field_name is passed-in :NEW values for the parent of the container being updated



CREATE OR REPLACE procedure containerContentCheck (
	old_child IN container%rowtype,
	new_child IN container%rowtype,
	parent IN container%rowtype,
	parent_position_count IN number,
	parent_notposition_count IN number,
	msg_out OUT varchar2
   ) is 
		msg varchar2(4000);
		sep varchar2(10);
		c number;
   	begin
	   	
	   	dbms_output.put_line('hello I am containerContentCheck');
	   	--- make sure they have access to the container's institution
	   	select count(*) into c from collection where institution_acronym=new_child.institution_acronym;
		if c=0 then
			msg := msg || sep || 'You do not have access to child container';
			sep := '; ';
		end if;
		 -- disallow institution change
	   	if new_child.institution_acronym != old_child.institution_acronym then
			msg := msg || sep || 'Changing institution_acronym is not allowed';
			sep := '; ';
		end if;
		-- no editing barcodes; deal with this in replaceParentContainer
		if new_child.barcode != old_child.barcode then
			msg := msg || sep || 'Changing barcode is not allowed';
			sep := '; ';
		end if;
		-- if parent.container_id is 0, they're not moving so we don't need to bother checking anyting relating to the parent
		if parent.container_id != 0 then
		
		
			select count(*) into c from collection where institution_acronym=parent.institution_acronym;
			if c=0 then
				msg := msg || sep || 'You do not have access to parent container';
				sep := '; ';
			end if;
	  
			-- don't allow mixing of positions and other junk
		   	if new_child.container_type='position' and parent_notposition_count > 0 then
				msg := msg || sep || 'Parent contains not-positions and cannot contain position containers';
				sep := '; ';
			end if;
			-- limit the number of positions
			if parent_position_count > parent.number_positions then
				msg := msg || sep || 'Too many positions';
				sep := '; ';
			end if;
			if new_child.container_type != 'position' and parent_position_count > 0 then
				msg := msg || sep || 'Parent contains positions and cannot contain not-position containers';
				sep := '; ';
			end if;
			-- don't allow position movement
			if new_child.parent_container_id != old_child.parent_container_id and old_child.container_type = 'position' then
				msg := msg || sep || 'Positions may not be moved.';
				sep := '; ';
			END IF;
			-- don't allow creating positions from other container types, or creating other container type from positions
			if new_child.container_type = 'position' and (old_child.container_type != 'position' and old_child.container_type not like '% lablel') then
				msg := msg || sep || 'Positions may only be created from labels.';
				sep := '; ';
			END IF;
			-- disallow movement of explicitly-locked containers
			if old_child.locked_position=1 and new_child.parent_container_id != old_child.parent_container_id then
				msg := msg || sep || 'This container is locked in position and may not be moved.';
				sep := '; ';
			END IF;
	
			-- don't allow eg box-->box
			if new_child.container_type = parent.container_type then
				msg := msg || sep || 'Parent and child may not be of the same container_type';
				sep := '; ';
			end if;
			-- derp
			if new_child.container_id=new_child.parent_container_id then
				msg := msg || sep || 'A container may not be in itself.';
				sep := '; ';
			END IF;
		
			-- labels cannot be used
			if parent.container_type like '%label%' then
				msg := msg || sep || 'You cannot put anything in a label.';
				sep := '; ';
			END IF;
			if new_child.container_type like '%label%' and parent.container_id != 0 then
			   msg := msg || sep || 'A label cannot have a parent.';
			   sep := '; ';
			END IF;
			-- will it fit?
		
			dbms_output.put_line('new_child.height = ' || new_child.height);
			dbms_output.put_line('parent.height = ' || parent.height);
			dbms_output.put_line('new_child.width = ' || new_child.width);
			dbms_output.put_line('parent.width = ' || parent.height);
			dbms_output.put_line('new_child.length = ' || new_child.length);
			dbms_output.put_line('parent.length = ' || parent.length);
	
			if (new_child.height>parent.height) OR (new_child.width>parent.width) OR (new_child.length>parent.length) then
			  msg := msg || sep || 'The child will not fit into the parent.';
			   sep:='; ';
			END IF;
			---------------- content control -------------
			-- parts are not puttable-innable
			if parent.container_type='collection object' then
				msg := msg || sep || 'You cannot put anything in a collection object.';
				sep := '; ';
			END IF; 
			-- herbarium folders exist only to hold herbarium sheets
			if parent.container_type = 'herbarium folder' and new_child.container_type != 'herbarium sheet' then
				msg := msg || sep || 'Herbarium folders may contain only herbarium sheets';
				sep:='; ';
			END IF;   
			-- herbarium sheets exist only to hold smooshed plants
			if parent.container_type = 'herbarium sheet' and new_child.container_type != 'collection object' then
				msg := msg || sep || 'Herbarium sheets may contain only collection objects';
				sep:='; ';
			END IF;
			-- legacy containers are legacy
			if 
			 	parent.container_type = 'legacy container' or 
			 	new_child.container_type='legacy container' or 
			 	parent.container_type='unknown' or 
			 	new_child.container_type='unknown' then
				msg := msg || sep || '"unknown" and "legacy container" may not be moved.';
				sep:='; ';
			END IF;
			-- limit where positions can occur
		    if new_child.container_type='position' and parent.container_type not in ('freezer','freezer box','freezer rack','microplate','shelf','slide box') then
				msg := msg || sep || 'Positions are not allowed in ' || parent.container_type;
				sep:='; ';
			END IF;
		end if; -- end parent = 0 check

		msg_out:= msg;
	end;
/
sho err;









CREATE OR REPLACE FUNCTION containerCheck(
	-- :NEW child
	c_container_id in number,
	c_parent_container_id in number,
	c_container_type in varchar2,
	c_barcode in varchar2,
	c_height in number,
	c_length in number,
	c_width in number,
	c_institution_acronym  in varchar2,
	-- :OLD child
	oc_container_type in varchar2,
	oc_parent_container_id in number,
	oc_institution_acronym in varchar2,
	oc_barcode in varchar2,
	-- :NEW parent
	p_container_type in varchar2,
	p_height in number,
	p_length in number,
	p_width in number,
	p_institution_acronym in varchar2,
	cnt_p_c_positions in number,
	cnt_p_c_notpositions in number
	)
RETURN varchar2
	AS 
		msg varchar2(4000);
		sep varchar2(10);
		c number;
	begin
		
	if c_container_type='position' and cnt_p_c_notpositions > 0 then
		msg := msg || sep || 'Parent contains not-positions and cannot contain position containers';
		sep := '; ';
	end if;
	
	if c_container_type != 'position' and cnt_p_c_positions > 0 then
		msg := msg || sep || 'Parent contains positions and cannot contain not-position containers';
		sep := '; ';
	end if;
	
	if c_barcode != oc_barcode then
		msg := msg || sep || 'Changing barcode is not allowed';
		sep := '; ';
	end if;
	
	if c_container_type = p_container_type then
		msg := msg || sep || 'Parent and child may not be of the same container_type';
		sep := '; ';
	end if;
	
	if c_institution_acronym != oc_institution_acronym then
		msg := msg || sep || 'Changing institution_acronym is not allowed';
		sep := '; ';
	end if;
	select count(*) into c from collection where institution_acronym=c_institution_acronym;
	if c=0 then
		msg := msg || sep || 'You do not have access to child container';
		sep := '; ';
	end if;
	select count(*) into c from collection where institution_acronym=p_institution_acronym;
	if c=0 then
		msg := msg || sep || 'You do not have access to parent container';
		sep := '; ';
	end if;
	if c_parent_container_id != oc_parent_container_id and oc_container_type = 'position' then
		msg := msg || sep || 'Positions may not be moved.';
		sep := '; ';
	END IF;
	if c_container_type = 'position' or oc_container_type = 'position' and c_container_type != oc_container_type then
		msg := msg || sep || 'Positions may not be changed to other container types.';
		sep := '; ';
	END IF;
	if c_container_id=c_parent_container_id then
		msg := msg || sep || 'A container may not be in itself.';
		sep := '; ';
	END IF;
	if p_container_type='collection object' then
		msg := msg || sep || 'You cannot put anything in a collection object.';
		sep := '; ';
	END IF; 
	if p_container_type like '%label%' then
		msg := msg || sep || 'You cannot put anything in a label.';
		sep := '; ';
	END IF;
	if c_container_type like '%label%' then
	   msg := msg || sep || 'A label cannot have a parent.';
	   sep := '; ';
	END IF;  
	 if p_container_type like '%label%' then
	   msg := msg || sep || 'A label cannot be a parent.';
	   sep := '; ';
	END IF;
	
	dbms_output.put_line('c_height = ' || c_height);
	
	 if (c_height>=p_height) OR (c_width>=p_width) OR (c_length>=p_length) then
	  msg := msg || sep || 'The child will not fit into the parent.';
	   sep:='; ';
	END IF;
	if p_container_type = 'herbarium folder' and c_container_type != 'herbarium sheet' then
		msg := msg || sep || 'Herbarium folders may contain only herbarium sheets';
		sep:='; ';
	END IF;       
	if p_container_type = 'herbarium sheet' and c_container_type != 'collection object' then
		msg := msg || sep || 'Herbarium sheets may contain only collection objects';
		sep:='; ';
	END IF;
	if p_container_type = c_container_type then
		msg := msg || sep || 'A container and parent container may not share container type';
		sep:='; ';
	END IF;
	if 
	 	p_container_type = 'legacy container' or 
	 	c_container_type='legacy container' or 
	 	p_container_type='unknown' or 
	 	c_container_type='unknown' then
		msg := msg || sep || '"unknown" and "legacy container" may not be moved.';
		sep:='; ';
	END IF;
	if c_container_type='position' and p_container_type not in ('freezer','freezer box','freezer rack','microplate','shelf','slide box') then
		msg := msg || sep || 'Positions are not allowed in ' || p_container_type;
		sep:='; ';
	END IF;
	return msg;
	end;
/
sho err;
	
CREATE OR REPLACE PUBLIC SYNONYM containerCheck FOR containerCheck;
GRANT EXECUTE ON containerCheck TO manage_container;




