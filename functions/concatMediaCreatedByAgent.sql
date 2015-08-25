CREATE OR REPLACE FUNCTION concatMediaCreatedByAgent (p_key_val  in varchar2 )
return varchar2
as
type rc is ref cursor;
l_str    varchar2(4000);
l_sep    varchar2(3);
l_val    varchar2(4000);
l_cur    rc;
begin
open l_cur for 'select /*+ RESULT_CACHE */ agent_name
from preferred_agent_name,media_relations
where
media_relations.related_primary_key=preferred_agent_name.agent_id AND
media_relations.media_relationship=''created by agent'' and
media_relations.media_id = :x
order by agent_name'
using p_key_val;
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
  
  
  create or replace public synonym concatMediaCreatedByAgent for concatMediaCreatedByAgent;
  
  grant execute on concatMediaCreatedByAgent to public;
  
  