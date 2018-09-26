-- 2014-06-16: Add stripped_key in an attempt to keep functional duplicates out



-- moving this into TRG_HIGHER_GEOG_MagicDups
drop trigger TRG_HIGHER_GEOG_wikisrc;


DO NOT CREATE OR REPLACE TRIGGER TRG_HIGHER_GEOG_wikisrc
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
BEGIN
	
	if not regexp_like(:NEW.SOURCE_AUTHORITY,'^https?://e(n|n).wikipedia.org/wiki/%') then
		 raise_application_error(
            -20371,
            'Source authority must be a page on English or Spanish Wikipedia.');	
	end if;
end;
/


CREATE OR REPLACE TRIGGER TRG_HIGHER_GEOG_MagicDups
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
DECLARE 
	PRAGMA AUTONOMOUS_TRANSACTION;
	n number;
	gid number;
BEGIN
	-- see if we can detect some common problems
	if updating then
		gid:=:OLD.geog_auth_rec_id;
	else
		gid:=-1;
	end if;
	
	if not regexp_like(:NEW.SOURCE_AUTHORITY,'^https?://e(n|s).wikipedia.org/wiki/') then
		 raise_application_error(
            -20371,
            'Source authority must be a page on English or Spanish Wikipedia.');	
	end if;
	if :NEW.SOURCE_AUTHORITY like '%#%' then
		 raise_application_error(
            -20371,
            'Source authority must be a specific article, not an anchor.');	
	end if;
	
	
	if :NEW.island is not null then
		if :NEW.island like '%St.%' then
			raise_application_error(
	           	-20368,
	           	'St. cannot be in Island.');	
     	end if;
     	
		if substr(:NEW.island,1,1) = '*' then
			:NEW.island:=replace(:NEW.island,'*');
		else
			select count(*) into n from GEOG_AUTH_REC where geog_auth_rec_id!=gid and trim(replace(replace(island,' Island'),'Isla '))=trim(replace(replace(:NEW.island,' Island'),'Isla '));
			if n>0 then
				raise_application_error(
	            	-20368,
	            	'Potential duplicate detected in Island. Double-check existing data. Prefix Island with an asterisk to force-create.');	
	     	end if;
	     end if;
	end if;
	
	if :NEW.state_prov is not null then
		if :NEW.state_prov like '%St.%' then
			raise_application_error(
	           	-20368,
	           	'St. cannot be in State.');	
     	end if;
	end if;
	
	if :NEW.county is not null then
		if :NEW.county like '%St.%' then
			raise_application_error(
	           	-20368,
	           	'St. cannot be in County.');	
     	end if;
	end if;
	
	
END;
/
sho err;




CREATE OR REPLACE TRIGGER TRG_MK_HIGHER_GEOG
BEFORE INSERT OR UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
DECLARE 
	hg varchar2(4000);
	temp varchar2(4000);
	TYPE STR_LIST_TYPE IS TABLE OF VARCHAR2(15);
	V_STR_VALUES STR_LIST_TYPE;
	thisval varchar2(15);
	n number;
