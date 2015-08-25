CREATE OR REPLACE FUNCTION isValidAttribute (
	attribute  in varchar,
	attributeValue in varchar,
	attributeUnits in varchar,
	collection_cde in varchar)
return number as
	numRecs NUMBER;
	attributeValueTable varchar2(255);
	attributeUnitsTable varchar2(255);
	attributeCodeTableColName varchar2(255);
	thesql varchar2(255);
	temp varchar2(4000);
	BEGIN
		select  /*+ RESULT_CACHE */ count(*) INTO numRecs FROM ctattribute_type WHERE ATTRIBUTE_TYPE = attribute AND collection_cde = collection_cde;
		IF (numRecs = 0) THEN
			dbms_output.put_line('; ATTRIBUTE_1 is invalid: ');
			return 0;
		END IF;
		-- now see if there is a value or units code table
		BEGIN
			select  /*+ RESULT_CACHE */ VALUE_CODE_TABLE,UNITS_CODE_TABLE into attributeValueTable,attributeUnitsTable from ctattribute_code_tables where attribute_type=attribute;
		EXCEPTION WHEN NO_DATA_FOUND THEN
			-- there is not value or units table, but it's a valid attribute since we made it this far
			-- error if units are given, otherwise whatever
			if attributeUnits is not null then
				return 0;
			end if;
		END;
		--dbms_output.put_line('attributeValueTable: ' || attributeValueTable);
		--dbms_output.put_line('attributeUnitsTable: ' || attributeUnitsTable);
		IF attributeValueTable is not null THEN
			-- need code-table controlled value, no units
			--dbms_output.put_line('got attributeValueTable');	
			if attributeUnits is not null then
				return 0;
			end if;
			thesql := 'select /*+ RESULT_CACHE */ count(*) from user_tab_cols where table_name = upper(''' ||attributeValueTable || ''') and column_name=''COLLECTION_CDE''' ;
			execute immediate thesql into numRecs;
	    	thesql := 'select  /*+ RESULT_CACHE */ column_name from user_tab_cols where table_name = ''' ||upper(attributeValueTable) || '''
	    		and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''';
			execute immediate thesql into attributeCodeTableColName;
		    if numRecs = 1 then
				-- there is a collection code	
				--dbms_output.put_line('there is a collection code');
				--dbms_output.put_line('attributeValue: ' || attributeValue);
		    	temp:=replace(attributeValue,'''','''''');
				--dbms_output.put_line('temp: ' || temp);
				execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeValueTable || ' where ' || 
					attributeCodeTableColName || ' = ''' || temp || ''' and collection_cde = ''' || 
					collection_cde || '''' into numRecs;
				if numRecs = 0 then
					return 0;
				end if;
			else
				--dbms_output.put_line('attributeCodeTableColName: ' || attributeCodeTableColName);
				--dbms_output.put_line('attributeValue: ' || attributeValue);
				execute immediate 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeValueTable || ' where ' || 
					attributeCodeTableColName || ' = ''' || attributeValue || '''' into numRecs;
				if numRecs = 0 then
					return 0;
				end if;
			end if;
    	elsif attributeUnitsTable is not null then
    		--dbms_output.put_line('got attributeUnitsTable');
	    	-- attribute value must be number
    		if is_number(attributeValue)=0 then
	    		--dbms_output.put_line('attributeValue is not a number - ' || attributeValue);
	    		return 0;
	    	end if;
	        --dbms_output.put_line('there is a units table--' || attributeUnitsTable);	
		    thesql := 'select  /*+ RESULT_CACHE */ count(*) from user_tab_cols where table_name = upper(''' || attributeUnitsTable || ''') and column_name=''COLLECTION_CDE''';
   		    --dbms_output.put_line(thesql);	
   		  dbms_output.put_line('user_tab_cols##='||numRecs);	
		    execute immediate thesql into numRecs;
    		thesql := 'select  /*+ RESULT_CACHE */ column_name from user_tab_cols where table_name = upper(''' ||upper(attributeUnitsTable) || ''')
	    		and column_name <> ''DESCRIPTION'' and column_name <> ''COLLECTION_CDE''';
	    	 --dbms_output.put_line(thesql);		 
    		execute immediate thesql into attributeCodeTableColName;
    	   	--dbms_output.put_line('attributeCodeTableColName=' || attributeCodeTableColName);	
	    	if numRecs = 1 then
    			thesql :='select  /*+ RESULT_CACHE */ count(*) from ' || attributeUnitsTable || ' where ' || 
    				attributeCodeTableColName || ' = ''' || attributeUnits || ''' and collection_cde = ''' || 
    				collection_cde || '''';
    			 --dbms_output.put_line(thesql);	
    		 	 --dbms_output.put_line(numRecs);	
    			execute immediate thesql into numRecs;
    		if numRecs = 0 then
				return 0;
			end if;
    	else
    		thesql := 'select  /*+ RESULT_CACHE */ count(*) from ' || attributeUnitsTable || ' where ' || 
    			attributeCodeTableColName || ' = ''' || attributeUnits || '''';
    		    --dbms_output.put_line(thesql);	
   			execute immediate thesql into numRecs;	
			if numRecs = 0 then
				return 0;
			end if;
    	end if;
    end if;	
	--dbms_output.put_line('happy');

	return 1;
end;
/
sho err;


CREATE or replace PUBLIC SYNONYM isValidAttribute FOR isValidAttribute;
GRANT execute ON isValidAttribute TO PUBLIC;

-- select isValidAttribute('sex','female','','mammf') from dual;
select isValidAttribute(ATTRIBUTE,ATTRIBUTE_VALUE,ATTRIBUTE_UNITS,trim(SUBSTR(guid_prefix, INSTR(guid_prefix, ':')+1))),attribute,attribute_value,attribute_units from cf_temp_attributes where username='DLM' and  attribute='reproductive data' and attribute_units is not null;

