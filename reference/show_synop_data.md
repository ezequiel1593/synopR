# Decode multiple SYNOP messages

This function decodes a vector or data frame column of SYNOP strings
belonging to the same or different meteorological surface station.

## Usage

``` r
show_synop_data(data, wmo_identifier = NULL, remove_empty_cols = TRUE)
```

## Arguments

- data:

  A character vector, a data frame column containing raw SYNOP strings,
  or the exact data frame returned by
  [`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md).

- wmo_identifier:

  A 5-digit character string or integer representing the station WMO ID.
  If NULL (default), all messages are decoded.

- remove_empty_cols:

  Logical. Should columns containing only `NA` values be removed?
  Default is TRUE.

## Value

A data frame where each row represents one observation time and each
column a decoded meteorological variable.

1.  wmo_id - WMO station identifier

2.  Year - (from parse_ogimet())

3.  Month - (from parse_ogimet())

4.  Day - As informed by Section 0

5.  Hour - As informed by Section 0

6.  Cloud_base_height - Lowest cloud base height, in intervals

7.  Visibility - In meters

8.  Total_cloud_cover - In oktas, 9 means 'invisible' sky by fog or
    other phenomenon

9.  Wind_direction - In tens of degree, 99 means 'variable wind
    direction'

10. Wind_speed

11. Wind_speed_unit - Either 'm/s' or 'knots'

12. Air_temperature - In degrees Celsius

13. Dew_point - In degrees Celsius

14. Relative_humidity - As a percentage

15. Station_pressure - In hPa

16. MSLP_GH - Mean sea level pressure (in hPa) or geopotential height
    (in gpm)

17. Pressure_tendency - In hPa

18. Charac_pressure_tend - String, simplified decoding

19. Precipitation_S1 - In mm

20. Precip_period_S1 - In hours ('Precipitation_S1' fell in the last
    'Precip_period_S1' hours)

21. Present_weather - String, simplified decoding

22. Past_weather1 - String, simplified decoding

23. Past_weather2 - String, simplified decoding

24. Cloud_amount_Nh - Cloud coverage from low or medium cloud, same as
    'Total_cloud_cover'

25. Low_clouds_CL - String, simplified decoding

26. Medium_clouds_CM - String, simplified decoding

27. High_clouds_CH - String, simplified decoding

28. Max_temperature - In degrees Celsius

29. Min_temperature - In degrees Celsius

30. Ground_state - String, simplified decoding

31. Ground_temperature - Integer, in degrees Celsius

32. Snow_ground_state - String, simplified decoding

33. Snow_depth - In cm

34. Ev_Evt - Evaporation (ev) or evapotranspiration (evt), in mm

35. Sunshine_daily - In hours (generally from the previous civil day)

36. Positive_Net_Rad_last_24h - In J/cm^2

37. Negative_Net_Rad_last_24h - In J/cm^2

38. Global_Solar_Rad_last_24h - In J/cm^2

39. Diffused_Solar_Rad_last_24h - In J/cm^2

40. Downward_LongWave_Rad_last_24h - In J/cm^2

41. Upward_LongWave_Rad_last_24h - In J/cm^2

42. ShortWave_Rad_last_24h - In J/cm^2

43. Net_ShortWave_Rad_last_24h - In J/cm^2

44. Direct_Solar_Rad_last_24h - In J/cm^2

45. Sunshine_last_hour - In hours

46. Positive_Net_Rad_last_hour - In kJ/m^2

47. Negative_Net_Rad_last_hour - In kJ/m^2

48. Global_Solar_Rad_last_hour - In kJ/m^2

49. Diffused_Solar_Rad_last_hour - In kJ/m^2

50. Downward_LongWave_Rad_last_hour - In kJ/m^2

51. Upward_LongWave_Rad_last_hour - In kJ/m^2

52. ShortWave_Rad_last_hour - In kJ/m^2

53. Net_ShortWave_Rad_last_hour - In kJ/m^2

54. Direct_Solar_Rad_last_hour - In kJ/m^2

55. Cloud_drift_direction - In cardinal and intercardinal directions for
    "low - medium - high" clouds

56. Cloud_elevation_direction - String indicating genera, direction and
    elevation angle

57. Pressure_change_last_24h - In hPa

58. Precipitation_S3 - In mm

59. Precip_period_S3 - In hours ('Precipitation_S3' fell in the last
    'Precip_period_S3' hours)

60. Precipitation_last_24h - In mm

61. Cloud_layer_1 - String indicating cover, genera and height

62. Cloud_layer_2 - String indicating cover, genera and height

63. Cloud_layer_3 - String indicating cover, genera and height

64. Cloud_layer_4 - String indicating cover, genera and height

## Examples

``` r
msg <- paste0("AAXX 01123 87736 32965 13205 10214 20143 ",
              "30022 40113 5//// 80005 333 10236 20128 56000 81270=")
synop_df <- data.frame(messages = msg)
decoded_data <- show_synop_data(synop_df)
```
