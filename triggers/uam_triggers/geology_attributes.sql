CREATE or replace TRIGGER sq_GEOLOGY_ATTRIBUTES_SQ
	BEFORE INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
BEGIN
    IF :new.geology_attribute_id IS NULL THEN
    	SELECT sq_geology_attribute_id.nextval
    	INTO :new.geology_attribute_id
		FROM dual;
    END IF;
END;
/


CREATE or replace TRIGGER GEOLOGY_ATTRIBUTES_CHECK
BEFORE UPDATE OR INSERT ON GEOLOGY_ATTRIBUTES
FOR EACH ROW
DECLARE numrows NUMBER;
BEGIN
	-- these are "locality attributes"
	-- control the type, not the value
	if :NEW.geology_attribute NOT IN (
		'Site Found By',
		'Site Found Date',
		'Site Identifier',
		'Site Collector Number',
		'Site Field Number',
		'TRS aliquot'
	) then
		SELECT COUNT(*) INTO numrows FROM geology_attribute_hierarchy WHERE attribute=:NEW.geology_attribute and ATTRIBUTE_VALUE=:NEW.GEO_ATT_VALUE and USABLE_VALUE_FG=1;
		IF (numrows = 0) THEN
			raise_application_error(
			    -20001,
			    'Invalid geology_attribute: ' || :NEW.geology_attribute || '='||:NEW.GEO_ATT_VALUE);
		END IF;
	end if;
END;
/

UAM@ARCTOSTE>  desc geology_attribute_hierarchy
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOLOGY_ATTRIBUTE_HIERARCHY_ID 				   NOT NULL NUMBER
 PARENT_ID								    NUMBER
 ATTRIBUTE							   NOT NULL VARCHAR2(255)
 ATTRIBUTE_VALUE						   NOT NULL VARCHAR2(255)
 USABLE_VALUE_FG						   NOT NULL NUMBER
 DESCRIPTION								    VARCHAR2(4000)


UAM@ARCTOS> desc geology_attributes;
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 GEOLOGY_ATTRIBUTE_ID						   NOT NULL NUMBER
 LOCALITY_ID							   NOT NULL NUMBER
 GEOLOGY_ATTRIBUTE						   NOT NULL VARCHAR2(255)
 GEO_ATT_VALUE							   NOT NULL VARCHAR2(255)
 GEO_ATT_DETERMINER_ID							    NUMBER
 GEO_ATT_DETERMINED_DATE						    DATE
 GEO_ATT_DETERMINED_METHOD						    VARCHAR2(255)
 GEO_ATT_REMARK 							    VARCHAR2(4000)

UAM@ARCTOS> 


alter table geology_attribute_hierarchy add constraint PK_geo_attr_h PRIMARY KEY (ATTRIBUTE_VALUE) using index TABLESPACE UAM_IDX_1;

