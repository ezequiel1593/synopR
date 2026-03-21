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


