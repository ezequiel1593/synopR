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

A data frame with validation results for each message.

## Examples

``` r
msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
              "30022 40113 5//// 80005 333 10236 20128=")
checked_synops <- check_synop(msg)
```
