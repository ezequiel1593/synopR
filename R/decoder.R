
################################################################################
##---------------- VECTORIZATION
################################################################################

#' @noRd
section1_data <- function(chain) {
  n <- length(chain)
  res <- data.frame(
    iR_indicator = NA_real_, iX_indicator = NA_real_, Cloud_base_height = NA_character_, Visibility = NA_real_,
    Total_cloud_cover = NA_real_, Wind_direction = NA_real_, Wind_speed = NA_real_,

    Air_temperature = NA_real_, Dew_point = NA_real_,
    Station_pressure = NA_real_, MSLP_GH = NA_real_, Pressure_tendency = NA_real_, Charac_pressure_tend = NA_character_,
    Precipitation_S1 = NA_real_, Precip_period_S1 = NA_real_,
    Present_weather = NA_character_, Past_weather1 = NA_character_,Past_weather2 = NA_character_,
    Cloud_amount_Nh = NA_real_, Low_clouds_CL = NA_character_, Medium_clouds_CM = NA_character_, High_clouds_CH = NA_character_,

    stringsAsFactors = FALSE
  )
  res <- res[rep(1, n), ]
  rownames(res) <- NULL

  #missing_chain <- chain == 'NIL' | is.na(chain)

  # BLOCK SEPARATION
  matches <- regmatches(chain, regexec("^\\s*(\\S+)\\s+(\\S+)\\s*(.*)$", chain, perl = TRUE))

  g1_secc1_0 <- vapply(matches, function(x) if(length(x) >= 2) x[2] else NA_character_, character(1))
  g2_secc1_0  <- vapply(matches, function(x) if(length(x) >= 3) x[3] else NA_character_, character(1))
  block_secc1_1 <- vapply(matches, function(x) if(length(x) >= 4) x[4] else NA_character_, character(1))

  # GROUPS DECODING
  # Secc1_0
  res[, c("iR_indicator", "iX_indicator", "Cloud_base_height", "Visibility")] <- get_visibility_hcloud_and_indicators_vec(g1_secc1_0)
  res[, c("Total_cloud_cover", "Wind_direction", "Wind_speed")] <- get_cloud_cover_and_wind_vec(g2_secc1_0)

  # Secc1_1
  ws_99_or_more <- res$Wind_speed >= 99 & !is.na(res$Wind_speed)
  wind_speed_exced <- substr(get_group_vector("00[0-9]{3}", block_secc1_1),3,5)
  res$Wind_speed[ws_99_or_more] <- as.numeric(wind_speed_exced[ws_99_or_more]) # Handle wind_speed >= 99

  res$Air_temperature <- get_temperature_vec(get_group_vector("1[01][0-9]{3}", block_secc1_1))
  res$Dew_point <- get_temperature_vec(get_group_vector("2[01][0-9]{3}", block_secc1_1))
  res$Station_pressure <- get_pressure_vec(get_group_vector("3[0-9/]{4}", block_secc1_1))
  res$MSLP_GH <- get_pressure_or_geop_height_vec(get_group_vector("4[05789][0-9]{3}", block_secc1_1))
  res[,c('Pressure_tendency','Charac_pressure_tend')] <- get_pressure_tendency_vec(get_group_vector("5[0-9/]{4}", block_secc1_1))
  res[,c('Precipitation_S1','Precip_period_S1')] <- get_precipitation_vec(get_group_vector("6[0-9/]{4}", block_secc1_1))
  res[,c('Present_weather',
         'Past_weather1',
         'Past_weather2')] <- get_present_past_weather_vec(get_group_vector("7[0-9/]{4}", block_secc1_1), res$iX_indicator)
  res[,c('Cloud_amount_Nh',
         'Low_clouds_CL',
         'Medium_clouds_CM',
         'High_clouds_CH')] <- get_cloudiness_vec(get_group_vector("8[0-9/]{4}", block_secc1_1))

  return(res)
}

#' @noRd
get_synop_block <- function(target_flag, text_vector) {
  pattern <- paste0("(^|\\s)(", target_flag, ")(\\s|$)")
  pos <- regexpr(pattern, text_vector) # Find position
  block <- substr(text_vector, pos, pos + 11) # Indicator and the associated group
  block[pos == -1] <- NA_character_ # If not found
  return(trimws(block))
}

