CREATE OR REPLACE FUNCTION is_markdown (inp  in varchar)
return varchar
-- validate markdown
-- allow characters
  -- [PRINT] class
  -- chr(10)
  -- chr(13)
as
	t varchar2(4000);
	r varchar2(255):='valid';
begin
	

IF inp IS NULL THEN
    RETURN r;
END IF;
t:=inp;
t:=replace(t,chr(10));
t:=replace(t,chr(13));

if regexp_like(t,'[^[:print:]]') then
	r:='Invalid characters detected; only PRINT-class characters and linefeeds are allowed in markdown.';
end if;
return r;
end;
/

sho err;


CREATE OR REPLACE PUBLIC SYNONYM is_markdown FOR is_markdown;
GRANT EXECUTE ON is_markdown TO PUBLIC;
