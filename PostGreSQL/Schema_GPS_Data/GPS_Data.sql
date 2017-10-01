BEGIN;
    
    DROP SCHEMA IF EXISTS gps_data CASCADE;
    CREATE SCHEMA gps_data AUTHORIZATION jwm;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA
        gps_data
    GRANT
        INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLES
    TO "admin_jwm_data" WITH GRANT OPTION;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA
        gps_data
    GRANT
        USAGE, SELECT, UPDATE ON SEQUENCES
    TO "admin_jwm_data" WITH GRANT OPTION;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA
        gps_data
    GRANT SELECT, REFERENCES, TRIGGER
        ON TABLES
    TO "access_jwm_data";
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA
        gps_data
    GRANT
        SELECT ON SEQUENCES
    TO "access_jwm_data" WITH GRANT OPTION;
    
    CREATE TABLE gps_data.file_in (
        gps_file TEXT PRIMARY KEY
      , loaded BOOLEAN NOT NULL DEFAULT(FALSE)
    );
    
    CREATE TABLE gps_data.staging (
        pid SERIAL PRIMARY KEY
      , time TIMESTAMP
      , lat NUMERIC
      , lon NUMERIC
      , elevation NUMERIC
      , accuracy NUMERIC
      , bearing NUMERIC
      , speed NUMERIC
      , satellites INTEGER
      , provider TEXT
      , hdop NUMERIC
      , vdop NUMERIC
      , pdop NUMERIC
      , geoidheight NUMERIC
      , ageofdgpsdata TEXT
      , dgpsid TEXT
      , activity TEXT
      , battery NUMERIC
    );
    
    CREATE TABLE gps_data.gps_point (
        pid SERIAL PRIMARY KEY
      , time TIMESTAMP NOT NULL
      , lat NUMERIC NOT NULL
      , lon NUMERIC NOT NULL
      , elevation NUMERIC
      , accuracy NUMERIC
      , bearing NUMERIC
      , speed NUMERIC
      , satellites TEXT
      , provider TEXT
      , hdop NUMERIC
      , vdop NUMERIC
      , pdop NUMERIC
      , geoidheight NUMERIC
      , ageofdgpsdata TEXT
      , dgpsid TEXT
      , activity TEXT
      , battery NUMERIC
      , the_geom GEOMETRY(POINT, 27700)
      , CONSTRAINT unique_placetime UNIQUE (time, lat, lon)
    );
    
    CREATE INDEX gps_point_the_geom_idx
        ON gps_data.gps_point USING gist
        (the_geom);
    
    CREATE INDEX gps_point_time_idx
        ON gps_data.gps_point USING btree
        (time);
    
    CREATE INDEX gps_point_accuracy_idx
        ON gps_data.gps_point USING btree
        (accuracy);
    
    CREATE INDEX gps_point_time_plus_20_idx
        ON gps_data.gps_point (("time" + '20 seconds'::INTERVAL));
    
    CREATE TABLE gps_data.gps_line (
        start_point INTEGER REFERENCES gps_data.gps_point (pid)
      , end_point INTEGER REFERENCES gps_data.gps_point (pid)
      , the_geom GEOMETRY(LINESTRING, 27700)
      , CONSTRAINT gps_line_pkey PRIMARY KEY (start_point, end_point)
    );
    
    CREATE INDEX gps_line_the_geom_idx
        ON gps_data.gps_line USING gist
        (the_geom);
    
    CREATE OR REPLACE FUNCTION gps_data.gps_load()
        RETURNS TRIGGER AS $trig$
    BEGIN
        
        IF NEW.satellites = 0 THEN
            NEW.satellites := NULL;
        END IF;
        IF NEW.ageofdgpsdata = '' THEN
            NEW.ageofdgpsdata := NULL;
        END IF;
        IF NEW.dgpsid = '' THEN
            NEW.dgpsid := NULL;
        END IF;
        IF NEW.activity = '' THEN
            NEW.activity := NULL;
        END IF;
        
        INSERT INTO gps_data.gps_point
            (time
           , lat
           , lon
           , elevation
           , accuracy
           , bearing
           , speed
           , satellites
           , provider
           , hdop
           , vdop
           , pdop
           , geoidheight
           , ageofdgpsdata
           , dgpsid
           , activity
           , battery
           , the_geom
             )
        SELECT
            NEW.time
          , NEW.lat
          , NEW.lon
          , NEW.elevation
          , NEW.accuracy
          , NEW.bearing
          , NEW.speed
          , NEW.satellites
          , NEW.provider
          , NEW.hdop
          , NEW.vdop
          , NEW.pdop
          , NEW.geoidheight
          , NEW.ageofdgpsdata
          , NEW.dgpsid
          , NEW.activity
          , NEW.battery
          , ST_Transform(ST_SetSRID(ST_MakePoint(NEW.lon,
                                                 NEW.lat
                                                 ),
                                 4326
                                 ),
                         27700
                         )
        ON CONFLICT DO NOTHING;
        
        RETURN NEW;
        
    END;
    $trig$ LANGUAGE plpgsql;
    
    CREATE OR REPLACE FUNCTION gps_data.gps_line()
        RETURNS TRIGGER AS $trig$
    BEGIN
        
        INSERT INTO gps_data.gps_line
            (start_point, end_point, the_geom)
        SELECT
            s.pid
          , e.pid
          , ST_MakeLine(s.the_geom, e.the_geom)
        FROM
            gps_data.gps_point AS s
            INNER JOIN gps_data.gps_point AS e ON e.time > s.time AND
                                                  e.time < (s.time + '20 seconds'::INTERVAL) AND
                                                  s.accuracy <= 25 AND
                                                  e.accuracy <= 25
        WHERE
            e.pid = NEW.pid
        ORDER BY
            extract(epoch FROM age(e.time, s.time))
        LIMIT 1
        ON CONFLICT DO NOTHING;
        
        RETURN NEW;
        
    END;
    $trig$ LANGUAGE plpgsql;
    
    CREATE TRIGGER import_gps AFTER INSERT OR UPDATE ON gps_data.staging
        FOR EACH ROW
        EXECUTE PROCEDURE gps_data.gps_load();
    
    CREATE TRIGGER create_line AFTER INSERT OR UPDATE ON gps_data.gps_point
        FOR EACH ROW
        WHEN (NEW.accuracy < 25)
        EXECUTE PROCEDURE gps_data.gps_line();
        
    
COMMIT;
