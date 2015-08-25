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

