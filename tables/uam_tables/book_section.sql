CREATE TABLE BOOK_SECTION (
	PUBLICATION_ID NUMBER NOT NULL,
	BOOK_ID NUMBER NOT NULL,
	BOOK_SECTION_TYPE VARCHAR2(25) NOT NULL,
	BEGINS_PAGE_NUMBER NUMBER,
	ENDS_PAGE_NUMBER NUMBER,
	BOOK_SECTION_ORDER NUMBER,
		CONSTRAINT PK_BOOK_SECTION
		    PRIMARY KEY (PUBLICATION_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
		CONSTRAINT FK_BOOKSECTION_BOOK
			FOREIGN KEY (BOOK_ID)
			REFERENCES BOOK (PUBLICATION_ID)
) TABLESPACE UAM_DAT_1;
