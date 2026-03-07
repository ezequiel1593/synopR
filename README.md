# synopR <img src="man/figures/logo.png" align="right" height="139" />

## Overview
The goal of **synopR** is to provide a simple and robust tool for decoding SYNOP (Surface Synoptic Observations) messages, specifically optimized for data retrieved from Ogimet or standard WMO formats. It focuses on extracting Sections 0, 1 and 3 into a tidy, analysis-ready format.

## Installation

You can install the development version of synopR from [GitHub](https://github.com/ezequiel1593/synopR) with:

```r
# install.packages("devtools")
devtools::install_github("ezequiel1593/synopR", build_vignettes = TRUE)
```

## Features
This package extracts the following meteorological parameters:

### Section 1
* **Clouds:** Lower cloud base height (`h`), total coverage (`N`), low or medium cloud amount (`Nh`), and types (`Cl`, `Cm`, `Ch`).
* **Visibility:** Horizontal visibility (`VV`).
* **Wind:** Direction (`dd`) in **tens of degree** (99 means variable direction) and speed (`ff`) with its unit.
* **Temperature and humidity:** Air temperature (`TTT`) and dew point (`TdTdTd`) in **°C**. Relative humidity is derived from both.
* **Pressure:** Mean sea level pressure (`PPPP`) and surface pressure (`PPPP1`) in **hPa**.
* **Precipitation:** Amount (`RRR1`) in **mm** and time window (`tR1`) in **hours**.
* **Weather:** Present (`ww`) and past weather (`W1`, `W2`).

### Section 3
* **Temperature extremes:** Maximum (`Tx`) and Minimum (`Tn`) temperature in **°C**.
* **Ground and snow:** State of the ground (`E`, `E'`), snow depth (`sss`) in **cm** and ground minimum temperature (`TgTg`) in **°C**.
* **Section 3 Precipitation:** Amount (`RRR3`) in **mm** and time window (`tR3`) in **hours**.

> **Note:** Parameters like `h`, `VV`,`dd`,`ff`, `N`, `Nh`, `ww`, `W1`, `W2`, `E`, `E'`, `Cl`, `Cm`, and `Ch` are extracted in their original coded format from the WMO tables. 
For `N` and `Nh`, the values 0-8 directly represent coverage in oktas. Vectors with some WMO Code Tables are available [here](https://ezequiel1593.github.io/synopR/articles/Code_Tables.html).

## Usage
### Decoding Ogimet Data
The package includes a parser specifically designed for the comma-separated format used by Ogimet:

```r
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

* **Sections:** The package does not support sections `222` (Maritime data) or `444` (Cloud data).
* **Format:** The package automatically discards national data sections (Section 555).
* **Timing:** Observations are assumed to occur at the time indicated in Section 0 (Group 9 from Section 1 is currently ignored).
* **Wind:** Speed (`ff`) is reported in m/s or knots and its value does not exceed 99.
* **Humidity:** Group 2 (Section 1) contains dew point, not relative humidity.
* **Pressure:** Group 4 (Section 1) reports MSL pressure, not geopotential height.
* **Snow:** Group 4 from Section 3 contains a snow depth value between 1 cm and 996 cm.
* **Precipitation (Trace):** Values coded as `990` are converted to `0.01` (mm) to allow numerical analysis while representing non-zero values.
* **Regionality:** Section 3, Group 3 is interpreted as ground minimum temperature.
* **Groups not supported:** Groups 5, 7, 8 and 9 from Section 3 are currently not supported.

## Validation
You can check the structural integrity of your SYNOP messages before decoding:

```r
check_synop(c("AAXX 01183 87736 11463 41813 10330 20148 39982 40072 5//// 60001 70700 83105 333 56600 83818=",
              "AAXX 01183 87736 11463 41813 10330 20148 39982 4007 5//// 60001 70700 83105 333 56600 83818="))
```

## Documentation

The complete documentation, including function references and tutorials in both **English** and **Español**, is available at:

👉 [https://ezequiel1593.github.io/synopR/](https://ezequiel1593.github.io/synopR/)
