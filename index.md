# synopR

## Overview

The goal of **synopR** is to provide a simple and fast tool for decoding
FM 12 SYNOP (Report of surface observation from a fixed land station)
messages, following the WMO standards (*World Meteorological
Organization (WMO). Manual on Codes (WMO-No. 306), Volume I.1. Geneva,
2019.*). It focuses on extracting data from Sections 0, 1 and 3.

**synopR** is dependency-free! Only R (\>= 4.1.0) is needed.

## Installation

Install from CRAN:

``` r
install.packages("synopR")
```

Or install the development version from
[GitHub](https://github.com/ezequiel1593/synopR) with:

``` r
# install.packages("devtools")
devtools::install_github("ezequiel1593/synopR", build_vignettes = TRUE)
```

## Features

- More than 50 meteorological parameters can be obtained in just
  seconds. A detailed guide of data extracted by
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  is available in the vignette “Extracted_data_reference”.

- You can check the structural integrity of your SYNOP messages before
  decoding:

``` r
library(synopR)

check_synop(c("AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818=",
              "AAXX 01183 87736 11463 41813 10330 20148 39982 4007 5//// 60001 70700 83105 333 56600 83818="))
```

- Download raw SYNOP messages from Ogimet with
  [`download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/download_from_ogimet.md),
  or download, check and decode all at once with
  [`direct_download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/direct_download_from_ogimet.md).

- The package includes a parser specifically designed for the
  comma-separated format used by Ogimet:

``` r
library(synopR)

raw_data <- "87736,2026,01,01,18,00,AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818="

# Parse and decode
decoded <- parse_ogimet(raw_data) |> show_synop_data()

print(decoded)
```

## Performance

[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md),
the core function, is completely vectorized. It means it’s super fast!

![Benchmark](reference/figures/benchmark_result.PNG)  
*45k SYNOP messages decoded in just 13 seconds.*

## Constraints & Assumptions

- **Sections:** The package does not support sections `222` (maritime
  data), `444` (data for clouds with base below station level) and `555`
  (data for national use, which is quietly discarded).
- **Time of observation:** Observations are assumed to occur at the time
  indicated in Section 0 (Group 9 from Section 1 is currently ignored).
- **Humidity:** Group 2 (Section 1) contains dew point, not relative
  humidity.
- **Geopotential height:** Only pressure levels 850, 700 and 500 hPa are
  supported.
- **Trace Precipitation:** They are converted to `0.01` (mm).
- **Groups not supported:** Groups starting with 54 and 9 from Section 3
  are currently ignored.

## Issues

Feel free to report any issue you may find:
[Github](https://github.com/ezequiel1593/synopR/issues)

- “NA introduced by coercion” are generally associated with a specific
  part of the SYNOP message incorrectly codified.

## Documentation

The complete documentation, including function references and tutorials
is available at: <https://ezequiel1593.github.io/synopR/>

## Citation

Elias E (2026). synopR: Fast Decoding of SYNOP (Surface Synoptic
Observations) Meteorological Messages. R package version 1.0.0,
<https://ezequiel1593.github.io/synopR/>.
