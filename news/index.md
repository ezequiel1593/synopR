# Changelog

## synopR 1.0.0

CRAN release: 2026-04-03

- SynopR is now dependency-free. Only R (\>= 4.1.0) is needed.
- [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  and the associated internal functions are completely vectorized,
  meaning execution times have been dramatically reduced.
- Any SYNOP message is now almost completely decoded by
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md).
  Only groups 29UUU and 9 from section 1 and groups 54 and 9 from
  section 3 remain ignored.
- Argument “remove_empty_cols” default value from
  [`show_synop_data()`](https://ezequiel9315.github.io/synopR/reference/show_synop_data.md)
  have been changed from FALSE to TRUE.
- New function
  [`download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/download_from_ogimet.md)
  to retrieve SYNOP messages from Ogimet.
- New function
  [`direct_download_from_ogimet()`](https://ezequiel9315.github.io/synopR/reference/direct_download_from_ogimet.md)
  to download, check and decode all at once.
- New vignette named “Extracted data Reference”.

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
