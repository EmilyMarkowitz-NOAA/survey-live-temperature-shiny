# Source scripts ---------------------------------------------------------------
## Support scripts -------------------------------------------------------------
source(here::here("files_support", "style.R")) 
source(here::here("files_support", "functions.R"))
# source(here::here("files_support", "data_dl.R"))
source(here::here("files_support", "data.R"))

## UI scripts parsed by feature ------------------------------------------------
source(here::here("files_ui", "ui_surveymap.R"))
source(here::here("files_ui", "ui_metadata.R"))
source(here::here("files_ui", "ui_glossary.R"))
source(here::here("files_ui", "ui_test.R"))
source(here::here("files_ui", "ui_data.R"))
# source(here::here("files_ui", "ui_plots.R"))
source(here::here("files_ui", "ui_licencing.R"))
source(here::here("files_ui", "ui_manual.R"))

## Server script parsed by feature ---------------------------------------------
source(here::here("files_server", "s_test.R"))
source(here::here("files_server", "s_surveymap.R"))
# source(here::here("files_server", "s_glossary.R"))
# source(here::here("files_server", "s_data.R"))
# source(here::here("files_server", "s_glossary.R"))

# User Interface ---------------------------------------------------------------
## Define -----------------------------------------------------------------------
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
    #width     = nchar(title0)*10.5,
    
    ### Sidebar menu items -----------------------------------------------------
    sidebarMenu(
      # Bottom trawl survey progress map(s)
      menuItem(
        "Survey Map", 
        tabName = "surveymap", 
        icon    = icon("file-image")
      ),
      # Bottom trawl survey progress map(s) TEST
      menuItem(
        "Test", 
        tabName = "test", 
        icon    = icon("globe")
      ),
      # Welcome
      menuItem(
        "Welcome",
        tabName = "welcome",
        icon    = icon("address-card")
      ),
      # Metadata
      menuItem(
        "Metadata",
        tabName = "metadata",
        icon    = icon("cogs")
      ),
      # Glossary of Terms
      menuItem(
        "Glossary and Literature Cited",
        tabName = "glossary",
        icon    = icon("road")
      ),
      # Access to the QAQC data
      menuItem(
        "Download Data",
        tabName = "data",
        icon    = icon("road")
      ),
      # Import Data
      menuItem(
        "Import Data",
        tabName = "import",
        icon    = icon("cloud-upload")
      ),
      # Evaluation Metrics
      menuItem(
        "Calculator",
        tabName = "calculator",
        icon    = icon("cogs")
      ),
      # Export Predictions
      menuItem(
        "Licencing",
        tabName = "licencing",
        icon    = icon("list-alt")
      ),
      # Manual
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
    tabItems(
      # Bottom trawl survey progress map(s)
      # tabItem(
      #   tabName = "surveymap",
      #   ui.surveymap("map1")
      # ),
      # Bottom trawl survey progress map(s) TEST
      tabItem(
        tabName = "test", 
        ui_test("maptest")           
      )
      # # Welcome
      # tabItem(
      #   tabName = "",
      #   ui.welcome()
      # ),
      # # Metadata
      # tabItem(
      #   tabName = "",
      #   ui.metadata()
      # ),
      # # Glossary of Terms
      # tabItem(
      #   tabName = "",
      #   ui.glossary()            
      # ),
      # # High Quality Maps
      # tabItem(
      #   tabName = "",
      #   ui.plots()          
      # ),
      # # Access to the QAQC data
      # tabItem(
      #   tabName = "",
      #   ui.data()          
      # ),
      # # Import Data
      # tabItem(
      #   tabName = "",
      #   ui.import()          
      # ),
      # # Evaluation Metrics
      # tabItem(
      #   tabName = "",
      #   # ui.calculator()         
      # ),
      # # Export Predictions
      # tabItem(
      #   tabName = "",
      #   ui.licencing()           
      # ),
      # # Manual
      # tabItem(
      #   tabName = "",
      #   ui.manual()          
      # )
    )
  )

## Call ---------------------------------------------------
ui <- 
  dashboardPage(
    header, 
    sidebar, 
    body
  )

# Server -----------------------------------------------------------------------
server <- function(input, output, session){
  s_test("maptest")
}

shinyApp(ui, server)