CREATE TABLE CF_COLLECTION (
	CF_COLLECTION_ID NUMBER NOT NULL,
	COLLECTION_ID NUMBER,
	DBUSERNAME VARCHAR2(34),
	DBPWD VARCHAR2(47),
	HEADER_COLOR VARCHAR2(20),
	HEADER_IMAGE VARCHAR2(255),
	COLLECTION_URL VARCHAR2(255),
	COLLECTION_LINK_TEXT VARCHAR2(60),
	INSTITUTION_URL VARCHAR2(255),
	INSTITUTION_LINK_TEXT VARCHAR2(60),
	META_DESCRIPTION VARCHAR2(255),
	META_KEYWORDS VARCHAR2(255),
	STYLESHEET VARCHAR2(60),
	HEADER_CREDIT CHAR(1),
	PORTAL_NAME VARCHAR2(30) NOT NULL,
	COLLECTION VARCHAR2(30) NOT NULL,
	PUBLIC_PORTAL_FG NUMBER(1,0) DEFAULT 1 NOT NULL
	INSTITUTION VARCHAR2(255),
	DESCR VARCHAR2(4000)
) TABLESPACE UAM_DAT_1;


-- YO LAM!
-- I'm using this table to filter out from selects
-- non-public collections. (I'm also updating this table manually to
-- make empty collections non-public.) It contains passwords in cleartext.
-- said passwords should be able to do nothing that can't be done
-- on the public forms. Still scary for some reason. Should we 
-- reconsider?

create or replace public synonym CF_COLLECTION for CF_COLLECTION;
grant select on cf_collection to public;