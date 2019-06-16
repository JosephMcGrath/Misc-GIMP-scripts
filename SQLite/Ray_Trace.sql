/*Table of angles.*/
CREATE TABLE angles (r REAL PRIMARY KEY);

WITH RECURSIVE angle_temp (d) AS (
    VALUES (0)
    UNION ALL
    SELECT d + (360 / 256)
    FROM angle_temp
    WHERE d < 360
)

INSERT OR IGNORE INTO angles (r)
SELECT Radians(d) FROM angle_temp
ORDER BY d;

/*Test Layers*/
CREATE TABLE base_point (
    fid INTEGER PRIMARY KEY
  , sight REAL DEFAULT 1
  , the_geom POINT
);

SELECT RecoverGeometryColumn('base_point' , 'the_geom' , 27700 , 'POINT');

CREATE TABLE wall (
    fid INTEGER PRIMARY KEY
  , the_geom LINESTRING
);

SELECT RecoverGeometryColumn('wall' , 'the_geom' , 27700 , 'LINESTRING');


CREATE TABLE los (
    fid INTEGER PRIMARY KEY
  , the_geom POLYGON
);

SELECT RecoverGeometryColumn('los' , 'the_geom' , 27700 , 'POLYGON');

/*Intermediate Views*/
CREATE VIEW base_ray AS SELECT
    fid
  , r AS angle
  , MakeLine(the_geom,
             ST_Transform(ST_Project(ST_Transform(the_geom, 4326), sight, r), ST_SRID(the_geom))
             ) AS the_geom
FROM base_point CROSS JOIN angles ORDER BY r;

CREATE VIEW split_ray AS SELECT r.fid, r.angle, Coalesce(ST_GeometryN(ST_Split(r.the_geom, w.the_geom), 1), r.the_geom) AS the_geom
FROM base_ray AS r
    LEFT OUTER JOIN wall AS w
        ON ST_Intersects(r.the_geom, w.the_geom);

CREATE VIEW shortest_split_ray AS SELECT fid, angle, the_geom
FROM split_ray
GROUP BY fid, angle
HAVING ST_LENGTH(the_geom)  = MIN(ST_LENGTH(the_geom));

CREATE VIEW unclosed_ring AS SELECT fid, MakeLine(ST_PointN(the_geom, -1)) AS the_geom
FROM shortest_split_ray
GROUP BY fid;

CREATE VIEW view_ring AS SELECT fid, AddPoint(the_geom, ST_StartPoint(the_geom)) AS the_geom
FROM unclosed_ring;

/*Update Triggers*/
CREATE TRIGGER los_calc_insert AFTER INSERT ON base_point
BEGIN
    INSERT INTO los (fid, the_geom)
    SELECT fid, MakePolygon(the_geom) FROM view_ring
    WHERE fid = NEW.fid;
END;

CREATE TRIGGER los_calc_update AFTER UPDATE ON base_point
BEGIN
    DELETE FROM los WHERE fid = OLD.fid;

    INSERT INTO los (fid, the_geom)
    SELECT fid, MakePolygon(the_geom) FROM view_ring
    WHERE fid = NEW.fid;
END;

CREATE TRIGGER los_calc_delete AFTER DELETE ON base_point
BEGIN
    DELETE FROM los WHERE fid = OLD.fid;
END;
