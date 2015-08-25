CREATE OR REPLACE TRIGGER ENFORCE_CITATION_TYPE
BEFORE UPDATE OR INSERT ON CITATION
FOR EACH ROW
DECLARE IS_PEER_REVIEWED_FG publication.IS_PEER_REVIEWED_FG%TYPE;
BEGIN
    SELECT IS_PEER_REVIEWED_FG INTO IS_PEER_REVIEWED_FG 
    FROM publication 
    WHERE publication_id = :new.publication_id;
    
    IF IS_PEER_REVIEWED_FG = 1 AND :new.type_status = 'referral' THEN
        raise_application_error(
            -20001,
            'Invalid type_status for this is_peer_reviewed_fg');
    ELSIF IS_PEER_REVIEWED_FG = 0 AND :new.type_status != 'referral' THEN
        raise_application_error(
            -20001,
            'Invalid type_status for this is_peer_reviewed_fg');
    END IF;
END;

CREATE OR REPLACE TRIGGER TR_CITATION_AIUD_FLAT
AFTER INSERT OR UPDATE OR DELETE ON CITATION
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

CREATE OR REPLACE TRIGGER COLLECTING_EVENT_CT_CHECK
before UPDATE or INSERT
ON collecting_event
for each row
declare
numrows number;
BEGIN
SELECT COUNT(*) INTO numrows FROM ctcollecting_source WHERE collecting_source = 
:NEW.collecting_source;
	IF (numrows = 0) THEN
		 raise_application_error(
		-20001,
		'Invalid collecting_source'
	   );
	END IF;
END;
