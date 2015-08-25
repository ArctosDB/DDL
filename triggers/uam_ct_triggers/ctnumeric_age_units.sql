CREATE OR REPLACE TRIGGER TRG_CTNUMERIC_AGE_UNITS_UD
BEFORE UPDATE OR DELETE ON ctnumeric_age_units
FOR EACH ROW
BEGIN
    FOR r IN (
        SELECT COUNT(*) c
        FROM attributes
        WHERE attribute_type = 'numeric age'
        AND attribute_units = :OLD.numeric_age_units
    ) LOOP
        IF r.c > 0 THEN
             raise_application_error(
                -20001,
                :OLD.numeric_age_units || ' is used in attribute units');
        END IF;
    END LOOP;
END;
