ui_about <- function() {
  tabItem(
    tabName = "about",
    fluidRow(
      box(
        width        = 12, 
        id           = "About", 
        title        = NULL,
        headerBorder = FALSE,
        
        HTML("<html lang='en'>"), #Always have this as your first line
        
        h1("Alaska Fisheries Science Center"),
        h2("Resource Assessment and Conservation Engineering Division"),
        h3("Groundfish Assessment Program Bottom Trawl Survey"),
        
        p("The RACE Groundfish Assessment Program conducts bottom trawl surveys with the intent to collect data on the distribution and abundance of crab, groundfish, and other bottom-dwelling species in the Bering Sea, Aleutian Islands, and Gulf of Alaska. This work has been conducted annually since 1982 in the Eastern Bering sea. Bottom trawl Surveys began more recently in other regions, and occur intermittently (i.e., Northern Bering Sea) or biannually in alternating years (i.e., Aleutian Islands and Gulf of Alaska)."), 

        br(),

        p("This application serves as a general-purpose tool to explore and visualize those data. For more specific needs or collaboration, please contact <First.Last@noaa.gov>")
      ),
      # target the box header of About
      tags$head(tags$style('#About .box-header{ display: none}'))  
    )
  )
}