BEGIN
	-- keep this trigger to only be creating of higher_geog and HARD rules; this should never be disabled
	-- use TRG_HIGHER_GEOG_MagicDups for any wafflier "strong suggestions"
	
	if :NEW.VALID_CATALOG_TERM_FG is null then
		:NEW.VALID_CATALOG_TERM_FG:=1;
	end if;	
	IF :NEW.continent_ocean IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.continent_ocean;
		ELSE
			hg := hg || ', ' || :NEW.continent_ocean;
		END IF;
	END IF;   
	IF :NEW.sea IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.sea;
		ELSE
			hg := hg || ', ' || :NEW.sea;
		END IF;
	END IF;
	IF :NEW.country IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.country;
		ELSE
			hg := hg || ', ' || :NEW.country;
		END IF;
	END IF;
	IF :NEW.state_prov IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.state_prov;
		ELSE
			hg := hg || ', ' || :NEW.state_prov;
		END IF;
	END IF;
	IF :NEW.county IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.county;
		ELSE
			hg := hg || ', ' || :NEW.county;
		END IF;
	END IF;
	IF :NEW.quad IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.quad || ' Quad';
		ELSE
			hg := hg || ', ' || :NEW.quad || ' Quad';
		END IF;
	END IF;
	IF :NEW.feature IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.feature;
		ELSE
			hg := hg || ', ' || :NEW.feature;
		END IF;
	END IF;
	IF :NEW.drainage IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.drainage;
		ELSE
			hg := hg || ', ' || :NEW.drainage;
		END IF;
	END IF;
	IF :NEW.island_group IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.island_group;
		ELSE
			hg := hg || ', ' || :NEW.island_group;
		END IF;
	END IF;
	IF :NEW.island IS NOT NULL THEN
		IF hg IS NULL THEN
			hg := :NEW.island;
		ELSE
			hg := hg || ', ' || :NEW.island;
		END IF;
	END IF;
	 
	if hg like '%  %' then
		 raise_application_error(
            -20370,
            'Detected double spaces.');	
	end if;
	-- list of characters that probably indicate garbage data
	V_STR_VALUES := STR_LIST_TYPE('}','{','(',')','[',']');
	FOR INDX IN V_STR_VALUES.FIRST..V_STR_VALUES.LAST LOOP
		thisval :=  V_STR_VALUES(INDX);
		if instr(hg ,thisval)>0 then
			raise_application_error(
			-20369,
			'Detected disallowed character: ' || thisval);	
   		end if; 
	END LOOP; 
	-- list of common evil abbreviations etc. - ignore case
	V_STR_VALUES := STR_LIST_TYPE('CO.','dept.','Depto.','ISL.','is.','Prov.','Pref.','Dist.','TERR.',' USA');
	FOR INDX IN V_STR_VALUES.FIRST..V_STR_VALUES.LAST LOOP
		thisval :=  upper(V_STR_VALUES(INDX));
		if instr(upper(hg) ,thisval)>0 then
   			 raise_application_error(
            -20369,
            'Detected disallowed phrase: ' || thisval);	
   		end if; 
	END LOOP;
	:NEW.higher_geog := trim(hg);

	temp:=lower(hg);
	-- Strip out common qualifiers etc. that are OK to include but lead to duplicates 
	-- and throw the result at a unique index. 
	-- No need to check for things that are outright disallowed by the above.

	temp:=replace(temp,'autonomous');
	
	temp:=replace(temp,'city');
	temp:=replace(temp,'community');
	temp:=replace(temp,'county');
	temp:=replace(temp,' co ');
	
	temp:=replace(temp,'departamento');
	temp:=replace(temp,' del ');
	temp:=replace(temp,' de ');
	temp:=replace(temp,'district');
	
	temp:=replace(temp,'governorate.');
	
	temp:=replace(temp,'island');
	temp:=replace(temp,'isla');
	temp:=replace(temp,' is ');
	temp:=replace(temp,' isl ');
	
	temp:=replace(temp,'kray');
	temp:=replace(temp,'kabupaten');
	
	temp:=replace(temp,' la ');
	
	temp:=replace(temp,'municipality');
	
	temp:=replace(temp,'oblast');
	temp:=replace(temp,' of ');
	
	temp:=replace(temp,'province');
	temp:=replace(temp,'provincia');
	temp:=replace(temp,'parish');

	temp:=replace(temp,'republic');
	
	temp:=replace(temp,'saint');
	temp:=replace(temp,'st');
	
	temp:=replace(temp,'territory');
	
	temp:=replace(temp,'ward');
	
	temp:=replace(temp,'.');
	
	temp:=replace(temp,'  ',' ');
	temp:=trim(temp);
	:NEW.stripped_key:=temp;

END;
/
sho err;



CREATE OR REPLACE TRIGGER TR_GEOGAUTHREC_AU_FLAT
AFTER UPDATE ON GEOG_AUTH_REC
FOR EACH ROW
BEGIN
    UPDATE flat SET
        stale_flag = 1,
        lastuser = sys_context('USERENV', 'SESSION_USER'),
        lastdate = SYSDATE
    WHERE geog_auth_rec_id = :NEW.geog_auth_rec_id;
END;

*/as

/*
 
   alter table log_geog_auth_rec add n_SOURCE_AUTHORITY VARCHAR2(255);
   alter table log_geog_auth_rec add o_SOURCE_AUTHORITY VARCHAR2(255); 
   alter table log_geog_auth_rec add o_GEOG_REMARK VARCHAR2(4000); 
   alter table log_geog_auth_rec add n_GEOG_REMARK VARCHAR2(4000); 
   
   
 * 
 */
 

CREATE OR REPLACE TRIGGER TR_LOG_GEOG_UPDATE
AFTER INSERT or update or delete ON geog_auth_rec
FOR EACH ROW
	declare
		action_type varchar2(255);		
