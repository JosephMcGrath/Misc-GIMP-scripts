--Attaches information about nodes at either end of the line to the line.
-- Note - this does NOT enforce topology, just uses the geometry links.
BEGIN;

--Points with attached data.
CREATE TABLE node_point (
    id INTEGER PRIMARY KEY
  , val TEXT
  , geometry POINT NOT NULL
);

SELECT
    RecoverGeometryColumn("node_point", "geometry", 27700, "POINT", "XY")
  , CreateSpatialIndex("node_point", "geometry");

--Lines linking those points.
CREATE TABLE link_line (
    id INTEGER PRIMARY KEY
  , val TEXT
  , geometry LINESTRING NOT NULL
);

SELECT
    RecoverGeometryColumn("link_line", "geometry", 27700, "LINESTRING", "XY")
  , CreateSpatialIndex("link_line", "geometry");

--A view to join lines to the node at either end.
CREATE VIEW attached_links AS SELECT
    l.rowid AS link_rowid
  , l.id AS link_id
  , n1.id AS node_1_id
  , n2.id AS node_2_id
  , l.val AS link_value
  , l.geometry AS geometry
FROM
    link_line AS l
    INNER JOIN node_point AS n1 ON Equals(StartPoint(l.geometry), n1.geometry)
    INNER JOIN node_point AS n2 ON Equals(EndPoint(l.geometry), n2.geometry);

INSERT INTO views_geometry_columns (
    view_name,
    view_geometry,
    view_rowid,
    f_table_name,
    f_geometry_column,
    read_only)
VALUES (
    'attached_links',
    'geometry',
    'link_id',
    'link_line',
    'geometry',
    1
    );

COMMIT;
