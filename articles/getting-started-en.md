# Introducing synopR

**2026-03-04**

**synopR** has been designed to easily transform SYNOP messages into
tidy data frames ready for subsequent analysis.

## Workflow with Ogimet

Decoding with **synopR** is straightforward. Let’s start with SYNOP
messages retrieved from
[Ogimet](https://www.ogimet.com/cgi-bin/getsynop?block=87736&begin=202602010300&end=202602012300)
for the Rio Colorado station, Argentina (WMO identifier: 87736). After
downloading and saving the data as a .txt file, we can read it using
readLines().

``` r
# Temporary file
synop_file <- tempfile(fileext = ".txt")
writeLines(c("87736,2026,02,01,03,00,AAXX 01034 87736 NIL=",
"87736,2026,02,01,06,00,AAXX 01064 87736 NIL=",
"87736,2026,02,01,09,00,AAXX 01094 87736 NIL=",
"87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=",
"87736,2026,02,01,15,00,AAXX 01154 87736 NIL=",
"87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
"87736,2026,02,01,21,00,AAXX 01214 87736 NIL="), synop_file)

# Read the file
data_input <- data.frame(synops = readLines(synop_file))

print(data_input)
#>                                                                                                                       synops
#> 1                                                                               87736,2026,02,01,03,00,AAXX 01034 87736 NIL=
#> 2                                                                               87736,2026,02,01,06,00,AAXX 01064 87736 NIL=
#> 3                                                                               87736,2026,02,01,09,00,AAXX 01094 87736 NIL=
#> 4 87736,2026,02,01,12,00,AAXX 01123 87736 12965 31808 10240 20210 39992 40082 5//// 60104 82075 333 10282 20216 56055 82360=
#> 5                                                                               87736,2026,02,01,15,00,AAXX 01154 87736 NIL=
#> 6             87736,2026,02,01,18,00,AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=
#> 7                                                                               87736,2026,02,01,21,00,AAXX 01214 87736 NIL=
```

Take a look at the data. We can observe two specific characteristics.
First, there are NIL messages, which contain no meteorological data.
Second, these are not “pure” SYNOP strings; they include a prefix added
by Ogimet that specifies the station ID (87736) along with the date and
time of the observation.

However, this is not an issue, as we can use the
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md)
function. This tool is specifically designed to strip away these headers
and extract the raw SYNOP message for processing.

``` r
library(synopR)

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
```

Before decoding, it is good practice to check the SYNOP messages for
non-standard structures. Occasionally, errors occur where data groups
are not separated by spaces or contain only 4 digits instead of the
required 5. The
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
function is designed to handle these cases, ensuring the integrity of
the data before processing.

``` r

check_synop(data_from_ogimet$Raw_synop)
#> # A tibble: 7 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""       
#> 3 TRUE     ""       
#> 4 TRUE     ""       
#> 5 TRUE     ""       
#> 6 TRUE     ""       
#> 7 TRUE     ""

check_synop(data_from_ogimet)
#> # A tibble: 7 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""       
#> 3 TRUE     ""       
#> 4 TRUE     ""       
#> 5 TRUE     ""       
#> 6 TRUE     ""       
#> 7 TRUE     ""
```

