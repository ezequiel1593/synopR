# R/utils.R

################################################################################
##---------------- VECTORIZATION
################################################################################

#' @noRd
get_group_vector <- function(pattern, chain) {
  m <- regexpr(pattern, chain, perl = TRUE)
  matches <- rep(NA_character_, length(chain))
  found <- !is.na(m) & m != -1
  if (any(found)) {
    matches[found] <- regmatches(chain, m)
  }
  return(matches)
}

#' @noRd
get_time_obs_wind_unit_vec <- function(groups) {

  days <- as.numeric(substr(groups,1,2))
  hours <- as.numeric(substr(groups,3,4))
  iw_char <- substr(groups,5,5)
  wind_unit <- c("0" = "m/s", "1" = "m/s", "3" = "knots", "4" = "knots")[iw_char]

  res <- data.frame(Day = days, Hour = hours, Wind_speed_unit = wind_unit,
                    stringsAsFactors = FALSE, row.names = NULL)
  return(res)
}

#' @noRd
get_visibility_hcloud_and_indicators_vec <- function(groups){

  n <- length(groups)
  areNA <- is.na(groups) | groups == 'NIL'

  # iR_ind
  iR_ind <- rep(NA_real_, n)
  iR_ind[!areNA] <- as.numeric(substr(groups[!areNA],1,1))

  # iX_ind
  iX_ind <- rep(NA_real_, n)
  iX_ind[!areNA] <- as.numeric(substr(groups[!areNA],2,2))

  # Height
  h <- rep(NA_character_, n)
  h[!areNA] <- h_labels[substr(groups[!areNA],3,3)]

  # Visibility
  VV <- rep(NA_real_, n)
  VV_char <- substr(groups,4,5)
  VV_not_missing <- !areNA & VV_char != '//'

  if (any(VV_not_missing)) {

    VV_num <- rep(NA_real_, n)
    VV_num[VV_not_missing] <- as.numeric(VV_char[VV_not_missing])

    VV[VV_num  == 0] <- 99 # Less than 100 m

    cond1 <- VV_num >= 1 & VV_num <= 50
    VV[cond1] <- VV_num[cond1] * 100

    cond2 <- VV_num >= 56 & VV_num <= 80
    VV[cond2] <- (VV_num[cond2] - 50) * 1000

    cond3 <- VV_num >= 81 & VV_num <= 88
    VV[cond3] <- (VV_num[cond3] * 5000) - 370000

    cond4 <- VV_num >= 89 & VV_num <= 99

    vv_labs <- c("89" = 71000, # > 70 km
                 "90" = 49, # < 50 m
                 "91" = 50,
                 "92" = 200,
                 "93" = 500,
                 "94" = 1000,
                 "95" = 2000,
                 "96" = 4000,
                 "97" = 10000,
                 "98" = 20000,
                 "99" = 51000) # >= 50 km

    VV[cond4] <- vv_labs[as.character(VV_num[cond4])]
  }

  return(data.frame(iR_ind = iR_ind, iX_ind = iX_ind, h = h, VV = VV,
                    stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_cloud_cover_and_wind_vec <- function(groups){

  n <- length(groups)
  areNA <- is.na(groups)

  # Cloud cover
  nub <- rep(NA_real_, n)
  nub_char <- substr(groups,1,1)
  nub_not_missing <- !areNA & nub_char != '/'
  nub[nub_not_missing] <- as.numeric(nub_char[nub_not_missing])

  # Wind direction
  wind_dir <- rep(NA_real_, n)
  wind_dir_char <- substr(groups,2,3)
  wind_dir_not_missing <- !areNA & wind_dir_char != '//'
  wind_dir[wind_dir_not_missing] <- as.numeric(wind_dir_char[wind_dir_not_missing])

  # Wind speed
  wind_vel <- rep(NA_real_, n)
  wind_vel_char <- substr(groups,4,5)
  wind_vel_not_missing <- !areNA & wind_vel_char != '//'
  wind_vel[wind_vel_not_missing] <- as.numeric(wind_vel_char[wind_vel_not_missing])

  return(data.frame(nub = nub, wind_dir = wind_dir, wind_vel = wind_vel,
                    stringsAsFactors = FALSE, row.names = NULL ))
}

#' @noRd
get_temperature_vec <- function(groups){

  res <- rep(NA_real_, length(groups))
  not_missing <- !is.na(groups) # section_data functions filter out missing cases like '1////'

  if (any(not_missing)) {
    g <- groups[not_missing]
    sn <- as.numeric(substr(g, 2, 2))
    val <- as.numeric(substr(g, 3, 5)) / 10
    res[not_missing] <- val * (1 - 2 * sn)
  }

  return(res)
}

#' @noRd
get_pressure_vec <- function(groups){

  res <- rep(NA_real_, length(groups))
  pressure_char <- substr(groups,2,5)
  not_missing <- !is.na(groups) & pressure_char != "////"

  if(any(not_missing)) {
    val_p <- as.numeric(pressure_char[not_missing]) / 10
    res[not_missing] <- ifelse(val_p < 100, val_p + 1000, val_p)
  }
  return(res)
}

#' @noRd
get_pressure_or_geop_height_vec <- function(groups){ # section1_data filter out missing cases like '4////'

  n <- length(groups)
  res <- rep(NA_real_, n)
  first_two_char <- substr(groups, 1, 2)

  # Pressure
  pressure_char <- substr(groups, 2, 5)
  not_missing_p <- !is.na(groups) & (first_two_char == '40' | first_two_char == '49')

  if (any(not_missing_p)) {
    val_p <- as.numeric(pressure_char[not_missing_p]) / 10
    res[not_missing_p] <- ifelse(val_p < 100, val_p + 1000, val_p)
  }

  # GH
  height_char <- substr(groups, 3, 5)
  not_missing_gh <- !is.na(groups) & (first_two_char == '48' | first_two_char == '47' | first_two_char == '45')

  if(any(not_missing_gh)) {
    height_num <- rep(NA_real_, n)
    height_num[not_missing_gh] <- as.numeric(height_char[not_missing_gh])

    base_geopotential_map <- c("48" = 1000, "47" = 3000, "45" = 5000)
    base_vec <- base_geopotential_map[first_two_char]

    adjustment <- rep(0, n)
    cond_adj <- not_missing_gh & (first_two_char == '47' | first_two_char == '45') & height_num > 500
    adjustment[cond_adj] <- -1000

    res[not_missing_gh] <- base_vec[not_missing_gh] + adjustment[not_missing_gh] + height_num[not_missing_gh]
  }
  return(res)
}

#' @noRd
get_pressure_tendency_vec <- function(groups){

  n <- length(groups)
  areNA <- is.na(groups)

  # Charac
  cpt_char <- substr(groups,2,2)
  cpt <- ctp_labels[cpt_char]

  # Pressure tendency
  pressure_tend <- rep(NA_real_, n)
  pressure_tend_char <- substr(groups,3,5)
  not_missing_ptend <- !areNA & pressure_tend_char != '///'

  if(any(not_missing_ptend)) {
    pressure_tend[not_missing_ptend] <- as.numeric(pressure_tend_char[not_missing_ptend]) / 10

    neg <- (cpt_char == '5' | cpt_char == '6' | cpt_char == '7' | cpt_char == '8') & !areNA
    pressure_tend[neg] <- pressure_tend[neg] * -1
  }
  return(data.frame(pressure_tend,cpt, stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_precipitation_vec <- function(groups) {

  n <- length(groups)
  prec_val <- rep(NA_real_, n)
  period <- rep(NA_real_, n)
  not_missing <- !is.na(groups)

  if (any(not_missing)) {
    prec_char <- substr(groups,2,4)
    prec_val[not_missing] <- as.numeric(prec_char[not_missing])
    is_decimal <- !is.na(prec_val) & prec_val >= 991

    prec_val[prec_val == 990] <- 0.01
    prec_val[is_decimal] <- (prec_val[is_decimal] - 990) / 10

    period_label <- c("1" = 6, "2" = 12, "3" = 18, "4" = 24, "5" = 1, "6" = 2, "7" = 3, "8" = 9, "9" = 15)
    period[not_missing] <- period_label[substr(groups,5,5)[not_missing]]
  }
  return(data.frame(prec_val = prec_val, period = period, stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_present_past_weather_vec <- function(groups, iX_indicator){

  n <- length(groups)
  ww_char <- rep(NA_character_,n)
  w1_char <- rep(NA_character_,n)
  w2_char <- rep(NA_character_,n)

  are_notNA <- !is.na(groups)
  manned    <- are_notNA & !is.na(iX_indicator) & iX_indicator >= 1 & iX_indicator <= 3
  automatic <- are_notNA & !is.na(iX_indicator) & iX_indicator >= 4 & iX_indicator <= 7

  if (any(manned)) {
    ww_char[manned] <- weather_labels[substr(groups[manned],2,3)]
    w1_char[manned] <- past_weather_labels[substr(groups[manned],4,4)]
    w2_char[manned] <- past_weather_labels[substr(groups[manned],5,5)]
  }
  if (any(automatic)) {
    ww_char[automatic] <- weather_autom_labels[substr(groups[automatic],2,3)]
    w1_char[automatic] <- past_weather_autom_labels[substr(groups[automatic],4,4)]
    w2_char[automatic] <- past_weather_autom_labels[substr(groups[automatic],5,5)]
  }
  return(data.frame(ww_char = ww_char, w1_char = w1_char, w2_char = w2_char,
                    stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_cloudiness_vec <- function(groups) {

  n <- length(groups)
  are_notNA <- !is.na(groups)

  # Cloud cover
  nub <- rep(NA_real_, n)
  nub_char <- substr(groups,2,2)
  nub_not_missing <- are_notNA & nub_char != '/'
  nub[nub_not_missing] <- as.numeric(nub_char[nub_not_missing])

  # Cloud description
  CL <- rep(NA_character_, n)
  CL[are_notNA] <- low_cloud_labels[substr(groups[are_notNA],3,3)]

  CM <- rep(NA_character_, n)
  CM[are_notNA] <- medium_cloud_labels[substr(groups[are_notNA],4,4)]

  CH <- rep(NA_character_, n)
  CH[are_notNA] <- high_cloud_labels[substr(groups[are_notNA],5,5)]

  return(data.frame(nub = nub, CL = CL, CM = CM, CH = CH,
                    stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_ground_temp_vec <- function(groups) {

  n <- length(groups)
  areNA <- is.na(groups)

  state <- rep(NA_character_, n)
  sn <- rep(NA_real_, n)
  temp <- rep(NA_real_, n)

  state <- state_ground_wosnow_label[substr(groups,2,2)]

  sn_char <- substr(groups, 3, 3)
  temp_char <- substr(groups, 4, 5)

  not_missing <- sn_char != '/' & temp_char != '//' & !areNA

  if (any(not_missing)) {
    sn_val   <- as.numeric(sn_char[not_missing])
    temp_val <- as.numeric(temp_char[not_missing])
    temp[not_missing] <- temp_val * (1 - 2 * sn_val)
  }

  return(data.frame(state = state, temp = temp, stringsAsFactors = FALSE, row.names = NULL))
}

#' @noRd
get_snow_depth_vec <- function(groups) {

  n <- length(groups)
  areNA <- is.na(groups)

  state <- rep(NA_character_, n)
  snow_depth <- rep(NA_real_, n)

  # State ground
  state_char <- substr(groups,2,2)
  state <- state_ground_snow_label[state_char]

  # Snow depth
  snow_depth_char <- substr(groups, 3, 5)
  not_missing <- snow_depth_char != '///' & !areNA

  if (any(not_missing)) {
    snow_depth[not_missing] <- as.numeric(snow_depth_char[not_missing])
  }
  snow_depth[snow_depth == 997] <- 0.1
  snow_depth[snow_depth == 998 | snow_depth == 999] <- NA_real_

  return(data.frame(state = state, snow_depth = snow_depth, stringsAsFactors = FALSE, row.names = NULL))

}

#' @noRd
get_evaporation_last_24h_vec <- function(groups) {

  n <- length(groups)
  res <- rep(NA_character_, n)

  evap_char <- substr(groups, 2, 4)
  evap_type_char <- substr(groups, 5, 5)
  not_missing <- evap_char != '///' & evap_type_char != '/' & !is.na(groups)

  if (any(not_missing)) {

    values <- as.numeric(evap_char[not_missing]) / 10
    types  <- as.numeric(evap_type_char[not_missing])
    suffix <- rep("", length(values))

    is_ev <- types >= 0 & types <= 4 & !is.na(types)
    is_evt <- types >= 5 & types <= 9 & !is.na(types)

    suffix[is_ev]  <- " mm (ev)"
    suffix[is_evt] <- " mm (evt)"

    res[not_missing] <- paste0(values, suffix)

  }
  return(res)
}

#' @noRd
get_sunshine_vec <- function(groups) {

  res <- rep(NA_real_, length(groups))

  sunshine_char <- substr(groups, 3, 5)
  not_missing <- sunshine_char != '///' & !is.na(groups)

  if (any(not_missing)) {
    res[not_missing] <- as.numeric(sunshine_char[not_missing]) / 10
  }
  return(res)
}

#' @noRd
get_sunshine_last_hour_vec <- function(groups) {

  res <- rep(NA_real_, length(groups))

  sunshine_char <- substr(groups, 4, 5)
  not_missing <- sunshine_char != '//' & !is.na(groups)

  if (any(not_missing)) {
    res[not_missing] <- as.numeric(sunshine_char[not_missing]) / 10
  }
  return(res)
}

#' @noRd
get_solar_radiation_vec <- function(groups) { # Last 24 hours or last hour
  # POSITIVE NET RADIATION (0)
  # NEGATIVE NET RADIATION (1)
  # GLOBAL SOLAR RADIATION (2)
  # DIFFUSED SOLAR RADIATION (3)
  # DOWNWARD LONG-WAVE RADIATION (4) ---> NET SHORT-WAVE RADIATION if 55507/55407
  # UPWARD LONG-WAVE RADIATION (5)  ---> DIRECT SOLAR RADIATION if 55508/55408
  # SHORT-WAVE RADIATION (6)

  res <- rep(NA_real_, length(groups))

  rad_char <- substr(groups, 2, 5)
  not_missing <- rad_char != '////' & !is.na(groups)

  if (any(not_missing)) {
    res[not_missing] <- as.numeric(rad_char[not_missing])
  }
  return(res)
}

#' @noRd
get_direction_cloud_drift_vec <- function(groups) {

  dir1 <- directions_label[substr(groups, 3, 3)]
  dir2 <- directions_label[substr(groups, 4, 4)]
  dir3 <- directions_label[substr(groups, 5, 5)]

  result <- paste(dir1, dir2, dir3, sep = " - ")
  result[is.na(groups)] <- NA_character_

  return(result)
}

#' @noRd
get_cloud_elevation_direction_vec <- function(groups) {

  genera <- genera_label[substr(groups, 3, 3)]
  direction <- directions_label[substr(groups, 4, 4)]
  elevation_angle <- elevation_angle_label[substr(groups, 5, 5)]

  result <- paste(genera, direction, elevation_angle, sep = " - ")
  result[is.na(groups)] <- NA_character_

  return(result)
}

#' @noRd
get_pressure_change_last_24h_vec <- function(groups) {

  pressure_change_value <- rep(NA_real_, length(groups))

  first_two_digits <- substr(groups, 1, 2)
  pressure_char <- substr(groups, 3, 5)
  not_missing <- pressure_char != '///' & !is.na(groups)

  positives <- not_missing & first_two_digits == '58'
  negatives <- not_missing & first_two_digits == '59'

  pressure_change_value[positives] <- as.numeric(pressure_char[positives]) / 10
  pressure_change_value[negatives] <- as.numeric(pressure_char[negatives]) / -10

  return(pressure_change_value)
}

#' @noRd
get_precipitation_last_24h_vec <- function(groups) {

  res <- rep(NA_real_, length(groups))

  prec_char <- substr(groups,2,5)

  not_missing <- !is.na(groups) & prec_char != '////'

  if(any(not_missing)) {
    res[prec_char == '9999'] <- 0.01
    cond <- which(prec_char != '9999' & not_missing)
    res[cond] <- as.numeric(prec_char[cond]) / 10
  }
  return(res)
}

#' @noRd
get_cloud_layer_vec <- function(groups) {

  n <- length(groups)
  are_noNA <- !is.na(groups)

  # Oktas
  oktas <- rep(NA_character_, n)
  oktas_char <- substr(groups,2,2)
  not_visible <- oktas_char == "9" | oktas_char == "/"
  oktas[not_visible & are_noNA] <- 'Not visible'
  oktas[!not_visible & are_noNA] <- paste0(oktas_char[!not_visible & are_noNA],'/8')

  # Genera
  genera <- genera_label[substr(groups, 3, 3)]

  # Height
  h_num <- rep(NA_real_, n)
  height_char <- substr(groups,4,5)
  height_not_missing <- are_noNA & height_char != '//'

  if (any(height_not_missing)) {

    h_num[height_not_missing] <- as.numeric(height_char[height_not_missing])

    height_char[h_num  == 0] <- '< 30 m'

    cond1 <- which(h_num >= 1 & h_num <= 50)
    height_char[cond1] <- paste0(h_num[cond1] * 30, ' m')

    cond2 <- which(h_num >= 56 & h_num <= 80)
    height_char[cond2] <- paste0((h_num[cond2] * 300) - 15000, ' m')

    cond3 <- which(h_num >= 81 & h_num <= 88)
    height_char[cond3] <- paste0((h_num[cond3] * 1500) - 111000, ' m')

    cond4 <- which(h_num >= 89 & h_num <= 99)
    h_labs <- c("89" = "> 21000 m",
                "90" = "< 50 m",
                "91" = "50 to 100 m",
                "92" = "100 to 200 m",
                "93" = "200 to 300 m",
                "94" = "300 to 600 m",
                "95" = "600 to 1000 m",
                "96" = "1000 to 1500 m",
                "97" = "1500 to 2000 m",
                "98" = "2000 to 2500 m",
                "99" = "> 2500 mm or no clouds")

    height_char[cond4] <- h_labs[as.character(h_num[cond4])]

  }

  result <- paste0(oktas,' - ',genera,' - ',height_char)
  result[!are_noNA] <- NA_character_

  return(result)
}

#' @noRd
calculate_relative_humidity <- function(t, td) {
  #Magnus-Tetens Equation
  e  <- exp((17.625 * td) / (td + 243.04))
  es <- exp((17.625 * t) / (t + 243.04))
  rh <- 100 * (e / es)
  return(round(rh, 1))
}


