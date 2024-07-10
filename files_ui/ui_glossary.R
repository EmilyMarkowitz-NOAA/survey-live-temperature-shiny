ui_glossary <- function(id) {
  ns <- NS(id)
  
  tabItem(
    tabName = "glossary",
    fluidRow(
      HTML("<html lang='en'>"), #Always have this as your first line
      
      h1("Glossary of Terms"),
      column(
        12, 
        wellPanel(
          DT::dataTableOutput(ns("gloss"))
        )
      )
    )
  )
}