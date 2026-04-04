
# get_visibility_hcloud_and_indicators()
h_labels <- c("0" = "0 to 50 m",
              "1" = "50 to 100 m",
              "2" = "100 to 200 m",
              "3" = "200 to 300 m",
              "4" = "300 to 600 m",
              "5" = "600 to 1000 m",
              "6" = "1000 to 1500 m",
              "7" = "1500 to 2000 m",
              "8" = "2000 to 2500 m",
              "9" = "2500 m or more, or no clouds",
              "/" = "Unknown")

# get_pressure_tendency()
ctp_labels <- c("0" = "Inc, then dec",
                "1" = "Inc, then steady or inc more slowly",
                "2" = "Inc",
                "3" = "Non-inc, then inc; or inc more rapidly",
                "4" = "Steady",
                "5" = "Dec, then inc",
                "6" = "Dec, then steady or dec more slowly",
                "7" = "Dec",
                "8" = "Non-dec, then dec; or dec more rapidly",
                "/" = "Unknown")


# get_present_past_weather()
weather_labels <- c(
  "00"="NSW", "01"="NSW", "02"="NSW", "03"="NSW",
  "04"="Smoke or volcanic ashes", "05"="Haze", "06"="Dust", "07"="Dust", "08"="Dust or sand whirl(s)",
  "09"="Duststorm or sandstorm", "10"="Mist", "11"="Shallow fog or ice fog", "12"="Shallow fog or ice fog",
  "13"="Lightning", "14"="Virga", "15"="Precipitation within sight", "16"="Precipitation within sight",
  "17"="Thunderstorm, but no precipitation", "18"="Squalls", "19"="Funnel cloud(s)",
  "20"="Recent drizzle or snow grains", "21"="Recent rain", "22"="Recent snow",
  "23"="Recent rain and snow or ice pellets", "24"="Recent freezing drizzle or freezing rain",
  "25"="Recent shower(s) of rain", "26"="Recent shower(s) of snow, or of rain and snow",
  "27"="Recent shower(s) of hail, or of rain and hail", "28"="Recent fog or ice fog",
  "29"="Recent thunderstorm", "30"="Duststorm or sandstorm", "31"="Duststorm or sandstorm",
  "32"="Duststorm or sandstorm", "33"="Duststorm or sandstorm", "34"="Duststorm or sandstorm",
  "35"="Duststorm or sandstorm", "36"="Drifting snow", "37"="Drifting snow", "38"="Blowing snow",
  "39"="Blowing snow", "40"="Fog or ice fog", "41"="Fog or ice fog", "42"="Fog or ice fog",
  "43"="Fog or ice fog", "44"="Fog or ice fog", "45"="Fog or ice fog", "46"="Fog or ice fog",
  "47"="Fog or ice fog", "48"="Fog, depositing rime", "49"="Fog, depositing rime", "50"="Drizzle",
  "51"="Drizzle", "52"="Drizzle", "53"="Drizzle", "54"="Drizzle", "55"="Drizzle", "56"="Drizzle, freezing",
  "57"="Drizzle, freezing", "58"="Drizzle and rain", "59"="Drizzle and rain", "60"="Rain", "61"="Rain",
  "62"="Rain", "63"="Rain", "64"="Rain", "65"="Rain", "66"="Rain, freezing", "67"="Rain, freezing",
  "68"="Rain or drizzle and snow", "69"="Rain or drizzle and snow", "70"="Snowflakes", "71"="Snowflakes",
  "72"="Snowflakes", "73"="Snowflakes", "74"="Snowflakes", "75"="Snowflakes", "76"="Diamond dust",
  "77"="Snow grains", "78"="Isolated star-like snow crystals", "79"="Ice pellets", "80"="Rain shower(s)",
  "81"="Rain shower(s)", "82"="Rain shower(s)", "83"="Shower(s) of rain and snow mixed",
  "84"="Shower(s) of rain and snow mixed", "85"="Snow shower(s)", "86"="Snow shower(s)",
  "87"="Shower(s) of snow pellets or hail", "88"="Shower(s) of snow pellets or hail", "89"="Shower(s) of hail",
  "90"="Shower(s) of hail", "91"="Rain, recent thunderstorm", "92"="Rain, recent thunderstorm",
  "93"="Snow, or rain and snow mixed or hail, recent thunderstorm",
  "94"="Snow, or rain and snow mixed or hail, recent thunderstorm", "95"="Thunderstorm",
  "96"="Thunderstorm with hail", "97"="Thunderstorm", "98"="Thunderstorm with duststorm or sandstorm",
  "99"="Thunderstorm with hail",
  '//' = 'Unknown'
)

