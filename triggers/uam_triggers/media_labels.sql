CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_SQ
BEFORE INSERT ON MEDIA_LABELS
FOR EACH ROW
BEGIN
    IF :new.media_label_id IS NULL THEN
    	SELECT sq_media_label_id.nextval
    	INTO :new.media_label_id
    	FROM dual;
    END IF;
        
    IF :NEW.assigned_by_agent_id IS NULL THEN
    	SELECT agent_name.agent_id
		INTO :NEW.assigned_by_agent_id
		FROM agent_name
		WHERE agent_name_type = 'login'
		AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
    if :NEW.assigned_on_date is null then
    	:NEW.assigned_on_date:=sysdate;
    end if;
end;
/
sho err;


CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_SQ
BEFORE INSERT ON MEDIA_LABELS
FOR EACH ROW
BEGIN
    IF :new.media_label_id IS NULL THEN
    	SELECT sq_media_label_id.nextval
    	INTO :new.media_label_id
    	FROM dual;
    END IF;
        
    IF :NEW.assigned_by_agent_id IS NULL THEN
    	SELECT agent_name.agent_id
		INTO :NEW.assigned_by_agent_id
		FROM agent_name
		WHERE agent_name_type = 'login'
		AND upper(agent_name.agent_name) = SYS_CONTEXT('USERENV','SESSION_USER');
    end if;
end;

CREATE OR REPLACE TRIGGER TR_MEDIA_LABELS_BIU
BEFORE INSERT or UPDATE ON MEDIA_LABELS
FOR EACH ROW
DECLARE isgd VARCHAR2(255);
BEGIN
    IF :new.media_label in ('created date','begin date','begin date','end date','made date') then
    	select is_iso8601(:NEW.label_value) into isgd from dual;
    	if isgd != 'valid' then
    		 raise_application_error(-20001,'Invalid value for ' || :NEW.media_label);
    	end if;
    end if;
end;
/
