CREATE OR REPLACE FUNCTION concatMediaDescription (p_key_val  in varchar2 )
return varchar2
as
type rc is ref cursor;
l_str    varchar2(4000);
l_sep    varchar2(3);
l_val    varchar2(4000);
l_cur    rc;
begin
open l_cur for 'select /*+ RESULT_CACHE */ label_value
from media_labels
where
media_label=''description'' and
media_labels.media_id = :x
order by label_value'
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
  
  
  create or replace public synonym concatMediaDescription for concatMediaDescription;
  
  grant execute on concatMediaDescription to public;
  
