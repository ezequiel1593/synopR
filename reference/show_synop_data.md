# Decode multiple SYNOP messages from a single station

This function decodes a vector or data frame column of raw SYNOP strings
belonging to the same WMO station. It efficiently processes multiple
observations at once, returning a tidy data frame.

## Usage

``` r
show_synop_data(data, wmo_identifier = NULL, remove_empty_cols = FALSE)
```

## Arguments

- data:

  A character vector, or a data frame or tibble with one column
  containing raw SYNOP strings.

- wmo_identifier:

  A 5-digit character string or integer representing the station WMO ID.
  If NULL (default), all messages are decoded.

- remove_empty_cols:

  Logical. Should columns containing only `NA` values be removed?

## Value

A tidy tibble where each row represents one observation time and each
column a decoded meteorological variable.

1.  wmo_id - WMO station identifier

2.  Year - (from parse_ogimet())

3.  Day - As informed by Section 0

4.  Hour - As informed by Section 0

5.  Cloud_base_height - Lowest cloud base height, not decoded

6.  Visibility - Not decoded

7.  Total_cloud_cover - In oktas, 9 means 'invisible' sky by fog or
    other phenomenon

8.  Wind_direction - In tens of degree, 99 means 'variable wind
    direction'

9.  Wind_speed

10. Wind_speed_unit - Either 'm/s' or 'knots'

11. Air_temperature - In degrees Celsius

12. Dew_point - In degrees Celsius

13. Relative_humidity - As a percentage

14. Station_pressure - In hPa

15. MSLP_GH - Mean sea level pressure (in hPa) or geopotential height
    (in gpm)

16. Present_weather - Not decoded

17. Past_weather1 - Not decoded

18. Past_weather2 - Not decoded

19. Precipitation_S1 - In mm

20. Precip_period_S1 - In hours ('Precipitation_S1' fell in the last
    'Precip_period_S1' hours)

21. Cloud_amount_Nh - Cloud coverage from low or medium cloud, same as
    'Total_cloud_cover'

22. Low_clouds_CL - Not decoded

23. Medium_clouds_CM - Not decoded

24. High_clouds_CH - Not decoded

25. Max_temperature - In degrees Celsius

26. Min_temperature - In degrees Celsius

27. Ground_state - Not decoded

28. Ground_temperature - Integer, in degrees Celsius

29. Snow_ground_state - Not decoded

30. Snow_depth - In cm, is assumed to be between 1 and 996 cm

31. Precipitation_S3 - In mm

32. Precip_period_S3 - In hours ('Precipitation_S3' fell in the last
    'Precip_period_S3' hours)

## Examples

``` r
msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
              "30022 40113 5//// 80005 333 10236 20128 56000 81270=")
synop_df <- data.frame(messages = msg)
decoded_data <- show_synop_data(synop_df, "87736")
```
