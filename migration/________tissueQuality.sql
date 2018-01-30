create table cttissue_quality (
  tissue_quality varchar2(255) not null,
  description varchar2(4000) not null
);

create public synonym cttissue_quality for cttissue_quality;

grant all on cttissue_quality to manage_codetables;

grant select on cttissue_quality to public;


insert into cttissue_quality (tissue_quality,description) values ('rotten','test');
insert into cttissue_quality (tissue_quality,description) values ('spiffy','test');

																								

create table log_cttissue_quality (
username varchar2(60),
when date default sysdate,
n_DESCRIPTION VARCHAR2(255),
n_tissue_quality VARCHAR2(255),
o_DESCRIPTION VARCHAR2(255),
o_tissue_quality VARCHAR2(255)
);


create or replace public synonym log_cttissue_quality for log_cttissue_quality;

grant select on log_cttissue_quality to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_cttissue_quality AFTER INSERT or update or delete ON cttissue_quality
FOR EACH ROW
BEGIN
insert into log_cttissue_quality (
username,
when,
n_DESCRIPTION,
n_tissue_quality,
o_DESCRIPTION,
o_tissue_quality
) values (
SYS_CONTEXT('USERENV','SESSION_USER'),
sysdate,
:NEW.DESCRIPTION,
:NEW.tissue_quality,
:OLD.DESCRIPTION,
:OLD.tissue_quality
);
END;
/ 
