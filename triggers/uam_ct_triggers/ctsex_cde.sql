CREATE OR REPLACE TRIGGER TR_CTSEX_CDE_UD
BEFORE UPDATE OR DELETE ON ctsex_cde
FOR EACH ROW
BEGIN
   IF :old.sex_cde != :new.sex_cde THEN 
       FOR r IN (
            SELECT COUNT(*) c
            FROM attributes, cataloged_item, collection
            WHERE attributes.collection_object_id = cataloged_item.collection_object_id
            AND cataloged_item.collection_id = collection.collection_id
            AND attribute_type = 'sex'
            AND attribute_value = :OLD.sex_cde
            AND collection.collection_cde = :OLD.collection_cde
        ) LOOP
            IF r.c > 0 THEN
                 raise_application_error(
                    -20001,
                    :OLD.sex_cde || ' is used in attributes for collection type ' || :OLD.collection_cde);
            END IF;
        END LOOP;
   END IF;
END;
