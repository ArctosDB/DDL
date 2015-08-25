CREATE OR REPLACE TRIGGER TR_COLLOBJENC_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON COLL_OBJECT_ENCUMBRANCE
FOR EACH ROW
DECLARE id NUMBER;
BEGIN
    IF deleting THEN 
        id := :OLD.collection_object_id;
    ELSE
        id := :NEW.collection_object_id;
    END IF;
        
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
		lastdate = SYSDATE
    WHERE collection_object_id = id;
END;



CREATE OR REPLACE TRIGGER TR_COLLOBJENC_BI
before INSERT ON COLL_OBJECT_ENCUMBRANCE
-- there is no reason anyone should ever try to change a collection_object_id - I hope....
FOR EACH ROW declare
	c number;
	ismask number;
BEGIN
   select  /*+ RESULT_CACHE */ count(*) c into ismask from encumbrance where ENCUMBRANCE_ACTION='mask record' and encumbrance_id=:NEW.encumbrance_id;
   if ismask>0 then
   		select  /*+ RESULT_CACHE */ count(*) into c from 
   			specimen_archive,archive_name 
   			where specimen_archive.archive_id=archive_name.archive_id and
   			archive_name.is_locked=1 and
   			specimen_archive.collection_object_id=:NEW.collection_object_id;
   		if c>0 then
   			RAISE_APPLICATION_ERROR(-20001,'Specimens in locked archives may not be "mask record" encumbered.');
  		 end if;
   end if;
END;
/