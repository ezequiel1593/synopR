# Changelog

## synopR 0.3.0.9000

- New function
  [`download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/download_from_ogimet.md)
  to retrieve SYNOP messages from Ogimet.com.
- More data can be obtained with
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md):
  19 related with sunshine and solar radiation, plus data about cloud
  drift, pressure change and precipitation from the last 24h.
- `stringr` is no longer a direct dependency, in favor of R base, which
  resulted in improved speed (tested with `microbenchmark` package). For
  example, an internal function responsible for validating every single
  group is now 10x faster.
- The `purrr` dependency has been changed to `furrr`.
- [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  and
  [`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
  are now compatible with the future ecosystem for optional parallel
  processing.
- Argument “remove_empty_cols” default value from
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  have been changed from FALSE to TRUE.

## synopR 0.2.2

CRAN release: 2026-03-18

- CRAN release
- The argument “wmo_identifier” from
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  is now optional.
- Column “Sea_level_pressure” from
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  has been changed to “MSLP_GH” as geopotential heights for the pressure
  levels 850, 700 and 500 hPa are now supported
- Tests with ~ 4000 SYNOP messages from Argentina resulted in
  improvement of internal functions, which now can better handle
  potential errors

## synopR 0.2.0

- Found out some SYNOP downloaded from Ogimet end with “==” instead of
  “=”, now
  [`parse_ogimet()`](https://ezequiel9315.github.io/synopR/reference/parse_ogimet.md)
  can fix it. Also,
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  and
  [`check_synop()`](https://ezequiel9315.github.io/synopR/reference/check_synop.md)
  are now aware of this.
- Added new argument to
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  named `remove_empty_cols` which precisely removes empty columns.
- The argument `wmo_identifier` from
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  can be either an integer or a string.
- [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  generates two novel columns: ‘Wind_speed_unit’ and ‘Relative_humidity’
  (Magnus-Tetens Equation).
- Official WMO Tables for conversion in the form of vectors are
  available.
- Fixed a bug related with an internal function returning NULL when a
  string with a “=” character is included in the input, instead of
  removing it.
- A more clear documentation.

## synopR 0.1.0

- Initial release.
