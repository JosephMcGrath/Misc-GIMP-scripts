library("markdown")

dirIn <- getwd()
styleIn <- file.path(dirIn, "Notes.css")

filesIn <- list.files(path = dirIn,
                      recursive = TRUE,
                      full.name = TRUE,
                      pattern = "\\.md$"
                      )
filesOut <- gsub("\\..*$",
                 ".html",
                 gsub(dirIn,
                      file.path(dirIn, "Rendered"),
                      filesIn, fixed = TRUE
                      )
                 )

for(thisFile in filesIn){
    print(thisFile)
    markdownToHTML(file = thisFile,
                   output = gsub("(?i)\\.[a-z]+$", ".html", thisFile),
                   stylesheet = styleIn,
                   extensions = c("tables", "fenced_code")
                  )
}
