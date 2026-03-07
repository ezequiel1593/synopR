# synopR 0.2.0

* Found out some SYNOP downloaded from Ogimet end with "==" instead of "=", now `parse_ogimet()` can fix it. Also, `show_synop_data()` and ``check_synop()` are now aware of this.
* Added new argument to `show_synop_data()` named `remove_empty_cols` which precisely removes empty columns.
* The argument `wmo_identifier` from `show_synop_data()` can be either an integer or a string.
* `show_synop_data()` generates two novel columns: 'Wind_speed_unit' and 'Relative_humidity' (Magnus-Tetens Equation).
* Official WMO Tables for conversion in the form of vectors are available.
* A more clear documentation.


# synopR 0.1.0

* Initial release.
