CREATE OR REPLACE TRIGGER CF_TEMP_TAXONOMY_KEY
BEFORE INSERT ON cf_temp_taxonomy
FOR EACH ROW
DECLARE nsn varchar2(4000);
BEGIN
    IF :NEW.key IS NULL THEN
        SELECT somerandomsequence.nextval
        INTO :NEW.key
        FROM dual;
    END IF;

    IF :NEW.subspecies IS NOT null THEN
        nsn := :NEW.subspecies;
    END IF;

    IF :NEW.infraspecific_rank IS NOT null THEN
        nsn := :NEW.infraspecIFic_rank || ' ' || nsn;
    END IF;

    IF :NEW.species IS NOT null THEN
        nsn := :NEW.species || ' ' || nsn;
    END IF;

    IF :NEW.genus IS NOT null THEN
        nsn := :NEW.genus || ' ' || nsn;
    END IF;

    IF :NEW.tribe IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.tribe;
        END IF;
    END IF;

    IF :NEW.subfamily IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.subfamily;
        END IF;
    END IF;

    IF :NEW.family IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.family;
        END IF;
    END IF;

    IF :NEW.suborder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.suborder;
        END IF;
    END IF;

    IF :NEW.phylorder IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylorder;
        END IF;
    END IF;

    IF :NEW.phylclass IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylclass;
        END IF;
    END IF;

    IF :NEW.phylum IS NOT null THEN
        IF nsn IS null THEN
            nsn := :NEW.phylum;
        END IF;
    END IF;

    :NEW.scientific_name := trim(nsn);
END;
