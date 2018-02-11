/*============================================================================*/
/*This code creates a view to generate Vorojoi polygons for a set of inputs.  */
/*Points are grouped by a column allowing multiple Vorojoi diagrams in one    */
/*  table.                                                                    */
/*============================================================================*/
BEGIN;
/*Setup-----------------------------------------------------------------------*/
/*Create a table of points to work from.*/
CREATE TABLE base_point (
    pid INTEGER PRIMARY KEY
  , point_set INTEGER NOT NULL /*A Vorojoi diagram will be created for each unique entry in this column.*/
  , some_data VARCHAR /*Some example data to attach to the outputs.*/
  , the_geom POINT
);

SELECT
    RecoverGeometryColumn('base_point',
                          'the_geom',
                          27700,
                          'POINT',
                          'XY'
                          )
  , CreateSpatialIndex('base_point', 'the_geom');

/*Populate with random points.*/
INSERT INTO base_point
    (point_set, some_data, the_geom)
VALUES
    (1, 'Data', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'in', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'this', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'column', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'will', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'be', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'preserved', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (2, 'through', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (2, 'the', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (2, 'Vorojoi', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (3, 'creation', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (3, 'process', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (3, 'and', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (3, 'added', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (4, 'to', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (2, 'the', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700))
  , (1, 'output', MakePoint(ABS(RANDOM() / POWER(10, 16)), ABS(RANDOM() / POWER(10, 16)), 27700));

DELETE FROM base_point WHERE pid = 2;

/*Create a dummy table to register the views against.*/
CREATE TABLE dummy_geom (
    pid INTEGER PRIMARY KEY
  , the_poly POLYGON
  , the_multipoly MULTIPOLYGON
);

SELECT
    RecoverGeometryColumn('dummy_geom',
                          'the_poly',
                          27700,
                          'POLYGON',
                          'XY'
                          )
  , RecoverGeometryColumn('dummy_geom',
                          'the_multipoly',
                          27700,
                          'MULTIPOLYGON',
                          'XY'
                          );
UPDATE geometry_columns_auth
SET hidden = 1
WHERE f_table_name = 'dummy_geom';

/*Intermediate views----------------------------------------------------------*/
/*The whole set of Vorojoi diagrams as multipolygons.*/
CREATE VIEW voronoi_raw AS SELECT
    point_set
  , VoronojDiagram(ST_Union(the_geom), /*Merge the points for each set into a single multipolygon.*/
                   0, /*We want the polygons, not just the boundaries.*/
                   20 /*Return polygons covering an area 20% larger the input.*/
                   ) AS the_geom
FROM
    base_point
GROUP BY
    point_set;

/*The diagram split into individual polygons*/
CREATE VIEW voronoi_split AS SELECT
    p.pid
  , v.point_set
  , GeometryN(v.the_geom,
              (SELECT COUNT(*) FROM base_point AS x WHERE x.pid <= p.pid) /*Just using pid would break in the event of a row being deleted.*/
              ) AS the_geom
FROM
    base_point AS p
    CROSS JOIN voronoi_raw AS v
WHERE
    (SELECT COUNT(*) FROM base_point AS x WHERE x.pid <= p.pid) <= NumGeometries(v.the_geom);


/*Generate the final output---------------------------------------------------*/
/*Finally re-add the data.*/
CREATE VIEW voronoi_out AS SELECT
    p.pid
  , p.point_set
  , p.some_data
  , v.the_geom
FROM
    base_point AS p
    INNER JOIN voronoi_split AS v ON ST_Within(p.the_geom, v.the_geom) AND
                                     p.point_set = v.point_set;
/*The output could be ordered by point_set to make it draw a little bit nicer.*/

INSERT INTO views_geometry_columns
    (view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES
    ('voronoi_out', 'the_geom', 'pid', 'dummy_geom', 'the_poly', 0);

COMMIT;

SELECT * FROM voronoi_out;
