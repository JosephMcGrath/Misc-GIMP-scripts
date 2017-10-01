BEGIN;

DROP SEQUENCE IF EXISTS wandering_isles.wid_sequence CASCADE;

CREATE SEQUENCE wandering_isles.wid_sequence
    INCREMENT 1
    START 1;

--Revision control--------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.revision_log CASCADE;
CREATE TABLE wandering_isles.revision_log (
    id SERIAL PRIMARY KEY
  , table_name TEXT NOT NULL
  , revision_type TEXT NOT NULL
  , wid TEXT NOT NULL
  , revision_time TIMESTAMP DEFAULT NOW()
);

DROP FUNCTION IF EXISTS wandering_isles.log_revision() CASCADE;
CREATE OR REPLACE FUNCTION wandering_isles.log_revision()
  RETURNS trigger AS
$BODY$
BEGIN
    
    IF TG_OP != 'DELETE' THEN
        INSERT INTO wandering_isles.revision_log (
             table_name,
             revision_type,
             wid
        ) VALUES (
            TG_TABLE_NAME,
            TG_OP,
            NEW.wid
        );
    ELSE
        INSERT INTO wandering_isles.revision_log (
             table_name,
             revision_type,
             wid
        ) VALUES (
            TG_TABLE_NAME,
            TG_OP,
            OLD.wid
        );
    END IF;
    
 RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';

--scale-------------------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.scale CASCADE;

CREATE TABLE wandering_isles.scale (
    scale TEXT PRIMARY KEY
  , description TEXT
  , min_scale REAL
  , max_scale REAL
);

--make--------------------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.make CASCADE;

CREATE TABLE wandering_isles.make (
    make TEXT PRIMARY KEY
  , description TEXT UNIQUE NOT NULL
);

--class_primary-----------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.class_primary CASCADE;

CREATE TABLE wandering_isles.class_primary (
    class_primary TEXT PRIMARY KEY
  , description TEXT UNIQUE NOT NULL
);

--class_secondary---------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.class_secondary CASCADE;

CREATE TABLE wandering_isles.class_secondary (
    class_secondary TEXT PRIMARY KEY
  , description TEXT
);

--material----------------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.material CASCADE;

CREATE TABLE wandering_isles.material (
    material TEXT PRIMARY KEY
  , description TEXT
);

--feature_purpose---------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.feature_purpose CASCADE;

CREATE TABLE wandering_isles.feature_purpose (
    feature_purpose TEXT PRIMARY KEY
  , description TEXT
  , abbreviation TEXT NOT NULL UNIQUE
);

--transport_type----------------------------------------------------------------
DROP TABLE IF EXISTS wandering_isles.transport_type CASCADE;

CREATE TABLE wandering_isles.transport_type (
    transport_type TEXT PRIMARY KEY
  , description TEXT
);

COMMIT;
