CREATE OR REPLACE procedure bulkUpdateContainer is 
   		old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		msg varchar2(4000);
		containerofpartid number;
		c number;
    begin
	    -- re-check important things
	    -- old_container_type is a "people checksum" - make sure it's right
	    select count(*) into c from cf_temp_lbl2contr where (barcode,OLD_CONTAINER_TYPE) not in (select barcode,container_type from container);
	    if c>0 then
	        raise_application_error(-20000, 'FAIL: old container type mismatch');
	    end if;
	    for r in (select * from cf_temp_lbl2contr) loop
	    	if r.CONTAINER_TYPE = 'position' then
	    		 raise_application_error(-20000, 'FAIL: positions may not be edited.');
	    	end if;
	    
	    	select * into old_child from container where barcode=r.barcode;
	    	if old_child.parent_container_id = 0 then
	    		parent.container_id:=0;
	    		parent_position_count:=NULL;
	    		parent_notposition_count:=NULL;
	    	else	    		
	    		select * into parent from container where container_id=old_child.parent_container_id;
	    		select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        		select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
	    	end if;
	    	if parent_position_count > 0 then
	    		-- we're trying to update a container which holds positions; disallow if positions info is being updated
	    		if 
					(nvl(old_child.NUMBER_ROWS,-1)  != nvl(r.NUMBER_ROWS,-1)) or
					(nvl(old_child.NUMBER_COLUMNS,-1)  != nvl(r.NUMBER_COLUMNS,-1)) or
					(nvl(old_child.ORIENTATION,'dFLT')  != nvl(r.ORIENTATION,'dFLT') ) or
					(nvl(old_child.POSITIONS_HOLD_CONTAINER_TYPE,'dFLT')  != nvl(r.POSITIONS_HOLD_CONTAINER_TYPE,'dFLT'))
				then
		        	raise_application_error(-20000, 'FAIL: Changing position layout of containers holding positions is not allowed.');
		        end if;
	    	end if;
	    	
	    	new_child:=old_child;
	    	new_child.CONTAINER_TYPE:=r.CONTAINER_TYPE;
	    	if r.label is not null then
	    		new_child.label:=r.label;
	    	end if;
	    	
	    	if r.DESCRIPTION is not null then
	    		new_child.DESCRIPTION:=r.DESCRIPTION;
	    	end if;	    
	    	if r.DESCRIPTION='NULL' then
	    		new_child.DESCRIPTION:=null;
	    	end if;
	    	
	    	if r.CONTAINER_REMARKS is not null then
	    		new_child.CONTAINER_REMARKS:=r.CONTAINER_REMARKS;
	    	end if;	    
	    	if r.CONTAINER_REMARKS='NULL' then
	    		new_child.CONTAINER_REMARKS:=null;
	    	end if;
	    	
	    	if r.HEIGHT is not null then
	    		new_child.HEIGHT:=r.HEIGHT;
	    	end if;	    
	    	if r.HEIGHT=0 then
	    		new_child.HEIGHT:=null;
	    	end if;
	    	
	    	if r.LENGTH is not null then
	    		new_child.LENGTH:=r.LENGTH;
	    	end if;	    
	    	if r.LENGTH=0 then
	    		new_child.LENGTH:=null;
	    	end if;
	    	
	    	if r.WIDTH is not null then
	    		new_child.WIDTH:=r.WIDTH;
	    	end if;	    
	    	if r.WIDTH=0 then
	    		new_child.WIDTH:=null;
	    	end if;
	    	
	    	if r.POSITIONS_HOLD_CONTAINER_TYPE is not null then
	    		new_child.POSITIONS_HOLD_CONTAINER_TYPE:=r.POSITIONS_HOLD_CONTAINER_TYPE;
	    	end if;
	    	if r.NUMBER_ROWS is not null then
	    		new_child.NUMBER_ROWS:=r.NUMBER_ROWS;
	    	end if;	   
	    	if r.NUMBER_COLUMNS is not null then
	    		new_child.NUMBER_COLUMNS:=r.NUMBER_COLUMNS;
	    	end if;	   
	    	if r.ORIENTATION is not null then
	    		new_child.ORIENTATION:=r.ORIENTATION;
	    	end if;	   
	    	
	    	if new_child.container_type='position' or old_child.container_type='position' then
	    		msg:='this form does not work with container type position.';
	    	else
	    		containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
	    	end if;
	    	
			if msg is not null then
	            raise_application_error(-20000, 'FAIL: ' || msg);
	        else
	        	update 
	        		container 
	        	set
	        		CONTAINER_TYPE=new_child.container_type,
	        		DESCRIPTION=new_child.DESCRIPTION,
	        		LABEL=new_child.label,
	        		CONTAINER_REMARKS=new_child.CONTAINER_REMARKS,
	        		HEIGHT=new_child.HEIGHT,
	        		LENGTH=new_child.LENGTH,
	        		WIDTH=new_child.WIDTH,
	        		NUMBER_ROWS=new_child.NUMBER_ROWS,
	        		NUMBER_COLUMNS=new_child.NUMBER_COLUMNS,
	        		ORIENTATION=new_child.ORIENTATION,
	        		POSITIONS_HOLD_CONTAINER_TYPE=new_child.POSITIONS_HOLD_CONTAINER_TYPE
	        	where
	        		CONTAINER_ID=new_child.container_id;
	        end if;
	    end loop;
	    
	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM bulkUpdateContainer FOR bulkUpdateContainer;
GRANT EXECUTE ON bulkUpdateContainer TO manage_container;

   
   
   