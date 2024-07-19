# Load data from FOSS API ------------------------------------------------------

## Load packages ---------------------------------------------------------------
# install.packages(c("httr", "jsonlite"))
library(httr)
library(jsonlite)
library(dplyr)
options(scipen = 999)

# Toggle internet access -------------------------------------------------------
doihaveinternet <- FALSE

# Download FOSS data ----------------------------------------------------------
if (doihaveinternet) {
  
  ## lastdl = current date --------
  lastdl <- Sys.Date()
  
  ## link to the Haul API --------
  api_link_haul <- "https://apps-st.fisheries.noaa.gov/ods/foss/afsc_groundfish_survey_haul/"
  
  dat_haul_api0 <- data.frame()
  
  for (i in seq(0, 500000, 10000)){
    ## find how many iterations it takes to cycle through the data
    print(i)
    ## query the API link
    res <- 
      httr::GET(
        url = paste0(
          api_link_haul, 
          "?offset=",i,
          "&limit=10000"
        )
      )
    ## convert from JSON format
    data <- jsonlite::fromJSON(base::rawToChar(res$content)) 
    
    ## if there are no data, stop the loop
    if (is.null(nrow(data$items))) {
      break
    }
    
    ## bind sub-pull to dat data.frame
    dat_haul_api0 <- 
      dplyr::bind_rows(
        dat_haul_api0, 
        data$items
      )
  }

  # save outputs for later comparison
  dat_haul_api <- 
    dat_haul_api0 %>% 
    dplyr::rename(
      SRVY = srvy, 
      # survey_definition_id  = survey_name,
      # survey_name = survey_definition_id
    ) %>% 
    dplyr::mutate(
      data_type = "offical", 
      date      = as.Date(date_time)
    ) %>% 
    dplyr::select(
      -links
    )

## Parse FOSS data -------------------------------------------------------------  
### dat_survey_list ------------------------------------------------------------
  dat_survey_list <- 
    dat_haul_api %>% 
    dplyr::select(
      survey_definition_id, 
      SRVY, 
      survey, 
      survey_name
    ) %>% 
    dplyr::distinct() %>% 
    dplyr::ungroup()

### dat_surveys ----------------------------------------------------------------  
  dat_surveys <- 
    dat_haul_api %>% 
    dplyr::select(
      year, 
      SRVY, 
      survey, 
      survey_definition_id,
      survey_name, 
      date_time, 
      vessel_name, 
      vessel_id, 
      # latitude_dd_start, 
      # longitude_dd_start, 
      # latitude_dd_end, 
      # longitude_dd_end, 
      # bottom_temperature_c, 
      # surface_temperature_c, 
      # depth_m
    ) %>% 
    dplyr::group_by(
      year, 
      SRVY, 
      survey, 
      survey_definition_id, 
      survey_name, 
      vessel_name, 
      vessel_id
    ) %>% 
    dplyr::summarise(
      date_min = 
        min(
          as.Date(date_time), 
          na.rm = TRUE
        ), 
      date_max = 
        max(
          as.Date(date_time), 
          na.rm = TRUE
        )
    )  %>% 
    dplyr::mutate(
      vessel_shape = 
        substr(
          x     = vessel_name, 
          start = 1, 
          stop  = 1
        ),
      vessel_ital = 
        paste0(
          "F/V *", 
          stringr::str_to_title(vessel_name), 
          "*"
        ), 
      vessel_name = 
        paste0(
          "F/V ", 
          stringr::str_to_title(vessel_name)
        ), 
      survey = 
        survey_name, 
      survey_dates = 
        paste0(
          format(date_min, "%B %d"), 
          " - ", 
          format(date_max, "%B %d, %Y")
        )
    ) %>% 
    dplyr::select(
      -date_min, 
      -date_max
    ) %>% 
    dplyr::ungroup() %>% 
    dplyr::mutate(
      vessel_color = pal(vessel_name)
    )
  
## Oracle data -----------------------------------------------------------------
  if (file.exists("Z:/Projects/ConnectToOracle.R")) {
    source("Z:/Projects/ConnectToOracle.R")
    
    # I set up a ConnectToOracle.R that looks like this: 
    #   
    # PKG <- c("RODBC")
    # for (p in PKG) {
    #   if(!require(p,character.only = TRUE)) {  
    #     install.packages(p)
    #     require(p,character.only = TRUE)}
    # }
    # 
    # channel<-odbcConnect(dsn = "AFSC",
    #                      uid = "USERNAME", # change
    #                      pwd = "PASSWORD", #change
    #                      believeNRows = FALSE)
    # 
    # odbcGetInfo(channel)
    
  } else { # For those without a ConnectToOracle file
    
    # # library(devtools)
    # # devtools::install_github("afsc-gap-products/gapindex")
    # library(gapindex)
    # channel <- gapindex::get_connected()
    
    # or 
    
    library(rstudioapi)
    library(RODBC)
    channel <- odbcConnect(
      dsn = "AFSC", 
      uid = rstudioapi::showPrompt(
        title   = "Username", 
        message = "Oracle Username", default = ""
      ), 
      pwd = rstudioapi::askForPassword("Enter Password"),
      believeNRows = FALSE
    )
  }
  
  date_max <- 
    RODBC::sqlQuery(
      channel, 
      paste0("SELECT CREATE_DATE FROM RACE_DATA.EDIT_HAULS;")
    )
  date_max <- 
    sort(
      as.numeric(
        unique(
          unlist(
            format(
              date_max, 
              format = "%Y"
            )
          )
        )
      )
    )
  date_max <- 
    max(
      date_max[date_max <= format(Sys.Date(), format = "%Y")]
    ) 
  # Note: sometimes there are dates that haven't happened yet b/c testing
  
  ## Pull in current year ------------------------------------------------------
  # if this year's data hasn't been entered into the production data
  if (max(dat_surveys$year) < date_max) { 
    
    dat_haul_oracleraw <- dplyr::inner_join(
      # Pull event data
      x = RODBC::sqlQuery(
        channel, 
        paste0( 
          "SELECT HAUL_ID, 
          EDIT_DATE_TIME, 
          EDIT_LATITUDE AS LATITUDE_DD_START, 
          EDIT_LONGITUDE AS LONGITUDE_DD_START 
          FROM RACE_DATA.EDIT_EVENTS
          WHERE EVENT_TYPE_ID = 3;"
        )
      ) %>%   # standard haul
      dplyr::filter(
        format(as.Date(EDIT_DATE_TIME), format = "%Y") == date_max
      ) %>%
      dplyr::rename(
        date = EDIT_DATE_TIME
      ) %>%
        # Removes erroneous entry where LAT/LON are 0, which causes a failure in
        # the next step
      dplyr::filter(
        LATITUDE_DD_START != 0 | LONGITUDE_DD_START !=0
      ) %>%
      dplyr::mutate(
        # date = format(as.Date(date), format = c("%Y-%m-%d %H:%M")),
        LONGITUDE_DD_START = ddm2dd(LONGITUDE_DD_START), 
        LATITUDE_DD_START = ddm2dd(LATITUDE_DD_START)
      ),
      
      # Pull haul data
      y = RODBC::sqlQuery(
        channel, 
        paste0( #  EDIT_GEAR_TEMPERATURE_UNITS, EDIT_SURFACE_TEMPERATURE_UNITS, ABUNDANCE_HAUL, CREATE_DATE, 
          "SELECT HAUL_ID, 
          CRUISE_ID, 
          HAUL, 
          STATION, 
          -- STRATUM, 
          EDIT_BOTTOM_DEPTH as DEPTH_M, 
          EDIT_SURFACE_TEMPERATURE AS surface_temperature_c, 
          EDIT_GEAR_TEMPERATURE AS bottom_temperature_c
          FROM RACE_DATA.EDIT_HAULS
          WHERE PERFORMANCE >= 0;"
        )
      ), 
      
      by = "HAUL_ID"
    )  %>% 
      
      # Get vessel info and SURVEY_ID
    dplyr::left_join(
      y = RODBC::sqlQuery(
        channel, 
        paste0(
          "SELECT CRUISE_ID, 
          SURVEY_ID, 
          VESSEL_ID, 
          START_DATE, 
          END_DATE
          FROM RACE_DATA.CRUISES;"
        )
      ) %>% 
      dplyr::mutate(
        survey_dates = paste0(
          format(START_DATE, "%B %d"), 
          " - ", 
          format(END_DATE, "%B %d, %Y")
        )
      ) %>% 
      dplyr::select(
        -START_DATE, 
        -END_DATE
      ), 
      by = "CRUISE_ID"
    ) %>%
      
    # Add SURVEY_DEFINITION_ID
    dplyr::left_join(
      y = RODBC::sqlQuery(
        channel, 
        paste0(
          "SELECT SURVEY_DEFINITION_ID, 
          SURVEY_ID
          FROM RACE_DATA.SURVEYS;")
        ), 
      by = "SURVEY_ID"
    ) %>%
      
    janitor::clean_names() %>% 
    dplyr::select(
      -survey_id, 
      -cruise_id, 
      -haul_id
    ) %>%
    dplyr::left_join(
      x = ., 
      y = dat_surveys %>%
        dplyr::select(
          -survey_dates, 
          -year
        ) %>% 
        dplyr::distinct()
    ) %>% 
    dplyr::mutate(
      data_type = "raw"
    ) %>% 
    dplyr::mutate(
      year = date_max
    ) %>% 
    dplyr::ungroup()
    
  } else {
    dat_haul_oracleraw <- data.frame()
  }

  save(
    dat_haul_oracleraw, 
    dat_haul_api, 
    date_max, 
    file = here::here("data","backupdata.rdat")
  )

} else {
  
  ## lastdl = backup date -----------------------------------------------------
  lastdl <- 
    as.Date(
      file.info(here::here("data","backupdata.rdat"))$ctime
    )
  
  # Load data backup
  load(
    here::here("data","backupdata.rdat")
  )
  
}

#------------------------------------------------------------------------------#
############################### END DATA IMPORT ################################


# Convert from DDM to DD
ddm2dd <- function(xx){ 
  x <- 
    strsplit(
      x = as.character(xx/100), 
      split = ".", 
      fixed = TRUE
    )
  min <- 
    as.numeric(
      unlist(
        lapply(
          x, 
          `[[`, 
          1
        )
      )
    )
  deg <- 
    as.numeric(
      paste0(
        ".", 
        unlist(
          lapply(
            x, 
            `[[`, 
            2
          )
        )
      )
    )*100
  
  y <- min + deg/60
  
  return(y)
}

## Define color palette --------------------------------------------------------
pal <- colorFactor(
  viridis(
    option   = "D", 
    n        = length(unique(dat_haul_api$vessel_name)), 
    begin    = .2, 
    end      = .8), 
  ordered  = FALSE,
  domain   = levels(unique(dat_haul_api$vessel_name)),
  na.color = "black"
)

# Combined haul data -----------------------------------------------------------

dat <- 
  dplyr::bind_rows(
    dat_haul_oracleraw, 
    dat_haul_api
  )  %>% 
  dplyr::select(
    year, 
    stratum, 
    station, 
    date, 
    data_type,
    survey_definition_id,
    SRVY, 
    survey, 
    survey_dates, 
    vessel_id, 
    vessel_name, 
    vessel_color, 
    vessel_ital, 
    vessel_shape, 
    depth_m,
    surface_temperature_c,
    bottom_temperature_c,
    latitude_dd_start, 
    longitude_dd_start
    # st = surface_temperature_c, 
    # bt = bottom_temperature_c, 
    # latitude = latitude_dd_start, 
    # longitude = longitude_dd_start
  ) %>% 
  dplyr::mutate(
    survey_long = dplyr::case_when(
      SRVY == "EBS" ~ "Eastern Bering Sea", 
      SRVY == "NBS" ~ "Northern Bering Sea", 
      SRVY == "BBS" ~ "Bering Sea Slope",
      SRVY == "GOA" ~ "Gulf of Alaska", 
      SRVY == "AI" ~ "Aleutian Islands"
    ),
    .after = SRVY
  ) %>% 
  dplyr::arrange(-year)
  # dplyr::filter(
  #   !(is.na(station)) &
  #     !is.na(surface_temperature_c) &
  #     !is.na(bottom_temperature_c) & 
  #     # there shouldn't be bottom temps of 0 in the AI or GOA
  #     ((SRVY %in% c("AI", "GOA") & surface_temperature_c != 0) | (SRVY %in% c("EBS", "NBS"))) & 
  #     ((SRVY %in% c("AI", "GOA") & bottom_temperature_c != 0) | (SRVY %in% c("EBS", "NBS")))) %>% 

# Load data_dl.R shapefiles ----------------------------------------------------

load(file = here::here("data", "shp_all.rdata"))

temp_storage <- shp_all$survey.grid 

var_breaks <- c(-10, seq(from = -2, to = 8, by = 1), 50)

var_labels <- c()
for(i in 2:c(length(var_breaks))) {
  var_labels <- c(var_labels, 
                  dplyr::case_when(
                    i==2 ~ paste0("\u2264 ",# "≤ ", #
                                  var_breaks[i]), # ,"\u00B0C" <=
                    i==(length(var_breaks)) ~ paste0("> ", var_breaks[i-1]), # , "\u00B0C"
                    TRUE ~ paste0("> ",
                                  var_breaks[i-1],"\u2013",var_breaks[i]) # ,"\u00B0C" "\u00B0"
                  ))
}

var_color <- 
  viridis::viridis_pal(
    begin  = 0.2, 
    end    = 0.9, 
    option = "B"
  )(length(var_labels))

# Parse apart station and corner polygons. This allows corner stations to be
# overlayed in those years when corner station data are available, else the full
# survey grid is displayed
shp_all$survey.grid <- 
  bind_rows(
    shp_all$survey.grid %>%
      filter(
        grepl("-", station),
        is.na(comment)
      ),
    shp_all$survey.grid %>%
      filter(
        !grepl("-", station)
      )
  )

dat <- 
  left_join(
    x = dat,
    y =
      dplyr::select(
        shp_all$survey.grid,
        station,
        geometry, 
        comment
      ),
    by = c(
      join_by(station == station),
      join_by(SRVY == SRVY)
    ),
    relationship = "many-to-many"
  ) %>%
  mutate(
    bot_bin = base::cut(
      x = as.numeric(bottom_temperature_c), 
      breaks = var_breaks, 
      labels = FALSE,
      include.lowest = TRUE,
      right = FALSE
    ),
    .after = bottom_temperature_c
  ) %>%
  mutate(
    sur_bin = base::cut(
      x = as.numeric(surface_temperature_c), 
      breaks = var_breaks, 
      labels = FALSE,
      include.lowest = TRUE,
      right = FALSE
    ),
    .after = surface_temperature_c
  ) %>%
  mutate(
    bot_bin = base::factor(
      x = var_labels[bot_bin],
      levels = var_labels,
      labels = var_labels,
    ),
    sur_bin = base::factor(
      x = var_labels[sur_bin],
      levels = var_labels,
      labels = var_labels,
    )
  ) %>%
  st_as_sf()
