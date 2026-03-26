# R/utils.R

#' Internal "not in" operator
#' @noRd
`%nin%` <- Negate(`%in%`)

#' @noRd
check_group <- function(group) {
  if (is.na(group) || group == "") return(NULL)
  if (grepl("[^0-9/=]", group)) {
    message(group,' contains disallowed character. NULL returned.') ; return(NULL) }
  if (nchar(group) != 5) {
    # Some strings have 6 characters because of the final "=", now this function is aware of that
    has_equal_sign <- endsWith(group, '=')
    if (has_equal_sign) {
      group <- sub('=','', group)
    } else {
      message(group,' is not a 5-digits group. Null returned.') ; return(NULL)
    }
  }
  return(group)
}

#' @noRd
get_time_obs_wind_unit <- function(group) {
  res <- data.frame(Day = NA_real_, Hour = NA_real_, Wind_speed_unit = NA_character_, stringsAsFactors = FALSE)
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(res) }
  res$Day <- as.numeric(substr(checked_group,1,2))
  res$Hour <- as.numeric(substr(checked_group,3,4))
  iw_char <- substr(checked_group,5,5)
  wind_unit <- c("0" = "m/s", "1" = "m/s", "3" = "knots", "4" = "knots")[iw_char]
  if (!is.na(wind_unit)) { res$Wind_speed_unit <- wind_unit }
  return(res)
}

#' @noRd
get_visibility_hcloud_and_indicators <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(rep(NA_real_, 3)) }
  iR_ind <- as.numeric(substr(checked_group,1,1))
  h_char <- substr(checked_group,3,3)
  VV_char <- substr(checked_group,4,5)
  h <- ifelse(h_char == "/", NA_real_, as.numeric(h_char))
  VV <- ifelse(VV_char == "//", NA_real_, as.numeric(VV_char))
  return(c(iR_ind,h,VV))
}

#' @noRd
get_cloud_cover_and_wind <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(rep(NA_real_, 3)) }
  nub_char <- substr(checked_group,1,1)
  wind_dir_char <- substr(checked_group,2,3)
  wind_vel_char <- substr(checked_group,4,5)
  nub <- ifelse(nub_char == "/", NA_real_, as.numeric(nub_char))
  wind_dir <- ifelse(wind_dir_char == "//", NA_real_, as.numeric(wind_dir_char))
  wind_vel <- ifelse(wind_vel_char == "//", NA_real_, as.numeric(wind_vel_char))
  return(c(nub, wind_dir, wind_vel))
}

#' @noRd
get_temperature <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (checked_group == '1////' | checked_group == '2////') {return(NA_real_)}
  first_two_char <- substr(checked_group,1,2)
  if (!(first_two_char == '10' || first_two_char == '11' ||
        first_two_char == '20' || first_two_char == '21')) {
    message('Temperature data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)
  }
  sn <- as.numeric(substr(checked_group, 2, 2))
  value <- as.numeric(substr(checked_group,3,5)) / 10
  return(value * (1 - 2 * sn))
}

