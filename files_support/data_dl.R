#' ---------------------------------------------
#' title: Create public data 
#' author: EH Markowitz
#' start date: 2022-01-01
#' Notes: 
#' ---------------------------------------------

# 
# # Shapefiles -------------------------------------------------------------------
# 
# ## EBS + NBS  ------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "bs.all", set.crs = "auto")
# survey_area$survey.grid <- survey_area$survey.grid %>% 
#   sf::st_transform(x = ., survey_area$crs$input) %>%
#   dplyr::rename(station = STATIONID) %>%
#   dplyr::left_join(x = ., 
#                    y = haul %>%
#                      # dplyr::rename(station = stationid) %>% 
#                      dplyr::select(station, stratum) %>% 
#                      dplyr::distinct(), 
#                    by = "station") %>% 
#   dplyr::mutate(region = "Bering Sea")
# survey_area$place.labels$y[survey_area$place.labels$lab == "200 m"] <- -60032.7
# survey_area$survey.area <- survey_area$survey.area %>% 
#   dplyr::mutate(SRVY = ifelse(SURVEY == "EBS_SHELF", "EBS", "NBS"))
# shp_bs <- survey_area
# 
# ## EBS  ------------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "bs.south", set.crs = "auto")
# survey_area$survey.area <- shp_bs$survey.area %>%
#   dplyr::filter(SRVY == "EBS")
# shp_ebs <- survey_area
# 
# ## NBS  ------------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "bs.north", set.crs = "auto")
# survey_area$survey.area <- shp_bs$survey.area %>%
#   dplyr::filter(SRVY == "NBS")
# shp_nbs <- survey_area
# 
# ## AI  ------------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "ai", set.crs = "auto")
# survey_area$survey.grid <-
#   dplyr::left_join(
#     x = survey_area$survey.grid %>%
#       dplyr::rename(station = ID,
#                     stratum = STRATUM),
#     y = goa_goa_strata0 %>%
#       dplyr::filter(survey == "AI") %>%
#       dplyr::mutate(SRVY = "AI",
#                     region = stringr::str_to_title(inpfc_area),
#                     region = dplyr::case_when(
#                       region %in% c("Western Aleutians", "Chirikof") ~ "Western Aleutians",
#                       TRUE ~ region)) %>%
#       dplyr::select(SRVY, stratum, region) %>%
#       dplyr::distinct(),
#     by = "stratum")  %>%
#   dplyr::arrange(region) %>%
#   dplyr::filter(!is.na(region))
# survey_area$survey.area <- survey_area$survey.area %>%
#   dplyr::mutate(SURVEY = "AI",
#                 SRVY = "AI")
# shp_ai <- survey_area
# 
# ## GOA  ------------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "goa", set.crs = "auto")
# survey_area$survey.grid <-  
#   dplyr::left_join(
#     x = survey_area$survey.grid %>%
#       dplyr::rename(station = ID, 
#                     stratum = STRATUM),
#     y = goa_goa_strata0 %>%
#       dplyr::filter(survey == "GOA") %>%
#       dplyr::mutate(SRVY = "GOA",
#                     region = stringr::str_to_title(inpfc_area) ) %>%
#       dplyr::select(SRVY, stratum, region) %>%
#       dplyr::distinct(),
#     by = "stratum")  %>% 
#   dplyr::arrange(region) %>% 
#   dplyr::filter(!is.na(region))
# survey_area$survey.area <- survey_area$survey.area %>% 
#   dplyr::mutate(SURVEY = "GOA", 
#                 SRVY = "GOA")
# shp_goa <- survey_area
# 
# 
# ## bsslope  ------------------------------------------------------------------------
# survey_area <- akgfmaps::get_base_layers(select.region = "ebs.slope", set.crs = "auto")
# survey_area$survey.area <- survey_area$survey.area %>% 
#   dplyr::mutate(SRVY = "BSS")
# shp_bss <- survey_area
# 
# ## combine  ------------------------------------------------------------------------
# 
# ### survey area  ------------------------------------------------------------------------
# 
# shp_all$survey.area <- dplyr::bind_rows(list(
#   shp_ebs$survey.area %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "EBS"), 
#   # shp_bs$survey.area %>% 
#   #   sf::st_transform(crs = "EPSG:3338") %>% 
#   #   dplyr::mutate(SRVY = "BS"), 
#   shp_nbs$survey.area  %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "NBS"), 
#   shp_ai$survey.area %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "AI"), 
#   shp_goa$survey.area %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "GOA"), 
#   shp_bss$survey.area %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "BSS"))) %>% 
#   dplyr::select(SRVY, geometry) %>%
#   st_transform(crs = "+proj=longlat +datum=WGS84") %>% 
#   # st_transform(crs = "+proj=longlat +ellps=WGS84 +pm=-360 +datum=WGS84 +no_defs")
#   dplyr::left_join(x = ., 
#                    y = surveys %>% 
#                      dplyr::mutate(survey = stringr::str_to_title(SRVY_long), 
#                                    survey_long = paste0(survey, " Bottom Trawl Survey")), 
#                    by = "SRVY")
# 
# ### survey station points  ------------------------------------------------------------------------
# 
# shp_stn <- dplyr::bind_rows(list(
#   shp_ebs$survey.grid %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     sf::st_centroid() %>%
#     dplyr::mutate(SRVY = "EBS") %>% 
#     dplyr::select(SRVY, station = STATIONID, geometry), 
#   shp_nbs$survey.grid  %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     sf::st_centroid() %>%
#     dplyr::mutate(SRVY = "NBS") %>% 
#     dplyr::select(SRVY, station = STATIONID, geometry), 
#   shp_ai$survey.grid %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     sf::st_centroid() %>%
#     dplyr::mutate(SRVY = "AI") %>% 
#     dplyr::select(SRVY, station, stratum, region, geometry), 
#   shp_goa$survey.grid %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     sf::st_centroid() %>%
#     dplyr::mutate(SRVY = "GOA") %>% 
#     dplyr::select(SRVY, station, stratum, region, geometry)#, 
#   # shp_bss$survey.grid %>% 
#   #   sf::st_transform(crs = "EPSG:3338") %>% 
#   #   sf::st_centroid() %>% 
#   #   dplyr::mutate(SRVY = "BSS"))
#   )) %>% 
#   st_transform(crs = "+proj=longlat +datum=WGS84") %>% 
#   # st_transform(crs = "+proj=longlat +ellps=WGS84 +pm=-360 +datum=WGS84 +no_defs")
#   dplyr::left_join(x = ., 
#                    y = surveys %>% 
#                      dplyr::mutate(survey = stringr::str_to_title(SRVY_long), 
#                                    survey_long = paste0(survey, " Bottom Trawl Survey")), 
#                    by = "SRVY")
# 
# shp_stn <- shp_stn %>% 
#   dplyr::bind_cols(shp_stn %>% 
#                      st_coordinates() %>% 
#                      data.frame()) %>% 
#   dplyr::rename(lon = X, 
#                 lat = Y) 
# 
# ### survey stratum areas ------------------------------------------------------------------------
# 
# shp_strat <- dplyr::bind_rows(list(
#   shp_bs$survey.strata %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "NEBS") %>% 
#     dplyr::rename(STRATUM = Stratum) %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)), 
#   shp_ebs$survey.strata %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "EBS") %>% 
#     dplyr::rename(STRATUM = Stratum) %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)), 
#   shp_nbs$survey.strata  %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "NBS") %>% 
#     dplyr::rename(STRATUM = Stratum) %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)), 
#   shp_ai$survey.strata %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "AI") %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)), 
#   shp_goa$survey.strata %>% 
#     sf::st_transform(crs = "EPSG:3338") %>% 
#     dplyr::mutate(SRVY = "GOA") %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)), 
#   shp_bss$survey.strata %>%
#     sf::st_transform(crs = "EPSG:3338") %>%
#     dplyr::mutate(SRVY = "BSS") %>% 
#     dplyr::mutate(STRATUM = as.character(STRATUM)))
#   )  %>% 
#   dplyr::select(SRVY, stratum = STRATUM, geometry) %>% 
#   st_transform(crs = "+proj=longlat +datum=WGS84") %>% 
#   # st_transform(crs = "+proj=longlat +ellps=WGS84 +pm=-360 +datum=WGS84 +no_defs")
#   dplyr::left_join(x = ., 
#                    y = surveys %>% 
#                      dplyr::mutate(survey = stringr::str_to_title(SRVY_long), 
#                                    survey_long = paste0(survey, " Bottom Trawl Survey")), 
#                    by = "SRVY")
# 
# save(shp_all$survey.area, shp_stn, shp_strat, file = here::here("data", "shp.rdata"))
# 
# 
# #### NEW AND IMPROVDED, BUT NOT YET INTEGRATED ---------------------------------
# 
# # Load shape files -------------------------------------------------------------
# 
# 
# 
# Download oracle data ----------------------------------------------------------

