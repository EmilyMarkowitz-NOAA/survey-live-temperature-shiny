# Load packages ----------------------------------------------------------------

# Here we list all the packages we will need for this whole process
# We'll also use this in our works cited page!!!

PKG <- c(
  ## General support
  "tidyverse",
    # Note that tidyverse includes:
    #   ggplot2
    #   dplyr
    #   tidyr
    #   reader
    #   tibble
    #   stringr
    #   purr
    #   forcats
  
  ## Markdown support -------
  "knitr", # A general-purpose tool for dynamic report generation in R
  "rmarkdown", # R Markdown Document Conversion, #https://stackoverflow.com/questions/33499651/rmarkdown-in-shiny-application
  "quarto",
  
  ## File Management ------
  "here",     # For finding the root directory of your scripts and thus, find your files
  "devtools", # Package development tools for R; used here for downloading packages from GitHub


  ## Text Management -----
  "htmltools", 
  "htmlwidgets",
  
  ## Graphical support ------
  "nmfspalette", # devtools::install_github("nmfs-general-modeling-tools/nmfspalette")
  "cowplot",
  "png",
  "extrafont",
  "viridis",
  
  ## Spatial support -----
  "sf",
  "rlist", 
  "prettymapr",
  "rosm", 
  "shadowtext", 
  "ggspatial", 
  "digest", 
  "ps", 
  "backports", 
  "callr", 
  "labeling", 
  "gstat", 
  "raster", 
  "reshape", 
  "stars",
  "mapview",
  "akgfmaps", # devtools::install_github("afsc-gap-products/akgfmaps", build_vignettes = TRUE)
  "coldpool", # devtools::install_github("afsc-gap-products/coldpool", build_vignettes = TRUE)
  
  ## For outputting JS files -----
  "jsonlite", 
  
  ## For editing XML files -----
  "XML", 
  
  ## Oracle connectivity -----
  "RODBC", 
  
  ## FTP connectivity -----
  "RCurl",
  
  ## Shiny support -----
  "shiny",
  "shinydashboard",
  "shinydashboardPlus",
  "shinythemes", 
  "shinyauthr", 
  
  ## Java Script support -----
  "shinyjs", 
  "shinyBS", 
  "V8", 
  
  ## Formatting tables -----
  "DT", 
  "kableExtra", 
  "formattable", 
  
  ## Basemap polygons -----
  "rnaturalearth", 
  "rnaturalearthdata", 

  ## leaflet -----
  "leaflet", 
  "leafem", 
  "leafpop", 
  "leaflet.extras", 
  
  ## Image support -----
  "magick", 
  "qpdf",
  
  ## Other -----
  "data.table",
  "glue",
  "googledrive",
  "readxl",
  # "officer"
  "tinytex", # tinytex::install_tinytex(); https://yihui.org/tinytex/
  "janitor"  # clean up variable names and structure

)

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    if (p %in% c("akgfmaps", "coldpool", "gapindex")) {
      devtools::install_github("afsc-gap-products/akgfmaps")
    } else {
      install.packages(p, verbose = FALSE)
    }
    require(p,character.only = TRUE)}
}