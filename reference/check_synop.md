# Check SYNOP messages for structural integrity

Validates if SYNOP strings meet basic structural requirements,
considering section indicators and 5-digit data groups.

## Usage

``` r
check_synop(data)
```

## Arguments

- data:

  A character vector of SYNOP strings or the exact data frame returned
  by
  [`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

## Value

A tibble with validation results for each message.
