CREATE OR REPLACE TRIGGER ti_bulkstage_cid before INSERT OR UPDATE ON bulkloader_stage FOR EACH ROW 
   
    BEGIN
	    if :NEW.ENTEREDTOBULKDATE is null then
	    	:NEW.ENTEREDTOBULKDATE := sysdate;
	    end if;
	     IF :new.collection_object_id IS NULL THEN
	            SELECT somerandomsequence.nextval
	            INTO :NEW.collection_object_id
	            FROM dual;
	        END IF;
	end;
/