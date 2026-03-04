# Check SYNOP messages for structural integrity

Validates if SYNOP strings meet basic structural requirements,
considering section indicators (222, 333, 444, 555) and 5-digit data
groups.

## Usage

``` r
check_synop(data)
```

## Arguments

- data:

  A character vector or a data frame containing SYNOP strings.

## Value

A tibble with validation results for each message.
