
CREATE OR REPLACE procedure moveManyPartToContainer (
	-- USAGE: 
		-- update parent_container_type
		-- move a bunch of parts (via the parent of the part-container) into the new parent
    v_collection_object_id in varchar2, -- comma-list of part IDs
    v_parent_barcode in varchar2,
    v_parent_container_type in varchar2
   ) is 
   
   	v_tab parse_list.varchar2_table;
   	 v_nfields integer;
   	 
   		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		
		msg varchar2(4000);

		containerofpartid number;

    begin
	    if v_parent_container_type is not null then
	    	-- change the parent container type
	    	select * into old_child from container where barcode=v_parent_barcode;
	    	new_child:=old_child;
	    	new_child.container_type:=v_parent_container_type;
	    	select * into parent from container where container_id=old_child.parent_container_id;
	    	select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        	select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
    	
		    containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
			if msg is not null then
	            raise_application_error(-20000, 'FAIL: ' || msg);
	        else
	        	update 
	        		container 
	        	set
	        		CONTAINER_TYPE=new_child.container_type
	        	where
	        		CONTAINER_ID=new_child.container_id;
	        end if;
	   	end if;
	   	-- now just move everything into the (potentially) newly-typed container
	   	-- parent is the barcode passed in
	   	select * into parent from container where barcode=v_parent_barcode;
		select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
    	    parse_list.delimstring_to_table (v_collection_object_id, v_tab, v_nfields);
	    
	    for i in 1..v_nfields loop
	    	-- each child is the PARENT of the collection_object_id passed in
	    	dbms_output.put_line(v_tab(i));
	    	
	    	
	    	select container.parent_container_id into containerofpartid from 
	    	coll_obj_cont_hist,container where 
	    	coll_obj_cont_hist.container_id=container.container_id and
	    	coll_obj_cont_hist.collection_object_id=v_tab(i);
	    	dbms_output.put_line('got ' || containerofpartid);
	    	select * into old_child from container where container_id=containerofpartid;
	    	new_child:=old_child;
	    	new_child.parent_container_id:=parent.container_id;
	    	
		    containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
			if msg is not null then
	            raise_application_error(-20000, 'FAIL: ' || msg);
	        else
	        	update 
	        		container 
	        	set
	        		parent_container_id=new_child.parent_container_id
	        	where
	        		CONTAINER_ID=new_child.container_id;
	        end if;
	    end loop;

	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM moveManyPartToContainer FOR moveManyPartToContainer;
GRANT EXECUTE ON moveManyPartToContainer TO manage_container;

   
   
   