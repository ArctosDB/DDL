CREATE OR REPLACE TRIGGER TR_CTSPECIMEN_PRES_MET_UD
BEFORE UPDATE OR DELETE ON ctspecimen_preserv_method
FOR EACH ROW
BEGIN
    FOR r IN (
        SELECT COUNT(*) c
        FROM specimen_part, cataloged_item, collection
        WHERE specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
        AND cataloged_item.collection_id = collection.collection_id
        AND part_name = :OLD.preserve_method
        AND collection.collection_cde = :OLD.collection_cde
    ) LOOP
        IF r.c > 0 THEN
            raise_application_error(
                -20001,
                :OLD.PRESERVE_METHOD || ' is used for collection type ' || :OLD.collection_cde);
        END IF;
    END LOOP;
END;
