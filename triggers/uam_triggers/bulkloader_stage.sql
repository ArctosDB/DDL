CREATE OR REPLACE TRIGGER ti_bulkstage_cid before INSERT OR UPDATE ON bulkloader_stage FOR EACH ROW 
   
    BEGIN
	    if :NEW.ENTEREDTOBULKDATE is null then
	    	:NEW.ENTEREDTOBULKDATE := sysdate;
	    end if;
	end;
/