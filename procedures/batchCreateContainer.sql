CREATE OR REPLACE procedure batchCreateContainer is 
		c number;
   	begin
	   	-- revalidate, because
	   	select count(*) into c from cf_temp_container where barcode in (select barcode from container where barcode is not null);
	   	if c > 0 then
            raise_application_error(-20000, 'Existing barcodes detected');
        end if;
		select count(*) into c from (select count(barcode) from cf_temp_container group by barcode having count(barcode) > 1);
        if c > 0 then
            raise_application_error(-20000, 'Duplicate barcodes detected');
        end if;
		select count(*) into c from cf_temp_container where barcode != trim(barcode);
        if c > 0 then
            raise_application_error(-20000, 'Untrimmed barcodes detected');
        end if;
		select count(*) into c from cf_temp_container where container_type not in (select container_type from ctcontainer_type);
        if c > 0 then
            raise_application_error(-20000, 'Invalid container_type');
        end if;
		select count(*) into c from cf_temp_container where institution_acronym not in (select institution_acronym from collection);
        if c > 0 then
            raise_application_error(-20000, 'Invalid institution_acronym');
        end if;
        select count(*) into c from cf_temp_container where barcode is not null and IS_CLAIMED_BARCODE(barcode) != 'PASS';
        if c > 0 then
            raise_application_error(-20000, 'Invalid barcodes detected');
        end if;
    
        -- if we made it here, rock on
        
        insert into container (
		  CONTAINER_ID,
		  PARENT_CONTAINER_ID,
		  CONTAINER_TYPE,
		  LABEL,
		  BARCODE,
		  INSTITUTION_ACRONYM,
		  DESCRIPTION,
		  CONTAINER_REMARKS
		) (
		  select
		    sq_container_id.nextval,
		    0,
		    CONTAINER_TYPE,
		    LABEL,
		    BARCODE,
		    INSTITUTION_ACRONYM,
		    DESCRIPTION,
		    CONTAINER_REMARKS
		  from
		    cf_temp_container
		);
		

 
 
	end;
/
sho err;




	
CREATE OR REPLACE PUBLIC SYNONYM batchCreateContainer FOR batchCreateContainer;
GRANT EXECUTE ON batchCreateContainer TO manage_container;




