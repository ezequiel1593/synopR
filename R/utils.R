# R/utils.R

#' Internal "not in" operator
#' @noRd
`%nin%` <- Negate(`%in%`)

#' @noRd
check_group <- function(group) {
  if (is.na(group) || group == "") return(NULL)
  if (sum(stringr::str_extract_all(group,'')[[1]] %nin% c(0:9,'/','='))) {
    warning(group,' contains disallowed character. NULL returned.') ; return(NULL) }
  if (nchar(group) != 5) {
    # Some strings have 6 characters because of the final "=", they shouldn't be removed
    has_equal_sign <- stringr::str_detect(group, "=")
    if (has_equal_sign) {
      group <- stringr::str_remove(group, "=")
    } else {
      warning(group,' is not a 5-digits group. Null returned.') ; return(NULL)
    }
     }
  return(group)
}

#' @noRd
get_time_obs_wind_unit <- function(group) {
  if (is.null(check_group(group))) { return(dplyr::tibble(Day = NA_real_, Hour = NA_real_, Wind_speed_unit = NA)) }
  day_obs <- as.numeric(substr(group,1,2))
  hour_obs <- as.numeric(substr(group,3,4))
  iw <- as.numeric(substr(group,5,5))
  wind_unit <- switch(iw, 'm/s', 'm/s', NA, 'knots', 'knots')
  return(dplyr::tibble(Day = day_obs, Hour = hour_obs, Wind_speed_unit = wind_unit))
}

#' @noRd
get_visibility_and_hcloud <- function(group){
  if (is.null(check_group(group))) { return(rep(NA_real_, 2)) }
  h_char <- substr(group,3,3)
  h <- ifelse(h_char == "/", NA_real_, as.numeric(h_char))
  VV <- as.numeric(substr(group,4,5))
  return(c(h,VV))
}

#' @noRd
get_cloud_cover_and_wind <- function(group){
  if (is.null(check_group(group))) { return(rep(NA_real_, 3)) }
  nub <- as.numeric(substr(group,1,1))
  wind_dir <- as.numeric(substr(group,2,3))
  wind_vel <- as.numeric(substr(group,4,5))
  return(c(nub,wind_dir,wind_vel))
}

#' @noRd
get_temperature <- function(group){
  if (is.null(check_group(group))) {return(NA_real_)}
  first_digit <- as.numeric(group) %/% 1000
  if (first_digit %nin% c(10,11,20,21)) { message('Not temperature group!') ; return(NA_real_)}
  resultado <- (as.numeric(substr(group,3,5)) / 10) * ifelse(first_digit %in% c(10,20),1,-1)
  return(resultado)
}

#' @noRd
get_pressure <- function(group){
  if (is.null(check_group(group))) {return(NA_real_)}
  first_digit <- as.numeric(group) %/% 10000
  if (first_digit %nin% c(3,4)) { message('Not pressure group!') ; return(NA_real_)}
  pre_resultado <- as.numeric(substr(group,2,5)) / 10
  resultado <- ifelse(pre_resultado > 900, pre_resultado, pre_resultado + 1000)
  return(resultado)
}

#' @noRd
get_present_past_weather <- function(group){
  if (is.null(check_group(group))) {return(rep(NA_real_, 3))}
  first_digit <- as.numeric(group) %/% 10000
  if (first_digit != 7) { message('Not present and past weather group!') ; return(rep(NA_real_, 3)) }
  c(as.numeric(substr(group,2,3)), as.numeric(substr(group,4,4)), as.numeric(substr(group,5,5)))
}

#' @noRd
get_precipitation <- function(group) {
  if (is.null(check_group(group))) {return(rep(NA_real_, 2))}
  if (as.numeric(group) %/% 10000 != 6) { message('Not precipitation group!') ; return(rep(NA_real_, 2)) }
  prec <- as.numeric(substr(group,2,4))
  prec_val <- ifelse(prec < 989, prec, ifelse(prec == 990, 0.01 ,(prec - 990)/10))
  period <- switch(substr(group,5,5), "1" = 6, "2" = 12, "3" = 18, "4" = 24,
                   "5" = 1, "6" = 2, "7" = 3, "8" = 9, "9" = 15)
  return(c(prec_val, period))
}

#' @noRd
get_cloudiness <- function(group) {
  if (is.null(check_group(group))) {return(rep(NA_real_, 4))}
  partido <- as.numeric(strsplit(group, "")[[1]])
  if (partido[1] != 8) { message('Not cloudiness group!') ; return(rep(NA_real_, 4)) }
  return(partido[2:5])
}

#' @noRd
get_ground_temp <- function(group) {
  if (is.null(check_group(group))) {return(rep(NA_real_, 2))}
  if (as.numeric(group) %/% 10000 != 3) { message('Not ground temperature group!') ; return(rep(NA_real_, 2)) }
  state <- as.numeric(substr(group,2,2))
  sign <- as.numeric(substr(group,3,3))
  temp <- as.numeric(substr(group,4,5)) * ifelse(sign == 0, 1, -1)
  return(c(state, temp))
}

#' @noRd
get_snow_depth <- function(group) {
  if (is.null(check_group(group))) {return(rep(NA_real_, 2))}
  if (as.numeric(group) %/% 10000 != 4) { message('Not snow depth group!') ; return(rep(NA_real_, 2)) }
  return(c(as.numeric(substr(group,2,2)), as.numeric(substr(group,3,5))))
}

#' @noRd
calculate_relative_humidity <- function(t, td) {
  #Magnus-Tetens Equation
  e  <- exp((17.625 * td) / (td + 243.04))
  es <- exp((17.625 * t) / (t + 243.04))
  rh <- 100 * (e / es)
  return(round(rh, 1))
}