#' @noRd
section3_data <- function(chain, iR_indicator) {

  n <- length(chain)

  res <- data.frame(
    Max_temperature = NA_real_, Min_temperature = NA_real_, Ground_state = NA_character_,
    Ground_temperature = NA_real_, Snow_ground_state = NA_real_, Snow_depth = NA_real_, Ev_Evt = NA_character_,

    Sunshine_daily = NA_real_,
    Positive_Net_Rad_last_24h = NA_real_, Negative_Net_Rad_last_24h = NA_real_, Global_Solar_Rad_last_24h = NA_real_,
    Diffused_Solar_Rad_last_24h = NA_real_, Downward_LongWave_Rad_last_24h = NA_real_, Upward_LongWave_Rad_last_24h = NA_real_,
    ShortWave_Rad_last_24h = NA_real_, Net_ShortWave_Rad_last_24h = NA_real_, Direct_Solar_Rad_last_24h = NA_real_,

    Sunshine_last_hour = NA_real_,
    Positive_Net_Rad_last_hour = NA_real_, Negative_Net_Rad_last_hour = NA_real_, Global_Solar_Rad_last_hour = NA_real_,
    Diffused_Solar_Rad_last_hour = NA_real_, Downward_LongWave_Rad_last_hour = NA_real_, Upward_LongWave_Rad_last_hour = NA_real_,
    ShortWave_Rad_last_hour = NA_real_, Net_ShortWave_Rad_last_hour = NA_real_, Direct_Solar_Rad_last_hour = NA_real_,

    Cloud_drift_direction = NA_character_, Cloud_elevation_direction = NA_character_, Pressure_change_last_24h = NA_real_,
    Precipitation_S3 = NA_real_, Precip_period_S3 = NA_real_, Precipitation_last_24h = NA_real_,

    Cloud_layer_1 = NA_character_, Cloud_layer_2 = NA_character_, Cloud_layer_3 = NA_character_, Cloud_layer_4 = NA_character_,

    stringsAsFactors = FALSE
  )

  res <- res[rep(1, n), ]
  rownames(res) <- NULL

  # BLOCK SEPARATION
  # Blocks with 2 groups, one of which is the indicator '55407', '55408', '55507' or '55508'
  b55407 <- get_synop_block("55407", chain)
  b55408 <- get_synop_block("55408", chain)
  b55507 <- get_synop_block("55507", chain)
  b55508 <- get_synop_block("55508", chain)

  # Block radiation 24h
  pattern_24h <- "(55[012/][0-9/]{2}\\s+(.*?)(?=\\s+553|\\s+554|\\s+555|\\s+56|\\s+57|\\s+58|\\s+59|\\s+6|\\s+7|\\s+8|\\s+9|$))"
  m24 <- regexec(pattern_24h, chain, perl = TRUE)
  block_rad24h <- vapply(regmatches(chain, m24), function(x) if(length(x)>2) x[2] else NA_character_, character(1))

  # Block radiation 1h
  pattern_1h <- "(553[0-9/]{2}\\s+(.*?)(?=\\s+554|\\s+555|\\s+6|\\s+7|\\s+8|\\s+9|$))"
  m1h <- regexec(pattern_1h, chain, perl = TRUE)
  block_rad1h <- vapply(regmatches(chain, m1h), function(x) if(length(x)>2) x[2] else NA_character_, character(1))

  # All the other groups not included in the previous blocks
  block_gen <- Reduce(function(ch, bl) {
    ifelse(!is.na(bl), mapply(gsub, bl, " ", ch, fixed = TRUE), ch)
  }, list(b55407, b55408, b55507, b55508, block_rad24h, block_rad1h), init = chain)
  block_gen <- gsub("\\s+", " ", trimws(block_gen))


  # DECODING GROUPS
  # Block radiation 24h
  res$Sunshine_daily <- get_sunshine_vec(get_group_vector("55[0-9/]{3}", block_rad24h))
  res$Positive_Net_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("0[0-9/]{4}", block_rad24h))
  res$Negative_Net_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("1[0-9/]{4}", block_rad24h))
  res$Global_Solar_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("2[0-9/]{4}", block_rad24h))
  res$Diffused_Solar_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("3[0-9/]{4}", block_rad24h))
  res$Downward_LongWave_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", block_rad24h))
  res$Upward_LongWave_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("5[0-4/][0-9/]{3}", block_rad24h)) # Making an assumption: second digit is [0-4/]

  # Block 55507
  res$Net_ShortWave_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", b55507))

  # Block 55508
  res$Direct_Solar_Rad_last_24h <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", b55508))


  # Block radiation 1h
  res$Sunshine_last_hour <- get_sunshine_last_hour_vec(get_group_vector("553[0-9/]{2}", block_rad1h))
  res$Positive_Net_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("0[0-9/]{4}", block_rad1h))
  res$Negative_Net_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("1[0-9/]{4}", block_rad1h))
  res$Global_Solar_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("2[0-9/]{4}", block_rad1h))
  res$Diffused_Solar_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("3[0-9/]{4}", block_rad1h))
  res$Downward_LongWave_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", block_rad1h))
  res$Upward_LongWave_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("5[0-4/][0-9/]{3}", block_rad1h)) # Making an assumption: second digit is [0-4/]


  # Block 55407
  res$Net_ShortWave_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", b55407))

  # Block 55408
  res$Direct_Solar_Rad_last_hour <- get_solar_radiation_vec(get_group_vector("4[0-9/]{4}", b55408))

  # General block
  res$Max_temperature <- get_temperature_vec(get_group_vector("1[01][0-9]{3}", block_gen))
  res$Min_temperature <- get_temperature_vec(get_group_vector("2[01][0-9]{3}", block_gen))
  res[,c('Ground_state','Ground_temperature')] <- get_ground_temp_vec(get_group_vector("3[0-9/][01/][0-9/]{2}", block_gen))
  res[,c('Snow_ground_state','Snow_depth')] <- get_snow_depth_vec(get_group_vector("4[0-9/]{4}", block_gen))
  res$Ev_Evt <- get_evaporation_last_24h_vec(get_group_vector("5[0123][0-9/]{3}", block_gen))
  res$Cloud_drift_direction <- get_direction_cloud_drift_vec(get_group_vector("56[0-9/]{3}", block_gen))
  res$Cloud_elevation_direction <- get_cloud_elevation_direction_vec(get_group_vector("57[0-9/]{3}", block_gen))
  res$Pressure_change_last_24h <- get_pressure_change_last_24h_vec(get_group_vector("5[89][0-9/]{3}", block_gen))
  res$Precipitation_last_24h <- get_precipitation_last_24h_vec(get_group_vector("7[0-9/]{4}", block_gen))

  ## Clouds
  cloud_layer_list <- regmatches(block_gen, gregexpr("8[0-9/]{4}", block_gen))
  c1_raw <- vapply(cloud_layer_list, function(x) if(length(x) >= 1) x[1] else NA_character_, character(1))
  c2_raw <- vapply(cloud_layer_list, function(x) if(length(x) >= 2) x[2] else NA_character_, character(1))
  c3_raw <- vapply(cloud_layer_list, function(x) if(length(x) >= 3) x[3] else NA_character_, character(1))
  c4_raw <- vapply(cloud_layer_list, function(x) if(length(x) >= 4) x[4] else NA_character_, character(1))
  res$Cloud_layer_1 <- get_cloud_layer_vec(c1_raw)
  res$Cloud_layer_2 <- get_cloud_layer_vec(c2_raw)
  res$Cloud_layer_3 <- get_cloud_layer_vec(c3_raw)
  res$Cloud_layer_4 <- get_cloud_layer_vec(c4_raw)

  ## Group 6
  group6_list <- regmatches(block_gen, gregexpr("6[0-9/]{4}", block_gen))
  g6_1 <- vapply(group6_list, function(x) if(length(x) >= 1) x[1] else NA_character_, character(1))
  g6_2 <- vapply(group6_list, function(x) if(length(x) >= 2) x[2] else NA_character_, character(1))
  g6_3 <- vapply(group6_list, function(x) if(length(x) >= 3) x[3] else NA_character_, character(1))
  n_group6 <- vapply(group6_list,
                     function(x) { if (length(x) == 0 || (length(x) == 1 && is.na(x[1]))) { return(0L) } else { return(length(x)) } },
                     integer(1))

  is_rain_sec3 <- iR_indicator %in% c(0, 2)
  exists_block_rad24 <- !is.na(block_rad24h)
  exists_block_rad1h <- !is.na(block_rad1h)

  ## Evaluation of every condition
  cond3 <- which(n_group6 == 3)
  res$ShortWave_Rad_last_24h[cond3]   <- get_solar_radiation_vec(g6_1[cond3])
  res$ShortWave_Rad_last_hour[cond3] <- get_solar_radiation_vec(g6_2[cond3])
  res[cond3, c('Precipitation_S3','Precip_period_S3')] <- get_precipitation_vec(g6_3[cond3])

  cond2_A <- which(n_group6 == 2 & is_rain_sec3)
  res[cond2_A, c('Precipitation_S3','Precip_period_S3')] <- get_precipitation_vec(g6_2[cond2_A])
  res$ShortWave_Rad_last_24h[cond2_A[exists_block_rad24[cond2_A]]] <- get_solar_radiation_vec(g6_1[cond2_A[exists_block_rad24[cond2_A]]])
  res$ShortWave_Rad_last_hour[cond2_A[exists_block_rad1h[cond2_A]]] <- get_solar_radiation_vec(g6_1[cond2_A[exists_block_rad1h[cond2_A]]])

  cond2_B <- which(n_group6 == 2 & !is_rain_sec3)
  res$ShortWave_Rad_last_24h[cond2_B] <- get_solar_radiation_vec(g6_1[cond2_B])
  res$ShortWave_Rad_last_hour[cond2_B] <- get_solar_radiation_vec(g6_2[cond2_B])

  cond1_A <- which(n_group6 == 1 & is_rain_sec3)
  res[cond1_A, c('Precipitation_S3','Precip_period_S3')] <- get_precipitation_vec(g6_1[cond1_A])

  cond1_B <- which(n_group6 == 1 & !is_rain_sec3)
  res$ShortWave_Rad_last_24h[cond1_B[exists_block_rad24[cond1_B]]] <- get_solar_radiation_vec(g6_1[cond1_B[exists_block_rad24[cond1_B]]])
  res$ShortWave_Rad_last_hour[cond1_B[exists_block_rad1h[cond1_B]]] <- get_solar_radiation_vec(g6_1[cond1_B[exists_block_rad1h[cond1_B]]])

  return(res)

}