# Connect to oracle ------------------------------------------------------------

PKG <- c("magrittr", "readr", "dplyr", "janitor")

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {
    install.packages(p, verbose = FALSE)
    require(p,character.only = TRUE)}
}

if (file.exists("Z:/Projects/ConnectToOracle.R")) {
  source("Z:/Projects/ConnectToOracle.R")
  channel <- channel
} else { # For those without a ConnectToOracle file
  # # library(devtools)
  # # devtools::install_github("afsc-gap-products/gapindex")
  # library(gapindex)
  # channel <- gapindex::get_connected()

  # or

  library(rstudioapi)
  library(RODBC)
  channel <- odbcConnect(dsn = "AFSC",
                         uid = rstudioapi::showPrompt(title = "Username",
                                                      message = "Oracle Username", default = ""),
                         pwd = rstudioapi::askForPassword("Enter Password"),
                         believeNRows = FALSE)
}


locations<-c(
  "GAP_PRODUCTS.AKFIN_AREA",
  "GAP_PRODUCTS.AKFIN_STRATUM_GROUPS", 
  "GAP_PRODUCTS.AKFIN_HAUL",
  "GAP_PRODUCTS.AKFIN_CRUISE"
)

error_loading <- c()
for (i in 1:length(locations)){
  print(locations[i])

  a <- RODBC::sqlQuery(channel = channel,
                       query = paste0("SELECT *
    FROM ", locations[i], "
    FETCH FIRST 1 ROWS ONLY;"))

  end0 <- c()

  start0 <- ifelse(!("START_TIME" %in% names(a)),
                   "*",
                   paste0(paste0(names(a)[names(a) != "START_TIME"], sep = ",", collapse = " "),
                          " TO_CHAR(START_TIME,'MM/DD/YYYY HH24:MI:SS') START_TIME "))

  a <- RODBC::sqlQuery(channel = channel,
                       query = paste0("SELECT ", start0, " FROM ", locations[i], end0, "; "))

  if (is.null(nrow(a))) { # if (sum(grepl(pattern = "SQLExecDirect ", x = a))>1) {
    error_loading <- c(error_loading, locations[i])
  } else {
    
    assign(x = paste0(tolower(gsub(pattern = '.',
                                              replacement = "_",
                                              x = locations[i],
                                              fixed = TRUE)), "0"), 
           value = a %>% 
             janitor::clean_names())
    
    # write.csv(x = a,
    #           here::here("data",
    #                      paste0(tolower(gsub(pattern = '.',
    #                                          replacement = "_",
    #                                          x = locations[i],
    #                                          fixed = TRUE)),
    #                             ".csv")))
  }
  remove(a)
}
error_loading

# Wrangle data -----------------------------------------------------------------

# Wrangle gap_products tables to bind to shapefiles

# Find the correct design year to use for each survey

maxyr <- as.numeric(format(Sys.Date(), format = "%Y"))

dat_design_year <- gap_products_akfin_area0 %>% 
  dplyr::filter(design_year <= maxyr) %>% 
  dplyr::group_by(survey_definition_id) %>% 
  dplyr::summarise(design_year = max(design_year, na.rm = TRUE)) 

# Summarize stratums for each survey

dat_areas <- gap_products_akfin_area0  %>% 
  # find the most up to date design_year's
  dplyr::filter(
    eval(parse(text=paste0(
      "(survey_definition_id == ", dat_design_year$survey_definition_id, 
      " & ", "design_year == ", dat_design_year$design_year, ") ", 
      collapse = " | ")))) %>%
  # dplyr::filter((survey_definition_id %in% c(52, 47) & area_type %in% c("INPFC", "STRATUM")) | 
  #                 (survey_definition_id %in% c(143, 98, 78) & area_type == "STRATUM")) %>% 
  dplyr::filter(area_type %in% c("STRATUM", "INPFC")) %>% 
  dplyr::mutate(#area_name = stringr::str_to_title(inpfc_area),
    area_name = dplyr::case_when(
      area_name %in% c("Western Aleutians", "Chirikof") ~ "Western Aleutians",
      TRUE ~ area_name)
  ) %>% 
  dplyr::select(survey_definition_id, area_id, area_type, area_name, design_year) 

dat_areas <- dplyr::bind_rows(
  dat_areas %>% 
    dplyr::mutate(stratum = area_id) %>%
    dplyr::filter(!(survey_definition_id %in% c(47, 52)) & 
                    area_type == "STRATUM"), 
  gap_products_akfin_stratum_groups0 %>% 
    dplyr::filter(
      eval(parse(text=paste0(
        "(survey_definition_id == ", dat_design_year$survey_definition_id, 
        " & ", "design_year == ", dat_design_year$design_year, ") ", 
        collapse = " | ")))) %>%
    dplyr::filter(survey_definition_id %in% c(52, 47)) %>% 
    dplyr::filter(area_id %in% 
                    unique(dat_areas$area_id[dat_areas$area_type == "INPFC"])) %>%
    # dplyr::select(-design_year) %>% 
    dplyr::left_join(dat_areas %>% 
                       dplyr::filter(area_type == "INPFC") )) 

# Summarize stratums and stations for each survey
# 
# Because there is no nice, wholistic gap_products.stations (or similar) table, I need to summarize this from the the haul table. Hoping to create a stations table in the next round of gap_products dev. 

dat_survey_design <- dplyr::left_join(
  gap_products_akfin_haul0 %>% 
    dplyr::select(station, stratum, cruisejoin) %>% 
    dplyr::distinct(), 
  gap_products_akfin_cruise0 %>% 
    dplyr::select(survey_definition_id, survey_name, cruisejoin) %>% 
    dplyr::distinct()) %>% 
  dplyr::select(-cruisejoin) %>% 
  dplyr::distinct() %>%
  dplyr::left_join(dat_areas) %>%
  dplyr::mutate(
    SRVY = dplyr::case_when(
      survey_definition_id == 98 ~ "EBS",
      survey_definition_id == 143 ~ "NBS",
      survey_definition_id == 78 ~ "BSS",
      survey_definition_id == 47 ~ "GOA",
      survey_definition_id == 52 ~ "AI"))

# Load shapefiles --------------------------------------------------------------

# Pull available shape data for each survey from `akgfmaps`

crs_out <- "EPSG:3338"

shp_bs <- akgfmaps::get_base_layers(select.region = "bs.all", set.crs = "auto")
shp_bs_c <- akgfmaps::get_base_layers(select.region = "bs.all", set.crs = "auto", 
                                      include.corners = TRUE)
shp_ebs <- akgfmaps::get_base_layers(select.region = "bs.south", set.crs = "auto")
shp_ebs_c <- akgfmaps::get_base_layers(select.region = "bs.south", set.crs = "auto", 
                                       include.corners = TRUE)
shp_nbs <- akgfmaps::get_base_layers(select.region = "bs.north", set.crs = "auto")
shp_ai <- akgfmaps::get_base_layers(select.region = "ai", set.crs = "auto")
shp_ai$survey.strata$Stratum <- shp_ai$survey.strata$STRATUM
shp_goa <- akgfmaps::get_base_layers(select.region = "goa", set.crs = "auto")
shp_goa$survey.strata$Stratum <- shp_goa$survey.strata$STRATUM
shp_bss <- akgfmaps::get_base_layers(select.region = "ebs.slope", set.crs = "auto")

## Everything will be saved in this `shp_all` object
# 
# Wrangle shapefiles together so they are in the same object, and have the same column/row properties
# 
# - Here, I am removing the bs.all specific stuff (where I can) because I am hoping it is redundant to NBS and EBS unioned, and can just be selected together by the user


## Survey plot lat and lon breaks (list) ---------------------------------------

# > This is shared across all survey areas. For plotting purposes, you don't actually need survey-specific breaks. You can provide as many breaks as you want and it will match the appropriate break and spot
# 
# > A case could be made that this is not necesary to include in the object, but it also doesn't hurt to have. 

shp_all <- list()

shp_all$lon.breaks <- c(160, 165, 170,  175, -180, -175, -170, -165, -160, -155, -150, -145, -140, -135, -130, -125, -120)
shp_all$lat.breaks <- seq(from = 40, to = 70, by = 2)

## Land (polygons) -------------------------------------------------------------

shp_all$akland <- shp_bs$akland %>%
  sf::st_transform(crs = crs_out) %>% 
  dplyr::rename(name = DESC_)

shp_all$akland$name[2] <- "Alaska"

## Survey area (polygons) ------------------------------------------------------

shp_all$survey.area <- dplyr::bind_rows(list(
  ## removing the bs.all because I am hoping it is redundant to NBS and EBS unioned, 
  ## and can just be selected together by the user
  # shp_bs$survey.area %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "BS", 
  #                 comment = ifelse(SURVEY == "EBS_SHELF", "EBS", "NBS")),
  shp_ebs$survey.area %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "EBS"),
  shp_nbs$survey.area  %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "NBS"),
  shp_ai$survey.area %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "AI"),
  shp_goa$survey.area %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "GOA"),
  shp_bss$survey.area %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "BSS"))) %>%
  dplyr::select(SRVY, #comment, 
                geometry)  %>%
  dplyr::left_join(
    y = dat_survey_design %>%
      dplyr::select(survey_definition_id, SRVY, design_year) %>% # because EBS and NBS can just be called together
      dplyr::distinct()) %>% 
  dplyr::relocate(survey_definition_id, SRVY) %>%
  dplyr::mutate(
    survey_long = dplyr::case_when(
      SRVY == "EBS" ~ "Eastern Bering Sea",  
      SRVY == "NBS" ~ "Northern Bering Sea",
      SRVY == "AI" ~ "Aleutian Islands", 
      SRVY == "GOA" ~ "Gulf of Alaska",  
      SRVY == "BSS" ~ "Bering Sea Slope"
    )
  )

