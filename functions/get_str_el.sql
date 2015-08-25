create or replace function get_str_el (
   	mystring in varchar,
   	separator in varchar,
   	pos in number)
   	return varchar2
   	as
   		theThingy varchar2(4000);
   	begin
   		    
 select bla into theThingy from (
 SELECT rownum r,SUBSTR( mystring || separator,
                    NVL(LAG(TOKEN) OVER (ORDER BY TOKEN),0) + 1,
                    TOKEN - (NVL(LAG(TOKEN) OVER (ORDER BY TOKEN),0) + 1)) bla
      FROM (
     SELECT LEVEL,
            INSTR( mystring || separator, separator, 1, LEVEL ) TOKEN
       FROM DUAL
     CONNECT BY
        INSTR( mystring || separator, separator, 1, LEVEL ) != 0
    ORDER BY
       LEVEL
       ))
       where r=pos;     	  
     
     	  return theThingy;
     	  
     	  -- select get_str_el('a-b','-',1) from dual;
     	  -- select get_str_el('a b',' ',1) from dual;
     	  -- select get_str_el('a b',' ',23) from dual;
     	  -- select get_str_el('a|b','|',18) from dual;

   	end;
   	/
