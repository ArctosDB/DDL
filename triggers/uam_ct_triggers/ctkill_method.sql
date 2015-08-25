--CREATE OR REPLACE TRIGGER TRG_CTKILL_METHOD_UD
CREATE OR REPLACE TRIGGER TR_CTKILL_METHOD_UD
BEFORE UPDATE OR DELETE ON ctkill_method
FOR EACH ROW
BEGIN
    FOR r IN (
        SELECT COUNT(*) c
        FROM attributes,cataloged_item,collection
        WHERE attributes.collection_object_id = cataloged_item.collection_object_id
        AND cataloged_item.collection_id = collection.collection_id
        AND attribute_type = 'kill method'
        AND attribute_value = :OLD.kill_method
        AND collection.collection_cde = :OLD.collection_cde
    ) LOOP
        IF r.c > 0 THEN
             raise_application_error(
                -20001,
                :OLD.kill_method || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