## Graticules (line) -----------------------------------------------------------

temp <- dplyr::bind_rows(list(
  shp_bs$graticule %>%
    sf::st_transform(crs = crs_out), 
  shp_goa$graticule %>%
    sf::st_transform(crs = crs_out), 
  shp_ai$graticule %>%
    sf::st_transform(crs = crs_out))) %>% 
  dplyr::select(degree, type, degree_label, angle_start, angle_end, geometry) %>%
  dplyr::distinct() %>% 
  dplyr::arrange(degree)

# find duplicates
temp0 <- c()
for (i in unique(temp$degree)) {
  temp0 <- dplyr::bind_rows(
    temp0, 
    temp %>% 
      dplyr::filter(degree == i) %>% 
      head(1)) # take first of duplicate
}

shp_all$graticule <- temp0

## Survey strata (polygons) ----------------------------------------------------

# Stratum
shp_all$survey.strata <- dplyr::bind_rows(list(
  ## removing the bs.all because I am hoping it is redundant to NBS and EBS unioned, 
  ## and can just be selected together by the user
  # shp_bs_c$survey.strata %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "BS",
  #                 comment = "corner",
  #                 survey_definition_id = ifelse(SURVEY == "EBS_SHELF", 98, 143),
  #                 stratum = as.numeric(Stratum)) %>% 
  #   dplyr::select(-Stratum),
  # shp_bs$survey.strata %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "BS", 
  #                 survey_definition_id = ifelse(SURVEY == "EBS_SHELF", 98, 143),
  #                 stratum = as.numeric(Stratum)) %>% 
  # dplyr::select(-Stratum),
  # shp_ebs_c$survey.strata %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "EBS",
  #                 comment = "corner", 
  #                 survey_definition_id = 98,
  #                 stratum = as.numeric(Stratum)) %>% 
  #   dplyr::select(-Stratum),
  shp_ebs$survey.strata %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "EBS", 
                  survey_definition_id = 98,
                  stratum = as.numeric(Stratum)) %>% 
    dplyr::select(-Stratum),
  shp_nbs$survey.strata  %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "NBS", 
                  survey_definition_id = 143,
                  stratum = as.numeric(Stratum)) %>% 
    dplyr::select(-Stratum),
  shp_ai$survey.strata %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "AI", 
                  survey_definition_id = 52,
                  stratum = as.numeric(STRATUM)) %>% 
    dplyr::select(-STRATUM),
  shp_goa$survey.strata %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "GOA",
                  survey_definition_id = 47,
                  stratum = as.numeric(STRATUM)) %>% 
    dplyr::select(-STRATUM, -Stratum),
  shp_bss$survey.strata %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "BSS", 
                  survey_definition_id = 78,
                  stratum = as.numeric(STRATUM)) %>% 
    dplyr::select(-STRATUM))) %>%
  dplyr::select(SRVY, survey_definition_id, area_id = stratum, geometry) %>%
  # dplyr::left_join(y = dat_survey_design %>%
  #                    dplyr::select(stratum, SRVY, survey, survey, survey_definition_id) %>% 
  #                    dplyr::distinct()) %>% 
  dplyr::left_join(y = dat_areas) %>% # , relationship = "many-to-many"
  dplyr::relocate(survey_definition_id, SRVY)

