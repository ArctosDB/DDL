CREATE OR REPLACE function ConcatImageUrl(p_key_val  in number)
    return varchar2
    as
 type rc is ref cursor;
        l_str    clob;
       l_sep    clob;
       l_val    clob;

       l_cur    rc;
   		
   begin
   	open l_cur for 'select  media_uri
                         from media,media_relations
                        where 
                       media.media_id=media_relations.media_id and
                       MEDIA_RELATIONSHIP like ''% cataloged_item'' and
                       RELATED_PRIMARY_KEY  = :x '
                          using p_key_val;
      loop
           fetch l_cur into l_val;
           exit when l_cur%notfound;
           l_str := l_str || l_sep || l_val;
           l_sep := ' ';
       end loop;
       close l_cur;

       return l_str;
   end;
/
create OR REPLACE public synonym ConcatImageUrl for ConcatImageUrl;
grant execute on ConcatImageUrl to public;