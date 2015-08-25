CREATE OR REPLACE PROCEDURE VPD_COLLECTION_LOCALITY_STALE IS
    n NUMBER;
BEGIN
    FOR r IN (
        SELECT locality_id, collection_id
        FROM vpd_collection_locality WHERE stale_fg = 1
    ) LOOP
        SELECT COUNT(*) INTO n
        FROM cataloged_item, collecting_event
        WHERE cataloged_item.collecting_event_id = collecting_event.collecting_event_id
        AND collecting_event.locality_id = r.locality_id
        AND cataloged_item.collection_id = r.collection_id;
        
        IF n = 0 THEN
            DELETE FROM vpd_collection_locality
            WHERE locality_id = r.locality_id
            AND collection_id=r.collection_id;
        ELSE
            UPDATE vpd_collection_locality
            SET stale_fg = 0
            WHERE locality_id = r.locality_id
            AND collection_id=r.collection_id;
        END IF;
    END LOOP;
END;
/