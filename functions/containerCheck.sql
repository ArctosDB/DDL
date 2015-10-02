-- move all check container code here; call it from the various places it's used.

CREATE OR REPLACE FUNCTION containerCheck(
	new_container_type in varchar2,
	old_container_type in varchar2,
	new_barcode in varchar2,
	old_barcode in varchar2,
	new_container_type in varchar2,
	new_container_type in varchar2,
	 IN number, oid in varchar2)
