ui_surveymap <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    tabBox(
      title = "Alaska Bottom Trawl Survey",
      width = 10,
      tabPanel(
        "Map",
          leafletOutput(
            ns("mymap"),
            # 'vh' dynamically adjusts height of map to indicated % of window size
            height = '85vh',
            # width = '90vw'
          )
      ),
      tabPanel(
        "Data",
        DT::dataTableOutput(ns("DataTable"))
      )
    ),
    
    column(
      width = 2,
      wellPanel(
        selectInput(
          inputId  = ns("year"),
          label    = "Year",
          choices  = sort(unique(dat$year)),
          selected = max(dat$year),
          multiple = FALSE
        ),
        checkboxGroupInput(
          inputId  = ns("survey"),
          label    = "Survey region",
          choiceNames = sort(
            unique(
              shp_all$survey.area$survey_long
            )
          ),
          choiceValues = sort(
            unique(
              shp_all$survey.area$SRVY
            )
          ),
          selected = c("EBS", "NBS")
        ),
        # selectInput(
        #   inputId = ns("plot_display"),
        #   label   = "Display",
        #   choices = c(
        #     "Points"   = "pt",
        #     "Coldpool" = "coldpool"
        #   ),
        #   selected = "pt"
        # ),
        selectInput(
          inputId = ns("plot_unit"),
          label   = "Environmental variable",
          choices = c(
            "Bottom Temperature (°C)"  = "bottom",
            "Surface Temperature (°C)" = "surface",
            "None" = "none"
          ),
          selected = "none",
        ),
        selectInput(
          inputId = ns("plot_color"),
          label   = "Color scheme",
          choices = c(
            "Magma"   = "A",
            "Inferno" = "B",
            "Plasma"  = "C",
            "Viridis" = "D",
            "Cividis" = "E",
            "Rocket"  = "F",
            "Mako"    = "G",
            "Turbo"   = "H"
          ),
          selected = "A"
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
          inputId = ns("bathymetry"),
          label   = "Bathymetric contours",
          value   = FALSE
        ),
        # checkboxInput(
        #   inputId = ns("vessel"),
        #   label   = "Vessels",
        #   value   = FALSE
        # ),
        actionButton(
          inputId = ns("updateButton"),
          label   = "Update"
        )
      )
    )
  )
}