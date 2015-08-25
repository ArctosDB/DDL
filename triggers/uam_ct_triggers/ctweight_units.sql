CREATE OR REPLACE TRIGGER TR_CTWEIGHT_UNITS_UD
BEFORE UPDATE OR DELETE ON ctweight_units
FOR EACH ROW
BEGIN
    IF :new.weight_units != :old.weight_units THEN
        FOR r IN (
            SELECT COUNT(*) c
            FROM attributes
            WHERE attribute_type LIKE '%weight'
            AND attribute_units = :OLD.weight_units
        ) LOOP
            IF r.c > 0 THEN
                 raise_application_error(
                    -20001,
                    :OLD.weight_units || ' is used in attribute units');
            END IF;
        END LOOP;
    END IF;
END;
