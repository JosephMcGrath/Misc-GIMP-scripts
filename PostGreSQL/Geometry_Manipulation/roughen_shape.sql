/*Adds roughness to a shape by placing a new point halfway along each segment with a random offset.
  
  Known limitations:
    -Behaviour for multi-polygons is currently unknown.
    - The random position is calculated inside a square, wheras it would be better within a circle.
*/
CREATE OR REPLACE FUNCTION roughen_shape(the_geom GEOMETRY) RETURNS geometry AS
$$
DECLARE
    current_segment GEOMETRY(LINESTRING);
    candidate GEOMETRY;
    r_coeff REAL := 0.25; --The portion of the line that the new point may be placed in.
    r_coeff_2 REAL := r_coeff / 2; --
    type_in TEXT := ST_GeometryType(the_geom);
BEGIN
    
    IF type_in IN ('ST_Polygon', 'ST_MultiPolygon') THEN
        the_geom := ST_ExteriorRing(the_geom);
    END IF;
            
    FOR i IN REVERSE ST_NPoints(the_geom)..2 LOOP
        
        current_segment := ST_MakeLine(ST_PointN(the_geom, i - 1),
                                       ST_PointN(the_geom, i)
                                       );
        
        
        candidate := ST_AddPoint(the_geom,
                                 ST_Translate(ST_LineInterpolatePoint(current_segment,
                                                                      (random() * r_coeff) + r_coeff_2
                                                                      ),
                                              random() * ST_Length(current_segment) * r_coeff - r_coeff_2 * ST_Length(current_segment),
                                              random() * ST_Length(current_segment) * r_coeff - r_coeff_2 * ST_Length(current_segment)
                                 ),
                                 i - 1
                                 );
        
        
        IF ST_IsValid(candidate) THEN
            the_geom := candidate;
        END IF;
        
        
    END LOOP;
    
    IF type_in IN ('ST_Polygon', 'ST_MultiPolygon') THEN
        the_geom := ST_MakePolygon(the_geom);
    END IF;
    
    RETURN the_geom;
    
END;
$$
LANGUAGE plpgsql;
