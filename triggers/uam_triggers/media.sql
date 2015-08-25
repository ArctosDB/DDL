CREATE OR REPLACE TRIGGER TR_MEDIA_SQ
BEFORE INSERT OR UPDATE ON MEDIA
FOR EACH ROW
BEGIN
    IF inserting THEN
        IF :new.media_id IS NULL THEN
        	SELECT sq_media_id.nextval
    		INTO :new.media_id
    		FROM dual;
        END IF;
    END IF;
    IF :new.media_type='multi-page document' AND :new.mime_type != 'image/jpeg' THEN
        RAISE_APPLICATION_ERROR(
    	    -20001,
		    'Only JPGs may be arranged as multi-page documents.'
		);
    END IF;
END;