#' @noRd
get_pressure <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (substr(checked_group,1,1) != "3") { message('Pressure data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)}
  pressure_char <- substr(checked_group,2,5)
  if (pressure_char == '////') { return(NA_real_) }
  pre_resultado <- as.numeric(pressure_char) / 10
  resultado <- ifelse(pre_resultado > 100, pre_resultado, pre_resultado + 1000)
  return(resultado)
}

#' @noRd
get_pressure_or_geop_height <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (checked_group == '4////') {return(NA_real_)}

  first_two_char <- substr(checked_group,1,2)
  if (!(first_two_char == '40' || first_two_char == '41' ||
        first_two_char == '42' || first_two_char == '45' ||
        first_two_char == '47' || first_two_char == '48' ||
        first_two_char == '49')) {
    message('MSLP or geopotential height data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)
  }

  if (first_two_char == '40' | first_two_char == '49') {
    pressure_char <- substr(checked_group,2,5)
    if (pressure_char == '////') { return(NA_real_) }
    pre_resultado <- as.numeric(pressure_char) / 10
    resultado <- ifelse(pre_resultado > 100, pre_resultado, pre_resultado + 1000)
    return(resultado)
  } else {
    base_geopotential <- switch(first_two_char, "48" = 1000, "47" = 3000, "45" = 5000, NA_real_)
    if (is.na(base_geopotential)) return(NA_real_)
    height_char <- substr(checked_group, 3, 5)
    if (height_char == '///') return(NA_real_)

    adjustment <- ifelse(first_two_char == "48", 0, ifelse(height_char > 500, -1000, 0))
    result <- base_geopotential + adjustment + as.numeric(height_char)
    return(result)
  }
}

#' @noRd
get_present_past_weather <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 3))}
  if (substr(checked_group,1,1) != "7") { message('Present or past weather data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 3)) }
  ww_char <- substr(checked_group,2,3)
  w1_char <- substr(checked_group,4,4)
  w2_char <- substr(checked_group,5,5)
  ww <- ifelse(ww_char == "//", NA_real_, as.numeric(ww_char))
  w1 <- ifelse(w1_char == "/", NA_real_, as.numeric(w1_char))
  w2 <- ifelse(w2_char == "/", NA_real_, as.numeric(w2_char))
  return(c(ww,w1,w2))
}

#' @noRd
get_precipitation <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  if (substr(checked_group,1,1) != 6) { message('Precipitation data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  prec <- as.numeric(substr(checked_group,2,4))
  prec_val <- ifelse(prec < 989, prec, ifelse(prec == 990, 0.01 ,(prec - 990)/10))
  period <- switch(substr(checked_group,5,5), "1" = 6, "2" = 12, "3" = 18, "4" = 24,
                   "5" = 1, "6" = 2, "7" = 3, "8" = 9, "9" = 15)
  return(c(prec_val, period))
}

#' @noRd
get_cloudiness <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 4))}
  broken <- strsplit(checked_group, "")[[1]]
  result <- as.numeric(gsub("/", "10", broken, fixed = TRUE))
  if (result[1] != 8) { message('Cloud data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 4)) }
  return(result[2:5])
}

#' @noRd
get_ground_temp <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  if (substr(checked_group,1,1) != "3") { message('Ground temperature data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  if (checked_group == '3////') {return(rep(NA_real_, 2))}
  state_char <- substr(checked_group,2,2)
  state <- ifelse(state_char == '/', NA_real_, as.numeric(state_char))
  if (substr(checked_group,3,5) == '///') {return(c(state,NA_real_))}
  sign <- as.numeric(substr(checked_group,3,3))
  temp <- as.numeric(substr(checked_group,4,5)) * ifelse(sign == 0, 1, -1)
  return(c(state, temp))
}

#' @noRd
get_snow_depth <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  if (substr(checked_group,1,1) != 4) { message('Snow depth data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  state_char <- substr(checked_group,2,2)
  state <- ifelse(state_char == '/', NA_real_, as.numeric(state_char))
  snow_depth <- as.numeric(substr(checked_group,3,5))
  if (snow_depth == 997) { snow_depth <- 0.1 } # IMPORTANT ASSUMPTION (997 = less than 0.5 cm)
  if (snow_depth == 998 | snow_depth == 999) { snow_depth <- NA_real_ }
  return(c(state,snow_depth))
}

#' @noRd
get_evaporation_last_24h <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_character_)}
  first_two_digits <- substr(checked_group, 1, 2)
  if (!(first_two_digits == '50' || first_two_digits == '51' ||
        first_two_digits == '52' || first_two_digits == '53')) {
    message('Evaporation or evapotranspiration cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_character_)
  }
  evap_char <- substr(checked_group, 2, 4)
  if (evap_char == '///') return(NA_character_)
  evap_value <- as.numeric(evap_char) / 10

  evap_type_char <- substr(checked_group, 5, 5)
  if (evap_char == '/') return(NA_character_)
  evap_type <- ifelse(as.numeric(evap_type_char >= 0 | as.numeric(evap_type_char) <= 4),
                      ' mm (ev)', ' mm (evt)')
  rdo <- paste0(evap_value, evap_type)
  return(rdo)
}

#' @noRd
get_sunshine <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (substr(checked_group, 1, 2) != '55') { message('Daily sunshine hours cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  sunshine_char <- substr(checked_group, 3, 5)
  if (sunshine_char == '///') return(NA_real_)
  sunshine_hours <- as.numeric(sunshine_char) / 10
  return(sunshine_hours)
}

#' @noRd
get_sunshine_last_hour <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (substr(checked_group, 1, 3) != '553') { message('Hourly sunshine cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  sunshine_char <- substr(checked_group, 4, 5)
  if (sunshine_char == '//') return(NA_real_)
  sunshine_hours <- as.numeric(sunshine_char) / 10
  return(sunshine_hours)
}

#' @noRd
get_solar_radiation <- function(group) { # Last 24 hours or last hour
  # POSITIVE NET RADIATION (0)
  # NEGATIVE NET RADIATION (1)
  # GLOBAL SOLAR RADIATION (2)
  # DIFFUSED SOLAR RADIATION (3)
  # DOWNWARD LONG-WAVE RADIATION (4) ---> NET SHORT-WAVE RADIATION if 55507/55407
  # UPWARD LONG-WAVE RADIATION (5)  ---> DIRECT SOLAR RADIATION if 55508/55408
  # SHORT-WAVE RADIATION (6)
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  #first_digit <- substr(checked_group, 1, 1)
  #if (first_digit != '2') { message('Solar radiation cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  sr_char <- substr(checked_group, 2, 5)
  if (sr_char == '////') return(NA_real_)
  return(as.numeric(sr_char))
}

#' @noRd
get_direction_clouds <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (substr(checked_group, 1, 2) != '56') { message('Direction of cloud drift cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  directions_char <- substr(checked_group, 3, 5)
  digits <- strsplit(directions_char, "")[[1]]

  map_directions <- c(
    "0" = "Stationary or No clouds",
    "1" = "NE",
    "2" = "E",
    "3" = "SE",
    "4" = "S",
    "5" = "SW",
    "6" = "W",
    "7" = "NW",
    "8" = "N",
    "9" = "Unknown",
    "/" = "Unknown"
  )
  directions <- map_directions[digits]
  result <- paste(as.vector(directions), collapse = ' - ')
  return(result)
}

#' @noRd
get_pressure_change_last_24h<- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_two_digits <- substr(checked_group, 1, 2)
  if (!(first_two_digits == '58' | first_two_digits == '59')) { message('Pressure change (24h) cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  pressure_char <- substr(checked_group, 3, 5)
  if (pressure_char == '///') return(NA_real_)
  pressure_change_value <- ifelse(first_two_digits == '59', as.numeric(pressure_char) / -10, as.numeric(pressure_char) / 10)
  return(pressure_change_value)
}

#' @noRd
get_precipitation_last_24h <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (substr(checked_group, 1, 1) != '7') { message('Last 24-hour precipitation cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  prec_char <- substr(checked_group,2,5)
  if (prec_char == '////') return(NA_real_)
  if (prec_char == '9999') return(0.01)
  prec_val <- as.numeric(prec_char) / 10
  return(prec_val)
}

#' @noRd
calculate_relative_humidity <- function(t, td) {
  #Magnus-Tetens Equation
  e  <- exp((17.625 * td) / (td + 243.04))
  es <- exp((17.625 * t) / (t + 243.04))
  rh <- 100 * (e / es)
  return(round(rh, 1))
}


## GROUP 9 FROM SECTION 3

