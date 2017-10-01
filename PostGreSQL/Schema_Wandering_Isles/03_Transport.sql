BEGIN;
--transport==================================================================
--Table Definitions-------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.transport_base CASCADE;
CREATE TABLE wandering_isles.transport_base (
    pid SERIAL PRIMARY KEY
  , wid TEXT UNIQUE
  , transport_name TEXT NOT NULL
  , transport_type TEXT NOT NULL REFERENCES wandering_isles.transport_type (transport_type)
  , transport_scale TEXT NOT NULL REFERENCES wandering_isles.scale (scale)
  , transport_notes TEXT
  , make TEXT NOT NULL REFERENCES wandering_isles.make (make)
  , the_geom GEOMETRY(LINESTRING, 3857) NOT NULL
);

--Clean up new rows-------------------------------------------------------------
DROP FUNCTION IF EXISTS wandering_isles.transport_cleanup() CASCADE;
CREATE OR REPLACE FUNCTION wandering_isles.transport_cleanup()
  RETURNS trigger AS
$BODY$
BEGIN
    
    IF TG_OP = 'INSERT' THEN
        NEW.pid = nextval('wandering_isles.transport_base_pid_seq');
        NEW.wid = ('WID' || LPAD(nextval('wandering_isles.wid_sequence')::text, 10, '0'));
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.pid = OLD.pid;
        NEW.wid = OLD.wid;
    END IF;
    
    NEW.the_geom = ST_ForceRHR(ST_MakeValid(ST_RemoveRepeatedPoints(NEW.the_geom)));

 RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE TRIGGER transport_insert BEFORE INSERT ON wandering_isles.transport_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.transport_cleanup();

CREATE TRIGGER transport_update BEFORE UPDATE ON wandering_isles.transport_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.transport_cleanup();

--Version control trigger-------------------------------------------------------
CREATE TRIGGER transport_insert_log AFTER INSERT ON wandering_isles.transport_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER transport_update_log AFTER UPDATE ON wandering_isles.transport_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER transport_delete_log AFTER DELETE ON wandering_isles.transport_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

--View--------------------------------------------------------------------------
CREATE VIEW wandering_isles.transport AS SELECT
    pid
  , wid
  , transport_name
  , transport_type
  , transport_scale
  , transport_notes
  , make
  , the_geom
FROM wandering_isles.transport_base;

COMMIT;
