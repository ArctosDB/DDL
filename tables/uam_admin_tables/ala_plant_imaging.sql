CREATE TABLE ALA_PLANT_IMAGING (
	IMAGE_ID NUMBER NOT NULL,
	FOLDER_IDENTIFICATION VARCHAR2(255),
	FOLDER_BARCODE VARCHAR2(255),
	IDTYPE VARCHAR2(255),
	IDNUM VARCHAR2(255),
	BARCODE VARCHAR2(255),
	WHODUNIT VARCHAR2(255) NOT NULL,
	WHENDUNIT DATE,
	STATUS VARCHAR2(255),
	MB_STATUS NUMBER
) TABLESPACE UAM_DAT_1;
