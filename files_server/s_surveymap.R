s_surveymap <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Static values ----
    ## Define unique operator -----
    `%!in%` <- Negate(`%in%`)
    
    ## Survey regions color palette ----
    pal_shp <- 
      colorFactor(
        viridis_pal(
          # mako
          option = "G", 
          begin  = 0.2, 
          end    = 0.8
        )(length(unique(shp_all$survey.area$SRVY))),  
        domain   = unique(shp_all$survey.area$SRVY),
        na.color = "transparent"
      )
    
    # Reactive Expressions -------
    ##
    ## Temperature color palette ------
    pal_tmp <- reactive({
      leaflet::colorFactor(
        palette  = viridis_pal(
          begin  = 0.2,
          end    = 0.8,
          option = input$plot_color
        )(length(unique(dat$bot_bin))),
        domain = unique(dat$bot_bin),
        na.color = viridis(
          n      = 1,
          begin  = 0.8,
          end    = 0.8,
          option = input$plot_color
        )
      )
    })
    
    ## Subset data based on user selection ------
    dat_temps_grid <- reactive({
      dat %>%
      dplyr::filter(
        SRVY %in% input$survey,
        SRVY %!in% c("AI", "GOA"),
        year == input$year,
        is.na(comment)
      ) %>%
      st_transform(crs = "+proj=longlat +datum=WGS84")
    })
    
    dat_temps_crnr <- reactive({
      dat %>%
        dplyr::filter(
          SRVY %in% input$survey,
          SRVY %!in% c("AI", "GOA"),
          year == input$year,
          !is.na(comment)
        ) %>%
        st_transform(crs = "+proj=longlat +datum=WGS84")
    }) 
    
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
          # # AKFG shape files
          # data = 
          #   shp_all$akland %>%
          #   st_transform(crs = "+proj=longlat +datum=WGS84"),
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
          fillColor      = ~pal_shp(SRVY),
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
        # ) %>%
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
        # addDrawToolbar(
        #   targetGroup ='draw',
        #   editOptions = editToolbarOptions(
        #     selectedPathOptions = selectedPathOptions()
        #   ),
        #   polylineOptions = filterNULL(
        #     list(
        #       shapeOptions = drawShapeOptions(
        #         lineJoin = "round",
        #         weight   = 3
        #       )
        #     )
        #   ),
        #   circleOptions = filterNULL(
        #     list(
        #       shapeOptions = drawShapeOptions(),
        #       repeatMode   = FALSE,
        #       showRadius   = TRUE,
        #       metric       = TRUE,
        #       feet         = FALSE,
        #       nautic       = FALSE
        #     )
        #   )
        )

      if (input$plot_unit != "none") {
        leafletProxy(
          "mymap"
        ) %>%
          addMapPane(
            "grid",
            zIndex = 420
          ) %>%
          addMapPane(
            "corners",
            zIndex = 420
          ) %>%
          addPolygons(
            data        = dat_temps_grid(),
            options     = pathOptions(pane = "grid"),
            weight      = 1,
            color       = "black",
            fillColor   = ~pal_tmp()(dat_temps_grid()$bot_bin),
            fillOpacity = 1,
            popup       = paste(
              "Survey:",
              dat_temps_grid()$survey_long,
              "<br>",
              "Station:",
              dat_temps_grid()$station,
              "<br>",
              "Temperature:",
              dat_temps_grid()$bottom_temperature_c,
              "(°C)"
            )
          ) %>%
          addPolygons(
            data        = dat_temps_crnr(),
            options     = pathOptions(pane = "corners"),
            weight      = 1,
            color       = "black",
            fillColor   = ~pal_tmp()(dat_temps_grid()$bot_bin),
            fillOpacity = 1,
            popup       = paste(
              "Survey:",
              dat_temps_crnr()$survey_long,
              "<br>",
              "Station:",
              dat_temps_crnr()$station,
              "<br>",
              "Temperature:",
              dat_temps_crnr()$bottom_temperature_c,
              "(°C)"
            ),
          ) %>%
          addLegend(
            position = "bottomright",
            pal      = pal_tmp(),
            values   = dat_temps_grid()$bot_bin,
            title    = "Temperature (°C)",
            opacity  = 1.0
          )
      }
          # addPolygons(
          #   data        = dat_temps_grid,
          #   options     = pathOptions(pane = "grid"),
          #   weight      = 1,
          #   color       = "black",
          #   fillColor   = ~pal_tmp(bot_bin),
          #   fillOpacity = 1,
          #   popup       = paste(
          #     "Survey:",
          #     dat_temps_grid$survey_long,
          #     "<br>",
          #     "Station:",
          #     dat_temps_grid$station,
          #     "<br>",
          #     "Temperature:",
          #     dat_temps_grid$bottom_temperature_c,
          #     "(°C)"
          #   ),
          # ) %>%
          # addPolygons(
          #   data        = dat_temps_crnr,
          #   options     = pathOptions(pane = "corners"),
          #   weight      = 1,
          #   color       = "black",
          #   fillColor   = ~pal_tmp(bot_bin),
          #   fillOpacity = 1,
          #   popup       = paste(
          #     "Survey:",
          #     dat_temps_crnr$survey_long,
          #     "<br>",
          #     "Station:",
          #     dat_temps_crnr$station,
          #     "<br>",
          #     "Temperature:",
          #     dat_temps_crnr$bottom_temperature_c,
          #     "(°C)"
          #   ),
          # )
        
      #   if (input$plot_unit == "bottom_temperature_c") {
      #     a <- 
      #       a %>%
      #       addMapPane(
      #         "grid", 
      #         zIndex = 420
      #       ) %>%
      #       addMapPane(
      #         "corners",
      #         zIndex = 440
      #       ) %>%
      #       addPolygons(
      #         data        = dat_temps_grid,
      #         options     = pathOptions(pane = "grid"),
      #         weight      = 1,
      #         color       = "black",
      #         fillColor   = ~pal_tmp(bot_bin),
      #         fillOpacity = 1,
      #         popup       = paste(
      #           "Survey:",
      #           dat_temps_grid$survey_long,
      #           "<br>",
      #           "Station:",
      #           dat_temps_grid$station,
      #           "<br>",
      #           "Temperature:",
      #           dat_temps_grid$bottom_temperature_c,
      #           "(°C)"
      #         ),
      #       ) %>%
      #       addPolygons(
      #         data        = dat_temps_crnr,
      #         options     = pathOptions(pane = "corners"),
      #         weight      = 1,
      #         color       = "black",
      #         fillColor   = ~pal_tmp(bot_bin),
      #         fillOpacity = 1,
      #         popup       = paste(
      #           "Survey:",
      #           dat_temps_crnr$survey_long,
      #           "<br>",
      #           "Station:",
      #           dat_temps_crnr$station,
      #           "<br>",
      #           "Temperature:",
      #           dat_temps_crnr$bottom_temperature_c,
      #           "(°C)"
      #         ),
      #       ) %>%
      #       addLegend(
      #         position = "bottomright",
      #         pal      = pal_tmp,
      #         values   = dat_temps$bot_bin,
      #         title    = "Bottom </br> Temperature (°C)",
      #         opacity  = 1.0
      #       )
      #   # } else if (input$plot_unit == "surface_temperature_c") {
      #   #   a <- 
      #   #     a %>%
      #   #     addPolygons(
      #   #       data        = dat_temps,
      #   #       weight      = 1,
      #   #       color       = "black", 
      #   #       fillColor   = ~pal_tmp(sur_bin),
      #   #       fillOpacity = 1,
      #   #       popup       = paste(
      #   #         "Survey:",
      #   #         dat_temps$survey_long,
      #   #         "<br>",
      #   #         "Station:",
      #   #         dat_temps$station,
      #   #         "<br>",
      #   #         "Temperature:",
      #   #         dat_temps$surface_temperature_c,
      #   #         "(°C)"
      #   #       )
      #   #     ) %>%
      #   #     addLegend(
      #   #       position = "bottomleft",
      #   #       pal      = pal_tmp,
      #   #       values   = dat_temps$sur_bin,
      #   #       title    = "Surface </br> Temperature (°C)"
      #   #     )
      #   } 
      # }else {
      #   a
      # }
      
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