# Viz
x <- shp_all$survey.strata

## Survey station grids (polygon) ----------------------------------------------

shp_all$survey.grid <- dplyr::bind_rows(list(
  
  ## removing the bs.all because I am hoping it is redundant to NBS and EBS unioned, 
  ## and can just be selected together by the user
  
  # shp_bs_c$survey.grid %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "BS", 
  #                 comment = "corner",
  #                 station = STATIONID) %>% 
  #   dplyr::left_join(y = dat_survey_design %>% 
  #                      dplyr::filter(survey_definition_id %in% c(98, 143)) %>% 
  #                      dplyr::select(station, stratum, survey_definition_id) %>% 
  #                      dplyr::distinct()),
  # shp_bs$survey.grid %>%
  #   sf::st_transform(crs = crs_out) %>%
  #   dplyr::mutate(SRVY = "BS", 
  #                 station = STATIONID) %>% 
  #   dplyr::left_join(y = dat_survey_design %>% 
  #                      dplyr::filter(survey_definition_id %in% c(98, 143)) %>% 
  #                      dplyr::select(station, stratum, survey_definition_id) %>% 
  #                      dplyr::distinct()),
  
  shp_ebs_c$survey.grid %>%
    sf::st_transform(crs = crs_out) %>%
    # dplyr::filter(STATIONID %in% setdiff(shp_ebs_c$survey.grid$STATIONID, shp_ebs$survey.grid$STATIONID)) %>% 
    dplyr::mutate(SRVY = "EBS", 
                  design_year = 2019, 
                  comment = "corner",
                  station = STATIONID) %>% 
    dplyr::left_join(y = dat_survey_design %>% 
                       dplyr::filter(survey_definition_id %in% c(98)) %>% 
                       dplyr::select(SRVY, station, stratum, survey_definition_id) %>% 
                       dplyr::distinct()),
  shp_ebs$survey.grid %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "EBS", 
                  station = STATIONID) %>% 
    dplyr::left_join(y = dat_survey_design %>% 
                       dplyr::filter(survey_definition_id %in% c(98)) %>% 
                       dplyr::select(SRVY, station, stratum, survey_definition_id) %>% 
                       dplyr::distinct()),
  shp_nbs$survey.grid  %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "NBS", 
                  station = STATIONID) %>% 
    dplyr::left_join(y = dat_survey_design %>% 
                       dplyr::filter(survey_definition_id %in% c(143)) %>% 
                       dplyr::select(SRVY, station, stratum, survey_definition_id) %>% 
                       dplyr::distinct()),
  shp_ai$survey.grid %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "AI", 
                  survey_definition_id = 52, 
                  station = ID, 
                  stratum = STRATUM) %>% 
    dplyr::left_join(y = dat_survey_design %>% 
                       dplyr::filter(survey_definition_id %in% c(52)) %>% 
                       dplyr::select(SRVY, station, stratum) %>% 
                       dplyr::distinct()),
  shp_goa$survey.grid %>%
    sf::st_transform(crs = crs_out) %>%
    dplyr::mutate(SRVY = "GOA", 
                  survey_definition_id = 47, 
                  station = ID, 
                  stratum = STRATUM) %>% 
    dplyr::left_join(y = dat_survey_design %>% 
                       dplyr::filter(survey_definition_id %in% 47) %>% 
                       dplyr::select(SRVY, station, stratum) %>% 
                       dplyr::distinct()))) %>% 
  dplyr::select(survey_definition_id, SRVY, stratum, station, geometry, comment)  %>%
  dplyr::left_join(y = dat_areas, relationship = "many-to-many")