past_weather_labels <- c(
  "0"="NSW", "1"="NSW", "2"="NSW",
  "3"="Sandstorm, duststorm or blowing snow",
  "4"="Fog or ice fog or thick haze",
  "5"="Drizzle",
  "6"="Rain",
  "7"="Snow, or rain and snow mixed",
  "8"="Shower(s)",
  "9"="Thunderstorm(s)",
  '/' = 'Unknown'
)

weather_autom_labels <- c(
  "00"="NSW", "01"="NSW", "02"="NSW", "03"="NSW",
  "04"="Haze, smoke or dust",
  "05"="Haze, smoke or dust",
  "10"="Mist",
  "11"="Diamond dust",
  "12"="Distant lightning",
  "18"="Squalls",
  "20"="Recent fog",
  "21"="Recent precipitation",
  "22"="Recent drizzle or snow grains",
  "23"="Recent rain",
  "24"="Recent snow",
  "25"="Recent drizzle or freezing rain",
  "26"="Recent thunderstorm",
  "27"="Blowing or drifting snow or sand",
  "28"="Blowing or drifting snow or sand",
  "29"="Blowing or drifting snow or sand",
  "30"="Fog",
  "31"="Fog or ice fog",
  "32"="Fog or ice fog",
  "33"="Fog or ice fog",
  "34"="Fog or ice fog",
  "35"="Fog, depositing rime",
  "40"="Precipitation",
  "41"="Precipitation",
  "42"="Precipitation",
  "43"="Liquid precipitation",
  "44"="Liquid precipitation",
  "45"="Solid precipitation",
  "46"="Solid precipitation",
  "47"="Freezing precipitation",
  "48"="Freezing precipitation",
  "50"="Drizzle", "51"="Drizzle", "52"="Drizzle", "53"="Drizzle",
  "54"="Drizzle, freezing", "55"="Drizzle, freezing", "56"="Drizzle, freezing",
  "57"="Drizzle and rain", "58"="Drizzle and rain",
  "60"="Rain", "61"="Rain", "62"="Rain", "63"="Rain",
  "64"="Rain, freezing", "65"="Rain, freezing", "66"="Rain, freezing",
  "67"="Rain (or drizzle) and snow", "68"="Rain (or drizzle) and snow",
  "70"="Snow", "71"="Snow", "72"="Snow", "73"="Snow",
  "74"="Ice pellets", "75"="Ice pellets", "76"="Ice pellets",
  "77"="Snow grains", "78"="Ice crystals",
  "80"="Shower(s)",
  "81"="Rain shower(s)", "82"="Rain shower(s)", "83"="Rain shower(s)", "84"="Rain shower(s)",
  "85"="Snow shower(s)", "86"="Snow shower(s)", "87"="Snow shower(s)",
  "89"="Hail",
  "90"="Thunderstorm",
  "91"="Thunderstorm with no precipitation",
  "92"="Thunderstorm with rain and/or snow showers",
  "93"="Thunderstorm with hail",
  "94"="Thunderstorm with no precipitation",
  "95"="Thunderstorm with rain and/or snow showers",
  "96"="Thunderstorm with hail",
  "99"="Tornado",
  '//' = 'Unknown'
)

past_weather_autom_labels <- c(
  "0"="NSW",
  "1"="Visibility reduced",
  "2"="Blowing phenomena",
  "3"="Fog",
  "4"="Precipitation",
  "5"="Drizzle",
  "6"="Rain",
  "7"="Snow, or ice pellets",
  "8"="Showers",
  "9"="Thunderstorm",
  '/' = 'Unknown'
)

