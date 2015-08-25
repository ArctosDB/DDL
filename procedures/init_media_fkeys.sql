CREATE OR REPLACE PROCEDURE INIT_MEDIA_FKEYS (
	tabl IN varchar2,
	colName in varchar2) IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	fkname varchar2(38);
	cName varchar2(38);
	sqlstr VARCHAR2(4000);
BEGIN
	fkname:='CFK_' || tabl; -- foreign key name in the form of FK_AGENT
	cName:='FK_MR_' || tabl; -- constraint name in the form of FK_MR_AGENT
	sqlstr:='ALTER TABLE TAB_MEDIA_REL_FKEY ADD ' || fkname || ' NUMBER ';
	sqlstr:=sqlstr || ' CONSTRAINT ' || cName;
	sqlstr:=sqlstr || ' REFERENCES ' || tabl;
	sqlstr:=sqlstr || '(' || colName || ')';
	
	EXECUTE IMMEDIATE sqlstr;
	
	commit;
END;
/ 