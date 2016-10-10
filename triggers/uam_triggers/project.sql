CREATE OR REPLACE TRIGGER TR_PROJECT_BIU
BEFORE UPDATE OR INSERT ON PROJECT
FOR EACH ROW
declare
	c number;
BEGIN
	IF is_iso8601(:NEW.start_date) != 'valid' then
		raise_application_error(-20001,'start_date: ' || is_iso8601(:NEW.start_date));
	end if;
	IF is_iso8601(:NEW.end_date) != 'valid' then
		raise_application_error(-20001,'end_date: ' || is_iso8601(:NEW.end_date));
	end if;

END;
/

