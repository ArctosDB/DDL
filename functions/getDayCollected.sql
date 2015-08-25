CREATE OR REPLACE FUNCTION getDayCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
    rby varchar(4);
    rey  varchar(4);
   BEGIN
    if length(b) < 10 OR length(e) < 10 then
    	return '';
    end if;
    rby:=substr( b, 9, 2 );
    rey:=substr( e, 9, 2 );
	if (rby!=rey) then
		return '';
	end if;
	return rby;
end;
    /
    sho err;


CREATE OR REPLACE PUBLIC SYNONYM getDayCollected FOR getDayCollected;
GRANT EXECUTE ON getDayCollected TO PUBLIC;