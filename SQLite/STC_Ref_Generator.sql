/*============================================================================*/
/*This snippet generates manhole references as outlined in the STC Report 25  */
/*  'Sewer and Water Main Records' (Appendix N 'The referencing system').     */
/*The approach is as follows:                                                 */
/*  1. The UK is divided up into grid sheets.                                 */
/*      a. These have a reference of nnxxyyxy (e.g. SO138150).                */
/*        (Dates back from when maps were provided on physical sheets.)       */
/*  2. Each manhole is given a unique 2-digit number within it's sheet.       */
/*----------------------------------------------------------------------------*/
/*The main advantage of this system in a modern GIS (beyond already being in  */
/*  wide-scale use) is that it allows records from multiple agencies to be    */
/*  mashed together while maintaining unique keys.                            */
/*----------------------------------------------------------------------------*/
/*Disadvantages of this include being exclusive to the UK and the limit of 100*/
/*  manholes within a single square.                                          */
/*============================================================================*/

/*Need OS grid squares, so making a table of those----------------------------*/
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


/*--Then a table to hold the grid squares-------------------------------------*/
CREATE TABLE stc_square (
    pid INTEGER PRIMARY KEY
  , square_id STRING NOT NULL
  , point_id INTEGER REFERENCES test_point(pid)
);

CREATE INDEX stc_square_id_idx ON stc_square (square_id);

/*And test points-------------------------------------------------------------*/
CREATE TABLE test_point(
    pid INTEGER PRIMARY KEY
  , stc_ref TEXT UNIQUE
  , the_geom POINT
);

SELECT
    RecoverGeometryColumn('test_point',
                          'the_geom',
                          27700,
                          'POINT',
                          'XY'
                          );

/*Trigger to generate a reference---------------------------------------------*/
CREATE TRIGGER generate_stc_ref AFTER INSERT ON test_point
FOR EACH ROW
BEGIN
    INSERT INTO stc_square
        (square_id, point_id)
    SELECT
        g.grid_square ||
            SUBSTR(ST_X(p.the_geom), 2, 2) ||
            SUBSTR(ST_Y(p.the_geom), 2, 2) ||
            SUBSTR(ST_X(p.the_geom), 4, 1) ||
            SUBSTR(ST_Y(p.the_geom), 4, 1)
      , p.pid
    FROM
        test_point AS p
        INNER JOIN grid_sheet AS g ON ST_Within(p.the_geom, g.the_geom) AND
                                      p.pid = NEW.pid;
    
    UPDATE test_point
    SET stc_ref = (SELECT
                       square_id ||
                           (SELECT SUBSTR('00' || COUNT(*), -2, 2)
                            FROM stc_square AS x
                            WHERE
                                x.square_id = stc_square.square_id AND
                                x.pid <= stc_square.pid
                            )
                   FROM stc_square
                   WHERE stc_square.point_id = test_point.pid
                   )
    WHERE pid = NEW.pid;
END;

/*Insert points into the test table.------------------------------------------*/
INSERT INTO test_point
    (the_geom)
VALUES
    (MakePoint(421683, 336781, 27700))
  , (MakePoint(421685, 336784, 27700))
  , (MakePoint(448625, 375149, 27700))
  , (MakePoint(448629, 375149, 27700))
  , (MakePoint(435875, 313111, 27700))
  , (MakePoint(452937, 309875, 27700))
  , (MakePoint(456045, 399118, 27700))
  , (MakePoint(428438.34, 352385.10, 27700))
  , (MakePoint(421682, 336781, 27700))
  , (MakePoint(421600, 336700, 27700))
  , (MakePoint(421601, 336701, 27700))
  , (MakePoint(421601, 336699, 27700))
  , (MakePoint(421599, 336701, 27700))
  , (MakePoint(421599, 336699, 27700))
;

SELECT *
FROM test_point;
