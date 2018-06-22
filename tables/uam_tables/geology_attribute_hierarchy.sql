CREATE TABLE GEOLOGY_ATTRIBUTE_HIERARCHY (
	GEOLOGY_ATTRIBUTE_HIERARCHY_ID NUMBER NOT NULL,
	PARENT_ID NUMBER,
	ATTRIBUTE VARCHAR2(255) NOT NULL,
	ATTRIBUTE_VALUE VARCHAR2(255) NOT NULL,
	USABLE_VALUE_FG NUMBER NOT NULL,
	DESCRIPTION VARCHAR2(4000),
		CONSTRAINT PK_GEOLOGY_ATTRIBUTE_HIERARCHY
			PRIMARY KEY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID)
			USING INDEX TABLESPACE UAM_IDX_1,
        CONSTRAINT GEO_ATT_H_USABLE_CK
	         CHECK (usable_value_fg IN (0,1)),
		CONSTRAINT FK_GEOLATTRHIER_GEOLATTRHIER
			FOREIGN KEY (PARENT_ID)
			REFERENCES GEOLOGY_ATTRIBUTE_HIERARCHY (GEOLOGY_ATTRIBUTE_HIERARCHY_ID)
) TABLESPACE UAM_DAT_1;




drop table log_GEOLOGY_ATTRIBUTE_HIY;

create table log_GEOLOGY_ATTRIBUTE_HIY ( 
	username varchar2(60),	
	when date default sysdate,
	n_parent_id number,
	n_attribute varchar2(255),
	n_ATTRIBUTE_VALUE VARCHAR2(255),
	n_USABLE_VALUE_FG number,
	n_DESCRIPTION VARCHAR2(4000),	
	o_parent_id number,
	o_attribute varchar2(255),
	o_ATTRIBUTE_VALUE VARCHAR2(255),
	o_USABLE_VALUE_FG number,
	o_DESCRIPTION VARCHAR2(4000)
);


create or replace public synonym log_GEOLOGY_ATTRIBUTE_HIY for log_GEOLOGY_ATTRIBUTE_HIY;


grant select on log_GEOLOGY_ATTRIBUTE_HIY to coldfusion_user;


CREATE OR REPLACE TRIGGER TR_log_GEOLOGY_ATTRIBUTE_HIY 
	AFTER INSERT or update or delete ON GEOLOGY_ATTRIBUTE_HIERARCHY
	FOR EACH ROW 
BEGIN 
	insert into log_GEOLOGY_ATTRIBUTE_HIY ( 
		username, 
		when,
		n_parent_id,
		n_attribute,
		n_ATTRIBUTE_VALUE,
		n_USABLE_VALUE_FG,
		n_DESCRIPTION,	
		o_parent_id,
		o_attribute,
		o_ATTRIBUTE_VALUE,
		o_USABLE_VALUE_FG,
		o_DESCRIPTION
			) values (
		SYS_CONTEXT('USERENV','SESSION_USER'),
		sysdate,
		:NEW.parent_id,
		:NEW.attribute,
		:NEW.ATTRIBUTE_VALUE,
		:NEW.USABLE_VALUE_FG,
		:NEW.DESCRIPTION,	
		:OLD.parent_id,
		:OLD.attribute,
		:OLD.ATTRIBUTE_VALUE,
		:OLD.USABLE_VALUE_FG,
		:OLD.DESCRIPTION
	);
END;
/

