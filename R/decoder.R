#' @noRd
section1_0_data <- function(chain) {
  groups <- unlist(stringr::str_split(chain, "\\s+"))
  res <- dplyr::tibble(
    Cloud_base_height = NA_real_, Visibility = NA_real_, Total_cloud_cover = NA_real_,
    Wind_direction = NA_real_, Wind_speed = NA_real_
  )
  if (is.na(groups[1])) return(res)
  v1 <- get_visibility_and_hcloud(groups[1])
  res$Cloud_base_height <- v1[1]; res$Visibility <- v1[2]
  v2 <- get_cloud_cover_and_wind(groups[2])
  res$Total_cloud_cover <- v2[1]; res$Wind_direction <- v2[2]; res$Wind_speed <- v2[3]
  return(res)
}

#' @noRd
section1_1_data <- function(chain) {
  groups <- unlist(stringr::str_split(chain, "\\s+"))
  res <- dplyr::tibble(
    Air_temperature = NA_real_, Dew_point = NA_real_, Station_pressure = NA_real_,
    MSLP_GH = NA_real_, Present_weather = NA_real_, Past_weather1 = NA_real_,
    Past_weather2 = NA_real_, Precipitation_S1 = NA_real_, Precip_period_S1 = NA_real_,
    Cloud_amount_Nh = NA_real_, Low_clouds_CL = NA_real_, Medium_clouds_CM = NA_real_, High_clouds_CH = NA_real_
  )
  for (g in groups) {
    if (is.na(g) || g == "") next
    id <- substr(g, 1, 1)
    if (id == "1") res$Air_temperature <- get_temperature(g)
    else if (id == "2") res$Dew_point <- get_temperature(g)
    else if (id == "3") res$Station_pressure <- get_pressure(g)
    else if (id == "4") res$MSLP_GH <- get_pressure_or_geop_height(g)
    else if (id == "6") { v <- get_precipitation(g); res$Precipitation_S1 <- v[1]; res$Precip_period_S1 <- v[2] }
    else if (id == "7") { v <- get_present_past_weather(g); res$Present_weather <- v[1]; res$Past_weather1 <- v[2]; res$Past_weather2 <- v[3] }
    else if (id == "8") { v <- get_cloudiness(g); res$Cloud_amount_Nh <- v[1]; res$Low_clouds_CL <- v[2]; res$Medium_clouds_CM <- v[3]; res$High_clouds_CH <- v[4] }
  }
  return(res)
}

#' @noRd
section3_data <- function(chain) {
  groups <- unlist(stringr::str_split(chain, "\\s+"))
  res <- dplyr::tibble(
    Max_temperature = NA_real_, Min_temperature = NA_real_, Ground_state = NA_real_,
    Ground_temperature = NA_real_, Snow_ground_state = NA_real_, Snow_depth = NA_real_,
    Precipitation_S3 = NA_real_, Precip_period_S3 = NA_real_
  )
  for (g in groups) {
    if (is.na(g) || g == "") next
    id <- substr(g, 1, 1)
    if (id == "1") res$Max_temperature <- get_temperature(g)
    else if (id == "2") res$Min_temperature <- get_temperature(g)
    else if (id == "3") { v <- get_ground_temp(g); res$Ground_state <- v[1]; res$Ground_temperature <- v[2] }
    else if (id == "4") { v <- get_snow_depth(g); res$Snow_ground_state <- v[1]; res$Snow_depth <- v[2] }
    else if (id == "6") { v <- get_precipitation(g); res$Precipitation_S3 <- v[1]; res$Precip_period_S3 <- v[2] }
  }
  return(res)
}

