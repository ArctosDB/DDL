CREATE OR REPLACE TRIGGER TR_SPECIMEN_ANNOTATIONS_SQ 
BEFORE INSERT ON SPECIMEN_ANNOTATIONS
FOR EACH ROW
BEGIN
    IF :NEW.annotation_id IS NULL THEN
        SELECT sq_annotation_id.nextval
        INTO :new.annotation_id
        FROM dual;
    END IF;
        
    IF :NEW.annotate_date IS NULL THEN
        :NEW.annotate_date := sysdate;
    END IF;
END;
