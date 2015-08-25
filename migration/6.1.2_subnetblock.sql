
create table blacklist_subnet (
	subnet varchar2(7) not null,
	insert_date date default sysdate not null
);
create public synonym blacklist_subnet for blacklist_subnet;

grant all on blacklist_subnet to global_admin;

grant select on blacklist_subnet to public;

create unique index iu_blacklistsubnet_subnet on blacklist_subnet (subnet) tablespace uam_idx_1;

insert into blacklist_subnet (subnet) values ('46.23');
insert into blacklist_subnet (subnet) values ('94.124');
insert into blacklist_subnet (subnet) values ('79.135');
insert into blacklist_subnet (subnet) values ('82.102');
insert into blacklist_subnet (subnet) values ('27.153');
insert into blacklist_subnet (subnet) values ('5.10');
insert into blacklist_subnet (subnet) values ('222.239');
insert into blacklist_subnet (subnet) values ('121.254');
insert into blacklist_subnet (subnet) values ('182.211');
insert into blacklist_subnet (subnet) values ('200.31');
insert into blacklist_subnet (subnet) values ('188.165');
insert into blacklist_subnet (subnet) values ('110.77');
insert into blacklist_subnet (subnet) values ('188.18');
insert into blacklist_subnet (subnet) values ('187.185');
insert into blacklist_subnet (subnet) values ('190.118');
insert into blacklist_subnet (subnet) values ('37.53');
insert into blacklist_subnet (subnet) values ('92.113');
insert into blacklist_subnet (subnet) values ('46.118');
insert into blacklist_subnet (subnet) values ('37.110');
insert into blacklist_subnet (subnet) values ('96.47');
insert into blacklist_subnet (subnet) values ('86.56');
insert into blacklist_subnet (subnet) values ('79.106');
insert into blacklist_subnet (subnet) values ('222.252');
insert into blacklist_subnet (subnet) values ('189.241');
insert into blacklist_subnet (subnet) values ('190.113');
insert into blacklist_subnet (subnet) values ('159.224');
insert into blacklist_subnet (subnet) values ('176.33');
insert into blacklist_subnet (subnet) values ('1.2');
insert into blacklist_subnet (subnet) values ('92.47');
insert into blacklist_subnet (subnet) values ('200.61');
insert into blacklist_subnet (subnet) values ('37.54');
insert into blacklist_subnet (subnet) values ('212.178');
insert into blacklist_subnet (subnet) values ('125.212');
insert into blacklist_subnet (subnet) values ('103.21');
insert into blacklist_subnet (subnet) values ('178.127');
insert into blacklist_subnet (subnet) values ('117.254');
insert into blacklist_subnet (subnet) values ('93.178');
insert into blacklist_subnet (subnet) values ('62.221');
insert into blacklist_subnet (subnet) values ('85.133');
insert into blacklist_subnet (subnet) values ('5.143');
insert into blacklist_subnet (subnet) values ('109.251');
insert into blacklist_subnet (subnet) values ('2.178');
insert into blacklist_subnet (subnet) values ('95.59');



alter table cf_temp_citation add guid varchar2(20);
alter table cf_temp_citation modify GUID_PREFIX null;
alter table cf_temp_citation modify OTHER_ID_TYPE null;
alter table cf_temp_citation modify OTHER_ID_NUMBER null;


create table cf_temp_lbl2contr (
	barcode varchar2(255) not null,
	old_container_type varchar2(255) not null,
	container_type varchar2(255),
	description varchar2(255),
	container_remarks varchar2(255),
	height number,
	length number,
	width number,
	number_positions number
);
	
create public synonym cf_temp_lbl2contr for cf_temp_lbl2contr;

grant all on cf_temp_lbl2contr to manage_container;

create unique index iu_cf_temp_lbl2contr_bc on cf_temp_lbl2contr(barcode) tablespace uam_idx_1;

alter table cf_temp_lbl2contr add status varchar2(255);
alter table cf_temp_lbl2contr add note varchar2(4000);

 