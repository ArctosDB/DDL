insert into geology_attribute_hierarchy (attribute,attribute_value,usable_value_fg,description) values  ('access','private',1,'restrict access to locality and attched objects');

insert into geology_attributes (
	GEOLOGY_ATTRIBUTE_ID,
	LOCALITY_ID,
	GEOLOGY_ATTRIBUTE,
	GEO_ATT_VALUE
) values (
	sq_GEOLOGY_ATTRIBUTE_ID.nextval,
	11025859,
	'access',
	'private'
);



Elapsed: 00:00:00.00
UAM@ARCTOS> desc geology_attributes
 Name								   Null?    Type
 ----------------------------------------------------------------- -------- --------------------------------------------
 						   NOT NULL NUMBER
 							   NOT NULL NUMBER
 						   NOT NULL VARCHAR2(255)
 							   NOT NULL VARCHAR2(255)
 GEO_ATT_DETERMINER_ID							    NUMBER
 GEO_ATT_DETERMINED_DATE						    DATE
 GEO_ATT_DETERMINED_METHOD						    VARCHAR2(255)
 GEO_ATT_REMARK 							    VARCHAR2(4000)

UAM@ARCTOS> 
