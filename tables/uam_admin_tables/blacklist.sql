CREATE TABLE blacklist (
    ip VARCHAR2(40) NOT NULL
);
 
GRANT ALL ON blacklist TO global_admin;
