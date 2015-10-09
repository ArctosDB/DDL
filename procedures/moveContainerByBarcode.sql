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
        p container%ROWTYPE;
        c container%ROWTYPE;
        pct varchar2(255);
        cct varchar2(255);
        tn number;
        
        old_child container%rowtype;
		new_child container%rowtype;
		parent container%rowtype;
		parent_position_count number;
		parent_notposition_count number;
		
		
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
		select * into parent from container where container_id=(select parent_container_id from container where barcode=parent_barcode);
		-- "parent" is child for first update
		select * into old_child from container where container_id=(select container_id from container where barcode=parent_barcode);
		-- start with that....
		new_child:=old_child;
		-- change all this proc can
		new_child.container_type:=parent_container_type;
		if old_child.container_type != new_child.container_type then
			-- only need to update the parent if there's a change
			-- get position data
			select count(*) into parent_position_count from container where container_type='position' and parent_container_id=parent.container_id;
        	select count(*) into parent_notposition_count from container where container_type != 'position' and parent_container_id=parent.container_id;
    
			containerContentCheck(old_child,new_child,parent,parent_position_count,parent_notposition_count,ccmsg);
			 if ccmsg is not null then
			 	msg := msg || sep || ccmsg ;
          		sep := '; ';
          	end if;
       end if;
   end if;
   dbms_output.put_line('moved parent');
   
   -- parent-->its parent is now dealt with, deal with parent-->child as passed in to this
	select * into parent from container where barcode=parent_barcode;
	
	  	   dbms_output.put_line('1');

	-- if we updated the parent, then we need to update this too
	if parent_container_type is not null then
		parent.container_type:=parent_container_type;
	end if;
	  	   dbms_output.put_line('2');
	select * into old_child from container where barcode=child_barcode;
	-- start with current
	new_child:=old_child;
	
	  	   dbms_output.put_line('3');
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
	if ccmsg is not null then
	 	msg := msg || sep || ccmsg ;
  		sep := '; ';
  	end if;
  	
  	
  	   dbms_output.put_line('msg: ' || msg);

	if msg is not null then
		raise_application_error( -20001, msg );
    end if;
    EXCEPTION WHEN OTHERS THEN
        raise_application_error( -20001,  msgprefix || ': ' || msg );
  end;
/
sho err


CREATE OR REPLACE PUBLIC SYNONYM moveContainerByBarcode FOR moveContainerByBarcode;
GRANT EXECUTE ON moveContainerByBarcode TO manage_container;














CREATE OR REPLACE procedure 123errror__old__moveContainerByBarcode (
    child_barcode  VARCHAR2,
    parent_barcode VARCHAR2,
    child_container_type  varchar2 default null,
    parent_container_type  varchar2 default null
    ) is
         msgprefix  VARCHAR2(255);
         msg  VARCHAR2(255);
        sep varchar2(2);
        p container%ROWTYPE;
        c container%ROWTYPE;
        pct varchar2(255);
        cct varchar2(255);
        tn number;
   begin
   -- make very sure this stays synced with trigger move_container
   --EXECUTE IMMEDIATE 'ALTER TRIGGER MOVE_CONTAINER DISABLE';
   -- bla that executes implicit commit which cannot happen
   -- without that, can never update without making table-trigger angry
   -- so, horrible awful evil hack.
   -- I'm so sorry, poor person who has found this.
   -- alter table container add bypasscheck number;
   
   	-- prime the msg for better errors
   	msgprefix:=child_barcode;
   	if child_container_type is not null then
   		msgprefix:=msgprefix || ' (' || child_container_type || ')';
   	end if;
   	msgprefix:=msgprefix || ' --> ' || parent_barcode;
   	if parent_container_type is not null then
   		msgprefix:=msgprefix || ' (' || parent_container_type || ')';
   	end if;

   	SELECT count(*) INTO tn FROM container WHERE barcode=parent_barcode;
       if tn != 1 then
       		msg := msg || sep || 'Parent container not found.' ;
           sep := '; ';
       end if;
       SELECT count(*) INTO tn FROM container WHERE barcode=child_barcode;
       if tn != 1 then
       		msg := msg || sep || 'Child container not found.' ;
           sep := '; ';
       end if;
       
       -- if we have problems here, just abort
       
         if msg is not null then
          raise_application_error( -20002, msgprefix || ': ' || msg );
       end if;
       
       select containerCheck(
			c.container_id,
			c.parent_container_id,
			decode(child_container_type,null,c.container_type,child_container_type),
			c.barcode,
			c.height,
			c.length,
			c.width,
			c.container_type,
			c.parent_container_id,
			p.container_type
			p.height,
			p.length,
			p.width) from container c, container p where c.
	-- :NEW parent
	p_container_type in varchar2,
	p_height in number,
	p_length in number,
	p_width in number
	)
RETURN varchar2
       	)
       	
       
       SELECT * INTO p FROM container WHERE barcode=parent_barcode;
       SELECT * INTO c FROM container WHERE barcode=child_barcode;
       
       if child_container_type is null then
        cct:=c.container_type;
       else
        cct:=child_container_type;
       end if;
       if parent_container_type is null then
        pct:=p.container_type;
       else
        pct:=parent_container_type;
       end if;       
        if p.container_id=c.container_id then
           msg := msg || sep || 'A container may not be in itself.';
           sep := '; ';
       END IF;

       if pct='collection object' then
           msg := msg || sep || 'You cannot put anything in a collection object.';
           sep := '; ';
       END IF; 
       if pct like '%label%' then
           msg := msg || sep || 'You cannot put anything in a label.';
           sep := '; ';
       END IF;
       if cct like '%label%' then
           msg := msg || sep || 'A label cannot have a parent.';
           sep := '; ';
       END IF;
       if pct like '%label%' then
           msg := msg || sep || 'A label cannot be a parent.';
           sep := '; ';
       END IF;
       if (c.HEIGHT>=p.HEIGHT) OR (c.WIDTH>=p.WIDTH) OR (c.LENGTH>=p.LENGTH) then
           msg := msg || sep || 'The child will not fit into the parent.';
           sep:='; ';
       END IF;
       if (c.locked_position=1) then
            msg := msg || sep || 'Locked positions cannot be moved.';
           sep:='; ';
       END IF;
       if msg is null then
           if pct != p.container_type then
                UPDATE container SET container_type=parent_container_type,bypasscheck=42 WHERE barcode=parent_barcode;
            end if;
            UPDATE container SET bypasscheck=42, parent_container_id=p.container_id,container_type=cct WHERE barcode=child_barcode;
        else
          raise_application_error( -20001, msg );
       end if;
    EXCEPTION WHEN OTHERS THEN
        raise_application_error( -20001,  msgprefix || ': ' || msg );
  end;
/
sho err


