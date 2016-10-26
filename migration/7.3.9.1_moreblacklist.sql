

alter table blacklist add calc_subnet varchar2 (255);
update blacklist set calc_subnet=substr(ip,1,instr(ip,'.',1,2)-1) where calc_subnet is null;

CREATE OR REPLACE TRIGGER trg_blacklist_biu
before INSERT or update ON blacklist
FOR EACH ROW
BEGIN
	:NEW.calc_subnet:=substr(:NEW.ip,1,instr(:NEW.ip,'.',1,2)-1);
END;
/
sho err

create index ix_bl_sn on blacklist(calc_subnet) tablespace uam_idx_1;
create index ix_blsn_sn on blacklist_subnet(subnet) tablespace uam_idx_1;
