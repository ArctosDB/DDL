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
	   	--- User cannot change containers to which they do not have access
	   	select count(*) into c from collection where institution_acronym=old_child.institution_acronym;
		if c=0 then
			msg := msg || sep || 'You do not have access to the child container';
			sep := '; ';
		end if;
		 -- institution change is allowed only when the user has access to both the old and new institution
	   	if new_child.institution_acronym != old_child.institution_acronym then
	   		select count(*) into c from collection where institution_acronym=new_child.institution_acronym;
			if c=0 then
				msg := msg || sep || 'You do not have access to the new institution';
				sep := '; ';
			end if;
		end if;
		-- no editing barcodes; replaceParentContainer exists to move all children to a new parent, 
		-- so there is no reason to ever change a barcode, which has been the source of MANY problems
		if new_child.barcode != old_child.barcode then
			msg := msg || sep || 'Changing barcode is not allowed';
			sep := '; ';
		end if;
		-- if parent.container_id is 0, they're not moving so we don't need to bother checking anything relating to the parent
		if parent.container_id != 0 then
			-- user must have access to parent container
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
			-- limit the number of positions to parent's number_positions or fewer
			-- (exact isn't possible in any obvious way)
			if parent_position_count > parent.number_positions then
				msg := msg || sep || 'Too many positions';
				sep := '; ';
			end if;
			-- Containers which contain positions cannot contain anything else
			if new_child.container_type != 'position' and parent_position_count > 0 then
				msg := msg || sep || 'Parent contains positions and cannot contain not-position containers';
				sep := '; ';
			end if;
			/*
			-- Positions cannot be moved. Positions MAY be created with a parent
			if new_child.parent_container_id != old_child.parent_container_id and old_child.container_type = 'position' then
				msg := msg || sep || 'Positions may not be moved.';
				sep := '; ';
			END IF;
			*/
			-- EDIT
			-- Positions can be moved ONLY if they have no parent
			if 
				new_child.parent_container_id != old_child.parent_container_id and 
				old_child.container_type = 'position' and
				old_child.parent_container_id != 0 
				then
				msg := msg || sep || 'Already-placed Positions may not be moved.';
				sep := '; ';
			END IF;
			
			-- end position edit
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
	
			-- don't allow eg box-->box; parent and child must be of different container types
			-- (seems potentially problematic, but also prevents creating another freezer rack of freezer racks)
			if new_child.container_type = parent.container_type then
				msg := msg || sep || 'Parent and child may not be of the same container_type';
				sep := '; ';
			end if;
			-- derp
			if new_child.container_id=new_child.parent_container_id then
				msg := msg || sep || 'A container may not be in itself.';
				sep := '; ';
			END IF;
		
			-- labels cannot be used sa parents
			if parent.container_type like '%label%' then
				msg := msg || sep || 'You cannot put anything in a label.';
				sep := '; ';
			END IF;
			-- labels cannot be used as children
			if new_child.container_type like '%label%' and parent.container_id != 0 then
			   msg := msg || sep || 'A label cannot have a parent.';
			   sep := '; ';
			END IF;
			-- will it fit?
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
			-- legacy containers are legacy; update container type (or file an issue to get rid of container type altogether)
			-- before moving them
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
		-- now test all existing children of the container being edited (=new_child)
		-- do not allow a container to "shrink" such that it's children no longer fit
		if 
			(new_child.height is not null and new_child.height!=old_child.height) or
			(new_child.width is not null and new_child.width!=old_child.width) or
			(new_child.length is not null and new_child.length!=old_child.length)
		then
			select count(*) into c from container where
				parent_container_id=new_child.container_id and (
					height > nvl(new_child.height,9999999999) or
					width > nvl(new_child.width,9999999999) or
					length > nvl(new_child.length,9999999999)
				);
			if c>0 then
				msg := msg || sep || 'Edits to child size invalid; ' || c || ' children do not fit.';
				sep:='; ';
			end if;
		end if;
		msg_out:= msg;
	end;
/
sho err;

    
CREATE OR REPLACE PUBLIC SYNONYM containerContentCheck FOR containerContentCheck;
GRANT EXECUTE ON containerContentCheck TO manage_container;