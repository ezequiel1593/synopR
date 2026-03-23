# R/utils.R

#' Internal "not in" operator
#' @noRd
`%nin%` <- Negate(`%in%`)

#' @noRd
check_group <- function(group) {
  if (is.na(group) || group == "") return(NULL)
  if (sum(stringr::str_extract_all(group,'')[[1]] %nin% c(0:9,'/','='))) {
    message(group,' contains disallowed character. NULL returned.') ; return(NULL) }
  if (nchar(group) != 5) {
    # Some strings have 6 characters because of the final "=", now this function is aware of that
    has_equal_sign <- stringr::str_detect(group, "=")
    if (has_equal_sign) {
      group <- stringr::str_remove(group, "=")
    } else {
      message(group,' is not a 5-digits group. Null returned.') ; return(NULL)
    }
     }
  return(group)
}

#' @noRd
get_time_obs_wind_unit <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(dplyr::tibble(Day = NA_real_, Hour = NA_real_, Wind_speed_unit = NA)) }
  day_obs <- as.numeric(substr(checked_group,1,2))
  hour_obs <- as.numeric(substr(checked_group,3,4))
  iw <- as.numeric(substr(checked_group,5,5))
  wind_unit <- switch(iw + 1, 'm/s', 'm/s', NA, 'knots', 'knots')
  return(dplyr::tibble(Day = day_obs, Hour = hour_obs, Wind_speed_unit = wind_unit))
}

#' @noRd
get_visibility_hcloud_and_indicators <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(rep(NA_real_, 2)) }
  iR_ind <- as.numeric(substr(checked_group,1,1))
  h_char <- substr(checked_group,3,3)
  h <- ifelse(h_char == "/", NA_real_, as.numeric(h_char))
  VV <- as.numeric(substr(checked_group,4,5))
  return(c(iR_ind,h,VV))
}

#' @noRd
get_cloud_cover_and_wind <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(rep(NA_real_, 3)) }
  nub <- as.numeric(substr(checked_group,1,1))
  wind_dir <- as.numeric(substr(checked_group,2,3))
  wind_vel <- as.numeric(substr(checked_group,4,5))
  return(c(nub,wind_dir,wind_vel))
}

