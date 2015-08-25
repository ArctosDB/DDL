CREATE OR REPLACE FUNCTION is_positive_number (inStr VARCHAR2)
RETURN INTEGER
-- to find all non-numeric values:
-- select attribute_value,is_number(attribute_value) from
-- attributes where attribute_type='numeric age'
-- and is_number(attribute_value) = 0
IS
n NUMBER;
BEGIN
    n := to_number(inStr);
	IF n > 0 THEN
        RETURN 1;
	ELSE
	    RETURN 0;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		RETURN 0;
END;
/
sho err

CREATE PUBLIC SYNONYM IS_POSITIVE_NUMBER FOR IS_POSITIVE_NUMBER;
GRANT EXECUTE ON IS_POSITIVE_NUMBER TO PUBLIC;