
CREATE OR REPLACE FUNCTION 

deprecated

containerCheck(
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




