-- edit for https://github.com/ArctosDB/arctos/issues/1743
-- container types like "%position" are now the things which can be created in place
-- container types which are "postion" should be created by internal forms only

CREATE OR REPLACE procedure createContainer (
    v_container_type in varchar2,
    v_label in varchar2,
    v_description in varchar2,
    v_container_remarks in varchar2,
    v_barcode in varchar2,
    v_width in number,
    v_height in number,
    v_length in number,
    v_number_rows in number,
    v_number_columns in number,
    v_orientation in varchar2,
    v_posn_hld_ctr_typ in varchar2,
    v_institution_acronym in varchar2,
    v_parent_container_id in NUMBER default 0
   ) is
		parent_position_count  number;
		parent_notposition_count  number;
		parent_number_positions number;
		parent_position_orientation varchar2(255);
		parent_container_type varchar2(255);
    begin
	    -- make sure the parent isn't a label
	    if v_parent_container_id is not null and v_parent_container_id > 0 then
		    select container_type into parent_container_type from container where container_id=v_parent_container_id;
		    if instr(parent_container_type,'label') > 0 then
	        	 raise_application_error(-20000, 'Labels may not be parents.');
	        end if;
	    end if;
        -- only insert things that need no verification; do not put containers in parents EXCEPT positions
        if v_container_type not like '%position' and v_parent_container_id != 0 then
        	 raise_application_error(-20000, 'Only "%position" containers may be created with parents.');
        end if;
        if v_barcode is not null and IS_CLAIMED_BARCODE(v_barcode) != 'PASS' then
        	 raise_application_error(-20000, 'Invalid barcode.');
       	end if;
        -- for positions, confirm placement
        if v_container_type = 'position' and v_parent_container_id != 0 then
        	if v_barcode is not null then
        		raise_application_error(-20000, 'Positions may not have barcodes.');
        	end if;
        	select (number_rows * number_columns) into parent_number_positions from container where container_id=v_parent_container_id;
        	select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=v_parent_container_id;
        	select count(*) into parent_position_count from container where container_type = 'position' and parent_container_id=v_parent_container_id;
        	if parent_number_positions is null then
        		raise_application_error(-20000, 'Parent does not have values in NUMBER_ROWS and NUMBER_COLUMNS so cannot contain positions.');
        	end if;
        	
        	if parent_notposition_count > 0 then
        		raise_application_error(-20000, 'Parent contains not-positions and cannot contain positions');
        	end if;
        	if parent_position_count >= parent_number_positions then
        		raise_application_error(-20000, 'Too many positions');
        	end if;
        	
        	select orientation into parent_position_orientation from container where container_id=v_parent_container_id;
        	if parent_position_orientation is null then
        		raise_application_error(-20000, 'Parent orientation is required to proceed.');
        	end if;

        end if;
        
       	
        insert into container (
            CONTAINER_ID,
            PARENT_CONTAINER_ID,
            CONTAINER_TYPE,
            LABEL,
            BARCODE,
            INSTITUTION_ACRONYM,
            DESCRIPTION,
            CONTAINER_REMARKS,
            length,
            width,
            height,
            NUMBER_ROWS,
            NUMBER_COLUMNS,
            ORIENTATION,
            POSITIONS_HOLD_CONTAINER_TYPE
        ) values (
            sq_container_id.nextval,
            v_parent_container_id,
            v_container_type,
            v_label,
            v_barcode,
            v_institution_acronym,
            v_description,
            v_container_remarks,
            v_length,
            v_width,
            v_height,
            v_number_rows,
    		v_number_columns,
    		v_orientation,
    		v_posn_hld_ctr_typ
        );
    end;
/
sho err;

    
CREATE OR REPLACE PUBLIC SYNONYM createContainer FOR createContainer;
GRANT EXECUTE ON createContainer TO manage_container;

   
   
--revoke insert on container from manage_container;

   