#' Decode multiple SYNOP messages from a single station
#'
#' @description
#' This function decodes a vector or data frame column of raw SYNOP strings
#' belonging to the same WMO station. It efficiently processes multiple
#' observations at once, returning a tidy data frame.
#'
#' @param data A character vector, or a data frame or tibble with one column containing raw SYNOP strings.
#' @param wmo_identifier A 5-digit character string or integer representing the station WMO ID. If NULL (default), all messages are decoded.
#' @param remove_empty_cols Logical. Should columns containing only \code{NA} values be removed?
#'
#' @return A tidy tibble where each row represents one observation time and
#' each column a decoded meteorological variable.
#' \enumerate{
#'  \item wmo_id - WMO station identifier
#'  \item Year - (from parse_ogimet())
#'  \item Day - As informed by Section 0
#'  \item Hour - As informed by Section 0
#'  \item Cloud_base_height - Lowest cloud base height, not decoded
#'  \item Visibility - Not decoded
#'  \item Total_cloud_cover - In oktas, 9 means 'invisible' sky by fog or other phenomenon
#'  \item Wind_direction - In tens of degree, 99 means 'variable wind direction'
#'  \item Wind_speed
#'  \item Wind_speed_unit - Either 'm/s' or 'knots'
#'  \item Air_temperature - In degrees Celsius
#'  \item Dew_point - In degrees Celsius
#'  \item Relative_humidity - As a percentage
#'  \item Station_pressure - In hPa
#'  \item MSLP_GH - Mean sea level pressure (in hPa) or geopotential height (in gpm)
#'  \item Present_weather - Not decoded
#'  \item Past_weather1 - Not decoded
#'  \item Past_weather2 - Not decoded
#'  \item Precipitation_S1 - In mm
#'  \item Precip_period_S1 - In hours ('Precipitation_S1' fell in the last 'Precip_period_S1' hours)
#'  \item Cloud_amount_Nh - Cloud coverage from low or medium cloud, same as 'Total_cloud_cover'
#'  \item Low_clouds_CL - Not decoded
#'  \item Medium_clouds_CM - Not decoded
#'  \item High_clouds_CH - Not decoded
#'  \item Max_temperature - In degrees Celsius
#'  \item Min_temperature - In degrees Celsius
#'  \item Ground_state - Not decoded
#'  \item Ground_temperature - Integer, in degrees Celsius
#'  \item Snow_ground_state - Not decoded
#'  \item Snow_depth - In cm, is assumed to be between 1 and 996 cm
#'  \item Precipitation_S3 - In mm
#'  \item Precip_period_S3 - In hours ('Precipitation_S3' fell in the last 'Precip_period_S3' hours)
#'  }
#'
#' @examples
#' msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
#'               "30022 40113 5//// 80005 333 10236 20128 56000 81270=")
#' synop_df <- data.frame(messages = msg)
#' decoded_data <- show_synop_data(synop_df, "87736")
#'
#' @export
show_synop_data <- function(data, wmo_identifier = NULL, remove_empty_cols = FALSE) {

  # Check "wmo_identifier" validity
  if (!is.null(wmo_identifier)) {
    wmo_identifier <- sprintf("%05d", as.numeric(wmo_identifier))
    if (!stringr::str_detect(wmo_identifier, "^[0-9]{5}$")) {
      stop("Invalid wmo_identifier: must be a 5-digit character string.")
    }
  }

  # Handle data input
  if (is.character(data)) {
    data_input <- dplyr::tibble(Raw_synop = data)
  } else {
    data_input <- data
    colnames(data_input)[ncol(data_input)] <- "Raw_synop"
  }

  # Separate into sections (header,time_obs,wmo_id,secc1_0,secc1_1,secc3)
  synop_separado <- data_input |>
    # Removes "=" and "=="
    dplyr::mutate(Raw_synop = stringr::str_remove(Raw_synop, "={1,2}$")) |>
    # Separate header (AAXX) from the rest
    tidyr::separate_wider_delim(cols = Raw_synop, delim = " ", names = c("header", "the_rest"), too_many = 'merge') |>
    # Separate time_obs (YYGGIw) from the rest
    tidyr::separate_wider_delim(cols = the_rest, delim = " ", names = c("time_obs", "the_rest"), too_many = 'merge') |>
    # Separate wmo_id from the rest
    tidyr::separate_wider_delim(cols = the_rest, delim = " ", names = c("wmo_id", "the_rest"), too_many = 'merge') |>
    # From "the rest", separate secc5
    tidyr::separate_wider_delim(cols = the_rest, delim = ' 555 ', names = c('the_rest','secc5'), too_few = 'align_start') |>
    # From "the rest", separate into secc1 and secc3
    tidyr::separate_wider_delim(cols = the_rest, delim = ' 333 ', names = c('secc1','secc3'), too_few = 'align_start') |>
    # Separate secc1 into secc1_0 and secc1_1
    tidyr::separate_wider_regex(cols = secc1, patterns = c(secc1_0 = "^\\S+\\s+\\S+","\\s+",secc1_1 = ".*"), too_few = "align_start") |>
    # Remove section 5
    dplyr::select(-secc5)

  # Verify if wmo_identifier is present in the synops messages
  if (!is.null(wmo_identifier)) {
    found <- synop_separado$wmo_id == wmo_identifier
    if (all(!found)) {
      stop("The wmo_identifier '", wmo_identifier, "' was not found in any of the SYNOP strings.")
    }
    if (any(!found)) {
      warning(sum(!found), " message(s) do not contain the identifier '", wmo_identifier, "' and will be discarded.")
      synop_separado <- synop_separado |> dplyr::filter(wmo_id == wmo_identifier)
    }
  }

  synop_final <- synop_separado |>
    dplyr::mutate(d0 = furrr::future_map(time_obs, get_time_obs_wind_unit)) |> tidyr::unnest(d0) |>
    dplyr::mutate(d1_0 = furrr::future_map(secc1_0, section1_0_data)) |> tidyr::unnest(d1_0) |>
    dplyr::mutate(d1_1 = furrr::future_map(secc1_1, section1_1_data)) |> tidyr::unnest(d1_1) |>
    dplyr::mutate(d3 = furrr::future_map(secc3, section3_data)) |> tidyr::unnest(d3) |>
    dplyr::select(-header,-time_obs, -secc1_0, -secc1_1, -secc3)

  synop_final <- synop_final |>
    dplyr::select(-dplyr::any_of(c("Day_Ogimet", "Hour_Ogimet"))) |>
    dplyr::mutate(Relative_humidity = calculate_relative_humidity(Air_temperature, Dew_point)) |>
    dplyr::relocate(Relative_humidity, .after = Dew_point) |>
    dplyr::relocate(Wind_speed_unit, .after = Wind_speed) |>
    dplyr::relocate(wmo_id)

  if (remove_empty_cols) { synop_final <- synop_final[, !sapply(synop_final, function(x) all(is.na(x)))] }

  return(synop_final)
}


