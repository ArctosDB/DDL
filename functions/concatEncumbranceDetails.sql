

CREATE OR REPLACE FUNCTION concatEncumbranceDetails (p_key_val  in varchar2 )
	return varchar2 as
		type rc is ref cursor;
		l_str varchar2(4000);
		l_sep varchar2(30);
		l_val varchar2(4000);
 		l_cur rc;
   begin
      open l_cur for 'select encumbrance_action
  						|| '' by '' ||agent_name || '' on ''
  						|| to_char(made_date,''yyyy-mm-dd'') || ''.''
  						|| '' Expires '' || to_char(expiration_date,''yyyy-mm-dd''
						|| ''.'')
				 		from 
							encumbrance,
							coll_object_encumbrance,
							preferred_agent_name
						where
							encumbrance.EXPIRATION_DATE > sysdate and
							encumbrance.encumbrance_id = coll_object_encumbrance.encumbrance_id and 
							encumbrance.encumbering_agent_id=preferred_agent_name.agent_id AND 
							coll_object_encumbrance.collection_object_id = :x '
					  using p_key_val;
	loop
		fetch l_cur into l_val;
   		exit when l_cur%notfound;
   		l_str := l_str || l_sep || l_val;
   		l_sep := '; ';
    end loop;
   	close l_cur;
	return l_str;
  end;
 /
 sho err;