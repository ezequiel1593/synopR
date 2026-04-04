#' Parse SYNOP strings downloaded from Ogimet into a data frame
#'
#' @param ogimet_data A character vector of Ogimet-format SYNOP strings.
#' @return A data frame with Year, Month, Day, Hour, and Raw_synop.
#' @examples
#' msg <- paste0("87736,2026,01,01,12,00,AAXX 01123 87736 32965 13205 10214 20143 ",
#'               "30022 40113 5//// 80005 333 10236 20128=")
#' parsed_data <- parse_ogimet(msg)
#' @export
parse_ogimet <- function(ogimet_data) {
  res <- strsplit(ogimet_data, ",", fixed = TRUE)
  parts <- matrix(unlist(res), ncol = 7, byrow = TRUE)

  df <- data.frame(Year        = as.numeric(parts[,2]),
                   Month       = as.numeric(parts[,3]),
                   Day_Ogimet  = as.numeric(parts[,4]),
                   Hour_Ogimet = as.numeric(parts[,5]),
                   Raw_synop   = regmatches(parts[,7], regexpr("AAXX.*=", parts[,7])),
                   stringsAsFactors = FALSE)

  df$Raw_synop <- gsub("=+$", "=", df$Raw_synop)

  return(df)

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
#' Too many requests may trigger temporal blocks.
#'
#' If the station identifier starts with 0 (zero), then `wmo_identifier` must be a string (e.g., "06447").
#'
#' @examples
#' \dontrun{
#' download_from_ogimet(wmo_identifier = '87585',
#'                     initial_date = "2024-01-10",
#'                     final_date = "2024-01-11")
#' }
#'
#' @export
download_from_ogimet <- function(wmo_identifier, initial_date, final_date) {

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


#' Direct download of meteorological data from Ogimet
#'
#' @param wmo_identifier A 5-digit character string or integer representing the station WMO ID.
#' @param initial_date Initial date, format "YYYY-MM-DD".
#' @param final_date Final date, format "YYYY-MM-DD".
#'
#' @returns A data frame, as returned by \code{show_synop_data()}
#' @details
#' The requested period cannot exceed 370 days. All queries assume UTC time zone.
#' The returned data frame covers from 00:00 UTC of the \code{initial_date} to 23:00 UTC
#' of the \code{final_date}, inclusive.
#' Too many requests may trigger temporal blocks.
#'
#' If the station identifier starts with 0 (zero), then `wmo_identifier` must be a string (e.g., "06447").
#'
#' @examples
#' \dontrun{
#' direct_download_from_ogimet(wmo_identifier = '87585',
#'                             initial_date = "2024-01-10",
#'                             final_date = "2024-01-11")
#' }
#'
#' @export
direct_download_from_ogimet <- function(wmo_identifier, initial_date, final_date) {

  data_downloaded <- download_from_ogimet(wmo_identifier, initial_date, final_date) |>
    parse_ogimet()

  data_checked <- check_synop(data_downloaded)

  message('Data downloaded and checked. Decoding...')

  data_decoded <- show_synop_data(data_downloaded[which(data_checked$is_valid == TRUE),])

  return(data_decoded)

}
