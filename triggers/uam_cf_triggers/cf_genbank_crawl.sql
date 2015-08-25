CREATE OR REPLACE TRIGGER TRG_CF_GENBANK_CRAWL
BEFORE INSERT OR UPDATE ON cf_genbank_crawl
FOR EACH ROW
BEGIN
    SELECT somerandomsequence.nextval
    INTO :NEW.gbcid
    FROM dual;
END;
