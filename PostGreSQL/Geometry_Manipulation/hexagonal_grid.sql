/*Based heavily on http://rexdouglass.com/spatial-hexagon-binning-in-postgis/
  Broadly trying to replicate the functionality of SpatiaLite's 'HexagonalGrid' function
  
  Known limitations:
    -The current implimentation doesn't make regular hexagons, the initial geometry generation needs to be fixed.
    -Odd results are produced at negative coordinates, with mis-aligned hexes.
*/

CREATE OR REPLACE FUNCTION hexagonal_grid(input_geom geometry, width float)
  RETURNS TABLE (
    the_geom GEOMETRY) AS
$geom_out$
DECLARE
    input_geom_use GEOMETRY := ST_Union(input_geom);
    crs_in INTEGER:= ST_SRID(input_geom);
    
	b FLOAT := width / 2;
	a FLOAT := b / 2;
	c FLOAT := 2 * a;
	height FLOAT := 2 * a + c;
    
    --Create a bounding box to align the hexagonal grid to the current grid.
    snapped_geometry GEOMETRY := ST_MakeEnvelope(ST_XMin(input_geom_use) - 
                                                     ST_XMin(input_geom_use)::numeric % (width * 3)::integer,
                                                 ST_YMin(input_geom_use) - 
                                                     ST_YMin(input_geom_use)::numeric % (height * 3)::integer,
                                                 ST_XMax(input_geom_use) + 
                                                     (width + ST_XMax(input_geom_use)::numeric % (width * 3)::integer),
                                                 ST_YMax(input_geom_use) + 
                                                     (height + ST_YMax(input_geom_use)::numeric % (height * 3)::integer),
                                                 crs_in
                                                 );
    
	ncol FLOAT := CEIL(ABS(ST_XMax(snapped_geometry) - ST_XMin(snapped_geometry)) / width);
	nrow FLOAT := CEIL(ABS(ST_YMax(snapped_geometry) - ST_YMin(snapped_geometry)) / (height * 1.5));
    
    --This doesn't actually produce a regular hexagon - need to fix before putting this into use.
	hex_brush geometry := ST_SetSRID(
                              ST_GeomFromText(
                                  'POLYGON((' ||
	                                        0 || ' ' || 0 || ' , ' ||
                                            b || ' ' || a || ' , ' ||
                                            b || ' ' || a + c || ' , ' ||
                                            0 || ' ' || a + c + a || ' , ' ||
                                            -1 * b || ' ' || a + c || ' , ' ||
                                            -1 * b || ' ' || a || ' , ' ||
                                            0 || ' ' || 0 ||
                                            '))'
                                              ),
                                              crs_in
                                     );
    hex_brush_2 geometry := ST_Translate(hex_brush, b , a + c);
BEGIN
    
    RETURN QUERY
    SELECT
        x.the_geom
    FROM
        (
        SELECT
            ST_Translate(two_hex.temp_geom,
                         x_series * (2 * a + c) + ST_XMin(snapped_geometry),
                         y_series * (2 * (c + a)) + ST_YMin(snapped_geometry)
                         ) AS the_geom
        FROM
            generate_series(0, ncol::int, 1) AS x_series,
            generate_series(0, nrow::int, 1) AS y_series,
            (
               SELECT hex_brush AS temp_geom
               UNION
               SELECT hex_brush_2  as temp_geom
            ) AS two_hex
        ) AS x
        WHERE
            ST_Intersects(input_geom_use, x.the_geom)
    ;
    
END;
$geom_out$ LANGUAGE plpgsql;