# get_cloudiness()
low_cloud_labels <- c(
  "0" = "No clouds",
  "1" = "Cu humilis and/or fractus",
  "2" = "Cu mediocris or congestus",
  "3" = "Cb calvus",
  "4" = "Sc cumulogenitus",
  "5" = "Sc non-cumulogenitus",
  "6" = "St nebulosus and/or fractus",
  "7" = "St and/or Cu, fractus",
  "8" = "Cu and Sc non-cumulogenitus",
  "9" = "Cb capillatus",
  "/" = 'Unknown'
)

medium_cloud_labels <- c(
  "0" = "No clouds",
  "1" = "As translucidus",
  "2" = "As opacus or Ns",
  "3" = "Ac translucidus",
  "4" = "Ac translucidus",
  "5" = "Ac translucidus or opacus",
  "6" = "Ac cumulogenitus",
  "7" = "Ac translucidus or opacus",
  "8" = "Ac castellanus or floccus",
  "9" = "Ac of chaotic sky",
  "/" = 'Unknown'
)

high_cloud_labels <- c(
  "0" = "No clouds",
  "1" = "Ci fibratus",
  "2" = "Ci spissatus, castellanus or floccus",
  "3" = "Ci spissatus cumulonimbogenitus",
  "4" = "Ci uncinus and/or fibratus",
  "5" = "Ci and Cs, or Cs",
  "6" = "Ci and Cs, or Cs",
  "7" = "Cs",
  "8" = "Cs",
  "9" = "Cc",
  "/" = 'Unknown'
)

# get_ground_temp
state_ground_wosnow_label <- c("0" = "Dry",
                                "1" = "Moist",
                                "2" = "Wet",
                                "3" = "Flooded",
                                "4" = "Frozen",
                                "5" = "Glaze on it",
                                "6" = "Loose dry dust or sand",
                                "7" = "Thin cover of loose dry dust or sand",
                                "8" = "Moderate or thick cover of loose dry dust or sand",
                                "9" = "Extremely dry with cracks",
                                "/" = "Unknown")

# get_snow_depth
state_ground_snow_label <- c("0" = "Ice",
                              "1" = "Compact or wet snow - Less than 1/2 covered",
                              "2" = "Compact or wet snow - At least 1/2 covered",
                              "3" = "Compact or wet snow - Completely covered evenly",
                              "4" = "Compact or wet snow - Completely covered unevenly",
                              "5" = "Loose dry snow - Less than 1/2 covered",
                              "6" = "Loose dry snow - At least 1/2 covered",
                              "7" = "Loose dry snow - Completely covered evenly",
                              "8" = "Loose dry snow - Completely covered unevenly",
                              "9" = "Deep drifts - Completely covered",
                              "/" = "Unknown")


# get_direction_cloud_drift_vec()
# get_cloud_elevation_direction_vec()
directions_label <- c("0" = "Stationary or No clouds",
                      "1" = "NE",
                      "2" = "E",
                      "3" = "SE",
                      "4" = "S",
                      "5" = "SW",
                      "6" = "W",
                      "7" = "NW",
                      "8" = "N",
                      "9" = "Unknown",
                      "/" = "Unknown")


# get_cloud_elevation_direction_vec()
# get_cloud_layer_vec
genera_label <- c('0' = 'Ci', '1' = 'Cc', '2' = 'Cs',
                  '3' = 'Ac', '4' = 'As', '5' = 'Ns',
                  '6' = 'Sc', '7' = 'St', '8' = 'Cu', '9' = 'Cb',
                  '/' = 'Unkown')

# get_cloud_elevation_direction_vec()
elevation_angle_label <- c("0" = "Top not visible",
                           "1" = "> 45 deg", "about 2 deg" = "about 30 deg",
                           "3" = "about 20 deg", "4" = "about 15 deg",
                           "5" = "about 12 deg", "6" = "about 9 deg",
                           "7" = "about 7 deg", "8" = "about 6 deg",
                           "9" = "< 5 deg", "/" = 'Unkown')

