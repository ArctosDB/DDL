-- a way to split lists, used for protected IPs via manage/global settings
CREATE OR REPLACE PACKAGE parse_list AS ....

-- a way to check an IP for validity
CREATE or replace FUNCTION isValidIP (ip in varchar2 )

-- make sure cf_global_settings always contains a single row
CREATE OR REPLACE TRIGGER trg_cf_global_settings_onerow

-- make sure those protected IPs are in a sane format
-- disallow protecting already-blacklisted IPs
-- disallow protecting already-blacklisted subnetss
CREATE OR REPLACE TRIGGER trg_cf_global_settings_ckblist

-- don't allow blacklisting of protected or malformed IPs
CREATE OR REPLACE TRIGGER trg_blacklist_ckblist


-- don't allow blacklisting of protected or malformed subnets
CREATE OR REPLACE TRIGGER trg_blacklist_subnet_ckblist

-- because I have no idea...

alter table cf_global_settings add protect_ip_remark VARCHAR2(4000);
-- copy to prod @release