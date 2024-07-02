ui.test <- function() {
  tabItem(
    tabName = "test",
    fluidPage(
      leafletOutput(
        "mymap",
      ),
      absolutePanel(
        id        = "controls",
        class     = "panel panel-default",
        fixed     = TRUE,
        draggable = FALSE,
        top       = "550px",
        left      = "auto",
        right     = "15px",
        bottom    = "auto",
        width     = "auto",
        height    = "auto",
        
        br(),
        
        selectInput(
          inputId  = "year", 
          label    = "Year", 
          choices  = sort(unique(dat$year)), 
          # selected = max(dat$year), 
          selected = 2023, # FOR TESTING
          multiple = FALSE
        ),
        
        selectInput(
          inputId = "plot_display",
          label   = "Display",
          choices = c(
            "Points" = "pt",
            "Coldpool"    = "coldpool"
          ),
          selected = "pt"
        ),
        
        selectInput(
          inputId  = "survey", 
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
          inputId = "station", 
          label   = "Station Points", 
          value   = FALSE
        ),
        checkboxInput(
          inputId = "stratum", 
          label   = "Stratum", 
          value   = FALSE
        ), 
        checkboxInput(
          inputId = "vessel", 
          label   = "Vessels", 
          value   = FALSE
        ), 
        
        br(),
        
        selectInput(
          inputId = "plot_unit",
          label   = "Environmental Variable",
          choices = c(
            "Bottom Temperature (°C)" = "bottom_temperature_c",
            "Surface Temperature (°C)" = "surface_temperature_c",
            "None" = "none"
          ),
          selected = "none",
        ),
      )
    )
  )
}