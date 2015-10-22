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
	    	
	    	if r.NUMBER_POSITIONS is not null then
	    		new_child.NUMBER_POSITIONS:=r.NUMBER_POSITIONS;
	    	end if;	    
	    	if r.NUMBER_POSITIONS=0 then
	    		new_child.NUMBER_POSITIONS:=null;
	    	end if;
	    	
	    	containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,msg);
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
	        		NUMBER_POSITIONS=new_child.NUMBER_POSITIONS
	        	where
	        		CONTAINER_ID=new_child.container_id;
	        end if;
	    end loop;
	    
	end;
/
sho err;


CREATE OR REPLACE PUBLIC SYNONYM bulkUpdateContainer FOR bulkUpdateContainer;
GRANT EXECUTE ON bulkUpdateContainer TO manage_container;

   
   
   