CREATE OR REPLACE TRIGGER TR_CATITEM_VPD_AD
AFTER DELETE ON CATALOGED_ITEM
FOR EACH ROW
DECLARE lid collecting_event.locality_id%TYPE;
BEGIN
    SELECT locality_id INTO lid
	FROM collecting_event
	WHERE collecting_event_id = :OLD.collecting_event_id;
	
    UPDATE vpd_collection_locality
	SET stale_fg = 1
    WHERE locality_id = lid
	AND collection_id = :OLD.collection_id;
END;

CREATE OR REPLACE TRIGGER TR_CATITEM_AD_FLAT
AFTER DELETE ON CATALOGED_ITEM
FOR EACH ROW
BEGIN
    DELETE FROM flat
	WHERE collection_object_id = :OLD.collection_object_id;
END;

CREATE OR REPLACE TRIGGER TR_CATITEM_AI_FLAT
AFTER INSERT ON CATALOGED_ITEM
FOR EACH ROW
BEGIN
    INSERT INTO flat (
        collection_object_id,
		cat_num,
		accn_id,
		collecting_event_id,
		collection_cde,
		collection_id,
		catalognumbertext,
		stale_flag)
    VALUES (
        :NEW.collection_object_id,
		:NEW.cat_num,
		:NEW.accn_id,
		:NEW.collecting_event_id,
		:NEW.collection_cde,
		:NEW.collection_id,
		to_char(:NEW.cat_num),
		1);
END;

CREATE OR REPLACE TRIGGER TR_CATITEM_VPD_AIU
AFTER INSERT OR UPDATE ON CATALOGED_ITEM
FOR EACH ROW
DECLARE lid collecting_event.locality_id%TYPE;
BEGIN
    SELECT locality_id INTO lid
    FROM collecting_event
	WHERE collecting_event_id = :NEW.collecting_event_id;
	
	INSERT INTO vpd_collection_locality (
	    collection_id,
	    locality_id)
    VALUES(
        :NEW.collection_id,
        lid);
EXCEPTION
    WHEN dup_val_on_index THEN
        NULL;
END;

CREATE OR REPLACE TRIGGER TR_CATITEM_AU_FLAT
AFTER UPDATE ON CATALOGED_ITEM
FOR EACH ROW
BEGIN
    UPDATE flat SET 
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
		lastdate = SYSDATE
    WHERE collection_object_id = :OLD.collection_object_id
    OR collection_object_id = :NEW.collection_object_id;
END;


CREATE OR REPLACE TRIGGER TR_CATITEM_BIU
before insert or UPDATE ON CATALOGED_ITEM
FOR EACH ROW
BEGIN
    if :NEW.cat_num like '%/%' then
    	  raise_application_error(-20001,'Catnum may not contain forward slash.');
    end if;
    if :NEW.cat_num like '% %' then
    	  raise_application_error(-20001,'Catnum may not contain space.');
    end if;
END;
/
sho err;

