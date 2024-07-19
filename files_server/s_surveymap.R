s_surveymap <- function(id) {
  moduleServer(id, function(input, output, session) {
   
    ## Define unique operator
    `%!in%` <- Negate(`%in%`)
    
    ## PREAMBLE TESTING
    df0 <-
      reactive({
        dat %>%
        dplyr::filter(
          year == input$year &
            SRVY %in% input$survey
        )
      })
    
    # Survey regions color palette
    pal_shp <- 
      colorNumeric(
        viridis(
          option = "G", 
          n      = length(unique(shp_all$survey.area$survey_definition_id)), 
          begin  = 0.2, 
          end    = 0.8
        ), 
        domain   = shp_all$survey.area$survey_definition_id,
        na.color = "transparent"
      )
    
    # Temperature color palette
    pal_tmp <-
      leaflet::colorNumeric(
        palette = viridis_pal(
          begin  = 0.2,
          end    = 0.8,
          option = "B"
        )(2),
        domain = c(-2, 12),
        na.color = viridis(
          n      = 1,
          begin  = 0.8,
          end    = 0.8,
          option = "B"
        )
      )
    
    # Build the map
    output$mymap <- renderLeaflet({
      a <- 
        leaflet(
          options = leafletOptions(
            crs = leafletCRS(
              crsClass    = "L.Proj.CRS",
              code        = "EPSG:3338",
              proj4def    = "+proj=aea +lat_1=55 +lat_2=65 +lat_0=50 +lon_0=-154 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs",
              resolutions = 2^(16:7)
            ),
            minZoom = 4,
            zoomSnap = 0.5,
            zoomDelta = 0.5
          ) 
        ) %>%
        setView(
          lat  = 59.5,
          lng  = -172.0,
          zoom = 5
        ) %>%
        addScaleBar(
          position = "bottomright"
        ) %>%
        # Land mass polygons (i.e., Alaska)
        addPolygons(
          data = rnaturalearth::ne_countries(
            country     = c("United States of America", "Canada", "Russia"),
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
        # # Add map graticules
        # addPolylines(
        #   data = shp_all$graticule %>%
        #     st_transform(crs = "+proj=longlat +datum=WGS84"),
        #   weight = 1,
        #   color  = "#000000",
        #   label  = ~paste(degree),
        #   labelOptions = labelOptions(direction = "auto")
        # ) %>%
        # # Add bathymetric countours
        # addPolylines(
        #   data = shp_all$bathymetry %>%
        #     st_transform(crs = "+proj=longlat +datum=WGS84") %>%
        #     dplyr::filter(
        #       SRVY %in% input$survey
        #     ),
        #   weight = 2, 
        #   color  = "#000000",
        #   label  = ~paste(meters),
        #   labelOptions = labelOptions(direction = "auto")
        # ) %>%
        # Survey region polygons
        addPolygons(
          data = shp_all$survey.area %>%
            st_transform(crs = "+proj=longlat +datum=WGS84") %>%
            dplyr::filter(
              SRVY %in% input$survey
            ),
          weight         = 1,
          color          = "#444444",
          opacity        = 1,
          fillColor      = ~pal_shp(survey_definition_id),
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
      
      if (input$plot_unit == "bottom_temperature_c") {
        a <- 
          a %>%
          addPolygons(
            data = dat %>%
              st_transform(crs = "+proj=longlat +datum=WGS84") %>%
              dplyr::filter(
                SRVY %in% input$survey &
                  year == input$year
              ) %>%
              dplyr::filter(
                SRVY %!in% c("AI", "GOA")
              ),
            weight = 0.25,
            # color  = ~pal_tmp(bot_bin)
          )
      } else {
        a
      }
      
      ## ADD STRATUM POLYGONS -----------------
      if (input$stratum) {
        a <- 
          a %>% 
          addPolygons(
            data = 
              shp_all$survey.strata %>% 
              st_transform(crs = "+proj=longlat +datum=WGS84") %>%
              dplyr::filter(
                SRVY %in% input$survey
              ) %>%
              # AI and GOA strata are NA and cause performance issues. So,
              # better to not have the map render those polygons.
              dplyr::filter(
                SRVY %!in% c("AI", "GOA")
              ), 
            weight    = 0.25,
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
      } else {
        a
      }
      
      # ADD STATION POINTS ---------------------
      if (input$station) {
        
        a <-
          a %>%
          addPolygons( 
              data = shp_all$survey.grid %>%
                st_transform(crs = "+proj=longlat +datum=WGS84") %>%
                dplyr::filter(
                  SRVY %in% input$survey
                ) %>%
                # AI and GOA Points are densely packed, causing performance
                # issues, and less important to temperature data. So, better to
                # not have the map render those polygons
                dplyr::filter(
                  SRVY %!in% c("AI", "GOA")
                ),
              weight      = 0.25,
              color       = "black",
              fillColor   = "black",
              label       = ~station,
              # color   = nmfspalette::nmfs_palette(palette = "urchin")(1),
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