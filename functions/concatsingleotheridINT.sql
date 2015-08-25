
CREATE OR REPLACE FUNCTION "UAM"."CONCATSINGLEOTHERIDINT" (
    p_key_val IN number,
    p_other_col_name IN varchar2)
RETURN number
AS
    oidnum NUMBER;
    r NUMBER;
BEGIN
SELECT COUNT(*) INTO r
FROM coll_obj_other_id_num
WHERE other_id_type = p_other_col_name
AND collection_object_id = p_key_val;
IF r = 1 THEN
        SELECT other_id_number INTO oidnum
        FROM coll_obj_other_id_num
        WHERE other_id_type = p_other_col_name
        AND collection_object_id = p_key_val;
ELSE
oidnum := NULL;
END IF;
    RETURN oidnum;
END;

create public synonym ConcatSingleOtherIdInt for ConcatSingleOtherIdInt;
grant execute on ConcatSingleOtherIdInt to public;