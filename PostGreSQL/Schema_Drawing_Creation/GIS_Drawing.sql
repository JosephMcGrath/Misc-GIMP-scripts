BEGIN;

    CREATE SCHEMA drawing_data;
    
    CREATE TABLE drawing_data.line_in (
        oid SERIAL PRIMARY KEY
      , drawing_name VARCHAR NOT NULL
      , item_category VARCHAR NOT NULL
      , item_name VARCHAR
      , measured_length FLOAT
      , to_label BOOLEAN DEFAULT FALSE
      , label_position VARCHAR CHECK(Lower(label_position) IN ('above', 'on', 'below'))
      , label_offset FLOAT
      , the_geom GEOMETRY(LINESTRING, 27700) NOT NULL
    );
    
    CREATE OR REPLACE FUNCTION drawing_data.line_data_cleanup()
        RETURNS trigger AS
        $BODY$
        BEGIN
            
            IF NEW.drawing_name IS NULL THEN
                
                RAISE EXCEPTION 'Must enter a drawing name.';
                
            END IF;
            
            IF NEW.item_category IS NULL THEN
                
                RAISE EXCEPTION 'Must enter an item category.';
                
            END IF;
            
            NEW.label_position := Lower(NEW.label_position);
            
            --Forcing line directions for more consistent labeling
                --If lines are drawn in different directions, offsets of lines will be on different sides.
            IF ST_X(ST_StartPoint(NEW.the_geom)) >= ST_X(ST_EndPoint(NEW.the_geom)) OR 
               ST_Y(ST_StartPoint(NEW.the_geom)) > ST_Y(ST_EndPoint(NEW.the_geom))
            THEN
                
                NEW.the_geom := ST_Reverse(NEW.the_geom);
                
            END IF;
            
            RETURN NEW;
        END;
        $BODY$
        LANGUAGE plpgsql;
    
    CREATE TRIGGER line_data_insert
        BEFORE INSERT
        ON drawing_data.line_in
        FOR EACH ROW
        EXECUTE PROCEDURE drawing_data.line_data_cleanup();
    
    CREATE TRIGGER line_data_update
        BEFORE UPDATE
        ON drawing_data.line_in
        FOR EACH ROW
        EXECUTE PROCEDURE drawing_data.line_data_cleanup();
    
    CREATE OR REPLACE VIEW drawing_data.merged_polygon AS
        SELECT
            row_number() OVER () AS pid,
            oid,
            x.drawing_name,
            x.item_category,
            x.item_name,
            ST_MakePolygon((x.the_geom).geom) AS geom
        FROM (
            SELECT
                min(line_in.oid) AS oid,
                line_in.drawing_name,
                line_in.item_category,
                line_in.item_name,
                ST_Dump(
                        ST_LineMerge(
                                     ST_Union(line_in.the_geom)
                                     )
                        ) AS the_geom
            FROM drawing_data.line_in
                GROUP BY
                    line_in.drawing_name,
                    line_in.item_category,
                    line_in.item_name
            ) AS x
        WHERE
            ST_IsRing((x.the_geom).geom)
        ORDER BY
            ST_Area(ST_MakePolygon((x.the_geom).geom)) DESC;
        
        
        CREATE OR REPLACE VIEW drawing_data.broken_line AS 
            SELECT
                row_number() OVER () AS pid,
                x.drawing_name,
                x.item_category,
                x.item_name,
                ST_Boundary((x.the_geom).geom) AS the_geom
            FROM (SELECT
                      min(oid) AS oid,
                      drawing_name,
                      item_category,
                      item_name,
                      ST_Dump(ST_LineMerge(ST_Union(the_geom))) AS the_geom
                  FROM
                      drawing_data.line_in
                    GROUP BY
                        line_in.drawing_name,
                        line_in.item_category,
                        line_in.item_name
                  ) AS x
            WHERE
                NOT ST_IsRing((x.the_geom).geom);
        
    CREATE OR REPLACE VIEW drawing_data.line_diffs AS
        SELECT
            line_in.oid,
            line_in.drawing_name,
            line_in.item_category,
            line_in.measured_length,
            round(st_length(line_in.the_geom)::numeric, 3) AS line_length,
            round((st_length(line_in.the_geom) - line_in.measured_length)::numeric, 3) AS abs_diff,
            round(((st_length(line_in.the_geom) - line_in.measured_length) / line_in.measured_length * 100::double precision)::numeric, 2) AS perc_diff,
            line_in.the_geom
        FROM
            drawing_data.line_in
        WHERE
            line_in.measured_length IS NOT NULL AND
            abs((st_length(line_in.the_geom) - line_in.measured_length)) >= 0.001::double precision
        ORDER BY
            round(((st_length(line_in.the_geom) - line_in.measured_length) / line_in.measured_length * 100::double precision)::numeric, 2) DESC;
