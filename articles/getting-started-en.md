# Introducing synopR

**2026-04-03**

## Standard workflow

[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
is the package’s core function. It requires a character vector or a data
frame column where each element is a SYNOP string. It’s vectorized, so
large vectors can be processed in seconds. But, first of all, SYNOP
messages should be checked with
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md).
This function will make sure every message starts with “AAXX” and ends
with “=”, does not contain invalid characters (valid characters after
removing “AAXX” and “=” are digits 0-9, ‘/’ and ‘NIL’), and verifies
that all groups consist of 5 digits (except for the section identifiers
‘333’ and ‘555’). It will return a data frame with two columns: a
boolean column indicating the validity (can be used to filter out), and
a second one pointing out possible errors.

``` r
library(synopR)

# Notice that the second SYNOP will be removed because of the incomplete group '8127'
data_input_vector <- c("AAXX 04003 87736 32965 00000 10204 20106 39982 40074 5//// 333 10266 20158 =",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 8127 =",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 81270 =")

checked <- check_synop(data_input_vector)
my_data <- show_synop_data(data_input_vector[checked$is_valid == TRUE])

knitr::kable(t(my_data))
```

|                       |                              |                                                                             |
|:----------------------|:-----------------------------|:----------------------------------------------------------------------------|
| wmo_id                | 87736                        | 87736                                                                       |
| Day                   | 4                            | 3                                                                           |
| Hour                  | 0                            | 18                                                                          |
| Cloud_base_height     | 2500 m or more, or no clouds | 2500 m or more, or no clouds                                                |
| Visibility            | 15000                        | 15000                                                                       |
| Total_cloud_cover     | 0                            | 1                                                                           |
| Wind_direction        | 0                            | 27                                                                          |
| Wind_speed            | 0                            | 8                                                                           |
| Wind_speed_unit       | knots                        | knots                                                                       |
| Air_temperature       | 20.4                         | 25.4                                                                        |
| Dew_point             | 10.6                         | 5.2                                                                         |
| Relative_humidity     | 53.4                         | 27.3                                                                        |
| Station_pressure      | 998.2                        | 1000.5                                                                      |
| MSLP_GH               | 1007.4                       | 1009.8                                                                      |
| Charac_pressure_tend  | Unknown                      | Unknown                                                                     |
| Cloud_amount_Nh       | NA                           | 0                                                                           |
| Low_clouds_CL         | NA                           | No clouds                                                                   |
| Medium_clouds_CM      | NA                           | No clouds                                                                   |
| High_clouds_CH        | NA                           | Ci and Cs, or Cs                                                            |
| Max_temperature       | 26.6                         | NA                                                                          |
| Min_temperature       | 15.8                         | NA                                                                          |
| Cloud_drift_direction | NA                           | Stationary or No clouds - Stationary or No clouds - Stationary or No clouds |
| Cloud_layer_1         | NA                           | 1/8 - Cs - 6000 m                                                           |

All the columns associated with information not present in the SYNOP
messages are removed by default. If for some reason you don’t want that,
set `remove_empty_cols = FALSE`.

The optional `wmo_identifier` argument allows for automatic filtering in
case the data contains messages from different stations. If you are
working with thousands of SYNOP strings from multiple stations, this
built-in filtering becomes extremely convenient.

``` r
library(synopR)
# Messages from 87736 and 87016
mixed_synop <- c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                 "AAXX 04033 87016 41460 83208 10200 20194 39712 40114 50003 70292 888// 333 56699 82810 88615="
                 )

colorado_data <- show_synop_data(mixed_synop, wmo_identifier = '87736', remove_empty_cols = TRUE)
#> Warning in show_synop_data(mixed_synop, wmo_identifier = "87736",
#> remove_empty_cols = TRUE): 1 message(s) do not contain the identifier '87736'
#> and will be discarded.
knitr::kable(t(colorado_data))
```

|                       |                                                       |
|:----------------------|:------------------------------------------------------|
| wmo_id                | 87736                                                 |
| Day                   | 1                                                     |
| Hour                  | 18                                                    |
| Cloud_base_height     | 300 to 600 m                                          |
| Visibility            | 15000                                                 |
| Total_cloud_cover     | 2                                                     |
| Wind_direction        | 0                                                     |
| Wind_speed            | 0                                                     |
| Wind_speed_unit       | knots                                                 |
| Air_temperature       | 32.6                                                  |
| Dew_point             | 21.5                                                  |
| Relative_humidity     | 52.1                                                  |
| Station_pressure      | 997.4                                                 |
| MSLP_GH               | 1006.4                                                |
| Charac_pressure_tend  | Unknown                                               |
| Precipitation_S1      | 0                                                     |
| Precip_period_S1      | 6                                                     |
| Cloud_amount_Nh       | 2                                                     |
| Low_clouds_CL         | Cu humilis and/or fractus                             |
| Medium_clouds_CM      | No clouds                                             |
| High_clouds_CH        | No clouds                                             |
| Cloud_drift_direction | W - Stationary or No clouds - Stationary or No clouds |
| Cloud_layer_1         | 2/8 - Cu - 540 m                                      |

