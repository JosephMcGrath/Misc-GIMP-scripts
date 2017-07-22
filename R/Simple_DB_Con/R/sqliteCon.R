#--sqliteCon--------------------------------------------------------------------
#' A slightly simplified function to create a connection to an SQLite database.
#'
#' @param dbLoc The location of the database to connect to on disc. Defaults to an in-memory database.
#' 
#' @returns An SQL connection object.
#' 
sqliteCon <- function(dbLoc = ":memory:"){
    return(dbConnect(SQLite(), dbLoc))
}
