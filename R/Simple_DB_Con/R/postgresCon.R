#--pgConDetails-----------------------------------------------------------------
#' Creates a standard list with the information required to connect to PostgreSQL for later use.
#' 
#' @param dbnameIn The name of the database to connect to.
#' @param userIn The user name to connect as.
#' @param passwordIn The password for that user name.
#' @param hostIn The address of the database being connected to.
#' @param portIn The port to attempt connection on.
#' 
#' @returns 
#' 
pgConDetails <- function(dbnameIn, userIn, passwordIn, hostIn = "localhost", portIn = 5432){
    return(list(dbname = as.character(dbnameIn),
                host = as.character(hostIn),
                port = as.character(portIn),
                user = as.character(userIn),
                password = as.character(passwordIn)
                )
           )
}

#--pgConString------------------------------------------------------------------
#' Creates a string for use in OGR to connect to a PostgreSQL database.
#' 
#' @param conDetailsIn An list with database connection details produced by pgConDetails. 
#' 
#' @returns A standard string to describing the required connection details.
#' 
pgConString <- function(conDetailsIn){
    return(sprintf("PG:dbname='%s' host='%s' port='%s' user='%s' password='%s'",
                   conDetailsIn$dbname,
                   conDetailsIn$host,
                   conDetailsIn$port,
                   conDetailsIn$user,
                   conDetailsIn$password
                   )
           )
}

#--postgresCon------------------------------------------------------------------
#' Creates a connection object for RPostgreSQL.
#' 
#' @param conDetailsIn An list with database connection details produced by pgConDetails.
#' 
#' @returns A database connection object.
#' 
postgresCon <- function(conDetailsIn){
    return(dbConnect(dbDriver("PostgreSQL"),
                     dbname = conDetailsIn$dbname,
                     host = conDetailsIn$host,
                     port = conDetailsIn$port,
                     user = conDetailsIn$user,
                     password = conDetailsIn$password
                     )
           )
}
