
CREATE OR REPLACE FUNCTION dms_to_string (
    d_lat IN VARCHAR2,
    m_lat IN VARCHAR2,
    s_lat IN VARCHAR2,
    dir_lat IN VARCHAR2,
    d_long IN VARCHAR2,
    m_long IN VARCHAR2,
    s_long  IN VARCHAR2,
    dir_long  IN VARCHAR2
    ) return varchar2 as
       rval varchar2(4000);
   BEGIN
       rval := d_lat || 'd ' || m_lat || 'm ' || s_lat || 's ' ||upper(dir_lat) || '/' || d_long || 'd ' || m_long || 'm ' || s_long || 's ' ||upper(dir_long);
       if rval='/' then
       	rval:=NULL;
       end if;
       RETURN rval;
   END;
/

CREATE OR REPLACE PUBLIC SYNONYM dms_to_string FOR dms_to_string;
GRANT EXECUTE ON dms_to_string TO PUBLIC;