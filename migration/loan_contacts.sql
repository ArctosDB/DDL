DELETE FROM trans_agent WHERE trans_agent_role = 'in-house contact';
INSERT INTO cttrans_agent_role (trans_agent_role) VALUES ('in-house contact');

BEGIN
    FOR r IN (
        SELECT
        	trans_agent.transaction_id,
        	trans_agent.agent_id,
			trans_agent.trans_agent_role 
        FROM trans_agent, loan 
        WHERE trans_agent.transaction_id = loan.transaction_id 
        AND trans_agent_role = 'authorized by'
    ) LOOP
	    INSERT INTO trans_agent (
		    trans_agent.transaction_id,
		    agent_id,
			trans_agent_role
	    ) VALUES (
		    r.transaction_id,
		    r.agent_id,
			'in-house contact');
    END LOOP;
END;
/
 
DELETE FROM trans_agent WHERE trans_agent_role = 'outside contact';
INSERT INTO cttrans_agent_role (trans_agent_role) VALUES ('outside contact');

BEGIN
    FOR r IN (
        SELECT 
            trans_agent.transaction_id,
		    trans_agent.agent_id,
			trans_agent.trans_agent_role 
        FROM trans_agent, loan 
        WHERE trans_agent.transaction_id = loan.transaction_id 
        AND trans_agent_role='received by'
    ) LOOP
    	INSERT INTO trans_agent (
    		trans_agent.transaction_id,
			agent_id,
			trans_agent_role
	    ) VALUES (
		    r.transaction_id,
			r.agent_id,
		    'outside contact');
    END LOOP;
END;
/
