CREATE OR REPLACE PROCEDURE UP_BS_ID is
BEGIN
    FOR rec IN (SELECT collection_object_id FROM bulkloader_stage) LOOP
        update bulkloader_stage 
        set collection_object_id = bulkloader_pkey.nextval
        where collection_object_id=rec.collection_object_id;
    END LOOP;
END;
/