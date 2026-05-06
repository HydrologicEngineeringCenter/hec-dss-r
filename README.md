# hecdssr — R Interface to HEC-DSS

`hecdssr` is the R counterpart to
[hec-dss-python](https://github.com/HydrologicEngineeringCenter/hec-dss-python):
a thin [Rcpp](https://www.rcpp.org/) shim over the HEC-DSS C API
(`hecdss.dll` / `libhecdss.so`), with all higher-level logic implemented
in R. Time series records are returned as
[`xts`](https://cran.r-project.org/package=xts) objects with DSS metadata
stored in `xtsAttributes()`.

Read about HEC-DSS [here](https://www.hec.usace.army.mil/software/hec-dss/).

> **Status — Phase 1.** Regular and irregular time series are supported.
> Paired data, gridded data, text, location info, and arrays are planned
> for later phases.

The package installs as **`hecdssr`** (not `hecdss`) to avoid a Windows
DLL-name collision with the underlying HEC C library `hecdss.dll`.

## Installation

### Option 1 — pre-built binary (Windows, no Rtools needed)

Download the latest `hecdssr_<version>.zip` from the
[Releases page](https://github.com/HydrologicEngineeringCenter/hec-dss-r/releases)
and install it locally:

```r
install.packages("path/to/hecdssr_0.1.0.zip", repos = NULL)
```

The `latest` pre-release is rebuilt automatically on every push to
`main`; tagged releases (`vX.Y.Z`) are stable.

### Option 2 — install from source

```r
# install.packages("remotes")
remotes::install_github("HydrologicEngineeringCenter/hec-dss-r")
```

Building from source requires:

- **R** ≥ 4.1
- **Rtools** matching your R version (Windows) or a working C/C++ toolchain (Linux/macOS)
- The HEC-DSS native library — see [Developer setup](#developer-setup)

## Usage

```r
library(hecdssr)
library(xts)

dss <- open_dss("examples-all-data-types.dss")

# Browse the catalog
head(as.data.frame(dss$get_catalog()))

# Read a regular time series
ts <- dss$get("/regular-time-series/GAPT/FLOW/01Sep2021/6Hour/forecast1/")
plot(ts)
xtsAttributes(ts)         # units, type, record_type, ...

# Slice by time using xts subscripting
window <- ts["2021-09-02/2021-09-04"]

# Write a new regular time series
new_ts <- xts(runif(24, 100, 200),
              order.by = seq.POSIXt(as.POSIXct("2024-01-01", tz = "UTC"),
                                    by = "1 hour", length.out = 24))
xtsAttributes(new_ts) <- list(
    pathname = "/test/site_x/FLOW//1Hour/r_demo/",
    units    = "cfs",
    type     = "PER-AVER"
)
dss$put(new_ts, type = "regular")

dss$close()
```

See `examples/example.R` for the full version of the snippet above.

### DSS file methods (R6 class `HecDss`)

| Method | Purpose |
| --- | --- |
| `HecDss$new(filename)` / `open_dss(filename)` | Open a DSS file |
| `dss$get(pathname, ...)` | Read a record (returns an `xts` object for time series) |
| `dss$put(ts, type, ...)` | Write a regular or irregular time series |
| `dss$delete(pathname)` | Delete a record |
| `dss$get_catalog(filter, refresh)` | Condensed catalog of records |
| `dss$get_record_type(pathname)` | Record-type name for a path |
| `dss$get_version()` / `dss$record_count()` | File metadata |
| `dss$close()` | Close the file |

### Pathname helpers

`parse_dss_path()`, `format_dss_path()`, and `path_without_date()` operate on
the six-part `/A/B/C/D/E/F/` DSS pathname strings.

## Developer setup

1. **Clone** this repository.

2. **Fetch the HEC-DSS native library.** The C header
   `inst/include/hecdss.h` is vendored in-tree, but the platform-specific
   binary (`hecdss.dll` on Windows, `libhecdss.so` on Linux) must be
   downloaded into `inst/libs/`. The helper script does this from the HEC
   Maven Nexus:

    ```sh
    Rscript tools/download_hecdss.R
    ```

   The pinned version is set by `HECDSS_VERSION` near the top of that script;
   bump it (and re-vendor `inst/include/hecdss.h` from
   [`HydrologicEngineeringCenter/hec-dss`](https://github.com/HydrologicEngineeringCenter/hec-dss)
   at the matching tag) when the C API changes.

3. **Install R-side build tools** (one-time, from an R session):

    ```r
    install.packages(c("devtools", "Rcpp", "roxygen2", "testthat",
                       "R6", "xts", "zoo", "data.table"))
    ```

4. **Daily dev loop** from the package root:

    ```r
    devtools::document()   # regenerate NAMESPACE + man/ from roxygen
    devtools::load_all()   # compile src/ and load
    devtools::test()       # run tests/testthat
    devtools::check()      # full R CMD check
    ```

## Design

`hecdssr` mirrors the layered architecture of `hec-dss-python`:

| Layer | File | Role |
| --- | --- | --- |
| Native shim | `src/native.cpp` | One Rcpp wrapper per `hec_dss_*` C entry point. No business logic. |
| Public API | `R/hecdss.R` | The `HecDss` R6 class — user-facing entry point. |
| Catalog | `R/catalog.R` | Condensed-catalog construction. |
| Pathname | `R/dsspath.R` | Six-part DSS pathname parsing. |
| Date math | `R/dateconverter.R` | Julian-day ↔ POSIXct conversion. |
| Time series | `R/regular_timeseries.R`, `R/irregular_timeseries.R` | Read/write helpers returning `xts` objects. |

The native binding layer is intentionally minimal so that the higher-level
R code can evolve independently of the C library.

## License

Released under the MIT License (`LICENSE.md`). See [`INTENT.md`](INTENT.md)
for the U.S. Federal Government licensing-intent statement that accompanies
all HEC open-source projects.
