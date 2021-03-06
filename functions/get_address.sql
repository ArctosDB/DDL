CREATE OR REPLACE FUNCTION get_address(p_key_val IN NUMBER, atype in varchar2 default null, active_user in number default 1)
-- get address
-- optionally by type
-- default is to get address only for active users
-- override by setting variable to anything but 1
	RETURN VARCHAR2
	AS
		fa varchar2(4000);
		c NUMBER;
		l_str varchar2(4000);
		l_sep varchar2(2);
		l_val varchar2(4000);
		thistype varchar2(255);
    BEGIN
	    -- IF type is given, then return all addresses of that type, concatenated with a comma
		-- IF type is not given, then set type to:
		-- 	   1) valid correspondence address
		--     2) valid shipping address
		--     3) valid home address
		-- or return NULL 
		if atype is null then
		    SELECT COUNT(*) INTO c FROM address WHERE valid_addr_fg = 1 AND address_type = 'correspondence' AND agent_id = p_key_val;
		    --dbms_output.put_line('correspondence: ' || c);
			IF c > 0 THEN
				thistype:='correspondence';
			ELSE
    			SELECT COUNT(*) INTO c FROM address WHERE valid_addr_fg = 1 AND address_type = 'shipping' AND agent_id = p_key_val;
		    	--dbms_output.put_line('shipping: ' || c);
				IF c > 0 THEN
 					thistype:='shipping';
				ELSE
    				SELECT COUNT(*) INTO c FROM address WHERE valid_addr_fg = 1 AND address_type = 'home' AND agent_id = p_key_val;
		    		--dbms_output.put_line('home: ' || c);
    				IF c > 0 THEN
 						thistype:='home';
                	END IF;
				END IF;
			END IF;
		else
   			thistype:=atype;
   		end if;
   		if active_user = 1 then
   			-- get only addresses where the user is an active operator
	   		FOR r IN (
				SELECT 
					address.address 
				FROM
					agent_name,
					address,
					dba_users
				WHERE 
					agent_name.agent_id=address.agent_id and
					agent_name.agent_name_type='login' and
					upper(agent_name.agent_name)=upper(dba_users.username) and
					address.valid_addr_fg = 1 AND 
					dba_users.account_status='OPEN' and
					address.address_type=thistype AND 
					agent_name.agent_id = p_key_val
			) loop
	            l_val:=r.address;
	            --dbms_output.put_line('l_val: ' || l_val);
	            l_str := l_str || l_sep || l_val;
	            l_sep := ',';
			end loop;
		else
			-- get valid addresses regardless of operator status
			FOR r IN (SELECT address FROM address WHERE valid_addr_fg = 1 AND address_type=thistype AND agent_id = p_key_val) loop
	            l_val:=r.address;
	            --dbms_output.put_line('l_val: ' || l_val);
	            l_str := l_str || l_sep || l_val;
	            l_sep := ',';
			end loop;
		end if;
        RETURN l_str;
    END;
/
sho err









CREATE or replace PUBLIC SYNONYM get_address FOR get_address;
GRANT EXECUTE ON get_address TO PUBLIC;



select get_address(2072) from dual;

select get_address(2072,'email') from dual;


