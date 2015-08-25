--CREATE OR REPLACE TRIGGER TRG_CTAGE_CLASS_UD
CREATE OR REPLACE TRIGGER TR_CTAGE_CLASS_UD
BEFORE UPDATE OR DELETE ON ctage_class
FOR EACH ROW
DECLARE
    c number;
    v attributes.attribute_value%TYPE;
    o collection.collection_cde%TYPE;
BEGIN
    v := :old.AGE_CLASS;
    o := :OLD.COLLECTION_CDE;
    IF :OLD.age_class != :NEW.age_class THEN
        FOR r IN (
            SELECT COUNT(*) c
            FROM attributes, cataloged_item, collection
            WHERE attributes.collection_object_id = cataloged_item.collection_object_id
            AND cataloged_item.collection_id = collection.collection_id
            AND attribute_type = 'age class'
            AND attribute_value = v
            AND collection.collection_cde = o
        ) LOOP
            IF r.c > 0 THEN
                raise_application_error(
                -20001,
                v || ' (c = ' || r.c || ') is used in attributes for collection type ' || o);
            END IF;
        END LOOP;
    END IF;
END;
