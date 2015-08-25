
CREATE OR REPLACE FUNCTION getPreferredAgentName(aid IN varchar)
RETURN varchar
AS
   n varchar(255);
BEGIN
    SELECT  /*+ RESULT_CACHE */ preferred_agent_name INTO n FROM agent WHERE agent_id=aid;
    RETURN n;
end;
    /
    sho err;


CREATE or replace PUBLIC SYNONYM getPreferredAgentName FOR getPreferredAgentName;
GRANT EXECUTE ON getPreferredAgentName TO PUBLIC;