# Viz
x <- shp_all$survey.grid

## Ocean bathymetry (lines) ----------------------------------------------------

shp_all$bathymetry <- dplyr::bind_rows(list(
  shp_bs$bathymetry %>% 
    dplyr::mutate(SRVY = "BS") %>%
    sf::st_transform(crs = crs_out),
  shp_ebs$bathymetry %>% 
    dplyr::mutate(SRVY = "EBS") %>%
    sf::st_transform(crs = crs_out),
  shp_nbs$bathymetry %>% 
    dplyr::mutate(SRVY = "NBS") %>%
    sf::st_transform(crs = crs_out),
  shp_bss$bathymetry %>% 
    dplyr::mutate(SRVY = "BSS") %>%
    sf::st_transform(crs = crs_out),
  shp_goa$bathymetry %>% 
    dplyr::mutate(SRVY = "GOA") %>%
    sf::st_transform(crs = crs_out),
  shp_ai$bathymetry %>% 
    dplyr::mutate(SRVY = "AI") %>%
    sf::st_transform(crs = crs_out)
)) %>% 
  dplyr::select(geometry, SRVY, meters = METERS) %>% 
  dplyr::left_join(y = dat_survey_design %>%
                     dplyr::select(SRVY, survey_definition_id) %>%
                     dplyr::distinct()) 

