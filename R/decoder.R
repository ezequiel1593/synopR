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
    Sea_level_pressure = NA_real_, Present_weather = NA_real_, Past_weather1 = NA_real_,
    Past_weather2 = NA_real_, Precipitation_S1 = NA_real_, Precip_period_S1 = NA_real_,
    Cloud_amount_Nh = NA_real_, Low_clouds_CL = NA_real_, Medium_clouds_CM = NA_real_, High_clouds_CH = NA_real_
  )
  for (g in groups) {
    if (is.na(g) || g == "" || stringr::str_detect(g, "/")) next
    id <- substr(g, 1, 1)
    if (id == "1") res$Air_temperature <- get_temperature(g)
    else if (id == "2") res$Dew_point <- get_temperature(g)
    else if (id == "3") res$Station_pressure <- get_pressure(g)
    else if (id == "4") res$Sea_level_pressure <- get_pressure(g)
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
    if (is.na(g) || g == "" || stringr::str_detect(g, "/")) next
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
#' @param data A character vector, or a data frame or tibble with one column (V1) containing raw SYNOP strings.
#' @param wmo_identifier A 5-digit character string (e.g., "87736") representing the station WMO ID.
#'
#' @return A tidy tibble where each row represents one observation time and
#' each column a decoded meteorological variable.
#'
#' @details
#' The function is vectorized through `purrr::map`, meaning it can handle any
#' number of SYNOP messages in the input data frame, provided they all belong
#' to the station specified by `wmo_identifier`. It automatically handles
#' Section 0 (Time), Section 1 (Global), and Section 3 (Regional).
#'
#' @examples
#' # synop_df <- data.frame(messages = c("AAXX 01123 87736 32965 13205 10214 20143 30022 40113 5//// 80005 333 10236 20128 56000 81270=", "AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818="))
#' # decoded_data <- show_synop_data(synop_df, "87736")
#'
#' @export
show_synop_data <- function(data, wmo_identifier) {

  # Check "wmo_identifier" validity
  if (!stringr::str_detect(wmo_identifier, "^[0-9]{5}$")) {
    stop("Invalid wmo_identifier: must be a 5-digit character string.")
  }

  # Handle data input
  if (is.character(data)) {
    data_input <- dplyr::tibble(Raw_synop = data)
  } else {
    data_input <- data
    colnames(data_input)[ncol(data_input)] <- "Raw_synop"
  }

  # Verify if wmo_identifier is present in the synops messages
  found <- stringr::str_detect(data_input$Raw_synop, wmo_identifier)
  if (all(!found)) {
    stop("The wmo_identifier '", wmo_identifier, "' was not found in any of the SYNOP strings.")
  }
  if (any(!found)) {
    warning(sum(!found), " message(s) do not contain the identifier '", wmo_identifier, "' and will be discarded.")
    data_input <- data_input |> dplyr::filter(found)
  }

  #
  synop_separado <- data_input |>
    tidyr::separate_wider_delim(cols = Raw_synop, delim = paste0(' ',wmo_identifier,' '), names = c('secc0','secc1')) |>
    tidyr::separate_wider_delim(cols = secc1, delim = ' 333 ', names = c('secc1','secc3'), too_few = 'align_start') |>
    dplyr::mutate(secc3 = stringr::str_split_i(secc3, " 555 ", 1),
                  secc1 = stringr::str_split_i(secc1, " 555 ", 1)) |>
    tidyr::separate_wider_regex(cols = secc1, patterns = c(secc1_0 = "^\\S+\\s+\\S+","\\s+",secc1_1 = ".*"), too_few = "align_start") |>
    dplyr::mutate(secc0 = stringr::str_remove(secc0, "AAXX "), secc3 = stringr::str_remove(secc3, "=$"))

  synop_final <- synop_separado |>
    dplyr::mutate(wmo_id = wmo_identifier) |>
    dplyr::mutate(d0 = purrr::map(secc0, get_time_obs)) |> tidyr::unnest(d0) |>
    dplyr::mutate(d1_0 = purrr::map(secc1_0, section1_0_data)) |> tidyr::unnest(d1_0) |>
    dplyr::mutate(d1_1 = purrr::map(secc1_1, section1_1_data)) |> tidyr::unnest(d1_1) |>
    dplyr::mutate(d3 = purrr::map(secc3, section3_data)) |> tidyr::unnest(d3) |>
    dplyr::select(-secc0, -secc1_0, -secc1_1, -secc3)

  synop_final <- synop_final |>
    dplyr::select(-dplyr::any_of(c("Day_Ogimet", "Hour_Ogimet"))) |>
    dplyr::relocate(wmo_id)

  return(synop_final)
}


#' Parse Ogimet CSV strings into a data frame
#'
#' @param ogimet_data A character vector of Ogimet strings.
#' @return A tibble with Year, Month, Day, Hour, and Raw_Synop.
#' @export
parse_ogimet <- function(ogimet_data) {
  parts <- stringr::str_split_fixed(ogimet_data, ",", 7)

  dplyr::tibble(
    Year  = as.numeric(parts[,2]),
    Month = as.numeric(parts[,3]),
    Day_Ogimet = as.numeric(parts[,4]),
    Hour_Ogimet = as.numeric(parts[,5]),
    Raw_synop = stringr::str_extract(parts[,7], "AAXX.*=")
  ) |>
    dplyr::filter(!is.na(Raw_synop))
}


#' Check SYNOP messages for structural integrity
#'
#' @description
#' Validates if SYNOP strings meet basic structural requirements, considering
#' section indicators (222, 333, 444, 555) and 5-digit data groups.
#'
#' @param data A character vector or a data frame containing SYNOP strings.
#' @return A tibble with validation results for each message.
#' @export
check_synop <- function(data) {
  if (is.data.frame(data)) {
    strings <- data[[ncol(data)]]
  } else {
    strings <- data
  }

  results <- purrr::map_df(strings, function(s) {
    if (is.na(s) || s == "") return(dplyr::tibble(is_valid = FALSE, error_log = "Empty or NA"))

    clean_s <- stringr::str_squish(s)
    groups <- unlist(stringr::str_split(clean_s, "\\s+"))

    tech_groups <- groups[groups != "AAXX"]
    tech_groups <- stringr::str_remove(tech_groups, "=$")
    tech_groups <- tech_groups[tech_groups != ""]

    valid_format <- stringr::str_detect(tech_groups, "^[0-9/]{5}$|^[2345]{3}$|^NIL$")

    has_aaxx <- stringr::str_detect(s, "^AAXX")
    ends_correctly <- stringr::str_detect(s, "=$")
    all_groups_ok <- all(valid_format)

    reason <- c()
    if (!has_aaxx) reason <- c(reason, "Missing AAXX")
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
