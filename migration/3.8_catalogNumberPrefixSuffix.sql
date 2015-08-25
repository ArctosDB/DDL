*/
    GET LAM TO PULL GOOD FRESH BACKUPS
*/

CREATE TABLE dlm.cataloged_item20100909 AS SELECT * FROM cataloged_item;

ALTER TABLE cataloged_item ADD cat_num_prefix varchar2(10);
ALTER TABLE cataloged_item ADD cat_num_integer NUMBER;
ALTER TABLE cataloged_item ADD cat_num_suffix varchar2(10);

ALTER TRIGGER TR_CATITEM_AU_FLAT DISABLE;

UPDATE cataloged_item SET cat_num_integer=cat_num;

ALTER TABLE cataloged_item MODIFY cat_num_integer NOT NULL;
 
ALTER TABLE cataloged_item DROP CONSTRAINT CK_CATITEM_CATNUM;

ALTER TABLE cataloged_item MODIFY cat_num NULL;

DROP INDEX "UAM"."IU_CATITEM_CATNUM_COLLID";

UPDATE cataloged_item SET cat_num=NULL;

ALTER TABLE cataloged_item MODIFY cat_num VARCHAR2(40);

UPDATE cataloged_item SET cat_num=cat_num_integer;

ALTER TABLE cataloged_item MODIFY cat_num not NULL;

ALTER TABLE cataloged_item add CONSTRAINT CK_CATITEM_CATNUM CHECK (cat_num_integer > 0);

CREATE UNIQUE INDEX "UAM"."IU_CATITEM_CATNUM_COLLID" ON "UAM"."CATALOGED_ITEM" ("CAT_NUM", "COLLECTION_ID") TABLESPACE "UAM_IDX_1";

ALTER TRIGGER TR_CATITEM_AU_FLAT ENABLE;

CREATE OR REPLACE TRIGGER parse_cat_num
    BEFORE INSERT OR UPDATE ON cataloged_item
    FOR EACH ROW
    DECLARE
        dlms VARCHAR2(255) := '|-.; '; -- delimiters that can be used to split the "number"
    	td VARCHAR2(255);
    	dc number := 0;
    	allow_prefix_suffix NUMBER;
    BEGIN
	IF is_number(:NEW.cat_num) = 1 THEN -- just a number
	    :NEW.cat_num_prefix := NULL;
        :NEW.cat_num_integer := :NEW.cat_num;
        :NEW.cat_num_suffix := NULL;
	ELSE -- loop through list of delimiters defined above and see if one of them separates an integer
	   -- make sure we allow this
	   SELECT allow_prefix_suffix INTO allow_prefix_suffix FROM collection WHERE collection_id=:NEW.collection_id;
	   IF allow_prefix_suffix=0 THEN
	       RAISE_APPLICATION_ERROR(-20001,'This collection requires numeric catalog numbers. ' || :NEW.cat_num || ' is invalid.');
	   END IF;
	   FOR i IN 1..100 LOOP
	      td := substr(dlms,i,1);
	      EXIT WHEN td IS NULL;
	      IF instr(:NEW.cat_num,td,1,2) > 0 AND instr(:NEW.cat_num,td,1,3)=0 THEN
	          -- we have a 3-part string
	          dc:=dc+1;
	          :NEW.cat_num_prefix := get_str_el (:NEW.cat_num,td,1) || td;
	          :NEW.cat_num_integer := get_str_el (:NEW.cat_num,td,2);
	          :NEW.cat_num_suffix := td || get_str_el (:NEW.cat_num,td,3);
          ELSIF instr(:NEW.cat_num,td) > 0 AND instr(:NEW.cat_num,td,1,2)=0 THEN
              -- got a 2-part string
              dc:=dc+1;
              IF is_number(get_str_el (:NEW.cat_num,td,1)) = 1 THEN
                  -- got suffix
                  :NEW.cat_num_prefix := NULL;
                  :NEW.cat_num_integer:=get_str_el (:NEW.cat_num,td,1);
                  :NEW.cat_num_suffix:=td || get_str_el (:NEW.cat_num,td,2);
              ELSIF is_number(get_str_el(:NEW.cat_num,td,2)) = 1 THEN
                  -- got prefix
                  :NEW.cat_num_prefix:=get_str_el(:NEW.cat_num,td,1) || td;
                  :NEW.cat_num_integer:=get_str_el(:NEW.cat_num,td,2);
                  :NEW.cat_num_suffix := NULL;
              --ELSE something goofy happened, fail later
              END IF;
          END IF;
       END LOOP;
    END IF;
    if dc>1 then
    	RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: more than one potentially valid delimiter found');
    end if;
    IF :NEW.cat_num_integer IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: a numeric component could not be found in input (' || :NEW.cat_num || ')'); 
    END IF;
    IF (:NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix) != :NEW.cat_num THEN
       RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: result (' || :NEW.cat_num_prefix || :NEW.cat_num_integer || :NEW.cat_num_suffix || ') is not input (' || :NEW.cat_num || ')');
    END IF;
    IF is_number(:NEW.cat_num_integer) = 0 THEN
      RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is not numeric');
    END IF;
      IF round(:NEW.cat_num_integer) != :NEW.cat_num_integer THEN
          RAISE_APPLICATION_ERROR(-20001,'catnum parse failed: integer component (' || :NEW.cat_num_integer || ') is decimal');
      END IF;
end;
/
sho err


-- bulkloader.sql
/*
	OLD:@1244
	select nvl(max(cat_num),0) + 1 into l_cat_num from cataloged_item,collection
	NEW:
	select nvl(max(cat_num_integer),0) + 1 into l_cat_num from cataloged_item,collection
	

*/
ALTER TRIGGER TR_collection_AU_FLAT DISABLE;

ALTER TABLE collection ADD allow_prefix_suffix NUMBER;
UPDATE collection SET allow_prefix_suffix=0;
ALTER TABLE collection MODIFY allow_prefix_suffix NOT NULL;
ALTER TABLE collection add CONSTRAINT check_allow_prefix_suffix CHECK (allow_prefix_suffix IN (0,1));

ALTER TRIGGER TR_collection_AU_FLAT ENABLE;

ALTER TABLE flat ADD t NUMBER;
UPDATE flat SET t=cat_num;
ALTER TABLE flat MODIFY cat_num NULL;
UPDATE flat SET cat_num=NULL;

ALTER TABLE flat MODIFY cat_num VARCHAR2(40);

UPDATE flat SET cat_num=t;

ALTER TABLE flat DROP COLUMN t;
