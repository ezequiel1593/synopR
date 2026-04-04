#' Check SYNOP messages for structural integrity
#'
#' @description
#' Validates if SYNOP strings meet basic structural requirements, considering
#' section indicators and 5-digit data groups.
#'
#' @param data A character vector of SYNOP strings or the exact data frame
#'   returned by \code{parse_ogimet()}.
#' @return A data frame with validation results for each message.
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

  results <- lapply(strings, function(s) {

    # Check for NA or empty messages
    if (is.na(s) || s == "") {
      return(data.frame(is_valid = FALSE, error_log = "Empty or NA", stringsAsFactors = FALSE))
    }

    clean_s <- trimws(gsub("\\s+", " ", s)) # transform multiple whitespaces into a single one + removes them at start and end
    groups <- unlist(strsplit(clean_s, "\\s+")) # split by group

    # Removes "AAXX", "=", "" from groups to check valid characters
    tech_groups <- groups[groups != "AAXX"]
    tech_groups <- sub("=$","",tech_groups)
    tech_groups <- tech_groups[tech_groups != ""]

    valid_format <- grepl("^[0-9/]{5}$|^[2345]{3}$|^NIL$", tech_groups) # 0:9;/;NIL

    has_aaxx <- startsWith(s, 'AAXX') # Must start with 'AAXX'
    ends_correctly <- endsWith(s, '=') # Must end with '='
    ends_double_equal <- endsWith(s, '==') # Should not end with '=='
    all_groups_ok <- all(valid_format) # Must contain only valid characters

    reason <- c()
    if (!has_aaxx) reason <- c(reason, "Missing AAXX")
    if (ends_double_equal) reason <- c(reason, "Ends with '==', one '=' should be removed") # This is only informed
    if (!ends_correctly) reason <- c(reason, "Missing '=' terminator")
    if (!all_groups_ok) {
      bad_idx <- which(!valid_format)
      reason <- c(reason, paste0("Invalid groups: ", paste(tech_groups[bad_idx], collapse = ", ")))
    }

    return(data.frame(
      is_valid = (has_aaxx & ends_correctly & all_groups_ok),
      error_log = paste(reason, collapse = " | "),
      stringsAsFactors = FALSE
    ))
  })

  final_df <- do.call(rbind, results)

  return(final_df)
}
