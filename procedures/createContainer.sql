
revoke insert on container from manage_container;

CREATE OR REPLACE procedure createContainer (
    v_container_type in varchar2,
    v_label in varchar2,
    v_description in varchar2,
    v_container_remarks in varchar2,
    v_barcode in varchar2,
    v_width in number,
    v_height in number,
    v_length in number,
    v_number_positions in number,
    v_institution_acronym in varchar2,
    v_parent_container_id in NUMBER default 0
   ) is 
    begin
        -- only insert things that need no verification; do not put containers in parents EXCEPT positions
        if v_container_type != 'position' and v_parent_container_id != 0 then
        	 raise_application_error(-20000, 'Only positions may be created with parents.');
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
            height
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
            v_height
        );
    end;
/
sho err;

    
CREATE OR REPLACE PUBLIC SYNONYM createContainer FOR createContainer;
GRANT EXECUTE ON createContainer TO manage_container;

   
   
   