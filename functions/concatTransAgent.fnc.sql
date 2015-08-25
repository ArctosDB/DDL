 CREATE OR REPLACE FUNCTION concattransagent (
    trans_id in number,trans_agent_role IN VARCHAR )
return varchar2
as
type rc is ref cursor;
l_str    varchar2(4000);
l_sep    varchar2(3);
l_val    varchar2(4000);
l_cur    rc;
begin
open l_cur for 'select agent_name
from
        preferred_agent_name,trans_agent
where
trans_agent.agent_id=preferred_agent_name.agent_id AND
trans_agent.transaction_id = :x and
trans_agent.trans_agent_role = :y
order by agent_name'
using trans_id,trans_agent_role;
loop
fetch l_cur into l_val;
exit when l_cur%notfound;
l_str := l_str || l_sep || l_val;
l_sep := ', ';
end loop;
close l_cur;
       return l_str;
  end;
/
show err

create OR REPLACE public synonym concattransagent for concattransagent;
grant execute on concattransagent to public; 
