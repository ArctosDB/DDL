CREATE OR REPLACE PROCEDURE build_coll_code_tables IS
	thisTableName varchar2(38);
	n number;
	funkychars varchar2(4000);
BEGIN
	funkychars:='�';
