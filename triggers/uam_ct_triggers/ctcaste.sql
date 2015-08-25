--CREATE OR REPLACE TRIGGER TRG_CTCASTE_UD
CREATE OR REPLACE TRIGGER TR_CTCASTE_UD
BEFORE UPDATE OR DELETE ON ctcaste
FOR EACH ROW
BEGIN
    FOR r IN (
        SELECT COUNT(*) c
        FROM attributes, cataloged_item, collection
        WHERE attributes.collection_object_id = cataloged_item.collection_object_id
        AND cataloged_item.collection_id = collection.collection_id
        AND attribute_type = 'caste'
        AND attribute_value = :OLD.caste
        AND collection.collection_cde = :OLD.collection_cde
    ) LOOP
        IF r.c > 0 THEN
             raise_application_error(
                -20001,
                :OLD.caste || ' is used in attributes for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
