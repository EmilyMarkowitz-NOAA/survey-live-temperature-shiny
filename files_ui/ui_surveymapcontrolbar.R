ui_surveymapcontrolbar <- function(id) {
  ns <- NS(id)
  
  dashboardControlbar(
    id = 'controlbar',
    collapsed = FALSE,
    conditionalPanel(
      condition = "input.sidebarMenu == 'surveymap'",
      controlbarMenu(
        id = 'menu',
        controlbarItem(
          "Menu",
          
          selectInput(
            inputId  = ns("year"), 
            label    = "Year", 
            choices  = sort(unique(dat$year)), 
            # selected = max(dat$year), 
            selected = 2023, # FOR TESTING
            multiple = FALSE
          ),
          
          selectInput(
            inputId = ns("plot_display"),
            label   = "Display",
            choices = c(
              "Points" = "pt",
              "Coldpool"    = "coldpool"
            ),
            selected = "pt"
          ),
          
          selectInput(
            inputId  = ns("survey"), 
            label    = "Survey", 
            choices  = sort(
              unique(
                # Removes "NEBS" if present in the list
                grep(
                  "NEBS",
                  shp_all$survey.area$SRVY,
                  invert = TRUE,
                  value  = TRUE
                )
              )
            ), 
            selected = c("EBS", "NBS"), 
            multiple = TRUE
          ),
          checkboxInput(
            inputId = ns("station"), 
            label   = "Station Points", 
            value   = FALSE
          ),
          checkboxInput(
            inputId = ns("stratum"), 
            label   = "Stratum", 
            value   = FALSE
          ), 
          checkboxInput(
            inputId = ns("vessel"), 
            label   = "Vessels", 
            value   = FALSE
          ), 
          
          br(),
          
          selectInput(
            inputId = ns("plot_unit"),
            label   = "Environmental Variable",
            choices = c(
              "Bottom Temperature (°C)" = "bottom_temperature_c",
              "Surface Temperature (°C)" = "surface_temperature_c",
              "None" = "none"
            ),
            selected = "none",
          )
        )
      )
    )
  )
}