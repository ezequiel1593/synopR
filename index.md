# synopR

## Overview

The goal of **synopR** is to provide a simple and robust tool for
decoding SYNOP (Surface Synoptic Observations) messages, specifically
optimized for data retrieved from Ogimet or standard WMO formats. It
focuses on extracting Sections 0, 1 and 3 into a tidy, analysis-ready
format.

## Installation

You can install the development version of synopR from
[GitHub](https://github.com/ezequiel1593/synopR) with:

``` r
# install.packages("devtools")
devtools::install_github("ezequiel1593/synopR", build_vignettes = TRUE)
```

## Features

This package extracts the following meteorological parameters:

### Section 1

- **Clouds:** Lower cloud base height (`h`), Total coverage (`N`), Low
  or medium cloud amount (`Nh`), and types (`Cl`, `Cm`, `Ch`).
- **Visibility:** Horizontal visibility (`VV`).
- **Wind:** Direction (`dd`) and speed (`ff`) in knots.
- **Temperature:** Air temperature (`TTT`) and Dew point (`TdTdTd`) in
  **°C**.
- **Pressure:** MSL pressure (`PPPP`) and Surface pressure (`PPPP1`) in
  **hPa**.
- **Precipitation:** Amount (`RRR1`) and time window (`tR1`) in
  **hours**.
- **Weather:** Present (`ww`) and past weather (`W1`, `W2`).

### Section 3

- **Extremes:** Maximum (`Tx`) and Minimum (`Tn`) temperature in **°C**.
- **Ground:** State of the ground (`E`, `E'`), snow depth (`sss`) and
  ground minimum temperature (`TgTg`).
- **Section 3 Precipitation:** Amount (`RRR3`) and time window (`tR3`).

> **Note:** Parameters like `h`, `VV`, `N`, `Nh`, `ww`, `W1`, `W2`, `E`,
> `E'`, `Cl`, `Cm`, and `Ch` are extracted in their original coded
> format from the WMO tables. For `N` and `Nh`, the values 0-8 directly
> represent coverage in oktas.

## Usage

### Decoding Ogimet Data

The package includes a parser specifically designed for the
comma-separated format used by Ogimet:

``` r
library(synopR)

# Example Ogimet string
# Downloaded from: https://www.ogimet.com/cgi-bin/getsynop?block=87736&begin=202601011800&end=202601011800
raw_data <- "87736,2026,01,01,18,00,AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818="

# Parse and decode
decoded <- parse_ogimet(raw_data) |>
  show_synop_data(wmo_identifier = "87736")

print(decoded)
```

## Constraints & Assumptions

To ensure accurate decoding, the package assumes:

- **Sections:** The package does not support sections `222` (Maritime
  data) or `444` (Cloud data).
- **Format:** The package automatically discards national data sections
  (Section 555) and filters out NIL reports.
- **Timing:** Observations are assumed to occur at the time indicated in
  Section 0 (Group 9 time-shifts are currently ignored).
- **Wind:** Speed (`ff`) is reported in knots and is \< 100 kt.
- **Humidity:** Group 2 (Section 1) contains dew point, not relative
  humidity.
- **Pressure:** Group 4 (Section 1) reports MSL pressure, not
  geopotential height.
- **Precipitation (Trace):** Values coded as `990` are converted to
  `0.01` (mm) to allow numerical analysis while representing non-zero
  values.
- **Regionality:** Section 3, Group 3 is interpreted as ground minimum
  temperature.

## Validation

You can check the structural integrity of your SYNOP messages before
decoding:

``` r
check_synop(c("AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818=",
              "AAXX 01183 87736 11463 41813 10330 20148 39982 4007 5//// 60001 70700 83105 333 56600 83818="))
```

## Documentation

The complete documentation, including function references and tutorials
in both **English** and **Spanish**, is available at:

👉 <https://ezequiel1593.github.io/synopR/>
