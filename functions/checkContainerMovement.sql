CREATE OR REPLACE function checkContainerMovement (parent_barcode  in VARCHAR2, child_barcode IN VARCHAR2 )
    return VARCHAR2
    as
        msg VARCHAR2(4000);
        sep varchar2(2);
        p container%ROWTYPE;
        c container%ROWTYPE;
   begin
       SELECT * INTO p FROM container WHERE barcode=parent_barcode;
       SELECT * INTO c FROM container WHERE barcode=child_barcode;

       if p.container_id=c.container_id then
           msg := msg || sep || 'A container may not be in itself.';
           sep := '; ';
       END IF;

       if c.container_type='collection object' then
           msg := msg || sep || 'You cannot put anything in a collection object.';
           sep := '; ';
       END IF; 
       if p.container_type='%label%' then
           msg := msg || sep || 'You cannot put anything in a label.';
           sep := '; ';
       END IF;
       if c.container_type='%label%' then
           msg := msg || sep || 'A label cannot have a parent.';
           sep := '; ';
       END IF;
       if c.container_type='%label%' then
           msg := msg || sep || 'A label cannot have a parent.';
           sep := '; ';
       END IF;

       if (c.HEIGHT>=p.HEIGHT) OR (c.WIDTH>=p.WIDTH) OR (c.LENGTH>=p.LENGTH) then
           msg := msg || sep || 'The child will not fit into the parent.';
           sep:='; ';
       END IF;
        IF msg IS NULL THEN
            msg:='pass';
        ELSE
            msg := msg || '<-- that is not null.';
        END IF;
       return msg;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 'No Data Found - bad barcode?';
    WHEN OTHERS THEN
       RETURN SQLCODE || ': ' || SQLERRM;
  end;
/
sho err


CREATE OR REPLACE PUBLIC SYNONYM checkContainerMovement FOR checkContainerMovement;
GRANT EXECUTE ON checkContainerMovement TO PUBLIC;