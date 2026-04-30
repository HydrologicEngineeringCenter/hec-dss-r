# Example usage of the hecdss R package.
# Phase 1: regular and irregular time series only.

library(hecdssr)
library(xts)

filename <- "C:/Users/q0hecoah/Documents/data/examples-all-data-types.dss"

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
