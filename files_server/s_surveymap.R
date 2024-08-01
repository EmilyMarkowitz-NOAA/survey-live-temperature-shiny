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
    
    
    # Build the base map -----
    output$mymap <- renderLeaflet({
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
        ## Land mass polygons (i.e., Alaska) ----
        addPolygons(
          # AKFG shape files
          data =
            shp_all$akland %>%
            st_transform(crs = "+proj=longlat +datum=WGS84"),
          # data = rnaturalearth::ne_countries(
          #   country     = c("United States of America", "Canada", "Russia"),
          #   scale       = "medium",
          #   returnclass = "sf"
          # ) %>%
          # st_transform(crs = "+proj=longlat +datum=WGS84"),
          weight       = 0.5,
          color        = "black",
          opacity      = 0.5,
          fillOpacity  = 0.7,
          smoothFactor = 0.5,
          label        = ~paste(name),
          labelOptions = labelOptions(direction = "auto")
        ) %>%
        ## Survey region defaults ----
        addPolygons(
          data = shp_all$survey.area %>%
            st_transform(crs = "+proj=longlat +datum=WGS84") %>%
            dplyr::filter(
              SRVY %in% c("EBS", "NBS")
            ),
          group          = "regions",
          weight         = 1,
          color          = "#444444",
          opacity        = 1,
          fillColor      = ~pal_shp(SRVY),
          fillOpacity    = 0.2,
          smoothFactor   = 0.5,
          label          = ~paste(survey_long),
          labelOptions   = labelOptions(direction = "auto")
        ) %>%
        ## Add mouse over coordinates ----
        addMouseCoordinates(
          epsg = "EPSG:3338"
        ) %>%
        ## Add scale bars -----
        addMeasure(
          primaryLengthUnit = "kilometers",
          secondaryAreaUnit = "miles"
        # ) %>%
        ## Add map graticules -----
        # addPolylines(
        #   data = shp_all$graticule %>%
        #     st_transform(crs = "+proj=longlat +datum=WGS84"),
        #   weight = 1,
        #   color  = "#000000",
        #   label  = ~paste(degree),
        #   labelOptions = labelOptions(direction = "auto")
        # ) %>%
        ) %>%
        ## Add drawing tools for measurements -----
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
    })
    
    # Reactive Expressions -----
    ## Temperature color palette -----
    pal_tmp <- reactive({
      leaflet::colorFactor(
        palette  = viridis_pal(
          begin  = 0.2,
          end    = 0.8,
          option = input$plot_color
        )(length(unique(filter(dat, temperature_type == input$plot_unit)$temperature_bin))),
        domain = unique(filter(dat, temperature_type == input$plot_unit)$temperature_bin),
        na.color   = "transparent"
      )
    })
    
    ## Subset data based on user selection -----
    dat_temps_grid <- reactive({
      dat %>%
        dplyr::filter(
          SRVY %in% input$survey,
          year == input$year,
          temperature_type == input$plot_unit,
          grepl("-", station),
          is.na(comment)
        ) %>%
        st_transform(crs = "+proj=longlat +datum=WGS84")
    })
    
    dat_temps_crnr <- reactive({
      dat %>%
        dplyr::filter(
          SRVY %in% input$survey,
          year == input$year,
          temperature_type == input$plot_unit,
          !grepl("-", station),
          !is.na(comment)
        ) %>%
        st_transform(crs = "+proj=longlat +datum=WGS84")
    }) 
    
    # Add Map features ----
    observeEvent(input$updateButton, {
      ## Survey region polygons ----
      leafletProxy(
        "mymap"
        ) %>%
        clearGroup(
          "regions"
        ) %>%
        addPolygons(
        data = shp_all$survey.area %>%
          st_transform(crs = "+proj=longlat +datum=WGS84") %>%
          dplyr::filter(
            SRVY %in% input$survey
          ),
        group          = "regions",
        weight         = 1,
        color          = "#444444",
        opacity        = 1,
        fillColor      = ~pal_shp(SRVY),
        fillOpacity    = 0.2,
        smoothFactor   = 0.5,
        label          = ~paste(survey_long),
        labelOptions   = labelOptions(direction = "auto")
      )
      
      ## Temperature Data -----
      if (input$plot_unit != "none") {
      
        pal <- pal_tmp()
        
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            c(
              "temps_grid", 
              "temps_crnr"
            )
          ) %>%
          removeControl(
            "temps_legend"
          ) %>%
          addMapPane(
            "grid",
            zIndex = 450
          ) %>%
          addMapPane(
            "corners",
            zIndex = 460
          ) %>%
          addPolygons(
            data        = dat_temps_grid(),
            group       = "temps_grid",
            options     = pathOptions(pane = "grid"),
            weight      = 1,
            color       = "black",
            fillColor   = ~pal(temperature_bin),
            fillOpacity = 0.9,
            popup       = paste(
              "<strong>Region:</strong>",
              dat_temps_grid()$survey_long,
              "<br>",
              "<strong>Station:</strong>",
              dat_temps_grid()$station,
              "<br>",
              "<strong>Depth:</strong>",
              dat_temps_grid()$depth_m,
              "(m)",
              "<br>",
              "<strong>Temperature:</strong>",
              dat_temps_grid()$temperature_c,
              "(°C)"
            )
          ) %>%
          addPolygons(
            data        = dat_temps_crnr(),
            group       = "temps_crnr",
            options     = pathOptions(pane = "corners"),
            weight      = 1,
            color       = "black",
            fillColor   = ~pal(temperature_bin),
            fillOpacity = 0.9,
            popup       = paste(
              "<strong>Region:</strong>",
              dat_temps_crnr()$survey_long,
              "<br>",
              "<strong>Station:</strong>",
              dat_temps_crnr()$station,
              "<br>",
              "<strong>Depth:</strong>",
              dat_temps_crnr()$depth_m,
              "(m)",
              "<br>",
              "<strong>Temperature:</strong>",
              dat_temps_crnr()$temperature_c,
              "(°C)"
            )
          ) %>%
          # Temperature Legend -----
          addLegend(
            position = "bottomright",
            layerId  = "temps_legend",
            pal      = pal,
            values   = dat_temps_grid()$temperature_bin,
            title    = "Temperature (°C)",
            opacity  = 0.9
          )
      } else if (input$plot_unit == "none") {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            c(
              "temps_grid", 
              "temps_crnr"
            )
          ) %>%
          removeControl(
            "temps_legend"
          )
      }
    
      
      ## Add bathymetric countours ------
      if (input$bathymetry) {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            "survey_bathymetry"
          ) %>%
          addMapPane(
            "bathymetry",
            zIndex = 470
          ) %>%
        addPolylines(
        data = shp_all$bathymetry %>%
          st_transform(crs = "+proj=longlat +datum=WGS84") %>%
          dplyr::filter(
            SRVY %in% input$survey
          ),
        group        = "survey_bathymetry",
        options      = pathOptions(pane = "bathymetry"),
        weight       = 1.5,
        color        = "#000000",
        label        = ~paste(meters, "(m)"),
        labelOptions = labelOptions(direction = "auto")
        )
      } else if (input$bathymetry == FALSE) {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            "survey_bathymetry"
          )
      }
      
      ## Survey Strata -----
      if (input$stratum) {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            "survey_strata"
          ) %>%
          addMapPane(
            "strata",
            zIndex = 420
          ) %>%
          addPolygons(
            data      = shp_all$survey.strata %>%
              st_transform(crs = "+proj=longlat +datum=WGS84") %>%
              dplyr::filter(
                SRVY %in% input$survey
              ) %>%
              # AI and GOA strata are NA and cause performance issues. So,
              # better to not have the map render those polygons.
              dplyr::filter(
                SRVY %!in% c("AI", "GOA")
              ),
            group     = "survey_strata",
            options   = pathOptions(pane = "strata"),
            weight    = 0.5,
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
            highlightOptions = highlightOptions(
              fillColor    = 'grey50',
              fill         = 'grey50',
              bringToFront = TRUE
            )
          )
      } else if (input$stratum == FALSE) {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            "survey_strata"
          )
      }
  
      ## Stations -----
      if (input$station && input$plot_unit == "none") {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
              "survey_stations"
          ) %>%
          addMapPane(
            "stations",
            zIndex = 440
          ) %>%
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
              group       = "survey_stations",
              options     = pathOptions(pane = "stations"),
              weight      = 0.25,
              color       = "black",
              fillColor   = "black",
              label       = ~station,
              fillOpacity = 0.5,
          )
      } else if (input$station == FALSE) {
        leafletProxy(
          "mymap"
        ) %>%
          clearGroup(
            "survey_stations"
          )
      }
    
    ## Data Table ----  
    output$DataTable <- 
      DT::renderDataTable(
        datatable(
          dplyr::bind_rows(
            dat_temps_grid(),
            dat_temps_crnr()
          ) %>%
            dplyr::mutate(
              Date = as.IDate(date),
              "Time (z)" = as.ITime(date),
              .after = station
            ) %>%
            dplyr::select(
              -c(
                stratum,
                data_type,
                date,
                survey_definition_id,
                SRVY,
                survey,
                vessel_id,
                vessel_color,
                vessel_ital, 
                vessel_shape,
                temperature_type,
                temperature_bin,
                comment
              )
            ) %>%
            dplyr::rename(
              Year = year,
              Station = station,
              Survey = survey_long,
              Dates = survey_dates,
              Vessel = vessel_name,
              "Temperature (°C)" = temperature_c,
              "Depth (m)" = depth_m,
              "Starting Lat (dd)" = latitude_dd_start,
              "Starting Long (dd)" = longitude_dd_start
            ) %>%
            st_drop_geometry(),
          options = list(
            pageLength = 50, 
            dom        = 'tip', 
            dom        = 't',
            ordering   = FALSE, 
            paging     = FALSE
          ),
          class = "cell-border stripe",
          rownames = FALSE,
          # caption = 'Table 2: Defined terms used in web tool.', 
          escape   = FALSE
        ) %>%
          formatRound(c("Starting Lat (dd)", "Starting Long (dd)"), 3)
      )
    
    })
  })
}