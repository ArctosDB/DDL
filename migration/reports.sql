-- see http://code.google.com/p/arctos/issues/detail?id=301
CREATE USER report_user IDENTIFIED BY "repOrt.usr";
GRANT CONNECT TO report_user;
-- SET up cf datasource