A complete and detailed table with the meaning and details of all the
columns returned by
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
is available in the vignette “Extracted data reference”.

## Workflow with Ogimet

[Ogimet](https://www.ogimet.com) is a known and respectable source of
SYNOP messages.
[`download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/download_from_ogimet.md)
can be used to download SYNOP messages from this webpage. You will need
the WMO identifier of the station of interest. The period of interest
can’t be longer than 370 days. Be aware that the result will contain
prefixes added by Ogimet, with information regarding WMO id and date.
However, this is not an issue, as we can employ
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).
This tool is designed to separate these aggregates from the raw SYNOP
message for processing
([`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
will make use of these aggregates and will add the columns ‘Year’ and
‘Month’).

``` r
library(synopR)

# Suppose we have downloaded this data with:
# download_from_ogimet("87736","2026-02-01","2026-02-01")
data_input <- data.frame(synops = c("87736,2026,02,01,03,00,AAXX 01034 87736 NIL=",
                                    "87736,2026,02,01,06,00,AAXX 01064 87736 NIL=",
                                    "87736,2026,02,01,09,00,AAXX 01094 87736 NIL=",
                                    "87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=",
                                    "87736,2026,02,01,15,00,AAXX 01154 87736 NIL=",
                                    "87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                                    "87736,2026,02,01,21,00,AAXX 01214 87736 NIL="))

# Note that `parse_ogimet(data_input)` is incorrect
data_from_ogimet <- parse_ogimet(data_input$synops) 

# 'Year' and 'Month' column are included!
# 'NIL' messages are ignored
parse_ogimet(data_input$synops) |> show_synop_data() |> t() |> knitr::kable()
#> Warning in show_synop_data(parse_ogimet(data_input$synops)): 5 NIL messages
#> detected and removed.
```

|                       |                                   |                                                       |
|:----------------------|:----------------------------------|:------------------------------------------------------|
| wmo_id                | 87736                             | 87736                                                 |
| Year                  | 2026                              | 2026                                                  |
| Month                 | 2                                 | 2                                                     |
| Day                   | 1                                 | 1                                                     |
| Hour                  | 12                                | 18                                                    |
| Cloud_base_height     | 2500 m or more, or no clouds      | 300 to 600 m                                          |
| Visibility            | 15000                             | 15000                                                 |
| Total_cloud_cover     | 3                                 | 2                                                     |
| Wind_direction        | 18                                | 0                                                     |
| Wind_speed            | 8                                 | 0                                                     |
| Wind_speed_unit       | knots                             | knots                                                 |
| Air_temperature       | 24.0                              | 32.6                                                  |
| Dew_point             | 21.0                              | 21.5                                                  |
| Relative_humidity     | 83.3                              | 52.1                                                  |
| Station_pressure      | 999.2                             | 997.4                                                 |
| MSLP_GH               | 1008.2                            | 1006.4                                                |
| Charac_pressure_tend  | Unknown                           | Unknown                                               |
| Precipitation_S1      | 10                                | 0                                                     |
| Precip_period_S1      | 24                                | 6                                                     |
| Cloud_amount_Nh       | 2                                 | 2                                                     |
| Low_clouds_CL         | No clouds                         | Cu humilis and/or fractus                             |
| Medium_clouds_CM      | Ac translucidus or opacus         | No clouds                                             |
| High_clouds_CH        | Ci and Cs, or Cs                  | No clouds                                             |
| Max_temperature       | 28.2                              | NA                                                    |
| Min_temperature       | 21.6                              | NA                                                    |
| Cloud_drift_direction | Stationary or No clouds - SW - SW | W - Stationary or No clouds - Stationary or No clouds |
| Cloud_layer_1         | 2/8 - Ac - 3000 m                 | 2/8 - Cu - 540 m                                      |

Here, we didn’t make use of
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md).
But, it must be said that a data frame with multiple columns —where the
SYNOP column is not explicitly specified— will be accepted **if and only
if that data frame is the direct output of**
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

All these steps (download, parse, check and decode) are included in one
single function,
[`direct_download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/direct_download_from_ogimet.md),
which will return the direct decoded result.
