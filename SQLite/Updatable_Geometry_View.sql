BEGIN;

    CREATE TABLE base_table (
        pid INTEGER PRIMARY KEY
      , comments TEXT
      , geometry_wkt TEXT
      , geometry_json TEXT
      , geometry LINESTRING NOT NULL
    );
    
    SELECT
        RecoverGeometryColumn("base_table", "geometry", 27700, "LINESTRING", "XY")
      , CreateSpatialIndex("base_table", "geometry");
    
    CREATE VIEW use_view AS SELECT
        pid
      , comments
      , geometry
    FROM
        base_table;
    
    INSERT INTO views_geometry_columns (
        view_name,
        view_geometry,
        view_rowid,
        f_table_name,
        f_geometry_column,
        read_only)
    VALUES (
        'use_view',
        'geometry',
        'pid',
        'base_table',
        'geometry',
        0
        );
    
    CREATE TRIGGER use_view_insert INSTEAD OF INSERT ON use_view
        FOR EACH ROW
        BEGIN
        
            INSERT INTO base_table
                (comments, geometry, geometry_wkt, geometry_json)
            VALUES
                (NEW.comments, NEW.geometry, AsWKT(SnapToGrid(NEW.geometry, 0.001)), AsGeoJSON(SnapToGrid(NEW.geometry, 0.001)));
    END;
    
    CREATE TRIGGER use_view_delete INSTEAD OF DELETE ON use_view
        FOR EACH ROW
        BEGIN
        
            DELETE FROM base_table
            WHERE pid = OLD.pid;
    END;
    
    CREATE TRIGGER use_view_update INSTEAD OF UPDATE ON use_view
        FOR EACH ROW
        BEGIN
        
            UPDATE base_table
            SET
                comments = NEW.comments
              , geometry = SnapToGrid(NEW.geometry, 0.001)
              , geometry_wkt = AsWKT(SnapToGrid(NEW.geometry, 0.001))
              , geometry_json = AsGeoJSON(SnapToGrid(NEW.geometry, 0.001))
            WHERE
                pid = OLD.pid;
    END;
    
COMMIT;
