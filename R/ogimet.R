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


#' Download SYNOP messages from Ogimet
#'
#' @param wmo_identifier A 5-digit character string or integer representing the station WMO ID.
#' @param initial_date Initial date, format "YYYY-MM-DD".
#' @param final_date Final date, format "YYYY-MM-DD".
#'
#' @returns A character vector with SYNOP strings.
#' @details
#' The requested period cannot exceed 370 days. All queries assume UTC time zone.
#' The returned dataset covers from 00:00 UTC of the \code{initial_date} to 23:00 UTC
#' of the \code{final_date}, inclusive.
#'
#' @examples
#' \donttest{
#' download_from_ogimet(wmo_identifier = 87585, initial_date = "2024-01-10", final_date = "2024-01-11")
#' }
#'
#' @export
download_from_ogimet <- function(wmo_identifier, initial_date, final_date) {

  # Check "wmo_identifier" validity
  if (!is.null(wmo_identifier)) {

    if (!stringr::str_detect(as.character(wmo_identifier), "^[0-9]+$")) {
      stop("Invalid wmo_identifier: contains non-numeric characters (only 0-9 allowed).", call. = FALSE)
    }

    if (!stringr::str_detect(as.character(wmo_identifier), "^[0-9]{5}$")) {
      stop("Invalid wmo_identifier: must be a 5-digit string or integer.", call. = FALSE)
    }

    wmo_identifier <- sprintf("%05d", as.numeric(wmo_identifier))
  }

  # Check date validity
  init_date <- as.Date(initial_date, format = "%Y-%m-%d")
  if (is.na(init_date)) {
    stop(initial_date, " is invalid or does not follow the YYYY-MM-DD format.", call. = FALSE)
  }
  init_date_url <- format(init_date, "%Y%m%d")

  end_date <- as.Date(final_date, format = "%Y-%m-%d")
  if (is.na(end_date)) {
    stop(final_date, " is invalid or does not follow the YYYY-MM-DD format.", call. = FALSE)
  }
  end_date_url <- format(end_date, "%Y%m%d")

  if (init_date > end_date) {
    stop("Final_date must be equal or greater than initial_date.", call. = FALSE)
  }

  if (as.numeric(end_date - init_date) > 370) {
    stop("The requested period exceeds the limit of 370 days. Please split your request into smaller intervals.", call. = FALSE)
  }


  ogimet_url <- paste0('https://www.ogimet.com/cgi-bin/getsynop?block=',wmo_identifier,
                       '&begin=',init_date_url,'0000&end=',end_date_url,'2300')

  synop_messages <- readLines(ogimet_url)

  return(synop_messages)

}
