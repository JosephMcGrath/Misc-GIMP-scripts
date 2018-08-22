/* https://www.ordnancesurvey.co.uk/getoutside/guides/beginners-guide-to-grid-references/ */

/*Converts an Ordinance Survey grid coordinate into a geometry in British     */
/*National Grid.                                                              */

CREATE OR REPLACE FUNCTION os_ref_to_point(input_ref TEXT)
  RETURNS GEOMETRY(POINT, 27700) AS
$geom_out$
DECLARE
    
    --The gridsheet of the input, to be decoded later.
    in_code TEXT := LEFT(input_ref, 2);
    
    --The numberic part of the reference.
    in_number TEXT := RIGHT(input_ref, LENGTH(input_ref) - 2);
    
    --A multiplier to account for the variable precision of a reference.
    in_figures INTEGER := 10 ^ (5 - LENGTH(in_number) / 2);
    
    --The x position within the grid sheet.
    in_x REAL := LEFT(in_number, LENGTH(in_number) / 2)::REAL * in_figures;
    
    --The y position within the grid sheet.
    in_y REAL := RIGHT(in_number, LENGTH(in_number) / 2)::REAL * in_figures;
    
    --Output values.
    out_x REAL;
    out_y REAL;
    
BEGIN
    
    WITH grid_components (grid_letter, x_pos, y_pos) AS (
        VALUES
        ('A', 0::REAL, 4::REAL),
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
        ('Z', 4, 0)
    )
    
    SELECT
        ((a.x_pos - 2) * 5 + b.x_pos) * 100000 + in_x INTO out_x
    FROM
        grid_components AS a
        CROSS JOIN grid_components AS b
    WHERE
        a.grid_letter = LEFT(in_code, 1) AND
        b.grid_letter = RIGHT(in_code, 1)
    LIMIT 1;
    
    WITH grid_components (grid_letter, x_pos, y_pos) AS (
        VALUES
        ('A', 0::REAL, 4::REAL),
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
        ('Z', 4, 0)
    )
    
    SELECT
        ((a.y_pos - 1) * 5 + b.y_pos) * 100000 + in_y INTO out_y
    FROM
        grid_components AS a
        CROSS JOIN grid_components AS b
    WHERE
        a.grid_letter = LEFT(in_code, 1) AND
        b.grid_letter = RIGHT(in_code, 1)
    LIMIT 1;
    
    RETURN ST_SetSRID(ST_MakePoint(out_x, out_y), 27700);
    
END;
$geom_out$ LANGUAGE plpgsql;
