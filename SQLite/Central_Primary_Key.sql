/*============================================================================*/
/*This snippet includes a simple setup to hold a central primary key across an*/
/*  entire database, in the style of the Ordinance Survey's TOID system.      */
/*https://www.ordnancesurvey.co.uk/about/governance/policies/os-mastermap-toids.html*/
/*============================================================================*/

BEGIN;

/*Table to hold central ID values.*/
CREATE TABLE id_values (
    pid INTEGER PRIMARY KEY
  , date_created TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  , table_name TEXT NOT NULL /*The table the value exists in, added as part of the trigger.*/
);

/*An example table to use values from the central key.*/
CREATE TABLE target_table (
    id_value TEXT PRIMARY KEY DEFAULT ROWID /*The default primary key is rewritten on insert using a trigger.*/
  , val TEXT
);

/*Trigger to create and import the central primary key.*/
CREATE TRIGGER new_id_value AFTER INSERT ON target_table FOR EACH ROW BEGIN
    
    /*Generate the new entry (pid auto-increments as an integer primary key).*/
    INSERT INTO id_values
        (table_name)
    VALUES
        ('target_table');
    
    /*Apply the value to the table.*/
    UPDATE
        target_table
    SET
        id_value = (SELECT 'PKEY' || substr('0000000000'|| MAX(pid), -10, 10) FROM id_values)
    WHERE
        ROWID = NEW.ROWID;
    
END;

COMMIT;

INSERT INTO target_table (val) VALUES ('Test row.');
SELECT * FROM target_table;
