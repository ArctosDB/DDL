alter table geog_auth_rec add drainage varchar2(255);


CREATE OR REPLACE TRIGGER TRG_MK_HIGHER_GEOG....

alter table log_geog_auth_rec add n_drainage varchar2(255);
alter table log_geog_auth_rec add O_drainage varchar2(255);

CREATE OR REPLACE TRIGGER TR_LOG_GEOG_UPDATE....