#' Parse Ogimet strings into a data frame
#'
#' @param ogimet_data A character vector of Ogimet strings.
#' @return A tibble with Year, Month, Day, Hour, and Raw_synop.
#' @examples
#' msg <- paste0("87736,2026,01,01,12,00,AAXX 01123 87736 32965 13205 10214 20143 ",
#'               "30022 40113 5//// 80005 333 10236 20128=")
#' parsed_data <- parse_ogimet(msg)
#' @export
parse_ogimet <- function(ogimet_data) {
  parts <- stringr::str_split_fixed(ogimet_data, ",", 7)

  dplyr::tibble(
    Year  = as.numeric(parts[,2]),
    Month = as.numeric(parts[,3]),
    Day_Ogimet = as.numeric(parts[,4]),
    Hour_Ogimet = as.numeric(parts[,5]),
    Raw_synop = stringr::str_extract(parts[,7], "AAXX.*=")) |>
    dplyr::mutate(Raw_synop = gsub("=+$","=",Raw_synop)) # Change "==" to "="

}


#' Check SYNOP messages for structural integrity
#'
#' @description
#' Validates if SYNOP strings meet basic structural requirements, considering
#' section indicators and 5-digit data groups.
#'
#' @param data A character vector of SYNOP strings or the exact data frame
#'   returned by \code{parse_ogimet()}.
#' @return A tibble with validation results for each message.
#' @examples
#' msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
#'               "30022 40113 5//// 80005 333 10236 20128=")
#' checked_synops <- check_synop(msg)
#' @export
check_synop <- function(data) {

  if (is.data.frame(data)) {
    strings <- data[[ncol(data)]] # Data frame from parse_ogimet()
  } else {
    strings <- data
  }

  results <- furrr::future_map_dfr(strings, function(s) {

    # Check for NA or empty messages
    if (is.na(s) || s == "") return(dplyr::tibble(is_valid = FALSE, error_log = "Empty or NA"))

    clean_s <- stringr::str_squish(s) # str_trim + transform multiple whitespaces into a single one
    groups <- unlist(stringr::str_split(clean_s, "\\s+")) # split by group

    # Removes "AAXX", "=", "" from groups to check valid characters
    tech_groups <- groups[groups != "AAXX"]
    tech_groups <- stringr::str_remove(tech_groups, "=$")
    tech_groups <- tech_groups[tech_groups != ""]

    valid_format <- stringr::str_detect(tech_groups, "^[0-9/]{5}$|^[2345]{3}$|^NIL$") # 0:9;/;NIL

    has_aaxx <- stringr::str_detect(s, "^AAXX") # Must start with 'AAXX'
    ends_correctly <- stringr::str_detect(s, "=$") # Must end with '='
    ends_double_equal <- stringr::str_detect(s, "==$") # Should not end with '=='
    all_groups_ok <- all(valid_format) # Must contain only valid characters

    reason <- c()
    if (!has_aaxx) reason <- c(reason, "Missing AAXX")
    if (ends_double_equal) reason <- c(reason, "Ends with '==', one '=' should be removed")
    if (!ends_correctly) reason <- c(reason, "Missing '=' terminator")
    if (!all_groups_ok) {
      bad_idx <- which(!valid_format)
      reason <- c(reason, paste0("Invalid groups: ", paste(tech_groups[bad_idx], collapse = ", ")))
    }

    dplyr::tibble(
      is_valid = (has_aaxx & ends_correctly & all_groups_ok),
      error_log = paste(reason, collapse = " | ")
    )
  })

  return(results)
}
