CREATE TABLE LOAN_REQUEST (
	CORRESPONDENCE_ID NUMBER(38,0) NOT NULL,
	INSTALLMENT_COUNT NUMBER,
	REQUEST_STATUS VARCHAR2(20),
	LOAN_INSTRUCTIONS VARCHAR2(255),
	REQUEST_CLOSED_DATE DATE,
	SHIPPING_INSTRUCTIONS VARCHAR2(255)
) TABLESPACE UAM_DAT_1;
