CREATE OR REPLACE TRIGGER TR_CTSPECIMEN_PART_NAME_UD
BEFORE insert or UPDATE OR DELETE ON ctspecimen_part_name
FOR EACH ROW
DECLARE
    c number;
BEGIN
	FOR r IN (
		SELECT COUNT(*) c
		FROM specimen_part, cataloged_item, collection
		WHERE specimen_part.derived_from_cat_item = cataloged_item.collection_object_id
		AND cataloged_item.collection_id = collection.collection_id
		AND part_name = :OLD.part_name
		AND collection.collection_cde = :OLD.collection_cde
	) LOOP
		IF r.c > 0 THEN
		    IF deleting THEN
				raise_application_error(
					-20001,
					:OLD.part_name || ' is used for collection type ' || :OLD.collection_cde);
		    ELSIF updating THEN
			    IF :OLD.part_name != :NEW.part_name OR :OLD.collection_cde != :NEW.collection_cde THEN
				    raise_application_error(
					    -20001,
					    :OLD.part_name || ' is used for collection type ' || :OLD.collection_cde);
			     END IF;
		    END IF;
		END IF;
	END LOOP;

	
END;