The
[`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
function accepts either a character vector or a specific data frame
column containing SYNOP strings. A data frame with multiple columns
—where the SYNOP column is not explicitly specified— will be accepted
**if and only if that data frame is the direct output of**
[`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

``` r

my_df <- data.frame(syn = c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                            "AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818="),
                    second_column = c(5,7))

check_synop(my_df)
#> # A tibble: 2 × 2
#>   is_valid error_log                                                
#>   <lgl>    <chr>                                                    
#> 1 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 5
#> 2 FALSE    Missing AAXX | Missing '=' terminator | Invalid groups: 7

check_synop(my_df$syn)
#> # A tibble: 2 × 2
#>   is_valid error_log
#>   <lgl>    <chr>    
#> 1 TRUE     ""       
#> 2 TRUE     ""
```

So far, our messages have a correct structure (even the NIL ones). Now,
let’s see what happens when they don’t.

``` r

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

Now, we are ready to extract the information contained in the messages.
The
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
function is where the real work begins.

``` r

my_data <- show_synop_data(data_from_ogimet, wmo_identifier = '87736')

knitr::kable(t(my_data))
```

|                    |       |       |       |        |       |        |       |
|:-------------------|:------|:------|:------|:-------|:------|:-------|:------|
| wmo_id             | 87736 | 87736 | 87736 | 87736  | 87736 | 87736  | 87736 |
| Year               | 2026  | 2026  | 2026  | 2026   | 2026  | 2026   | 2026  |
| Month              | 2     | 2     | 2     | 2      | 2     | 2      | 2     |
| Day                | 1     | 1     | 1     | 1      | 1     | 1      | 1     |
| Hour               | 3     | 6     | 9     | 12     | 15    | 18     | 21    |
| Cloud_base_height  | NA    | NA    | NA    | 9      | NA    | 4      | NA    |
| Visibility         | NA    | NA    | NA    | 65     | NA    | 65     | NA    |
| Total_cloud_cover  | NA    | NA    | NA    | 3      | NA    | 2      | NA    |
| Wind_direction     | NA    | NA    | NA    | 18     | NA    | 0      | NA    |
| Wind_speed         | NA    | NA    | NA    | 8      | NA    | 0      | NA    |
| Air_temperature    | NA    | NA    | NA    | 24.0   | NA    | 32.6   | NA    |
| Dew_point          | NA    | NA    | NA    | 21.0   | NA    | 21.5   | NA    |
| Station_pressure   | NA    | NA    | NA    | 999.2  | NA    | 997.4  | NA    |
| Sea_level_pressure | NA    | NA    | NA    | 1008.2 | NA    | 1006.4 | NA    |
| Present_weather    | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Past_weather1      | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Past_weather2      | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precipitation_S1   | NA    | NA    | NA    | 10     | NA    | 0      | NA    |
| Precip_period_S1   | NA    | NA    | NA    | 24     | NA    | 6      | NA    |
| Cloud_amount_Nh    | NA    | NA    | NA    | 2      | NA    | 2      | NA    |
| Low_clouds_CL      | NA    | NA    | NA    | 0      | NA    | 1      | NA    |
| Medium_clouds_CM   | NA    | NA    | NA    | 7      | NA    | 0      | NA    |
| High_clouds_CH     | NA    | NA    | NA    | 5      | NA    | 0      | NA    |
| Max_temperature    | NA    | NA    | NA    | 28.2   | NA    | NA     | NA    |
| Min_temperature    | NA    | NA    | NA    | 21.6   | NA    | NA     | NA    |
| Ground_state       | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Ground_temperature | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Snow_ground_state  | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Snow_depth         | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precipitation_S3   | NA    | NA    | NA    | NA     | NA    | NA     | NA    |
| Precip_period_S3   | NA    | NA    | NA    | NA     | NA    | NA     | NA    |

The `wmo_identifier` argument might seem like an extra step, but it
offers a significant advantage: it allows for automatic filtering in
case the data contains messages from other stations.

While the following example uses a vector with only two messages for
simplicity, if you are working with thousands of SYNOP strings from
multiple stations, this built-in filtering becomes extremely convenient.

``` r

# Messages from 87736 and 87016
mixed_synop <- c("AAXX 01183 87736 12465 20000 10326 20215 39974 40064 5//// 60001 82100 333 56600 82818=",
                 "AAXX 04033 87016 41460 83208 10200 20194 39712 40114 50003 70292 888// 333 56699 82810 88615="
                 )

colorado_data <- show_synop_data(mixed_synop, wmo_identifier = '87736')
#> Warning in show_synop_data(mixed_synop, wmo_identifier = "87736"): 1 message(s)
#> do not contain the identifier '87736' and will be discarded.
print(colorado_data)
#> # A tibble: 1 × 29
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      1    18                 4         65                 2
#> # ℹ 23 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Air_temperature <dbl>, Dew_point <dbl>, Station_pressure <dbl>,
#> #   Sea_level_pressure <dbl>, Present_weather <dbl>, Past_weather1 <dbl>,
#> #   Past_weather2 <dbl>, Precipitation_S1 <dbl>, Precip_period_S1 <dbl>,
#> #   Cloud_amount_Nh <dbl>, Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>,
#> #   High_clouds_CH <dbl>, Max_temperature <dbl>, Min_temperature <dbl>,
#> #   Ground_state <dbl>, Ground_temperature <dbl>, Snow_ground_state <dbl>, …
```

## Standard workflow

All
[`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
requires is a character vector or a data frame column where each element
is a SYNOP string.

``` r

data_input_vector <- c("AAXX 04003 87736 32965 00000 10204 20106 39982 40074 5//// 333 10266 20158 555 64169 65090 =",
                       "AAXX 01094 87736 NIL=",
                       "AAXX 03183 87736 32965 12708 10254 20052 30005 40098 5//// 80005 333 56000 81270 =")

my_data <- show_synop_data(data_input_vector, wmo_identifier = '87736')

print(my_data)
#> # A tibble: 3 × 29
#>   wmo_id   Day  Hour Cloud_base_height Visibility Total_cloud_cover
#>   <chr>  <dbl> <dbl>             <dbl>      <dbl>             <dbl>
#> 1 87736      4     0                 9         65                 0
#> 2 87736      1     9                NA         NA                NA
#> 3 87736      3    18                 9         65                 1
#> # ℹ 23 more variables: Wind_direction <dbl>, Wind_speed <dbl>,
#> #   Air_temperature <dbl>, Dew_point <dbl>, Station_pressure <dbl>,
#> #   Sea_level_pressure <dbl>, Present_weather <dbl>, Past_weather1 <dbl>,
#> #   Past_weather2 <dbl>, Precipitation_S1 <dbl>, Precip_period_S1 <dbl>,
#> #   Cloud_amount_Nh <dbl>, Low_clouds_CL <dbl>, Medium_clouds_CM <dbl>,
#> #   High_clouds_CH <dbl>, Max_temperature <dbl>, Min_temperature <dbl>,
#> #   Ground_state <dbl>, Ground_temperature <dbl>, Snow_ground_state <dbl>, …
```

Group 555 (reserved for national distribution) is currently ignored, as
its content varies by country. However, future versions of **synopR**
may include functions to extract data from this section based on user
requirements.

## Limitations

**synopR** don’t accept sections 222 y 444. Please visit the official
[GitHub](https://github.com/ezequiel1593/synopR) repository for more
information regarding limitations and assumptions.
