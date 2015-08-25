CREATE TABLE redirect (
    redirect_id number not null,
	old_path varchar2(255) not null,
	new_path varchar2(255) not null,
	CONSTRAINT PK_redirect_id
        PRIMARY KEY (redirect_id)
        USING INDEX TABLESPACE UAM_IDX_1
) TABLESPACE UAM_DAT_1;

