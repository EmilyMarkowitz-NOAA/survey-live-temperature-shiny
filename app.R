# Source scripts ---------------------------------------------------------------
## Support scripts -------------------------------------------------------------
source(here::here("files_support", "style.R")) 
source(here::here("files_support", "functions.R"))
# source(here::here("files_support", "data_dl.R"))
source(here::here("files_support", "data.R"))

## UI scripts parsed by feature ------------------------------------------------
source(here::here("files_ui", "ui_surveymap.R"))
source(here::here("files_ui", "ui_surveymapcontrolbar.R"))
source(here::here("files_ui", "ui_metadata.R"))
source(here::here("files_ui", "ui_glossary.R"))
source(here::here("files_ui", "ui_data.R"))
source(here::here("files_ui", "ui_about.R"))
# source(here::here("files_ui", "ui_plots.R"))
source(here::here("files_ui", "ui_licensing.R"))
source(here::here("files_ui", "ui_manual.R"))

## Server script parsed by feature ---------------------------------------------
source(here::here("files_server", "s_surveymap.R"))
source(here::here("files_server", "s_glossary.R"))
# source(here::here("files_server", "s_data.R"))
# source(here::here("files_server", "s_glossary.R"))

# User Interface ---------------------------------------------------------------
## Define -----------------------------------------------------------------------
title0 <- " | Bottom Trawl Survey Temperature and Progress Maps "
subtitle0 <-  "NOAA Fisheries scientists share information on ocean temperatures recorded during the Aleutian Islands, Gulf of Alaska and Bering Sea Bottom Trawl Surveys"

## Code snippet for put a logo to the RIGHT of the collapse button
  # css <- 
  #   HTML(
  #     "/* move logo to center */
  #       #logo {
  #           position: absolute;
  #           left: 50%;
  #           top: 50%;
  #           transform: translate(-50%, -50%);
  #       }
  #     /* remove hover effect */
  #       #logo > a:hover {
  #           background-color: transparent !important;
  #       }"
  #   )

## Header ----------------------------------------------------------------------
header <-
  shinydashboardPlus::dashboardHeader(
  ## Possible solution to force collapse button to left of Title, however it
  ## creates a weird word-wrapping scenario that is really unpleasant
    # title = "",
    # tags$li(
    #   class = "dropdown",
    #   id = "logo",
    #   tags$a(
    #   # href = 'https://www.fisheries.noaa.gov/',
    #   tags$img(src="FISHERIES-Logo WEB ONLY.png", width = '90'),
    #   HTML(title0),
    #   style =
    #     paste0(
    #       "text-align: right;
    #       color: #10497e;
    #       font-weight: bold;
    #       font-size: 20px;
    #       font-family: Arial Narrow"
    #     )
    #   ),
    #   tags$style(css)
    # ),
    # 
    title = tags$a(
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
        ),
    ),

    titleWidth = nchar(title0)*10.5,

    ### Other icons ----
    #### Github repository ----
    tags$li(
      class = "dropdown",
      tags$a(
        icon("github"),
        href = "https://github.com/EmilyMarkowitz-NOAA/AFSCRACE_SurveyDataMapApp",
        title = "See the code on github",
        style = "color: #FFFFFF;"
      )
    ),
    
    #### Information ----
    dropdownMenu(
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
      id = "sidebarMenu",
      menuItem(
        "Survey Map", 
        tabName = "surveymap", 
        icon    = icon("file-image")
      ),
      # Metadata
      menuItem(
        "Metadata",
        tabName = "metadata",
        icon    = icon("cogs")
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
      # Information
      menuItem(
        "Information", 
        tabName = "information", 
        icon    = icon("book"),
        # About
        menuSubItem(
          "About", 
          tabName = "about",
        ), 
        # Export predictions
        menuSubItem(
          "Licensing", 
          tabName = "licensing",
        ),
        # Glossary of Terms
        menuSubItem(
          "Glossary of Terms",
          tabName = "glossary",
        ),
        menuSubItem(
          "Literature Cited",
          tabName = "",
        )
      )
    )
  )

## Body ----------------------------------------------------------------------
body <-  
  dashboardBody(
    tabItems(
      # Bottom trawl survey progress map(s)
      tabItem(
        tabName = "surveymap", 
        ui_surveymap("id_surveymap")           
      ),
      # # Metadata
      # tabItem(
      #   tabName = "",
      #   ui.metadata()
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
      # About
      tabItem(
        tabName = "about",
        ui_about()
      ),
      # Export Predictions
      tabItem(
        tabName = "licensing",
        ui_licensing()
      ),
      # Glossary of Terms
      tabItem(
        tabName = "glossary",
        ui_glossary("id_glossary")
      )
      # # Manual
      # tabItem(
      #   tabName = "",
      #   ui.manual()          
      # )
    )
  )

## Controlbar ------------------------------------------------------------------
# controlbar <-
#   dashboardControlbar(
#     ui_surveymapcontrolbar('id_surveymap')
#   )

## Call ---------------------------------------------------
ui <- 
  dashboardPage(
    header, 
    sidebar, 
    body,
    # controlbar
  )

# Server -----------------------------------------------------------------------
server <- function(input, output, session){
  s_surveymap("id_surveymap")
  s_glossary("id_glossary")
}

shinyApp(ui, server)