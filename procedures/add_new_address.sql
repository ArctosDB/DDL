-- called by tr_addr_bu (trigger on ADDR table)
-- inserts new record into ADDR table when there is a change in fields:
-- street_addr1, street_addr2, city, state, zip, country_cde, mail_stop,
-- agent_id, addr_type, job_title, institution, department

CREATE OR REPLACE PROCEDURE add_new_address (
	I_ADDRESS_TYPE in VARCHAR2,
	I_ADDRESS in VARCHAR2,
	I_AGENT_ID in VARCHAR2,
	I_VALID_ADDR_FG in VARCHAR2,
	I_ADDRESS_REMARK in VARCHAR2
)
AS
	pragma autonomous_transaction;
BEGIN
	INSERT INTO ADDRESS (
		ADDRESS_TYPE,
		ADDRESS,
		AGENT_ID,
		VALID_ADDR_FG,
		ADDRESS_REMARK)
	VALUES (
		I_ADDRESS_TYPE,
		I_ADDRESS,
		I_AGENT_ID,
		I_VALID_ADDR_FG,
		I_ADDRESS_REMARK);
		
	COMMIT;
END;
/