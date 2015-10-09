CREATE OR REPLACE TRIGGER TRANS_AGENT_ENTERED
AFTER INSERT ON TRANS
FOR EACH ROW
BEGIN
	INSERT INTO trans_agent (
        transaction_id,
        agent_id,
        trans_agent_role) (
    SELECT
        :new.transaction_id,
        agent_name.agent_id,
        'entered by'
    FROM agent_name
    WHERE agent_name_type = 'login'
    AND UPPER(agent_name) = UPPER(USER));
END;

CREATE OR REPLACE TRIGGER trg_TRANS_datecheck
before INSERT or update ON TRANS
FOR EACH ROW
	declare status varchar2(255);
BEGIN
	status:=is_iso8601(:NEW.TRANS_DATE);
    IF status != 'valid' THEN
        raise_application_error(-20001,'TRANS_DATE: ' || status);
    END IF;
END;
/
sho err
