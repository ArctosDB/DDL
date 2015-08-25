-- clean up old addr code
drop trigger tr_addr_sq;
drop trigger BUILD_FORMATTED_ADDR;


CREATE OR REPLACE TRIGGER trg_address_sq
 before insert  ON address
 for each row
    begin
	    IF :new.address_id IS NULL THEN
    		select sq_address_id.nextval into :new.address_id from dual;
    	end if;
    end;
/
sho err



CREATE OR REPLACE TRIGGER TR_ADDRESS_BU BEFORE UPDATE ON address
FOR EACH ROW
DECLARE
    ship INTEGER;
    new_data VARCHAR2(4000);
    old_data VARCHAR2(4000);
BEGIN
   old_data:=:OLD.address;
   old_data:=replace(old_data,chr(10));
   old_data:=replace(old_data,chr(13));
   old_data:=replace(old_data,' ');
   old_data:=replace(old_data,',');
   old_data:=trim(old_data);
   
   new_data:=:NEW.address;
   new_data:=replace(new_data,chr(10));
   new_data:=replace(new_data,chr(13));
   new_data:=replace(new_data,' ');
   new_data:=replace(new_data,',');
   new_data:=trim(new_data);
   
    IF old_data != new_data THEN
    	--dbms_output.put_line('changing');
        SELECT 
        	COUNT(*) 
        INTO 
        	ship
        FROM 
        	shipment
        WHERE 
        	shipped_to_addr_id = :OLD.address_id or 
        	shipped_from_addr_id = :OLD.address_id;

        IF (ship > 0) THEN
        	--dbms_output.put_line('got shipment');
            -- if we made it here we want to create a new record
            -- call procedure for autonomous transaction
            add_new_address(
                :NEW.ADDRESS_TYPE,
                :NEW.ADDRESS,
                :NEW.AGENT_ID,
                :NEW.VALID_ADDR_FG,
                :NEW.ADDRESS_REMARK);

            -- now that we've used the changes to create a new record,
            --   1) set valid_addr_fg = 0 and
            --   2) replace :NEW values with :OLD ones
            -- so that we don't update anything for the existing used record.
            -- formatted_addr gets updated by trigger BUILD_FORMATTED_ADDR

            :NEW.valid_addr_fg := 0;
            :NEW.ADDRESS := :OLD.ADDRESS;
            :NEW.agent_id := :OLD.agent_id;
            :NEW.ADDRESS_TYPE := :OLD.ADDRESS_TYPE;
            :NEW.ADDRESS_REMARK := :OLD.ADDRESS_REMARK;
        END IF;
    END IF;
END;
/
sho err
