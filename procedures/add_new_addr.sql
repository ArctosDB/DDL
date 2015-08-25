-- called by tr_addr_bu (trigger on ADDR table)
-- inserts new record into ADDR table when there is a change in fields:
-- street_addr1, street_addr2, city, state, zip, country_cde, mail_stop,
-- agent_id, addr_type, job_title, institution, department

CREATE OR REPLACE PROCEDURE add_new_addr (
	st1 in VARCHAR2,
	st2 in VARCHAR2,
	ci in VARCHAR2,
	st in VARCHAR2,
	zp in VARCHAR2,
	cc in VARCHAR2,
	ms in VARCHAR2,
	aid in NUMBER,
	atype in VARCHAR2,
	title in VARCHAR2,
	rmk in VARCHAR2,
	inst in VARCHAR2,
	dept in VARCHAR2
)
AS
	pragma autonomous_transaction;
BEGIN
	INSERT INTO addr (
		street_addr1,
		street_addr2,
		city,
		state,
		zip,
		country_cde,
		mail_stop,
		agent_id,
		addr_type,
		job_title,
		valid_addr_fg,
		addr_remarks,
		institution,
		department)
	VALUES (
		st1,
		st2,
		ci,
		st,
		zp,
		cc,
		ms,
		aid,
		atype,
		title,
		1,
		rmk,
		inst,
		dept);
		
	COMMIT;
END;
/