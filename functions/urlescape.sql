SET ESCAPE \
CREATE OR REPLACE function urlescape(str IN varchar2 )
    return varchar2 as
        final_str    varchar2(4000); 	
	begin
		-- utl_url.escape is retarded and requires a boolean to ACTUALLY escape a component
		-- that's not possible in SQL, so here we are.
		-- Woopee.
		final_str := utl_url.escape(str,TRUE,url_charset => 'UTF-8');
  		return  final_str;
  end;
/

sho err;

create or replace public synonym urlescape for urlescape;
grant execute on urlescape to public;