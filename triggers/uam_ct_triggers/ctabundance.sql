--CREATE OR REPLACE TRIGGER TRG_CTABUNDANCE_UD
CREATE OR REPLACE TRIGGER TR_CTABUNDANCE_UD
BEFORE UPDATE OR DELETE ON ctabundance
FOR EACH ROW
DECLARE
    c number;
    v attributes.attribute_value%TYPE;
    o collection.collection_cde%TYPE;
BEGIN
    if :OLD.abundance != :NEW.abundance then
		v := :old.abundance;
	    o := :OLD.COLLECTION_CDE;
	
	    FOR r IN (
	        SELECT COUNT(*) c
	        FROM attributes, cataloged_item, collection
	        WHERE attributes.collection_object_id = cataloged_item.collection_object_id
	        AND cataloged_item.collection_id = collection.collection_id
	        AND attribute_type = 'abundance'
	        AND attribute_value = v
	        AND collection.collection_cde = o
	    ) LOOP
	        IF r.c > 0 THEN
	            raise_application_error(
	                -20001,
	                v || ' (c = ' || r.c || ') is used in attributes for collection type ' || o);
	        END IF;
	    END LOOP;
	end if;
END;
