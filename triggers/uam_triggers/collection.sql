CREATE OR REPLACE TRIGGER TR_COLLECTION_AU_FLAT
	AFTER UPDATE ON collection FOR EACH ROW
	BEGIN
		if (:NEW.COLLECTION != :OLD.collection) OR (:new.guid_prefix != :old.guid_prefix) OR (:new.USE_LICENSE_ID != :old.USE_LICENSE_ID)  then
			UPDATE flat SET stale_flag = 1 WHERE collection_id = :OLD.collection_id;
		end if;
	END;
/
sho err;


ALTER TRIGGER TR_COLLECTION_AU_FLAT ENABLE;

CREATE OR REPLACE TRIGGER TR_COLLECTION_SYNC_BUID
BEFORE UPDATE OR INSERT OR DELETE ON collection
FOR EACH ROW
BEGIN
    IF inserting THEN
        INSERT INTO cf_collection (
            cf_collection_id,
            collection_id,
            dbusername,
            dbpwd,
            portal_name,
            collection,
            institution,
            descr)
        VALUES (
            :NEW.collection_id,
            :NEW.collection_id,
            'PUB_USR_' || upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
            'userpw.' || :NEW.collection_id,
            upper(:NEW.institution_acronym) || '_' || upper(:NEW.collection_cde),
            :NEW.collection,
            :NEW.institution,
            :NEW.descr);
    ELSIF deleting THEN
        DELETE FROM cf_collection WHERE collection_id = :OLD.collection_id;
    ELSIF updating THEN
        IF (:NEW.institution_acronym != :OLD.institution_acronym
            or :NEW.collection_cde != :OLD.collection_cde
            or :NEW.collection_id != :OLD.collection_id)
        THEN
            raise_application_error(
                -20000,
                'TR_COLLECTION_SYNC_BUID - You may not update the Institution Acronym or Collection Code or Collection ID!');
        ELSE
            UPDATE cf_collection
            SET
                collection = :NEW.collection,
                institution = :NEW.institution,
                descr = :NEW.descr
            WHERE collection_id = :OLD.collection_id;
        END IF;
    END IF;
END;
/

ALTER TRIGGER TR_COLLECTION_SYNC_BUID ENABLE;

