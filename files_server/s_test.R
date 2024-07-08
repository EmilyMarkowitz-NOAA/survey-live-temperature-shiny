s_test <- function(id) {
  moduleServer(id, function(input, output, session) {
   
    ## MAY NEED TO MOVE TO DATA.R or APP.R file
    shp_all$survey.area <- 
      dplyr::mutate(
        shp_all$survey.area,
        survey_long = dplyr::case_when(
          SRVY == "AI"  ~ "Aleutian Islands", 
          SRVY == "BSS" ~ "Bering Sea Slope", 
          SRVY == "EBS" ~ "Eastern Bering Sea",  
          SRVY == "GOA" ~ "Gulf of Alaska",  
          SRVY == "NBS" ~ "Northern Bering Sea"
        )
      )
    
    # Survey region shapefile color palette
    pal <- 
      colorNumeric(
        viridis(
          option = "G", 
          n      = 2, 
          begin  = 0.2, 
          end    = 0.8
        ), 
        domain  = shp_all$survey.area$survey_definition_id,
        na.color = "transparent"
      )
    
    output$mymap <- renderLeaflet({
      a <- 
        leaflet(
          options = leafletOptions(
            crs = leafletCRS(
              crsClass    = "L.Proj.CRS",
              code        = "EPSG:3338",
              proj4def    = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs",
              resolutions = 2^(16:7)
            )
          ) 
        ) %>%
        setView(
          lat  = 59.5,
          lng  = -165.5,
          zoom = 4
        ) %>%
        # Land masses (i.e., Alaska)
        addPolygons(
          data = rnaturalearth::ne_countries(
            scale       = "medium", 
            returnclass = "sf"
          ) %>% 
          st_transform(crs = "+proj=longlat +datum=WGS84"),
          weight       = 0.5, 
          color        = "black", 
          opacity      = 0.5,
          fillOpacity  = 0.7,
          smoothFactor = 0.5,
          label        = ~paste(name),
          labelOptions = labelOptions(direction = "auto")
        ) %>%
        addPolygons(
          data = shp_all$survey.area %>%
            st_transform(crs = "+proj=longlat +datum=WGS84") %>%
            dplyr::filter(
              SRVY %in% input$survey
            ),
          weight         = 1,
          color          = "#444444",
          opacity        = 1,
          fillColor      = ~pal(survey_definition_id),
          fillOpacity    = 0.2,
          smoothFactor   = 0.5,
          label          = ~paste(survey_long),
          labelOptions   = labelOptions(direction = "auto")
        )  %>%
        addMouseCoordinates(
          epsg = "EPSG:3338"
        ) %>% 
        addMeasure(
          primaryLengthUnit = "kilometers",
          secondaryAreaUnit = "miles"
        ) %>%
        addDrawToolbar(
          targetGroup ='draw',
          editOptions = editToolbarOptions(
            selectedPathOptions = selectedPathOptions()
          ),
          polylineOptions = filterNULL(
            list(
              shapeOptions = drawShapeOptions(
                lineJoin = "round",
                weight   = 3
              )
            )
          ),
          circleOptions = filterNULL(
            list(
              shapeOptions = drawShapeOptions(),
              repeatMode   = FALSE,
              showRadius   = TRUE,
              metric       = TRUE,
              feet         = FALSE,
              nautic       = FALSE
            )
          )
        )
      
      ## ADD STRATUM POLYGON? -----------------
      if (input$stratum) {
        
        a <- 
          a %>% 
          addPolygons(
            data = 
              shp_all$survey.strata %>% 
              st_transform(crs = "+proj=longlat +datum=WGS84") %>%
              dplyr::filter(
                SRVY %in% input$survey
              ), 
            weight    = 0.075,
            color     = "black", 
            fill      = "transparent",
            fillColor = "transparent",
            label     =  paste0(
              "Stratum: ",
              dplyr::filter(
                shp_all$survey.strata,
                SRVY %in% input$survey
              )$stratum
            ),
            # Can toggle this on to have blank labels for those with NA stratum
            # label     = ifelse(
            #   !is.na(dplyr::filter(
            #     shp_all$survey.strata, 
            #     SRVY %in% input$survey
            #   )$stratum),
            #   paste0(
            #   "Stratum: ", 
            #   dplyr::filter(
            #     shp_all$survey.strata, 
            #     SRVY %in% input$survey
            #   )$stratum
            #   ),
            #   ""
            # ),
            highlightOptions = highlightOptions(
              fillColor    = 'grey50',
              fill         = 'grey50',
              bringToFront = TRUE
            )
          )
      } else{
        a
      }
      
      # ADD STATION POINTS? ---------------------
      if (input$station) {
        a <-
          a %>%
          addPolygons( 
            data = shp_all$survey.grid %>%
              st_transform(crs = "+proj=longlat +datum=WGS84") %>%
              dplyr::filter(
                SRVY %in% input$survey
              ),
            weight      = 0.1,
            color       = "black",
            # fillcolor       = nmfspalette::nmfs_palette(palette = "urchin")(1),
            fillOpacity = 0.1,
            # popup       = paste(
            #   "<strong>Survey:</strong> ", df1$survey, "<br>",
            #   "<strong>Data State:</strong> ", df1$data_type,  "<br>",
            #   "<strong>Station:</strong> ", shp_stn$station, "<br>",
            #   "<strong>Stratum:</strong> ", shp_stn$stratum,  "<br>",
            #   "<strong>Latitude (&degN):</strong> ", round(shp_stn$lat, 2),  "<br>",
            #   "<strong>Longitude (&degW):</strong> ", round(shp_stn$lon, 2),  "<br>"
            # )
          )
      } else {
        a
      }
    })
  })
}