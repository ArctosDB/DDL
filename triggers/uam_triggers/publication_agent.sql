
CREATE OR REPLACE TRIGGER tr_publication_agent_biu
BEFORE UPDATE OR INSERT ON publication_agent
FOR EACH ROW
BEGIN
    IF :new.AGENT_ID=0 THEN
        raise_application_error(
            -20001,
            'Agent Zero cannot act as a publication agent.');
    END IF;
END;
/
