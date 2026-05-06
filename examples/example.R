# Example usage of the hecdss R package.
# Phase 1: regular and irregular time series only.

library(hecdssr)
library(xts)

# Default points at the HEC test fixture bundled in this directory.
# Override with HECDSSR_EXAMPLE_DSS to run against a different DSS file.
script_dir <- local({
    f <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
    if (is.null(f) || !nzchar(f)) {
        args <- commandArgs(trailingOnly = FALSE)
        farg <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
        f <- if (length(farg)) farg else file.path(getwd(), "examples")
    }
    dirname(normalizePath(f, mustWork = FALSE))
})
default_dss <- file.path(script_dir, "examples-all-data-types.dss")
filename <- Sys.getenv("HECDSSR_EXAMPLE_DSS", unset = default_dss)

if (!file.exists(filename)) {
    stop(sprintf(
        "Example DSS file not found: '%s'. Set HECDSSR_EXAMPLE_DSS or edit this script.",
        filename
    ))
}

# Open
dss <- open_dss(filename)
cat("DSS version:", dss$get_version(), "\n")
cat("Records:    ", dss$record_count(), "\n\n")

# Browse the catalog as a data.frame
cat_df <- as.data.frame(dss$get_catalog())
print(head(cat_df))

# --- Read a regular time series -------------------------------------------
ts_path <- "/regular-time-series/GAPT/FLOW/01Sep2021/6Hour/forecast1/"
ts <- dss$get(ts_path)
print(head(ts))
cat("\nMetadata:\n")
str(xtsAttributes(ts))

# --- Slice by time --------------------------------------------------------
window <- ts["2021-09-02/2021-09-04"]
print(window)

# --- Write a new regular time series --------------------------------------
new_ts <- xts(
    runif(24, 100, 200),
    order.by = seq.POSIXt(as.POSIXct("2024-01-01", tz = "UTC"),
                          by = "1 hour", length.out = 24)
)
xtsAttributes(new_ts) <- list(
    pathname = "/test/site_x/FLOW//1Hour/r_demo/",
    units = "cfs",
    type = "PER-AVER"
)
dss$put(new_ts, type = "regular")

# --- Round-trip read ------------------------------------------------------
echo <- dss$get("/test/site_x/FLOW//1Hour/r_demo/")
print(echo)

dss$close()
