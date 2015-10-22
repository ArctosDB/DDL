--select dbms_metadata.get_ddl('PROCEDURE','MOVECONTAINERBYBARCODE') FROM DUAL;

CREATE OR REPLACE procedure moveContainerByBarcode (
    child_barcode  VARCHAR2,
    parent_barcode VARCHAR2,
    child_container_type  varchar2 default null,
    parent_container_type  varchar2 default null
    ) is
        msgprefix  VARCHAR2(255);
        msg  VARCHAR2(255);
        ccmsg VARCHAR2(255);
        sep varchar2(2);
        
        old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		
		c number;
		
   begin
  
   	msgprefix:=child_barcode;
   	if child_container_type is not null then
   		msgprefix:=msgprefix || ' (' || child_container_type || ')';
   	end if;
   	msgprefix:=msgprefix || ' --> ' || parent_barcode;
   	if parent_container_type is not null then
   		msgprefix:=msgprefix || ' (' || parent_container_type || ')';
   	end if;
   	-- if parent_container_type is null, we're not changing anything.
   	-- if it's not, we MAY be changing something
   	if parent_container_type is not null then
		-- First, get what we need to feed the parent and it's parent to updateContainer
		-- parent of the parent we're trying to change.
		-- change is limited to container type, but we still need to run this first.
		-- the parent may not have a parent
		select count(*) into c from container where container_id=(select parent_container_id from container where barcode=parent_barcode);
		if c=0 then
			parent.container_id:=0;
	    	parent_position_count:=NULL;
	    	parent_notposition_count:=NULL;
	    else
	    	select * into parent from container where container_id=(select parent_container_id from container where barcode=parent_barcode);
	    	select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        	select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
	    end if;
		-- "parent" is child for first update
		select * into old_child from container where container_id=(select container_id from container where barcode=parent_barcode);
		-- start with that....
		new_child:=old_child;
		-- change all this proc can
		new_child.container_type:=parent_container_type;
		if old_child.container_type != new_child.container_type then
			-- only need to update the parent if there's a change
			-- get position data
			containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,ccmsg);
			--dbms_output.put_line('back with ccmsg=' || ccmsg);

			 if ccmsg is not null then
			 	msg := msg || sep || ccmsg ;
          		sep := '; ';
          	end if;
          	update container set container_type=new_child.container_type where barcode=parent_barcode;
       end if;
   end if;
   --dbms_output.put_line('OK to move parent');
   
   -- parent-->its parent is now dealt with, deal with parent-->child as passed in to this
	select * into parent from container where barcode=parent_barcode;
	
	select * into old_child from container where barcode=child_barcode;
	-- start with current
	new_child:=old_child;
	-- update to what's being changed
	new_child.parent_container_id:=parent.container_id;
	if child_container_type is not null then
		new_child.container_type:=child_container_type;
	end if;
	-- now call updateContainer with child-->parent
	-- get position data
	select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
    select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
    ccmsg:='';
	containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,ccmsg);
	--dbms_output.put_line('back with ccmsg=' || ccmsg);
	if ccmsg is not null then
	 	msg := msg || sep || ccmsg ;
  		sep := '; ';
  	end if;


	if msg is not null then
		raise_application_error( -20001, msgprefix || ': ' || msg );
    else
    	update 
    		container 
    	set 
    		parent_container_id=new_child.parent_container_id,
    		container_type=new_child.container_type
    	where
    		container_id=new_child.container_id;
    end if;
   -- EXCEPTION WHEN OTHERS THEN
   --     raise_application_error( -20001,  msgprefix || ': exception : ' || msg );
  end;
/
sho err


CREATE OR REPLACE PUBLIC SYNONYM moveContainerByBarcode FOR moveContainerByBarcode;
GRANT EXECUTE ON moveContainerByBarcode TO manage_container;








