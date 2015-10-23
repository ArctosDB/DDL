/*
	Cannot SQLLDR to prod, so create a DBLINK from test with:
*/


CREATE DATABASE LINK DB_production CONNECT TO UAM IDENTIFIED BY "secret password can this thing have spaces? 'no'." USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=db.corral.tacc.utexas.edu)(PORT=1521))(CONNECT_DATA=(SID=arctos)))';
