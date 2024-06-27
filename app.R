# source("data_dl.R") # Download Data

# Support scripts -------------------------------------------------------------
source(here::here("files_support", "style.R")) 
source(here::here("files_support", "functions.R"))
# source(here::here("files_support", "data_dl.R"))
source(here::here("files_support", "data.R"))

# UI scripts parsed by tabName ------------------------------------------------
source(here::here("files_ui", "ui_surveymap.R"))
source(here::here("files_ui", "ui_metadata.R"))
source(here::here("files_ui", "ui_glossary.R"))
source(here::here("files_ui", "ui_data.R"))
# source(here::here("files_ui", "ui_plots.R"))
source(here::here("files_ui", "ui_licencing.R"))
source(here::here("files_ui", "ui_manual.R"))


# Define -----------------------------------------------------------------------
title0 <- " | Bottom Trawl Survey Temperature and Progress Maps "
subtitle0 <-  "NOAA Fisheries scientists share information on ocean temperatures recorded during the Aleutian Islands, Gulf of Alaska and Bering Sea Bottom Trawl Surveys"

# ui - User Interface ----------------------------------------------------------

# Define UI for application that draws a histogram
ui <- tagList(
  dashboardPage(skin = "black",

## Title -----------------------------------------------------------------------

  title = 
    tags$head(
      tags$title(
        paste0("NOAA Fisheries ",title0," | NOAA Fisheries", subtitle0)
      ), 
      tags$link(
        rel="shortcut icon", 
        href="https://www.noaa.gov/sites/all/themes/custom/noaa/favicon.ico", 
        type="image/vnd.microsoft.icon"
      )
    ), 
  
## Header -----------------------------------------------------------------------
  
  header = 
    dashboardHeader(
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
      titleWidth = nchar(title0)*17,
  
      #For login
      tags$li(
        class = "dropdown", 
        style = paste0("padding: 8px;"),
        shinyauthr::logoutUI(
          "logout", 
          class = "btn-primary", 
          style = "background-color: #1f93d0; border: none; color: #ffffff"
        )
      ),
       
       
      #Other Icons
      dropdownMenu(
        tags$li(
          tags$style(
            HTML('color: #10497e;}')
          )
        ),                          
        type = "notifications",
        icon = icon("question-circle"),
        # icon = tags$a(icon("question-circle")#,
        #               # href = "https://github.com/emilyhmarkowitz/ShinyTemplateNMFS",
        #               # title = "Also see:",
        #               # style = "color: #1f93d0;"
        #               ),
        badgeStatus = NULL,
        headerText = "See also:",
        # style = "color: #1f93d0;")
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
     
      tags$li(
       class = "dropdown", 
       tags$a(
         icon("github"), 
         href = "https://github.com/EmilyMarkowitz-NOAA/AFSCRACE_SurveyDataMapApp",
         title = "See the code on github", 
         style = "color: #1f93d0;"
       )
      )
    ), 
  
## Sidebar -----------------------------------------------------------------------
  sidebar = 
    dashboardSidebar(
      collapsed = TRUE, 
      width     = nchar(title0)*17, 
      
      #Login
      div(textOutput("welcome"), 
        style = 
          "padding-top: 40px; 
          padding-bottom: 20px; 
          text-align:center; 
          color: #10497e; 
          font-weight: bold; 
          font-size: 20px;
          font-family:'Arial Narrow';"
      ), 
      
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
    ),
  
## Body -----------------------------------------------------------------------
  body = 
    dashboardBody(
      shinyjs::useShinyjs(),
      tags$head(
        tags$style(
          HTML(
            '.main-header .sidebar-toggle:before {color: #10497e;}'
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
        # includeScript("www/returnClick.js"), 
        tags$link(
          rel = "stylesheet", 
          type = "text/css", 
          href = "custom.css"
        ),
        tags$script(
          src = "./www/custom.js"
        ),
      # ),
      
      # tags$head(
        tags$style(
          HTML('
            /* logo */.skin-black 
            .main-header 
            .logo {
              background-color: #ffffff; 
              height: 65px;
            }
      
            /* logo when hovered */
            .skin-black 
            .main-header 
            .logo:hover {
              background-color: #ffffff;
              color: #000000;
            }
      
            /* navbar (rest of the header) */
            .skin-black 
            .main-header 
            .navbar {
              background-image: linear-gradient(to right, #ffffff , #d9effa);
              color: #000000;
            }
      
            /* main sidebar */
            .skin-black 
            .main-sidebar {
              background-color: #d9effa;
            }
      
            /* active selected tab in the sidebarmenu */
            .skin-black 
            .main-sidebar 
            .sidebar 
            .sidebar-menu 
            .active a{
              background-color: #1f93d0;
              color: #ffffff;
            }
      
            /* other links in the sidebarmenu */
            .skin-black 
            .main-sidebar 
            .sidebar 
            .sidebar-menu a {
              background-color: #d9effa;
              color: #10497e;
            }
      
            /* other links in the sidebarmenu when hovered */
            .skin-black 
            .main-sidebar 
            .sidebar 
            .sidebar-menu a:hover {
              background-color: #1f93d0;
              color: #ffffff;
            }
      
            /* toggle button when hovered  */
            .skin-black 
            .main-header 
            .navbar 
            .sidebar-toggle:hover{
              background-color: #1f93d0;
              color: #10497e;
            }
      
            /* body */
            .content-wrapper, 
            .right-side {
              background-color: #ffffff;
              color: #000000;
            }
      
            .content-wrapper,
            .right-side {
              background-color: #ffffff;
              color: #000000;
              padding: 30px;
            }
      
            .content-wrapper {
              background-color: #ffffff !important;
              color: #000000;
             .leaflet-top
             .leaflet-control {
                margin: 0px;
             }
      
            .leaflet-right {
               margin-right: 40px;
            }    
            .full {
              background-color: blue;
              border-radius: 50%;
              width: 20px;
              height: 20px;
              float: left;
            }

            .circle {
              background-color: #FFF;
              border: 3px solid blue;
              border-radius: 50%;
              height: 20px;
              width: 20px;
            }

            .leaflet-control i{
              margin-right: 25px;
            }'
          )
        )
      ),
      # div {
      #   padding-left: 5px;
      #   padding-top: 10px;
      # }
      
      
      #Login
      # shinyauthr::loginUI("login"),
      # uiOutput("user_table"),
      # HTML('<div data-iframe-height></div>'),
      
      tabItems(
      #   tabItem(
      #     tabName = "welcome"#, 
      #     uiOutput("ui.welcome")
      #     ),
        ui.surveymap(),     # Welcome
        # ui.welcome(),     # Welcome
        ui.metadata(),      # Roadmap
        ui.glossary(),      # Roadmap
        # ui.plots(),        # High Quality Maps
        ui.data(),        # High Quality Maps
        # ui.import(),       # Import Data
        # ui.calculator(),   # Evaluation Metrics
        ui.licencing(),       # Export Predictions
        ui.manual()        # Manual
      )
    )
  ), 
  
## Footer -----------------------------------------------------------------------

  # tags$footer("U.S. Department of Commerce | National Oceanic and Atmospheric Administration | National Marine Fisheries Service",
  #             align = "center",
  #             style = "
  #             position:absolute;
  #             bottom:0;
  #             width:100%;
  #             height:60px;   /* Height of the footer */
  #             color: #10497e;
  #             font-size: 15px;
  #             font-family:'Arial Narrow';
  #             padding: 10px;
  #             background-color: #ffffff;
  #             z-index: 1000;
  #             ")

tags$footer("U.S. Department of Commerce | National Oceanic and Atmospheric Administration | National Marine Fisheries Service",
            align = "center",
            style = "
              position:absolute;
              bottom:0;
              width:100%;
              height:25px;   /* Height of the footer */
              color: #10497e;
              font-size: 10px;
              font-family:'Arial Narrow';
              padding: 0px;
              background-color: #ffffff;
              z-index: 1000;
              ")

)

# server - server side code-----------------------------------------------------
server <- function(input, output, session) {
  
## Images ----------------------------------------------------------------------
  
  output$ImageFull <- renderImage({
    filename <- normalizePath(here::here("./www/noaa_fisheries_small.png"))
    list(src = filename,
         width = session$clientData$output_ImageFull_width,
         height = session$clientData$output_ImageFull_height
    )
  }, deleteFile = FALSE)

  output$Image <- renderImage({
    filename <- normalizePath(here::here("./www/noaa_logo.gif"))
    list(src = filename,
         width = session$clientData$output_Image_width,
         height = session$clientData$output_Image_height
    )
  }, deleteFile = FALSE)
  
## Body -----------------------------------------------------------------------
  # readline(here::here("files_server", "s_surveymap.R"))
  # source(here::here("files_server", "s_surveymap.R"))
  # source(here::here("files_server", "s_glossary.R"))
  source(here::here("files_server", "s_data.R"))
  # source(file = here::here("files_server", "s_glossary.R"))
  
## CSV Download --------------------------------------------------------------
  output$downloadData <- downloadHandler(
    # filename <- paste0("NOAAAcousticThresholds_", Sys.Date(), ".csv"),
    filename = #function() {
      "downloadData.csv",
    # },
    contentType = "text/csv",
    content = function(file) {

      filename0<-file#"downloadData.csv"#here::here(getwd(), "downloadData.csv")

      # Threshold Isopleths Results WARNINGS

      write.table(input$dataset,
                  file=filename0,
                  sep=",", row.names=FALSE, col.names=FALSE, append=TRUE)

      write.table("Data",
                  file=filename0,
                  sep=",", row.names=FALSE, col.names=FALSE, append=TRUE)

      write.table(input$datasetInput,
                  file=filename0,
                  sep=",", row.names=TRUE, col.names=FALSE, append=TRUE)

      write.table("", #Space
                  file=filename0,
                  sep=",", row.names=FALSE, col.names=FALSE, append=TRUE)

      # DISCLAIMER
      write.table("LICENCE",
                  file=filename0,
                  sep=",", row.names=FALSE, col.names=FALSE, append=TRUE)

      write.table(licence0,
                  file=filename0,
                  sep=",", row.names=TRUE, col.names=FALSE, append=TRUE)


    }
  )
  ### UI code for the 'eSDM GUI Roadmap and Load or Save Workspace' tab
  
  ui.surveymap <- function() {
    tabItem(
      tabName = "surveymap",
      fluidRow(
        HTML("<html lang='en'>"), #Always have this as your first line
        
        div(class="outer",
            
            tags$head(
              # Include our custom CSS
              includeCSS(here::here("files_support", "styles.css")),
              includeScript(here::here("files_support", "gomap.js"))
            ),
            
            # If not using custom CSS, set height of leafletOutput to a number instead of percent
            leafletOutput("survey_leaflet", width="100%", height="95%"),
            
            absolutePanel(id = "controls", 
                          class = "panel panel-default", 
                          fixed = TRUE,
                          draggable = TRUE, top = 60, 
                          left = "auto", right = 20, 
                          bottom = "auto",
                          width = 330, height = "auto",
                          
                          br(),
                          
                          selectInput(inputId = "year", 
                                      label = "Year", 
                                      choices = sort(unique(dat$year)), 
                                      selected = max(dat$year), 
                                      multiple = FALSE),
                          selectInput(inputId = "survey", 
                                      label = "Survey", 
                                      choices = sort(unique(shp_all$survey.area$SRVY))[sort(unique(shp_all$survey.area$SRVY)) != "NEBS"], 
                                      selected = c("EBS", "NBS"), 
                                      multiple = TRUE),
                          checkboxInput(inputId = "station", 
                                        label = "Station Points", 
                                        value = FALSE),
                          checkboxInput(inputId = "stratum", 
                                        label = "Stratum", 
                                        value = FALSE), 
                          checkboxInput(inputId = "vessel", 
                                        label = "Vessels", 
                                        value = FALSE), 
                          br(),
                          
                          selectInput(inputId = "plot_unit",
                                      label = "Environmental Variable",
                                      choices = c(
                                        "Bottom Temperature (°C)" = "bottom_temperature_c", 
                                        "Surface Temperature (°C)" = "surface_temperature_c", 
                                        "None" = "none"),
                                      selected = "none"),
                          uiOutput("plot_display"),
                          # uiOutput("vessels"),
                          uiOutput("plot_dates"),
                          # actionButton("download_pdf", "Download .pdf"), 
                          downloadButton(outputId = "dl_map",
                                         label = "Download Map (PNG)")
            )
        )
      )
      
    )
    
  }
  
  
  ## R Markdown Report  --------------------------------------------------------
  
  output$report <- downloadHandler(
    # For PDF output, change this to "report.pdf"
    filename = "report.html",
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
