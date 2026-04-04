# Parse SYNOP strings downloaded from Ogimet into a data frame

Parse SYNOP strings downloaded from Ogimet into a data frame

## Usage

``` r
parse_ogimet(ogimet_data)
```

## Arguments

- ogimet_data:

  A character vector of Ogimet-format SYNOP strings.

## Value

A data frame with Year, Month, Day, Hour, and Raw_synop.

## Examples

``` r
msg <- paste0("87736,2026,01,01,12,00,AAXX 01123 87736 32965 13205 10214 20143 ",
              "30022 40113 5//// 80005 333 10236 20128=")
parsed_data <- parse_ogimet(msg)
```
