# Download SYNOP messages from Ogimet

Download SYNOP messages from Ogimet

## Usage

``` r
download_from_ogimet(wmo_identifier, initial_date, final_date)
```

## Arguments

- wmo_identifier:

  A 5-digit character string or integer representing the station WMO ID.

- initial_date:

  Initial date, format "YYYY-MM-DD".

- final_date:

  Final date, format "YYYY-MM-DD".

## Value

A character vector with SYNOP strings.

## Details

The requested period cannot exceed 370 days. All queries assume UTC time
zone. The returned dataset covers from 00:00 UTC of the `initial_date`
to 23:00 UTC of the `final_date`, inclusive. Too many requests may
trigger temporal blocks.

If the station identifier starts with 0 (zero), then `wmo_identifier`
must be a string (e.g., "06447").

## Examples

``` r
if (FALSE) { # \dontrun{
download_from_ogimet(wmo_identifier = '87585',
                    initial_date = "2024-01-10",
                    final_date = "2024-01-11")
} # }
```
