ui_glossary <- function(id) {
  ns <- NS(id)
  
  tabItem(
    tabName = "glossary",
    fluidRow(
      box(
        width        = 12, 
        id           = "glossary",
        title        = NULL,
        headerBorder = FALSE,
        HTML("<html lang='en'>"), #Always have this as your first line
        
        h1("Glossary of Terms"),
        column(
          12, 
          wellPanel(
            DT::dataTableOutput(ns("gloss"))
          )
        )
      ),
      # target the box header of About
      tags$head(tags$style('#glossary .box-header{ display: none}'))  
    )
  )
}