s_glossary <- function(id){
  moduleServer(id, function(input, output, session) {
    
    glossary <- 
      read.csv(
        here::here(
          "data", 
          "glossary-of-terms.csv"
        )
      ) %>%
      dplyr::filter(
        is.na(include)
      ) %>%
      dplyr::select(
        -include
      ) %>%
      dplyr::rename(
        Term = term,
        Definition = definition
      )
    
    output$gloss <- 
      DT::renderDataTable({
        datatable(
          glossary, 
          options = list(
            pageLength = 50, 
            dom        = 'tip', 
            dom        = 't',
            ordering   = FALSE, 
            paging     = FALSE
          ), 
          rownames = FALSE,
          # caption = 'Table 2: Defined terms used in web tool.', 
          escape   = FALSE
        )
      })
  })
}