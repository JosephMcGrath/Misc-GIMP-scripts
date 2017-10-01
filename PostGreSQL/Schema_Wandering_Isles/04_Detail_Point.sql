BEGIN;
--detail_point==================================================================
--Table Definitions-------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.detail_point_base CASCADE;
CREATE TABLE wandering_isles.detail_point_base (
    pid SERIAL PRIMARY KEY
  , wid TEXT UNIQUE
  , feature_wid TEXT NOT NULL UNIQUE REFERENCES wandering_isles.landcover_detail_base (wid)
  , transport_wid TEXT NOT NULL REFERENCES wandering_isles.transport_base (wid)
  , address_name TEXT
  , address_number TEXT
  , address_street TEXT
  , address_district TEXT
  , address_city TEXT
  , box_text TEXT
  , feature_purpose TEXT NOT NULL REFERENCES wandering_isles.feature_purpose (feature_purpose)
  , the_geom GEOMETRY(POINT, 3857) NOT NULL
);

--Clean up new rows-------------------------------------------------------------
DROP FUNCTION IF EXISTS wandering_isles.detail_point_cleanup() CASCADE;
CREATE OR REPLACE FUNCTION wandering_isles.detail_point_cleanup()
  RETURNS trigger AS
$BODY$
BEGIN
    
    IF TG_OP = 'INSERT' THEN
        NEW.pid = nextval('wandering_isles.detail_point_base_pid_seq');
        NEW.wid = ('WID' || LPAD(nextval('wandering_isles.wid_sequence')::text, 10, '0'));
        
        IF NEW.feature_wid IS NULL THEN
            SELECT
                x.wid INTO NEW.feature_wid
            FROM
                wandering_isles.landcover_detail_base AS x
            WHERE
                ST_Intersects(NEW.the_geom, x.the_geom)
            LIMIT 1;
        END IF;
        
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.pid = OLD.pid;
        NEW.wid = OLD.wid;
    END IF;
    
    NEW.the_geom = ST_MakeValid(ST_RemoveRepeatedPoints(NEW.the_geom));

 RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

CREATE TRIGGER detail_point_insert BEFORE INSERT ON wandering_isles.detail_point_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.detail_point_cleanup();

CREATE TRIGGER detail_point_update BEFORE UPDATE ON wandering_isles.detail_point_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.detail_point_cleanup();

--Version control trigger-------------------------------------------------------
CREATE TRIGGER detail_point_insert_log AFTER INSERT ON wandering_isles.detail_point_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER detail_point_update_log AFTER UPDATE ON wandering_isles.detail_point_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

CREATE TRIGGER detail_point_delete_log AFTER DELETE ON wandering_isles.detail_point_base
    FOR EACH ROW
    EXECUTE PROCEDURE wandering_isles.log_revision();

--View--------------------------------------------------------------------------
CREATE VIEW wandering_isles.detail_point AS SELECT
    pid
  , wid
  , feature_wid
  , transport_wid
  , address_name
  , address_number
  , address_street
  , address_district
  , address_city
  , box_text
  , feature_purpose
  , the_geom
FROM wandering_isles.detail_point_base;

CREATE VIEW wandering_isles.point_transport_link AS SELECT
    p.pid
  , p.wid AS point_wid
  , t.wid AS transport_wid
  , ST_ShortestLine(p.the_geom, t.the_geom) AS the_geom
FROM
    wandering_isles.detail_point_base AS p
    INNER JOIN wandering_isles.transport_base AS t ON t.wid = p.transport_wid;

CREATE OR REPLACE VIEW wandering_isles.point_feature_position AS SELECT
    p.pid
  , p.wid AS point_wid
  , t.wid AS feature_wid
  , ST_PointOnSurface(t.the_geom) AS the_geom
FROM
    wandering_isles.detail_point_base AS p
    INNER JOIN wandering_isles.landcover_detail_base AS t ON t.wid = p.feature_wid;

COMMIT;
