# Introducing synopR

**2026-03-06**

## Standard workflow

[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
requires a character vector or a data frame column where each element is
a SYNOP string.

``` r
library(synopR)
data_input_vector <- c("AAXX 04003 87736 32965 00000 10204 20106 39982 40074 5//// 333 10266 20158 555 64169 65090 =",
                       "AAXX 01094 87736 NIL=",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 81270 =")

my_data <- show_synop_data(data_input_vector, wmo_identifier = '87736')

print(my_data)
#> # A tibble: 3 × 54
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      4     0                 9         65                 0
#> 2 87736      1     9                NA         NA                NA
#> 3 87736      3    18                 9         65                 1
#> # ℹ 48 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Wind_speed_unit <chr>, Air_temperature <dbl>, Dew_point <dbl>,
#> #   Relative_humidity <dbl>, Station_pressure <dbl>, MSLP_GH <dbl>,
#> #   Present_weather <dbl>, Past_weather1 <dbl>, Past_weather2 <dbl>,
#> #   Precipitation_S1 <dbl>, Precip_period_S1 <dbl>, Cloud_amount_Nh <dbl>,
#> #   Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>, High_clouds_CH <dbl>,
#> #   Max_temperature <dbl>, Min_temperature <dbl>, Ground_state <dbl>, …
```

If a meteorological parameter isn’t present in any of the SYNOP
messages, you can set `remove_empty_cols = TRUE` to remove the extra
columns.

The optional `wmo_identifier` argument offers a significant advantage:
it allows for automatic filtering in case the data contains messages
from other stations.

While the following example uses a vector with only two messages for
simplicity, if you are working with thousands of SYNOP strings from
multiple stations, this built-in filtering becomes extremely convenient.

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
| Cloud_base_height     | 4                                                     |
| Visibility            | 65                                                    |
| Total_cloud_cover     | 2                                                     |
| Wind_direction        | 0                                                     |
| Wind_speed            | 0                                                     |
| Wind_speed_unit       | knots                                                 |
| Air_temperature       | 32.6                                                  |
| Dew_point             | 21.5                                                  |
| Relative_humidity     | 52.1                                                  |
| Station_pressure      | 997.4                                                 |
| MSLP_GH               | 1006.4                                                |
| Precipitation_S1      | 0                                                     |
| Precip_period_S1      | 6                                                     |
| Cloud_amount_Nh       | 2                                                     |
| Low_clouds_CL         | 1                                                     |
| Medium_clouds_CM      | 0                                                     |
| High_clouds_CH        | 0                                                     |
| Cloud_drift_direction | W - Stationary or No clouds - Stationary or No clouds |

It is good practice to check the SYNOP messages for non-standard
structures. The
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
function is designed to handle these. It will make sure every message
starts with “AAXX” and ends with “=”, does not contain invalid
characters (valid characters after removing “AAXX” and “=” are digits
0-9, ‘/’ and ‘NIL’), and verifies that all groups consist of 5 digits
(except for the section identifiers ‘333’ and ‘555’).

The
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
function accepts either a string vector or a specific data frame column
containing SYNOP strings. A data frame with multiple columns —where the
SYNOP column is not explicitly specified— will be accepted **if and only
if that data frame is the direct output of**
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

``` r
library(synopR)

my_df <- data.frame(syn = c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                            "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818="),
                    second_column = c(5,7))

check_synop(my_df) # Bad
#> # A tibble: 2 × 2
#>   is_valid error_log                                                
#>   <lgl>    <chr>                                                    
#> 1 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 5
#> 2 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 7

check_synop(my_df$syn) # Good
#> # A tibble: 2 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""
```

So far, our messages have a correct structure (even the NIL ones). Now,
let’s see what happens when they don’t.

``` r
library(synopR)

check_synop(c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 6000182100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 2021 39974 40064 5//// 60001 82100 333 56600 82818=",
              "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818",
              "Not a synop message="))
#> # A tibble: 5 × 2
#>   is_valid error_log                                              
#>   <lgl>    <chr>                                                  
#> 1 TRUE     ""                                                     
#> 2 FALSE    "Invalid groups: 6000182100"                           
#> 3 FALSE    "Invalid groups: 2021"                                 
#> 4 FALSE    "Missing '=' terminator"                               
#> 5 FALSE    "Missing AAXX | Invalid groups: Not, a, synop, message"
```

[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
returns a tibble where the first column indicates whether each SYNOP is
valid (TRUE) or not (FALSE), and the second column describes the
specific error found. In our example:

- The first SYNOP is correct.
- In the second, there is a missing space between groups 6 and 8 in
  Section 1.
- In the third, group 2 of Section 3 contains only 4 digits.
- The fourth message is missing the “=” terminator (remember that SYNOP
  messages must always start with “AAXX” and end with “=”).
- The fifth is simply not a SYNOP string at all.

## Workflow with Ogimet

The following SYNOP messages were retrieved from
[Ogimet](https://www.ogimet.com/cgi-bin/getsynop?block=87736&begin=202602010300&end=202602012300)
for the Rio Colorado station, Argentina (WMO identifier: 87736). We will
observe that these are not “pure” SYNOP strings; they include a prefix
added by Ogimet that specifies the station ID (87736) along with the
date and time of the observation.

However, this is not an issue, as we can use the
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md)
function. This tool is specifically designed to separate these
aggregates from the raw SYNOP message for processing.

``` r
library(synopR)

data_input <- data.frame(synops = c("87736,2026,02,01,03,00,AAXX 01034 87736 NIL=",
                                    "87736,2026,02,01,06,00,AAXX 01064 87736 NIL=",
                                    "87736,2026,02,01,09,00,AAXX 01094 87736 NIL=",
                                    "87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=",
                                    "87736,2026,02,01,15,00,AAXX 01154 87736 NIL=",
                                    "87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                                    "87736,2026,02,01,21,00,AAXX 01214 87736 NIL="))

# Note that `parse_ogimet(data_input)` is incorrect
data_from_ogimet <- parse_ogimet(data_input$synops) 

print(data_from_ogimet)
#> # A tibble: 7 × 5
#>    Year Month Day_Ogimet Hour_Ogimet Raw_synop                                  
#>   <dbl> <dbl>      <dbl>       <dbl> <chr>                                      
#> 1  2026     2          1           3 AAXX 01034 87736 NIL=                      
#> 2  2026     2          1           6 AAXX 01064 87736 NIL=                      
#> 3  2026     2          1           9 AAXX 01094 87736 NIL=                      
#> 4  2026     2          1          12 AAXX 01123 87736 12965 31808 10240 20210 3…
#> 5  2026     2          1          15 AAXX 01154 87736 NIL=                      
#> 6  2026     2          1          18 AAXX 01183 87736 12465 20000 10326 20215 3…
#> 7  2026     2          1          21 AAXX 01214 87736 NIL=

# A 'Year' column is included!
parse_ogimet(data_input$synops) |> show_synop_data(wmo_identifier = 87736, remove_empty_cols = TRUE)
#> # A tibble: 7 × 25
#>   wmo_id  Year Month   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl> <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736   2026     2     1     3                NA         NA                NA
#> 2 87736   2026     2     1     6                NA         NA                NA
#> 3 87736   2026     2     1     9                NA         NA                NA
#> 4 87736   2026     2     1    12                 9         65                 3
#> 5 87736   2026     2     1    15                NA         NA                NA
#> 6 87736   2026     2     1    18                 4         65                 2
#> 7 87736   2026     2     1    21                NA         NA                NA
#> # ℹ 17 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Wind_speed_unit <chr>, Air_temperature <dbl>, Dew_point <dbl>,
#> #   Relative_humidity <dbl>, Station_pressure <dbl>, MSLP_GH <dbl>,
#> #   Precipitation_S1 <dbl>, Precip_period_S1 <dbl>, Cloud_amount_Nh <dbl>,
#> #   Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>, High_clouds_CH <dbl>,
#> #   Max_temperature <dbl>, Min_temperature <dbl>, Cloud_drift_direction <chr>
```

## Limitations

### General limitations

- The validity of a SYNOP string doesn’t mean its content is correct. A
  quality-control of the derived data is not included. Data
  post-processing is on you.

- Group 555 (reserved for national distribution) is currently ignored,
  as its content varies by country. However, future versions of
  **synopR** may include functions to extract data from this section
  based on user requirements.

- There is no support for sections 222 y 444.
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  will incorrectly decode the message.

### Specific limitations

The following meteorological parameters are not completely decoded, as
they will not produce a strictly numeric vector, or the output would be
too long:

- Horizontal visibility `VV`
- Lowest cloud base height `h`
- Cloud cover `N` and `Nh`, **but** they can be directly interpreted as
  in oktas (octaves), except when it’s 9, which means the sky is not
  visible due to fog or other meteorological phenomenon
- Present and past weather `ww`, `W1`, `W2`, cloud-related `Cl`, `Cm`
  and `Ch`. ground-related `E` and `E'`

However, **Code tables are available** in the section “Code Tables” for
direct conversions!

You should also be aware of this:

- Wind direction = 99 means “variable wind direction”
- Wind speed greater than 99 units (m/s or knots) are not supported (the
  final result will be 99), but it’s expected it won’t break the
  function
- If group 2 from section 1 informs relative humidity instead of dew
  point, the final value in the Dew_point column will be NA
- For geopotential height, only pressure levels 850, 700 and 500 hPa are
  supported (others pressure levels will result in NA)
- Groups 5 and 9 from section 1 are ignored
- Imperceptible precipitation, codified as 990, is considered as 0.01
  (mm), so it can be distinguished from a 0 value
- A cloud description “/” (clouds not visible) is mapped to 10
- Snow depth `sss` is assumed to be between 1 cm and 996 cm. ‘997’ means
  ‘less than 0.5 cm’, 998 “Snow cover, not continuous” and 999
  “Measurement impossible or inaccurate”
- Groups 5 (including 55, 56, 57, etc…), 7, 8 and 9 from section 3 are
  ignored
