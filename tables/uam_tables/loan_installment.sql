CREATE TABLE LOAN_INSTALLMENT (
	TRANSACTION_ID NUMBER(38,0) NOT NULL,
	CORRESPONDENCE_ID VARCHAR2(38),
	INSTALLMENT_DUE_DATE DATE,
	LOAN_NUM_PREFIX VARCHAR2(10),
	LOAN_NUM NUMBER,
	LOAN_NUM_SUFFIX VARCHAR2(10),
	LOAN_INSTALLMENT_STATUS VARCHAR2(20),
	INSTALLMENT_ORDER NUMBER,
	LENDER_INV_RET_FG NUMBER,
	BORROWER_INV_RET_FG NUMBER,
	LOAN_TYPE VARCHAR2(25)
) TABLESPACE UAM_DAT_1;