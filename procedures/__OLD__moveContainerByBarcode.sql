--select dbms_metadata.get_ddl('PROCEDURE','MOVECONTAINERBYBARCODE') FROM DUAL;


CREATE OR REPLACE procedure moveContainerByBarcode (
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


CREATE OR REPLACE PUBLIC SYNONYM moveContainerByBarcode FOR moveContainerByBarcode;
GRANT EXECUTE ON moveContainerByBarcode TO manage_container;


