CREATE OR REPLACE FUNCTION IS_NUMBER (inStr varchar2 )
return integer
-- to find all non-numeric values:
-- select attribute_value,is_number(attribute_value) from
-- attributes where attribute_type='numeric age'
-- and is_number(attribute_value) = 0
IS
n number;
BEGIN
n := to_number(inStr);
RETURN 1;
EXCEPTION
WHEN OTHERS THEN
RETURN 0;
END;