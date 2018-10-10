-- EDIT: optional flag to return future dates as invalid
CREATE OR REPLACE FUNCTION is_iso8601 (inp  in varchar,block_future in number default 0)
return varchar
as
	y char(4);
	mo char(2);
	d  char(2);
	h  char(2);
	mi  char(2);
	s  char(2);
	t varchar2(3);
	r varchar2(255):='valid';
	t2 varchar2(30);
	isneg number(1);
begin
IF inp IS NULL THEN
    RETURN r;
END IF;
-- deal with BCE years
if is_number(inp)=1 and abs(inp)!=inp and length(inp)=5 and regexp_like(inp,'^-[0-9]{4}$') then
	-- negative==BC - deal with only 4-digit negtive years
	return 'valid';
end if;

IF regexp_like(inp,'^[0-9]{4}$') then
	-- dbms_output.put_line('yearonly');
	y:=inp;
	
	
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}$') then
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	-- dbms_output.put_line('yyyy-mm');
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}$') then
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	-- dbms_output.put_line('yyyy-mm-dd');
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12');
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	h:=substr(inp,12,2);
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54');
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	h:=substr(inp,12,2);
	mi:=substr(inp,15,2);
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43');
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	h:=substr(inp,12,2);
	mi:=substr(inp,15,2);
	s:=substr(inp,18,2);
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}[+-][0-9]{2}$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43+03 OR yyyy-mm-ddT12:54:43-06');
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	h:=substr(inp,12,2);
	mi:=substr(inp,15,2);
	s:=substr(inp,18,2);
	t:=substr(inp,20);
elsif regexp_like(inp,'^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$') then
	-- dbms_output.put_line('yyyy-mm-ddT12:54:43Z');
	y:=substr(inp,1,4);
	mo:=substr(inp,6,2);
	d:=substr(inp,9,2);
	h:=substr(inp,12,2);
	mi:=substr(inp,15,2);
	s:=substr(inp,18,2);
	t:=substr(inp,20);
else
	-- dbms_output.put_line('somethingelse');
	r:='the input string "' || inp || '" is not in a recognizable format.';
end if;

	-- dbms_output.put_line('input: ' || inp);
	-- dbms_output.put_line('y: ' || y);
	-- dbms_output.put_line('mo: ' || mo);
	-- dbms_output.put_line('d: ' || d);
	-- dbms_output.put_line('h: ' || h);
	-- dbms_output.put_line('mi: ' || mi);
	-- dbms_output.put_line('s: ' || s);
	-- dbms_output.put_line('t: ' || t);
	-- dbms_output.put_line('checks follow. If none, then pass ');

	if mo is not null and (mo <1 or mo>12) then
			r:='month component "' || mo || '" is invalid';
			-- dbms_output.put_line('failmo: ' || mo);
	end if;
	if d is not null then
		if (d <1 or d>31) then
			-- dbms_output.put_line('failD');
			r:='d component "' || d || '" is invalid';
		end if;
		begin
			t2:=d ||'-'||mo||'-'||y;
			t2:=to_date(t2,'DD-MM-YYYY');
		exception when others then
			-- dbms_output.put_line('notadate: ' || t2);
			-- dbms_output.put_line(SQLERRM);
			r:=y||'-'||mo||'-'||d||' is not a valid date';
		end;
	end if;
	if h is not null and (h <0 or h>24) then
			r:='hour component "' || h || '" is invalid';
			-- dbms_output.put_line('failH');
	end if;
	if mi is not null and (mi <0 or mi>60) then
			r:='minute component "' || mi || '" is invalid';
			-- dbms_output.put_line('failmi');
	end if;
	if s is not null and (s <0 or s>60) then
			r:='second component "' || s || '" is invalid';
			-- dbms_output.put_line('failS');
	end if;
	if t is not null and t!='Z' and (t<-24 or t>24) then
		r:='timezone component "' || t || '" is invalid';
	end if;
	
	if block_future=1 and inp>to_char(sysdate,'yyyy-mm-dd') THEN
		r:='Future dates are disallowed.';
	end if;
	
	-- dbms_output.put_line('end checks');
	IF length(r)>200 THEN
	   -- dbms_output.put_line('r is long');
	    r:=substr(r,1,250) || '...';
	END IF;
	
	return r;
	--exception	when others then return 0;
end;
/

sho err;


CREATE OR REPLACE PUBLIC SYNONYM is_iso8601 FOR is_iso8601;
GRANT EXECUTE ON is_iso8601 TO PUBLIC;
