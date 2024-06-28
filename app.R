# source("data_dl.R") # Download Data

# Support scripts --------------------------------------------------------------
source(here::here("files_support", "style.R")) 
source(here::here("files_support", "functions.R"))
# source(here::here("files_support", "data_dl.R"))
source(here::here("files_support", "data.R"))

# UI scripts parsed by tabName -------------------------------------------------
source(here::here("files_ui", "ui_surveymap.R"))
source(here::here("files_ui", "ui_metadata.R"))
source(here::here("files_ui", "ui_glossary.R"))
source(here::here("files_ui", "ui_data.R"))
# source(here::here("files_ui", "ui_plots.R"))
source(here::here("files_ui", "ui_licencing.R"))
source(here::here("files_ui", "ui_manual.R"))

# Server script parsed by feature ----------------------------------------------
# readline(here::here("files_server", "s_surveymap.R"))
# source(here::here("files_server", "s_surveymap.R"))
# source(here::here("files_server", "s_glossary.R"))
source(here::here("files_server", "s_data.R"))
# source(here::here("files_server", "s_glossary.R"))

# Define -----------------------------------------------------------------------
title0 <- " | Bottom Trawl Survey Temperature and Progress Maps "
subtitle0 <-  "NOAA Fisheries scientists share information on ocean temperatures recorded during the Aleutian Islands, Gulf of Alaska and Bering Sea Bottom Trawl Surveys"

## Header ----------------------------------------------------------------------
header <-
  shinydashboardPlus::dashboardHeader(
    title =
      tags$a(
        href = 'https://www.fisheries.noaa.gov/',
        tags$img(src="FISHERIES-Logo WEB ONLY.png", width = '90'),
        HTML(title0),
        style =
          paste0(
            "text-align: right;
            color: #10497e;
            font-weight: bold;
            font-size: 20px;
            font-family:'Arial Narrow';"
          )
      ),
    titleWidth = nchar(title0)*10.5,
    
    ### Other icons ----
    #### Information ----
    dropdownMenu(
      tags$li(
        tags$style(
          HTML('color: #10497e;}')
        )
      ),
      type        = "notifications",
      icon        = icon("question-circle"),
      badgeStatus = NULL,
      headerText  = "See also:",
      notificationItem(
        "NOAA Fisheries",
        icon = icon("fish"),
        status = "info", # TOLEDO
        href = "https://www.fisheries.noaa.gov/"
      ),
      notificationItem(
        "AFSC RACE Division",
        icon = icon("ship"),
        status = "info",
        href = "https://www.fisheries.noaa.gov/about/resource-assessment-and-conservation-engineering-division"
      )
    ),
    
    #### Github repository ----
    tags$li(
      class = "dropdown",
      tags$a(
        icon("github"),
        href = "https://github.com/EmilyMarkowitz-NOAA/AFSCRACE_SurveyDataMapApp",
        title = "See the code on github",
        style = "color: #10497e;"
      )
    )
  )

## Sidebar ---------------------------------------------------------------------
sidebar = 
  dashboardSidebar(
    collapsed = FALSE, 
    minified  = FALSE,
    # width     = nchar(title0)*10.5,
    
    ### Sidebar menu items -----------------------------------------------------
    sidebarMenu(
      id = "tabs",
      menuItem(
        "Survey Map", 
        tabName = "surveymap", 
        icon    = icon("file-image")
      ),
      # menuItem(
      #   "Welcome",
      #   tabName = "welcome",
      #   icon    = icon("address-card")
      # ),
      menuItem(
        "Metadata",
        tabName = "metadata", 
        icon    = icon("cogs")
      ),
      menuItem(
        "Glossary and Literature Cited",
        tabName = "glossary", 
        icon    = icon("road")
      ),
      menuItem(
        "Download Data",
        tabName = "data", 
        icon    = icon("road")
      ),
      # menuItem(
      #   "Import Data", 
      #   tabName = "import", 
      #   icon    = icon("cloud-upload")
      # ),
      # menuItem(
      #   "Calculator",
      #   tabName = "calculator", 
      #   icon    = icon("cogs")
      # ),
      menuItem(
        "Licencing", 
        tabName = "licencing", 
        icon    = icon("list-alt")
      ),
      menuItem(
        "Manual", 
        tabName = "manual", 
        icon    = icon("book"),
        menuSubItem(
          "Sub Menu Item 1", 
          tabName = "sub_1"
        ), 
        menuSubItem(
          "Sub Menu Item 2", 
          tabName = "sub_2"
        )
      )
    )
  )

