# hecdssr 0.1.0

Initial release. R counterpart to
[hec-dss-python](https://github.com/HydrologicEngineeringCenter/hec-dss-python),
built as a thin Rcpp shim over the HEC-DSS C API with all higher-level
logic in R.

## Features

* `HecDss` R6 class (`open_dss()` convenience constructor) for opening,
  reading, writing, and deleting records in DSS version 7 files.
* Read/write support for **regular** and **irregular** time-series
  records. Returned as `xts` objects with DSS metadata (units, type,
  pathname, record type) stored in `xtsAttributes()`.
* Condensed catalog (`dss$get_catalog()`) with a `data.frame` view for
  inspection.
* Pathname helpers: `parse_dss_path()`, `format_dss_path()`,
  `path_without_date()`.
* Date conversion helpers mirroring the Python `DateConverter`:
  `date_times_from_julian_array()`, `julian_array_from_date_times()`,
  and the DSS-style `"DDmonYYYY HH:MM"` parser/formatter (24:00 midnight
  rule respected).

## Tooling

* `tools/download_hecdss.R` fetches the platform-specific HEC-DSS
  shared library from the HEC Maven Nexus into `inst/libs/`. The C
  header is vendored at `inst/include/hecdss.h` and tracks the same
  pinned version (currently **7-JA-7**).
* GitHub Actions workflow runs `R CMD check` on Ubuntu and Windows for
  every push and pull request.

## Known limitations

* Paired data, gridded data, text records, location-info records, and
  array records are not yet supported. Planned for later phases.
* macOS is not supported — HEC does not currently publish a macOS build
  of the native library.
