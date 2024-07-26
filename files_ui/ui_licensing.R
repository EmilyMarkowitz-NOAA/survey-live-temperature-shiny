ui_licensing <- function() {
  tabItem(
    tabName = "licensing",
    fluidRow(
      HTML("<html lang='en'>"), #Always have this as your first line
      h1("Licensing information"),
      
      p("Software code created by U.S. Government employees is not subject to copyright in the United States (17 U.S.C. §105). The United States/Department of Commerce reserve all rights to seek and obtain copyright protection in countries other than the United States for Software authored in its entirety by the Department of Commerce. To this end, the Department of Commerce hereby grants to Recipient a royalty-free, nonexclusive license to use, copy, and create derivative works of the Software outside of the United States."),
      br(),
      p("For any comments or questions please contact <First.Last@noaa.gov>."),
      br(),
      # ![NOAA Fisheries](./www/noaa_logo.gif "NOAA Fisheries"){width=50px}
      )
    )
}