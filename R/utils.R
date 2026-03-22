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
get_visibility_and_hcloud <- function(group){
  checked_group <- check_group(group)
  if (is.null(checked_group)) { return(rep(NA_real_, 2)) }
  h_char <- substr(checked_group,3,3)
  h <- ifelse(h_char == "/", NA_real_, as.numeric(h_char))
  VV <- as.numeric(substr(checked_group,4,5))
  return(c(h,VV))
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
calculate_relative_humidity <- function(t, td) {
  #Magnus-Tetens Equation
  e  <- exp((17.625 * td) / (td + 243.04))
  es <- exp((17.625 * t) / (t + 243.04))
  rh <- 100 * (e / es)
  return(round(rh, 1))
}
