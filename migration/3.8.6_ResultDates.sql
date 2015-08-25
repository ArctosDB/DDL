CREATE OR REPLACE FUNCTION getYearCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
   rby varchar(4);
    rey  varchar(4);
BEGIN
    if length(b) < 4 OR length(e) < 4 then
    	return '00';
    end if;
    rby:=substr( b, 1, 4 );
    rey:=substr( e, 1, 4 );
	if (rby!=rey) then
		return '00';
	end if;
	return rby;
end;
    /
    sho err;


CREATE OR REPLACE PUBLIC SYNONYM getYearCollected FOR getYearCollected;
GRANT EXECUTE ON getYearCollected TO PUBLIC;



CREATE OR REPLACE FUNCTION getMonthCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
    rby varchar(4);
    rey  varchar(4);
   BEGIN
    if length(b) < 7 OR length(e) < 7 then
    	return '00';
    end if;
    rby:=substr( b, 6, 2 );
    rey:=substr( e, 6, 2 );
	if (rby!=rey) then
		return '00';
	end if;
	return rby;
end;
    /
    sho err;


CREATE OR REPLACE PUBLIC SYNONYM getMonthCollected FOR getMonthCollected;
GRANT EXECUTE ON getMonthCollected TO PUBLIC;


CREATE OR REPLACE FUNCTION getDayCollected(b IN varchar,e IN varchar)
RETURN varchar
AS
    rby varchar(4);
    rey  varchar(4);
   BEGIN
    if length(b) < 10 OR length(e) < 10 then
    	return '00';
    end if;
    rby:=substr( b, 9, 2 );
    rey:=substr( e, 9, 2 );
	if (rby!=rey) then
		return '00';
	end if;
	return rby;
end;
    /
    sho err;


CREATE OR REPLACE PUBLIC SYNONYM getDayCollected FOR getMonthCollected;
GRANT EXECUTE ON getDayCollected TO PUBLIC;


UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER>45;

INsert INTO cf_spec_res_cols
(COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) VALUES (
'_day_of_ymd',NULL,'specimen',someRandomSequence.nextval,46);	



ALTER TABLE flat ADD preparators VARCHAR2(4000);
-- REBUILD UPDATE_FLAT

-- schedule this:

UPDATE flat SET preparators=concatprep(collection_object_id) WHERE collection_id=29 AND catnum<1000;

UPDATE cf_spec_res_cols SET DISP_ORDER=DISP_ORDER+1 WHERE DISP_ORDER>16;

INsert INTO cf_spec_res_cols
(COLUMN_NAME,SQL_ELEMENT,CATEGORY,CF_SPEC_RES_COLS_ID,DISP_ORDER) VALUES (
'preparators','flatTableName.preparators','specimen',someRandomSequence.nextval,17);	
ALTER TABLE media DROP COLUMN license_uri;
ALTER TABLE media DROP COLUMN media_license;


ALTER TABLE media ADD media_license_id NUMBER;

CREATE INDEX id_media_media_lic_id ON media(media_license_id) TABLESPACE uam_idx_1;


CREATE SEQUENCE sq_media_license_id;
create or replace public synonym sq_media_license_id for sq_media_license_id;
grant select on sq_media_license_id to public;

 CREATE TABLE ctmedia_license (
 media_license_id NUMBER NOT NULL,
 display VARCHAR2(30) NOT NULL,
 description VARCHAR2(255) NOT NULL,
 uri VARCHAR2(255) NOT NULL
);


ALTER TABLE ctmedia_license ADD CONSTRAINT pk_media_license PRIMARY KEY (media_license_id)
		    USING INDEX TABLESPACE UAM_IDX_1;
ALTER TABLE media
add CONSTRAINT fk_media_license
  FOREIGN KEY (media_license_id)
  REFERENCES ctmedia_license (media_license_id);		    
		    
CREATE OR REPLACE PUBLIC SYNONYM ctmedia_license FOR ctmedia_license;
GRANT ALL ON ctmedia_license TO manage_codetables;
GRANT SELECT ON ctmedia_license TO PUBLIC;


CREATE OR REPLACE TRIGGER TRG_BEF_ctmed_lic
BEFORE INSERT ON ctmedia_license
FOR EACH ROW
BEGIN
    IF :NEW.media_license_id IS NULL THEN
        SELECT sq_media_license_id.NEXTVAL
        INTO :NEW.media_license_id 
        FROM DUAL;
    END IF;
END;

INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC0','Public Domain','http://creativecommons.org/publicdomain/zero/1.0/');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY','Attribution','http://creativecommons.org/licenses/by/3.0/');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY-SA','Attribution-ShareAlike','http://creativecommons.org/licenses/by-sa/3.0/');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY-ND','Attribution-NoDerivs','http://creativecommons.org/licenses/by-nd/3.0');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY-NC','Attribution-NonCommercial','http://creativecommons.org/licenses/by-nc/3.0');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY-NC-SA','Attribution-NonCommercial-ShareAlike','http://creativecommons.org/licenses/by-nc-sa/3.0');
INSERT INTO ctmedia_license (DISPLAY,DESCRIPTION,URI) VALUES (
'CC BY-NC-ND','Attribution-NonCommercial-NoDerivs','http://creativecommons.org/licenses/by-nc-nd/3.0');


