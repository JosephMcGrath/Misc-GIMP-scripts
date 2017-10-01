BEGIN;
--landcover_detail_base========================================================
--Table Definitions-------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.landcover_detail_base CASCADE;
CREATE TABLE wandering_isles.landcover_detail_base (
    pid SERIAL PRIMARY KEY
  , wid TEXT UNIQUE NOT NULL DEFAULT ('WID' || LPAD(nextval('wandering_isles.wid_sequence')::text, 10, '0'))
  , class_primary TEXT NOT NULL REFERENCES wandering_isles.class_primary(class_primary)
  , class_secondary TEXT NOT NULL DEFAULT 'None'REFERENCES wandering_isles.class_secondary(class_secondary)
  , make TEXT NOT NULL REFERENCES wandering_isles.make (make)
  , material TEXT NOT NULL REFERENCES wandering_isles.material (material) DEFAULT 'Undefined'
  , height_above_ground REAL
  , height_above_datum REAL
  , snap_threshold REAL
  , the_geom GEOMETRY(POLYGON, 3857) NOT NULL CHECK (ST_NPoints(the_geom) > 2)
);

CREATE INDEX landcover_detail_base_the_geom_idx
    ON wandering_isles.landcover_detail_base USING gist
    (the_geom);

--Clean up new rows-------------------------------------------------------------
DROP FUNCTION IF EXISTS wandering_isles.landcover_detail_cleanup() CASCADE;
CREATE OR REPLACE FUNCTION wandering_isles.landcover_detail_cleanup()
  RETURNS trigger AS
$BODY$
BEGIN
    
    IF TG_OP = 'INSERT' THEN
        NEW.pid = nextval('wandering_isles.landcover_detail_base_pid_seq');
        NEW.wid = ('WID' || LPAD(nextval('wandering_isles.wid_sequence')::text, 10, '0'));
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.pid = OLD.pid;
        NEW.wid = OLD.wid;
    END IF;
    
    IF NEW.snap_threshold > 0 THEN
        NEW.the_geom = ST_SnapToGrid(NEW.the_geom, NEW.snap_threshold);
    END IF;
    
    NEW.the_geom = ST_ForceRHR(ST_MakeValid(ST_RemoveRepeatedPoints(NEW.the_geom)));

 RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE TRIGGER landcover_detail_insert BEFORE INSERT ON wandering_isles.landcover_detail_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.landcover_detail_cleanup();

CREATE TRIGGER landcover_detail_update BEFORE UPDATE ON wandering_isles.landcover_detail_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.landcover_detail_cleanup();


--Version control trigger-------------------------------------------------------
CREATE TRIGGER landcover_detail_insert_log AFTER INSERT ON wandering_isles.landcover_detail_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER landcover_detail_update_log AFTER UPDATE ON wandering_isles.landcover_detail_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER landcover_detail_delete_log AFTER DELETE ON wandering_isles.landcover_detail_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

--View--------------------------------------------------------------------------
CREATE VIEW wandering_isles.landcover_detail AS SELECT
    pid
  , wid
  , class_primary
  , class_secondary
  , make
  , material
  , height_above_ground
  , height_above_datum
  , snap_threshold
  , the_geom
FROM wandering_isles.landcover_detail_base;

COMMIT;
