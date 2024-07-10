ui_surveymap <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    column(
      width = 10,
      leafletOutput(
        ns("mymap"),
        # 'vh' dynamically adjusts height of map to indicated % of window size
        height = '91vh',
        # width = '90vw'
      )
    ),
    
    column(
      width = 2,
      wellPanel(
        selectInput(
          inputId  = ns("year"),
          label    = "Year",
          choices  = sort(unique(dat$year)),
          # selected = max(dat$year),
          selected = 2023, # FOR TESTING
          multiple = FALSE
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
        selectInput(
          inputId = ns("plot_display"),
          label   = "Display",
          choices = c(
            "Points"   = "pt",
            "Coldpool" = "coldpool"
          ),
          selected = "pt"
        ),
        selectInput(
          inputId = ns("plot_unit"),
          label   = "Environmental variable",
          choices = c(
            "Bottom Temperature (°C)"  = "bottom_temperature_c",
            "Surface Temperature (°C)" = "surface_temperature_c",
            "None" = "none"
          ),
          selected = "none",
        ),
        p("Additional toggles"),
        checkboxInput(
          inputId = ns("station"),
          label   = "Station points",
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
        actionButton(
          inputId = ns("updateButton"),
          label   = "Update map"
        )
      )
    )
  )
}