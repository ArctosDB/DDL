CREATE OR REPLACE PROCEDURE PARSE_OTHER_ID (
    collection_object_id IN number,
    other_id_num IN varchar2,
    other_id_type IN varchar,
	ID_REFERENCES IN varchar2)
IS
	part_one varchar2(255);
	part_two varchar2(255);
	part_three varchar2(255);
    dlms VARCHAR2(255) := '|-.; ';
    td VARCHAR2(255);
    pend_disp_val varchar2(255);
    part_two_number NUMBER;
	temp varchar2(255);
BEGIN
	--dbms_output.put_line('other_id_num: ' || other_id_num);
	IF is_number(other_id_num) = 1 THEN -- just a number
		part_one := NULL;
		part_two := other_id_num;
		part_three := NULL;
	ELSIF is_number(substr(other_id_num,1,length(other_id_num) - 1)) = 1 THEN
		-- number plus single char
		part_two := substr(other_id_num,1,length(other_id_num) - 1);
		part_three := substr(other_id_num,length(other_id_num));
	ELSIF is_positive_number(substr(other_id_num,2)) = 1 THEN
	 -- single char + number
		part_one := substr(other_id_num,1,1);
		part_two := substr(other_id_num,2);
	ELSIF substr(other_id_num,1,1) ='{' AND  substr(other_id_num,length(other_id_num),1) ='}' THEN
		-- entire thing surrounded by curly brackets==force all to prefix (eg, preserve leading zero)
		--dbms_output.put_line('is curly');
		part_one := other_id_num;
		part_one:=replace(part_one,'}');
		part_one:=replace(part_one,'{');
	ELSIF other_id_num like '%[%' and other_id_num like '%]%' then
		-- number between square brackets
		--dbms_output.put_line('squarebracket');
		part_one:=trim(regexp_replace(other_id_num,'\[.*$',''));
		part_two:=trim(regexp_substr(other_id_num,'\[(.*?)\]',1,1,null,1));
		part_three:=trim(regexp_replace(other_id_num,'^.*\]',''));
		--dbms_output.put_line('part_one: ' || part_one);
		--dbms_output.put_line('part_two: ' || part_two);
		--dbms_output.put_line('part_three: ' || part_three);
	ELSE -- loop through list of delimiter defined above and see what falls out
		--dbms_output.put_line('hit else');
		FOR i IN 1..100 LOOP
			td := substr(dlms,i,1);
			EXIT WHEN td IS NULL;
			IF instr(other_id_num,td) > 0 THEN  -- see if our number contains the current delimiter
				part_one := get_str_el (other_id_num,td,1) || td;
				part_two := get_str_el (other_id_num,td,2);
				IF instr(other_id_num,td,1,2) > 0 THEN
					part_three := td || get_str_el (other_id_num,td,3);
				END IF;
				IF part_three IS NULL THEN -- got back two parts, see if we can make one of them numeric
					IF is_number(part_two) = 0 AND is_number(part_one) = 1 THEN
						part_three := part_two;
						part_two := part_one;
						part_one := NULL;
					END IF;
				END IF;
			end IF;
		END LOOP;
	END IF;
	IF is_number(part_two) !=1 THEN
		--dbms_output.put_line('part two is not a number');
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	END IF;
	part_two_number:=part_two;
	pend_disp_val:=part_one || part_two_number || part_three;
	-- get rid of parens and square brackets
	temp:=replace(other_id_num,'[');
	temp:=replace(temp,']');
	temp:=replace(temp,'{');
	temp:=replace(temp,'}');
	--dbms_output.put_line('pend_disp_val: ' || pend_disp_val);
	IF pend_disp_val IS NULL OR temp != pend_disp_val THEN
		--dbms_output.put_line('pend_disp_val angry');
		part_one := other_id_num;
		part_two := NULL;
		part_three := NULL;
	END IF;
	--dbms_output.put_line('part_one: ' || part_one);
	--dbms_output.put_line('part_two: ' || part_two);
	--dbms_output.put_line('part_three: ' || part_three);
	INSERT INTO coll_obj_other_id_num (
	    COLLECTION_OBJECT_ID,
	    OTHER_ID_TYPE,
	    OTHER_ID_PREFIX,
	    OTHER_ID_NUMBER,
	    OTHER_ID_SUFFIX,
	    ID_REFERENCES
	) values (
	    collection_object_id,
	    other_id_type,
	    part_one,
	    part_two,
	    part_three,
	    ID_REFERENCES
	);
end;
/
sho err

create or replace public synonym PARSE_OTHER_ID for PARSE_OTHER_ID;
grant execute on PARSE_OTHER_ID to manage_specimens;

