CREATE OR REPLACE function b_concatGeologyAttributeDetail(bcollobjid  in number )
    return varchar2
    as
        type rc is ref cursor;
        l_str    varchar2(4000);
       l_sep    varchar2(30);
       l_val    varchar2(4000);
       temp varchar2(4000);
       thisAtt VARCHAR2(38);
       thisVal VARCHAR2(38);
       thisDet VARCHAR2(38);
       thisDate  VARCHAR2(38);
       thisMeth VARCHAR2(38);
       thisRemark  VARCHAR2(38);
/*
	returns a pipe-delimited list of geology attribute determinations
	FROM THE BULKLOADER
	
	Used in conjunction with concatGeologyAttributeDetail
	to check for existing localities
*/
   begin
    FOR i IN 1..6 LOOP
        thisAtt:='geology_attribute_' || i;
        thisVal:='geo_att_value_' || i;
        thisDet:='geo_att_determiner_' || i;
        thisDate:='geo_att_determined_date_' || i;
        thisMeth:='geo_att_determined_method_' || i;
        thisRemark:='geo_att_remark_' || i;
       
        EXECUTE IMMEDIATE 'SELECT ' || thisAtt || ' FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
        IF temp IS NOT NULL THEN
            l_str:=l_str||l_sep || temp;
            EXECUTE IMMEDIATE 'SELECT ' || thisVal || ' FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
            l_str:=l_str || '=' || temp;
            EXECUTE IMMEDIATE 'SELECT ' || thisDet || ' FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
            IF temp IS NOT NULL THEN
                l_str:=l_str || '; Determined by ' || temp;
            END IF;
            EXECUTE IMMEDIATE 'SELECT to_date(' || thisDate || ') FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
            IF temp IS NOT NULL THEN
                l_str:=l_str || ' on ' || temp;
            END IF;
            EXECUTE IMMEDIATE 'SELECT ' || thisMeth || ' FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
            IF temp IS NOT NULL THEN
                l_str:=l_str || '; Method: ' || temp;
            END IF;
               EXECUTE IMMEDIATE 'SELECT ' || thisRemark || ' FROM bulkloader WHERE collection_object_id=' || bcollobjid INTO temp ;
            IF temp IS NOT NULL THEN
                l_str:=l_str || '; Remark: ' || temp;
            END IF;
             l_sep := '|';
        END IF;
        
    END LOOP;
    return l_str;
  end;
/
--   select b_concatGeologyAttributeDetail(57012) from dual;
CREATE PUBLIC SYNONYM b_concatGeologyAttributeDetail FOR b_concatGeologyAttributeDetail;
GRANT EXECUTE ON b_concatGeologyAttributeDetail TO PUBLIC;