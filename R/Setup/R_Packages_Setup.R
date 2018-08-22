# Download a general set of libraries.

gis <- c("sp",
         "raster",
         "rgdal"
         )

graphics <- c("ggplot2", #Better graphs.
              "grid",
              "RColorBrewer",
              "hexbin"
              )
dataIngest <- c("RSQLite" #Direct interaction with SQLite
                )
development <- c("roxygen2", #Automatic documentation generation
                 "testthat" #Unit tests
                 )
data <- c("tidyverse")

fullList <- c(gis, graphics, dataIngest, development, data)

install.packages(fullList, dependencies = TRUE)