## Body ----------------------------------------------------------------------
body <-  
  dashboardBody(
    shinyjs::useShinyjs(),
    tags$head(
      tags$style(
        HTML(
          '.main-header
          .sidebar-toggle:before {
            color: #10497e;
          }'
        )
      )
    ),

    tags$head(
      tags$style(
        ".table{margin: 0 auto;}"
      ),
      tags$script(
        src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
        type="text/javascript"
      ),
      tags$link(
        rel = "stylesheet",
        type = "text/css",
        href = "custom.css"
      ),
      tags$script(
        src = "./www/custom.js"
      ),
    ),

    tabItems(
      ui.surveymap(),     # Bottom trawl survey progress map(s)
      # ui.welcome(),       # Welcome
      ui.metadata(),      # Roadmap
      ui.glossary(),      # Glossary of Terms
      # ui.plots(),       # High Quality Maps
      ui.data(),          # Access to the QAQC data
      # ui.import(),      # Import Data
      # ui.calculator(),  # Evaluation Metrics
      ui.licencing(),     # Export Predictions
      ui.manual()         # Manual
    )
  )

# User Interface - Dashboard ---------------------------------------------------
ui <- 
  dashboardPage(
    header, 
    sidebar, 
    body
  )

# Server -----------------------------------------------------------------------
server <- function(input, output, session) {
  
  ## Body ----------------------------------------------------------------------

  
  ## CSV Download --------------------------------------------------------------
  output$downloadData <- 
    downloadHandler(
    # filename <- paste0("NOAAAcousticThresholds_", Sys.Date(), ".csv"),
    filename = #function() {
      "downloadData.csv",
    # },
    contentType = "text/csv",
    content = 
      function(file) {
        filename0 <- file #"downloadData.csv"#here::here(getwd(), "downloadData.csv")
        
        # Threshold Isopleths Results WARNINGS
        write.table(
          input$dataset,
          file      = filename0,
          sep       = ",", 
          row.names = FALSE, 
          col.names = FALSE, 
          append    = TRUE
        )
        
        write.table(
          "Data",
          file      = filename0,
          sep       = ",", 
          row.names = FALSE, 
          col.names = FALSE, 
          append    = TRUE
        )
        
        write.table(
          input$datasetInput,
          file      = filename0,
          sep       = ",", 
          row.names = TRUE, 
          col.names = FALSE, 
          append    = TRUE
        )
        
        write.table(
          "", #Space
          file      = filename0,
          sep       = ",", 
          row.names = FALSE, 
          col.names = FALSE, 
          append    = TRUE
        )
        
        # DISCLAIMER
        write.table(
          "LICENCE",
          file      = filename0,
          sep       = ",", 
          row.names = FALSE, 
          col.names = FALSE, 
          append    = TRUE
        )
        
        write.table(
          licence0,
          file      =filename0,
          sep       = ",", 
          row.names = TRUE, 
          col.names = FALSE, 
          append    = TRUE
       )
      }
  )

  ## R Markdown Report  --------------------------------------------------------
  
  output$report <- 
    downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename    = "report.html",
    contentType = "text/html",

    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      tempReport <- here::here(getwd(), "report4.Rmd")
      file.copy(from = "report4.Rmd", "report2.Rmd", overwrite = TRUE)
      file.copy("report2.Rmd", tempReport, overwrite = TRUE)
      
      # Set up parameters to pass to Rmd document
      params <- list(
        ProjectName = input$ProjectName,
        distPlot = input$distPlot,
        table = input$table
      )
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(tempReport, output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }


  )
}

shinyApp(ui, server)