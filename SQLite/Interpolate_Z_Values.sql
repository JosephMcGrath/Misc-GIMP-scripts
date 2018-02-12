/*============================================================================*/
/*This snippet interpolates all of the points along a table of LINESTRINGZs.  */
/*Unfortunately, as the implementation uses WITH statements and at the time of*/
/*  writing they don't work inside triggers this cannot be baked-in to a table*/
/*============================================================================*/

BEGIN;
/*Setup-----------------------------------------------------------------------*/
/*Make tables to generate values*/
CREATE TABLE point_in (
    pid INTEGER PRIMARY KEY
  , the_geom POINT
);

INSERT INTO point_in
    (the_geom)
VALUES
    (MakePoint(1, 1, 27700))
  , (MakePoint(1, 2, 27700))
  , (MakePoint(2, 2, 27700))
  , (MakePoint(1, 3, 27700))
  , (MakePoint(3, 3, 27700))
  , (MakePoint(4, 4, 27700))
  , (MakePoint(5, 6, 27700));

CREATE TABLE line_in (
    pid INTEGER PRIMARY KEY
  , start_val REAL
  , end_val REAL
  , the_geom LINESTRING
);

CREATE TABLE line_out (
    pid INTEGER PRIMARY KEY
  , start_val REAL
  , end_val REAL
  , the_geom LINESTRINGZ
);
    
SELECT
    RecoverGeometryColumn("line_out",
                          "the_geom",
                          27700,
                          "LINESTRING",
                          "XYZ"
                          )
  , CreateSpatialIndex("line_out", "the_geom");

/*Sample values---------------------------------------------------------------*/
INSERT INTO line_in
    (start_val, end_val, the_geom)
SELECT
    12
  , 20
  , MakeLine(the_geom) FROM point_in WHERE pid <= 2 GROUP BY 1;

INSERT INTO line_in
    (start_val, end_val, the_geom)
SELECT
    10
  , -20
  , MakeLine(the_geom) FROM point_in WHERE pid <= 3 GROUP BY 1;

INSERT INTO line_in
    (start_val, end_val, the_geom)
SELECT
    10
  , 20
  , MakeLine(the_geom) FROM point_in WHERE pid <= 4 GROUP BY 1;

INSERT INTO line_in
    (start_val, end_val, the_geom)
SELECT
    -5
  , -2
  , MakeLine(the_geom) FROM point_in WHERE pid <= 5 GROUP BY 1;

INSERT INTO line_in
    (start_val, end_val, the_geom)
SELECT
    0
  , 0
  , MakeLine(the_geom) FROM point_in WHERE pid <= 7 GROUP BY 1;

/*Interpolate z values along existing lines.----------------------------------*/
/*Use Common Table Expressions to pull the lines apart,
    interpolate values, then put them back together.*/

/*In theory you could pull the entire table's data through the WITH segment,
    but it seems simpler and more efficient to just join at the end.*/
WITH RECURSIVE test_cte(x, the_geom, prop_dist, val_out, line_id) AS (
    SELECT
        1
      , PointN(the_geom, 1)
      , 0
      , start_val
      , pid
    FROM line_in
    UNION SELECT
        t.x + 1
      , PointN(l.the_geom, t.x + 1)
      , Line_Locate_Point(l.the_geom, PointN(l.the_geom, t.x + 1))
      , l.start_val + (l.end_val - l.start_val) *
            Line_Locate_Point(l.the_geom, PointN(l.the_geom, t.x + 1))
      , l.pid
    FROM line_in AS l CROSS JOIN test_cte AS t
    WHERE
        t.x < NumPoints(l.the_geom)
), cte_test_2 (line_id, the_geom) AS (
    SELECT
        line_id
      , MakeLine(MakePointZ(ST_X(the_geom), ST_Y(the_geom), val_out, 27700))
    FROM test_cte
    GROUP BY line_id
    ORDER BY line_id ASC, x ASC
)

/*Display outputs, joining onto the original table for data.*/
INSERT INTO line_out (
    pid
  , start_val
  , end_val
  , the_geom
) SELECT
    d.pid
  , d.start_val
  , d.end_val
  , g.the_geom
FROM
    line_in AS d
    INNER JOIN cte_test_2 AS g ON d.pid = g.line_id;

COMMIT;

SELECT * FROM line_out;