# Assuming they bathymetry feature can be shared across surveys, I would summarize this feature like this: 
shp_all$bathymetry <- shp_all$bathymetry %>% 
  dplyr::select(-SRVY, -survey_definition_id) %>% 
  dplyr::distinct() %>%
  sf::st_union(by_feature = TRUE)

## Plot lables (data.frame) ----------------------------------------------------

shp_all$place.labels = shp_ebs$place.labels %>% 
  dplyr::mutate(angle = ifelse(lab == "U.S.-Russia Maritime Boundary", 45, 0)) %>% 
  sf::st_as_sf(coords = c("x", "y"),
               remove = FALSE,
               crs = crs_out) %>% 
  dplyr::select(-x, -y, -region) %>%
  
  # add lat lon for easy user-finding
  dplyr::bind_cols(y = shp_ebs$place.labels %>% 
                     sf::st_as_sf(coords = c("x", "y"),
                                  remove = FALSE,
                                  crs = crs_out) %>% 
                     sf::st_transform(crs = "+proj=longlat") %>% 
                     sf::st_coordinates() %>% 
                     data.frame() %>% 
                     dplyr::rename(latitude_dd = Y, 
                                   longitude_dd = X)) 

### Place names ----------------------------------------------------------------

shp_all$place.labels = data.frame(
  type = c("islands", "islands", "islands", "islands", 
           "mainland", "mainland", "mainland", 
           "convention line", "peninsula", 
           "survey", "survey", "survey", "survey", "survey", 
           "bathymetry", "bathymetry", "bathymetry"), 
  lab = c("Pribilof Isl.", "Nunivak", "St. Matthew", "St. Lawrence", 
          "Alaska", "Russia", "Canada", 
          "U.S.-Russia Maritime Boundary", "Alaska Peninsula", 
          "Aleutian\nIslands", "Gulf of\nAlaska", 
          "Bering\nSea\nSlope", "Eastern\nBering Sea", "Northern\nBering Sea", 
          "200 m", "100 m", "50 m"), 
  angle = c(0, 0, 0, 0, 0, 0, 0, 30, 45, 0, 0, 0, 0, 0, 0, 0, 0), 
  latitude_dd = c(57.033348, 60.7, 61, 64.2, 
                  62.296686, 62.798276, 63.722890, 
                  62.319419, 56.352495, 
                  50.651569, 58.034767, 
                  56, 57.456912, 63.905936, 
                  58.527, 58.2857, 58.504532), 
  longitude_dd = c(-167.767168, -168, -174, -170.123016, 
                   -157.377210, 173.205231, -136.664024, 
                   -177.049063, -159.029430, 
                   174, -144, 
                   -176, -162, -165, 
                   -168, -172.5, -174.714527)) %>%
  sf::st_as_sf(coords = c("longitude_dd", "latitude_dd"), 
               remove = FALSE,
               crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") %>%
  sf::st_transform(crs = crs_out) 

# Save shapefile ---------------------------------------------------------------

save(shp_all, file = here::here("data", "shp_all.rdata"))



