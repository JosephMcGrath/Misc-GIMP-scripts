/*============================================================================*/
/*This snippet creates a view of the Ordinance Survey grid sheets for the UK. */
/*The grid sheets replace the initial digit of a coordinate on some maps.     */
/*There's two letters as part of the reference, replacing the hundred thousand*/
/*  metre digit.                                                              */
/*============================================================================*/

BEGIN;

/*This table is used to build the squares.------------------------------------*/
CREATE TABLE grid_components (
    grid_letter CHARACTER(1) PRIMARY KEY
  , x_pos INTEGER NOT NULL
  , y_pos INTEGER NOT NULL
);

/*List out the position of each square.*/
INSERT INTO grid_components (grid_letter, x_pos, y_pos) VALUES
    ('A', 0, 4),
    ('B', 1, 4),
    ('C', 2, 4),
    ('D', 3, 4),
    ('E', 4, 4),
    ('F', 0, 3),
    ('G', 1, 3),
    ('H', 2, 3),
    ('J', 3, 3),
    ('K', 4, 3),
    ('L', 0, 2),
    ('M', 1, 2),
    ('N', 2, 2),
    ('O', 3, 2),
    ('P', 4, 2),
    ('Q', 0, 1),
    ('R', 1, 1),
    ('S', 2, 1),
    ('T', 3, 1),
    ('U', 4, 1),
    ('V', 0, 0),
    ('W', 1, 0),
    ('X', 2, 0),
    ('Y', 3, 0),
    ('Z', 4, 0);

/*Mash them together into rectangles.-----------------------------------------*/
/*ST_SquareGrid may be useful but can't be ported to PostGIS.*/
CREATE VIEW grid_sheet AS SELECT
    1 + a.x_pos * 5 + b.x_pos + (a.y_pos * 5 + b.y_pos) * 25 AS pid
  , a.grid_letter || b.grid_letter AS grid_square
  , ((a.x_pos - 2) * 5 + b.x_pos) * 100000 AS x_min
  , ((a.y_pos - 1) * 5 + b.y_pos) * 100000 AS y_min
  , ((a.x_pos - 2) * 5 + b.x_pos + 1) * 100000 AS x_max
  , ((a.y_pos - 1) * 5 + b.y_pos + 1) * 100000 AS y_max
  , BuildMbr(((a.x_pos - 2) * 5 + b.x_pos) * 100000,
             ((a.y_pos - 1) * 5 + b.y_pos) * 100000,
             ((a.x_pos - 2) * 5 + b.x_pos + 1) * 100000,
             ((a.y_pos - 1) * 5 + b.y_pos + 1) * 100000,
             27700
             ) AS the_geom
FROM
    grid_components AS a
    CROSS JOIN grid_components AS b;

/*Register the views for use in QGIS etc.-------------------------------------*/
CREATE TABLE dummy_geom (
    pid INTEGER PRIMARY KEY
  , the_poly POLYGON
);

UPDATE geometry_columns_auth
SET hidden = 1
WHERE f_table_name = 'dummy_geom';

SELECT
    RecoverGeometryColumn('dummy_geom',
                          'the_poly',
                          27700,
                          'POLYGON',
                          'XY'
                          );

INSERT INTO views_geometry_columns
    (view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES
    ('grid_sheet', 'the_geom', 'pid', 'dummy_geom', 'the_poly', 0);

COMMIT;

SELECT * FROM grid_sheet ORDER BY pid ASC;