#' Decode multiple SYNOP messages
#'
#' @description
#' This function decodes a vector or data frame column of SYNOP strings
#' belonging to the same or different meteorological surface station.
#'
#' @param data A character vector, a data frame column containing raw SYNOP strings, or the exact data frame returned by \code{parse_ogimet()}.
#' @param wmo_identifier A 5-digit character string or integer representing the station WMO ID. If NULL (default), all messages are decoded.
#' @param remove_empty_cols Logical. Should columns containing only \code{NA} values be removed? Default is TRUE.
#'
#' @return A data frame where each row represents one observation time and
#' each column a decoded meteorological variable.
#' \enumerate{
#'  \item wmo_id - WMO station identifier
#'  \item Year - (from parse_ogimet())
#'  \item Day - As informed by Section 0
#'  \item Hour - As informed by Section 0
#'  \item Cloud_base_height - Lowest cloud base height, in intervals
#'  \item Visibility - In meters
#'  \item Total_cloud_cover - In oktas, 9 means 'invisible' sky by fog or other phenomenon
#'  \item Wind_direction - In tens of degree, 99 means 'variable wind direction'
#'  \item Wind_speed
#'  \item Wind_speed_unit - Either 'm/s' or 'knots'
#'  \item Air_temperature - In degrees Celsius
#'  \item Dew_point - In degrees Celsius
#'  \item Relative_humidity - As a percentage
#'  \item Station_pressure - In hPa
#'  \item MSLP_GH - Mean sea level pressure (in hPa) or geopotential height (in gpm)
#'  \item Pressure_tendency - In hPa
#'  \item Charac_pressure_tend - String, simplified decoding
#'  \item Precipitation_S1 - In mm
#'  \item Precip_period_S1 - In hours ('Precipitation_S1' fell in the last 'Precip_period_S1' hours)
#'  \item Present_weather - String, simplified decoding
#'  \item Past_weather1 - String, simplified decoding
#'  \item Past_weather2 - String, simplified decoding
#'  \item Cloud_amount_Nh - Cloud coverage from low or medium cloud, same as 'Total_cloud_cover'
#'  \item Low_clouds_CL - String, simplified decoding
#'  \item Medium_clouds_CM - String, simplified decoding
#'  \item High_clouds_CH - String, simplified decoding
#'  \item Max_temperature - In degrees Celsius
#'  \item Min_temperature - In degrees Celsius
#'  \item Ground_state - String, simplified decoding
#'  \item Ground_temperature - Integer, in degrees Celsius
#'  \item Snow_ground_state - String, simplified decoding
#'  \item Snow_depth - In cm
#'  \item Ev_Evt - Evaporation (ev) or evapotranspiration (evt), in mm
#'  \item Sunshine_daily - In hours (generally from the previous civil day)
#'  \item Positive_Net_Rad_last_24h - In J/cm^2
#'  \item Negative_Net_Rad_last_24h - In J/cm^2
#'  \item Global_Solar_Rad_last_24h - In J/cm^2
#'  \item Diffused_Solar_Rad_last_24h - In J/cm^2
#'  \item Downward_LongWave_Rad_last_24h - In J/cm^2
#'  \item Upward_LongWave_Rad_last_24h - In J/cm^2
#'  \item ShortWave_Rad_last_24h - In J/cm^2
#'  \item Net_ShortWave_Rad_last_24h - In J/cm^2
#'  \item Direct_Solar_Rad_last_24h - In J/cm^2
#'  \item Sunshine_last_hour - In hours
#'  \item Positive_Net_Rad_last_hour - In kJ/m^2
#'  \item Negative_Net_Rad_last_hour - In kJ/m^2
#'  \item Global_Solar_Rad_last_hour - In kJ/m^2
#'  \item Diffused_Solar_Rad_last_hour - In kJ/m^2
#'  \item Downward_LongWave_Rad_last_hour - In kJ/m^2
#'  \item Upward_LongWave_Rad_last_hour - In kJ/m^2
#'  \item ShortWave_Rad_last_hour - In kJ/m^2
#'  \item Net_ShortWave_Rad_last_hour - In kJ/m^2
#'  \item Direct_Solar_Rad_last_hour - In kJ/m^2
#'  \item Cloud_drift_direction - In cardinal and intercardinal directions for "low - medium - high" clouds
#'  \item Cloud_elevation_direction - String indicating genera, direction and elevation angle
#'  \item Pressure_change_last_24h - In hPa
#'  \item Precipitation_S3 - In mm
#'  \item Precip_period_S3 - In hours ('Precipitation_S3' fell in the last 'Precip_period_S3' hours)
#'  \item Precipitation_last_24h - In mm
#'  \item Cloud_layer_1 - String indicating cover, genera and height
#'  \item Cloud_layer_2 - String indicating cover, genera and height
#'  \item Cloud_layer_3 - String indicating cover, genera and height
#'  \item Cloud_layer_4 - String indicating cover, genera and height
#'  }
#'
#' @examples
#' msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
#'               "30022 40113 5//// 80005 333 10236 20128 56000 81270=")
#' synop_df <- data.frame(messages = msg)
#' decoded_data <- show_synop_data(synop_df)
#'
#' @export
show_synop_data <- function(data, wmo_identifier = NULL, remove_empty_cols = TRUE) {

  # Check "wmo_identifier" validity
  if (!is.null(wmo_identifier)) {

    if (!grepl("^[0-9]+$", as.character(wmo_identifier))) {
      stop("Invalid wmo_identifier: contains non-numeric characters (only 0-9 allowed).", call. = FALSE)
    }

    if (!grepl("^[0-9]{5}$", as.character(wmo_identifier))) {
      stop("Invalid wmo_identifier: must be a 5-digit string or integer.", call. = FALSE)
    }

    wmo_identifier <- sprintf("%05d", as.numeric(wmo_identifier))
  }

  # Handle data input
  if (is.character(data)) {
    # Is a vector
    data_input <- data.frame(Raw_synop = data)
  } else {
    # Is the dataframe from 'parse_ogimet()'
    data_input <- data
    colnames(data_input)[ncol(data_input)] <- "Raw_synop"
  }

  # Remove NILs (from Ogimet)
  is_nil <- grepl("NIL", data_input$Raw_synop)
  if (any(is_nil)) {
    warning(sum(is_nil), " NIL messages detected and removed.")
    data_input <- data_input[!is_nil, , drop = FALSE]
  }

  # SEPARATE INTO SECTIONS (header,time_obs,wmo_id,secc1_0,secc1_1,secc3)
  # Removes "=" and "=="
  data_input$Raw_synop <- sub("={1,2}$","",data_input$Raw_synop)

  # Section 0
  splited_by_group <- strsplit(data_input$Raw_synop, "\\s+")
  header   <- vapply(splited_by_group, function(x) x[1], character(1))
  time_obs <- vapply(splited_by_group, function(x) x[2], character(1))
  wmo_id   <- vapply(splited_by_group, function(x) x[3], character(1))

  # Sections 1, 2 and 3
  get_sec <- function(p, text) {
    res <- sub(paste0("^.*", p, " (.*)$"), "\\1", text)
    res[res == text] <- NA_character_
    sub(" (333|555) .*$", "", res)
  }
  secc3 <- unlist(lapply(data_input$Raw_synop, function(x) get_sec(' 333',x)))
  secc5 <- unlist(lapply(data_input$Raw_synop, function(x) get_sec(' 555',x)))
  secc1 <- unlist(lapply(data_input$Raw_synop, function(x) sub("^\\S+\\s+\\S+\\s+\\S+\\s+(.*?)( (333|555) .*|$)", "\\1", x)))

  # DF with separated synop
  synop_separado <- cbind(
    data_input[, names(data_input) != "Raw_synop", drop = FALSE],
    data.frame(header, time_obs, wmo_id, secc1, secc3, stringsAsFactors = FALSE)
  )

  # VERIFY IF WMO_IDENTIFIER IS PRESENT
  if (!is.null(wmo_identifier)) {
    found <- synop_separado$wmo_id == wmo_identifier
    if (all(!found)) {
      stop("The wmo_identifier '", wmo_identifier, "' was not found in any of the SYNOP strings.")
    }
    if (any(!found)) {
      warning(sum(!found), " message(s) do not contain the identifier '", wmo_identifier, "' and will be discarded.")
      synop_separado <- synop_separado[which(synop_separado$wmo_id == wmo_identifier),]
    }
  }

  # DATA EXTRACTION BY SECTION
  df_d0 <- get_time_obs_wind_unit_vec(synop_separado$time_obs)
  df_d1 <- section1_data(synop_separado$secc1)
  df_d3 <- section3_data(synop_separado$secc3, df_d1$iR_indicator)

  # COLLECTING DATA INTO A UNIQUE DF
  df_d1$iR_indicator <- NULL
  df_d1$iX_indicator <- NULL
  cols_to_keep <- !(names(synop_separado) %in% c("header", "time_obs", "secc1", "secc3", "iR_indicator","iX_indicator"))
  synop_final <- cbind(synop_separado[, cols_to_keep, drop = FALSE], df_d0, df_d1, df_d3)
  synop_final <- synop_final[, !(names(synop_final) %in% c("Day_Ogimet", "Hour_Ogimet")), drop = FALSE]

  # ADDING RELATIVE HUMIDITY
  synop_final$Relative_humidity <- calculate_relative_humidity(synop_final$Air_temperature, synop_final$Dew_point)

  # ORDERING COLS
  new_order <- c("wmo_id", setdiff(names(synop_final), c("wmo_id", "Relative_humidity", "Wind_speed_unit")))
  new_order <- append(new_order, "Relative_humidity", after = which(new_order == "Dew_point"))
  new_order <- append(new_order, "Wind_speed_unit", after = which(new_order == "Wind_speed"))
  synop_final <- synop_final[, new_order, drop = FALSE]
  rownames(synop_final) <- NULL

  # OPTIONAL REMOVAL OF EMPTY COLS
  if (remove_empty_cols) { synop_final <- synop_final[, !sapply(synop_final, function(x) all(is.na(x)))] }

  return(synop_final)
}