#' @noRd
get_temperature <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_two_char <- substr(checked_group,1,2)
  if (first_two_char %nin% c("10","11","20","21")) {
    if (checked_group %in% c('1////','2////')) {return(NA_real_)}
    else {message('Temperature data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)}
  }
  sn <- as.numeric(substr(checked_group, 2, 2))
  value <- as.numeric(substr(checked_group,3,5)) / 10
  return(value * (1 - 2 * sn))
}

#' @noRd
get_pressure <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_digit <- substr(checked_group,1,1)
  if (first_digit != "3") { message('Pressure data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)}
  pre_resultado <- as.numeric(substr(checked_group,2,5)) / 10
  resultado <- ifelse(pre_resultado > 100, pre_resultado, pre_resultado + 1000)
  return(resultado)
}

#' @noRd
get_pressure_or_geop_height <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  if (checked_group == '4////') {return(NA_real_)}

  first_two_charac <- substr(checked_group,1,2)
  if (first_two_charac %nin% c("40","41","42","45","47","48","49")) { message('MSLP or geopotential height data cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_)}

  if (first_two_charac %in% c("40","49")) {
    pre_resultado <- as.numeric(substr(checked_group,2,5)) / 10
    resultado <- ifelse(pre_resultado > 100, pre_resultado, pre_resultado + 1000)
    return(resultado)
  } else {
    base_geopotential <- switch(first_two_charac, "48" = 1000, "47" = 3000, "45" = 5000, NA_real_)
    if (is.na(base_geopotential)) return(NA_real_)
    height_char <- substr(checked_group, 3, 5)
    if (height_char == '///') return(NA_real_)

    adjustment <- ifelse(first_two_charac == "48", 0, ifelse(height_char > 500, -1000, 0))
    result <- base_geopotential + adjustment + as.numeric(height_char)
    return(result)
  }
}

#' @noRd
get_present_past_weather <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 3))}
  first_digit <- substr(checked_group,1,1)
  if (first_digit != "7") { message('Present or past weather data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 3)) }
  ww <- suppressWarnings(as.numeric(substr(checked_group,2,3))) # suppress warning For the '//' cases (NA coercion)
  w1 <- suppressWarnings(as.numeric(substr(checked_group,4,4))) # suppress warning For the '/' cases
  w2 <- suppressWarnings(as.numeric(substr(checked_group,5,5))) # suppress warning For the '/' cases
  return(c(ww,w1,w2))
}

#' @noRd
get_precipitation <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  if (as.numeric(checked_group) %/% 10000 != 6) { message('Precipitation data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
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
  result <- as.numeric(stringr::str_replace(broken, "/","10"))
  if (result[1] != 8) { message('Cloud data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 4)) }
  return(result[2:5])
}

#' @noRd
get_ground_temp <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  first_digit <- substr(checked_group,1,1)
  if (first_digit != "3") { message('Ground temperature data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  if (checked_group == '3////') {return(rep(NA_real_, 2))}
  state <- suppressWarnings(as.numeric(substr(checked_group,2,2))) # suppress warning For the '/' cases
  if (substr(checked_group,3,5) == '///') {return(c(state,NA_real_))}
  sign <- as.numeric(substr(checked_group,3,3))
  temp <- as.numeric(substr(checked_group,4,5)) * ifelse(sign == 0, 1, -1)
  return(c(state, temp))
}

#' @noRd
get_snow_depth <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(rep(NA_real_, 2))}
  if (as.numeric(checked_group) %/% 10000 != 4) { message('Snow depth data cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  state <- as.numeric(substr(checked_group,2,2))
  snow_depth <- as.numeric(substr(checked_group,3,5))
  return(c(state,snow_depth))
}

#' @noRd
get_evaporation_last_24h <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_two_digits <- substr(checked_group, 1, 2)
  if (first_two_digits %nin% c('50','51','52','53')) { message('Evaporation or evapotranspiration cannot be derived from ',checked_group,'. NA is returned.') ; return(rep(NA_real_, 2)) }
  evap_char <- substr(checked_group, 2, 4)
  if (evap_char == '///') return(rep(NA_real_, 2))
  evap_value <- as.numeric(evap_char) / 10
  return(evap_value)
}

#' @noRd
get_sunshine <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_two_digits <- substr(checked_group, 1, 2)
  if (first_two_digits != '55') { message('Daily sunshine hours cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  sunshine_char <- substr(checked_group, 3, 5)
  if (sunshine_char == '///') return(NA_real_)
  sunshine_hours <- as.numeric(sunshine_char) / 10
  return(sunshine_hours)
}

#' @noRd
get_sunshine_last_hour <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_three_digits <- substr(checked_group, 1, 3)
  if (first_three_digits != '553') { message('Hourly sunshine cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
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
  first_two_digits <- substr(checked_group, 1, 2)
  if (first_two_digits != '56') { message('Direction of cloud drift cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
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
  if (first_two_digits %nin% c('58','59')) { message('Pressure change (24h) cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  pressure_char <- substr(checked_group, 3, 5)
  if (pressure_char == '///') return(NA_real_)
  pressure_change_value <- ifelse(first_two_digits == '59', as.numeric(pressure_char) / -10, as.numeric(pressure_char) / 10)
  return(pressure_change_value)
}

#' @noRd
get_precipitation_last_24h <- function(group) {
  checked_group <- check_group(group)
  if (is.null(checked_group)) {return(NA_real_)}
  first_digit <- substr(checked_group, 1, 1)
  if (first_digit != '7') { message('Last 24-hour precipitation cannot be derived from ',checked_group,'. NA is returned.') ; return(NA_real_) }
  prec_char <- substr(checked_group,3,5)
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
