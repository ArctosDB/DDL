CREATE OR REPLACE procedure movePartToContainer (
    v_collection_object_id in number,
    -- part ID
    v_barcode in varchar2,
    -- barcode of part's new parent - required only if v_container_id is null
    v_container_id in number,
    -- container_id of part's new parent - required only if v_barcode is null
    v_parent_container_type in varchar2,
    -- new container_type for part's new parent
     v_parent_container_label in varchar2
    -- new label for part's new parent
   ) is    
   		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		msg varchar2(4000);
    begin
		if v_container_id is not null then
			select * into parent from container where container_id=v_container_id;
		elsif v_barcode is not null then
			select * into parent from container where barcode=v_barcode;			
		else
		  raise_application_error(-20000, 'FAIL: Need containerID or barcode');
		end if;
		select * into old_child from container where container_id=(
			select container_id from coll_obj_cont_hist where collection_object_id=v_collection_object_id
		);
		
		--dbms_output.put_line(v_parent_container_type);
		-- get new
		new_child:=old_child;
		-- give it the proper parent
		new_child.parent_container_id:=parent.container_id;
		-- autochange certain container type
		
		
		--dbms_output.put_line('v_parent_container_type: ' || v_parent_container_type);
		--dbms_output.put_line('parent.container_type: ' || parent.container_type);

				
				
		if parent.container_type='cryovial label' then
			parent.container_type:='cryovial';
		end if;
		
		-- if it is null, just update to existing value
		-- if not, update to new value
		if v_parent_container_label is not null then
			parent.LABEL:=v_parent_container_label;
		end if;
		
		
		--dbms_output.put_line('parent.container_type: ' || parent.container_type);
		
		
		-- even if we autochanged, overwrite if there's a provided type
		if v_parent_container_type is not null then
			parent.container_type:=v_parent_container_type;
		end if;
		
		
		
		--dbms_output.put_line('parent.container_type: ' || parent.container_type);
		
		
		
		select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
		containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
		if msg is not null then
            raise_application_error(-20000, 'FAIL: ' || msg);
        else
        	update 
        		container 
        	set 
        		CONTAINER_TYPE=parent.container_type,
        		label=parent.LABEL
        	where 
        		container_id=parent.container_id;
        	update 
        		container 
        	set
        		PARENT_CONTAINER_ID=parent.container_id
        	where
        		CONTAINER_ID=new_child.container_id;
        end if;
	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM movePartToContainer FOR movePartToContainer;
GRANT EXECUTE ON movePartToContainer TO manage_container;

   
   
   