# Decode multiple SYNOP messages from a single station

This function decodes a vector or data frame column of raw SYNOP strings
belonging to the same WMO station. It efficiently processes multiple
observations at once, returning a tidy data frame.

## Usage

``` r
show_synop_data(data, wmo_identifier)
```

## Arguments

- data:

  A character vector, or a data frame or tibble with one column (V1)
  containing raw SYNOP strings.

- wmo_identifier:

  A 5-digit character string (e.g., "87736") representing the station
  WMO ID.

## Value

A tidy tibble where each row represents one observation time and each
column a decoded meteorological variable.

## Details

The function is vectorized through
[`purrr::map`](https://purrr.tidyverse.org/reference/map.html), meaning
it can handle any number of SYNOP messages in the input data frame,
provided they all belong to the station specified by `wmo_identifier`.
It automatically handles Section 0 (Time), Section 1 (Global), and
Section 3 (Regional).

## Examples

``` r
# synop_df <- data.frame(messages = c("AAXX 01123 87736 32965 13205 10214 20143 30022 40113 5//// 80005 333 10236 20128 56000 81270=", "AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818="))
# decoded_data <- show_synop_data(synop_df, "87736")
```
