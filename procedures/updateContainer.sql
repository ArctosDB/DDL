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
    v_number_rows in number,
    v_number_columns in number,
    v_orientation in varchar2,
    v_posn_hld_ctr_typ in varchar2,
    v_institution_acronym in varchar2
   ) is 
		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		msg varchar2(4000);
        sep varchar2(10);
    begin
        -- pass off to containercheck
        ---- child, as it exists now
        ---- child, as it will exist if this works
        ---- parent
        -- No updates except through this
        -- revoke update on container from manage_container;
        -- so all of the logic/business rules can live here.
        if v_parent_container_id > 0 then
        	select * into parent from container where container_id=v_parent_container_id;
        	 select count(*) into parent_position_count from container where container_type='position' and parent_container_id=v_parent_container_id;
        	select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=v_parent_container_id;
       	else
       		parent.container_id:=0;
		end if;
		
		
        select * into old_child from container where container_id=v_container_id;
        
        if v_container_type='position' or old_child.container_type='position' then
        	raise_application_error(-20000, 'FAIL: Positions cannot be edited.');
        end if;
        	
        
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
        new_child.number_rows := v_number_rows;
        new_child.number_columns := v_number_columns;
        new_child.orientation := v_orientation;
        new_child.positions_hold_container_type := v_posn_hld_ctr_typ;
        new_child.institution_acronym := v_institution_acronym;
       containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
    	
	            
    	--dbms_output.put_line('got back ' || msg);
    	
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
        		INSTITUTION_ACRONYM=v_institution_acronym,
	            NUMBER_ROWS=v_number_rows,
	            NUMBER_COLUMNS=v_number_columns,
	            ORIENTATION=v_orientation,
	            POSITIONS_HOLD_CONTAINER_TYPE=v_posn_hld_ctr_typ
        	where
        		CONTAINER_ID=v_container_id;        	
        end if;
    end;
   /
   sho err;
   

    
CREATE OR REPLACE PUBLIC SYNONYM updateContainer FOR updateContainer;
GRANT EXECUTE ON updateContainer TO manage_container;