BEGIN
    if updating then
    	if :OLD.higher_geog != :NEW.higher_geog then
	    	insert into log_geog_auth_rec (
				GEOG_AUTH_REC_ID,
				username,
				action_type,
				when,
				n_CONTINENT_OCEAN,
				n_COUNTRY,
				n_STATE_PROV,
				n_COUNTY,
				n_QUAD,
				n_FEATURE,
				n_drainage,
				n_ISLAND,
				n_ISLAND_GROUP,
				n_SEA,
				n_SOURCE_AUTHORITY,
				n_GEOG_REMARK,
				o_CONTINENT_OCEAN,
				o_COUNTRY,
				o_STATE_PROV,
				o_COUNTY,
				o_QUAD,
				o_FEATURE,
				o_drainage,
				o_ISLAND,
				o_ISLAND_GROUP,
				o_SEA,
				o_SOURCE_AUTHORITY,
				o_GEOG_REMARK
			) values (
				:OLD.GEOG_AUTH_REC_ID,
				SYS_CONTEXT('USERENV','SESSION_USER'),
				'updating',
				sysdate,
				:NEW.CONTINENT_OCEAN,
				:NEW.COUNTRY,
				:NEW.STATE_PROV,
				:NEW.COUNTY,
				:NEW.QUAD,
				:NEW.FEATURE,
				:NEW.drainage,
				:NEW.ISLAND,
				:NEW.ISLAND_GROUP,
				:NEW.SEA,
				:NEW.SOURCE_AUTHORITY,
				:NEW.GEOG_REMARK,
				:OLD.CONTINENT_OCEAN,
				:OLD.COUNTRY,
				:OLD.STATE_PROV,
				:OLD.COUNTY,
				:OLD.QUAD,
				:OLD.FEATURE,
				:OLD.drainage,
				:OLD.ISLAND,
				:OLD.ISLAND_GROUP,
				:OLD.SEA,
				:OLD.SOURCE_AUTHORITY,
				:OLD.GEOG_REMARK
			);
		end if;
		
    elsif inserting then
    	insert into log_geog_auth_rec (
			GEOG_AUTH_REC_ID,
			username,
			action_type,
			when,
			n_CONTINENT_OCEAN,
			n_COUNTRY,
			n_STATE_PROV,
			n_COUNTY,
			n_QUAD,
			n_FEATURE,
			n_drainage,
			n_ISLAND,
			n_ISLAND_GROUP,
			n_SEA,
			n_SOURCE_AUTHORITY,
			n_GEOG_REMARK
		) values (
			:NEW.GEOG_AUTH_REC_ID,
			SYS_CONTEXT('USERENV','SESSION_USER'),
			'inserting',
			sysdate,
			:NEW.CONTINENT_OCEAN,
			:NEW.COUNTRY,
			:NEW.STATE_PROV,
			:NEW.COUNTY,
			:NEW.QUAD,
			:NEW.FEATURE,
			:NEW.drainage,
			:NEW.ISLAND,
			:NEW.ISLAND_GROUP,
			:NEW.SEA,
			:NEW.SOURCE_AUTHORITY,
			:NEW.GEOG_REMARK
		);
    elsif deleting then
    	insert into log_geog_auth_rec (
			GEOG_AUTH_REC_ID,
			username,
			action_type,
			when,
			o_CONTINENT_OCEAN,
			o_COUNTRY,
			o_STATE_PROV,
			o_COUNTY,
			o_QUAD,
			o_FEATURE,
			o_drainage,
			o_ISLAND,
			o_ISLAND_GROUP,
			o_SEA,
			o_SOURCE_AUTHORITY,
			o_GEOG_REMARK
		) values (
			:OLD.GEOG_AUTH_REC_ID,
			SYS_CONTEXT('USERENV','SESSION_USER'),
			'deleting',
			sysdate,
			:OLD.CONTINENT_OCEAN,
			:OLD.COUNTRY,
			:OLD.STATE_PROV,
			:OLD.COUNTY,
			:OLD.QUAD,
			:OLD.FEATURE,
			:OLD.drainage,
			:OLD.ISLAND,
			:OLD.ISLAND_GROUP,
			:OLD.SEA,
			:OLD.SOURCE_AUTHORITY,
			:OLD.GEOG_REMARK
		);
		
    end if;
    
    
END;
/
sho err;
