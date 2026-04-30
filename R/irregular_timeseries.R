# Irregular time series storage. Reads share get_timeseries() with regular.

#' Store an xts as an irregular DSS time series.
#'
#' @param dss DssPtr from native_open / open_dss.
#' @param ts xts. Index is POSIXct; first column is the value.
#' @param pathname Optional pathname override.
#' @param time_granularity_seconds 1, 60, 3600, or 86400. Default 60.
#' @export
store_irregular_timeseries <- function(dss, ts, pathname = NULL,
                                       time_granularity_seconds = 60L) {
    if (!xts::is.xts(ts)) stop("ts must be an xts object")
    attrs <- xtsAttributes(ts)
    pathname <- pathname %||% attrs$pathname
    if (is.null(pathname) || !nzchar(pathname)) {
        stop("pathname is required (set via xtsAttributes(ts)$pathname or argument)")
    }

    times <- zoo::index(ts)
    if (length(times) == 0L) stop("ts is empty")

    # Anchor the integer time offsets to 1900-01-01.
    base <- as.POSIXct("1900-01-01", tz = "UTC")
    int_times <- julian_array_from_date_times(
        times, time_granularity_seconds = time_granularity_seconds,
        start_date_base = base
    )
    start_date_base_str <- format(base, "%d%b%Y")

    cd <- zoo::coredata(ts)
    if (is.matrix(cd)) {
        values  <- as.numeric(cd[, 1L])
        quality <- if ("quality" %in% colnames(cd)) {
            as.integer(cd[, "quality"])
        } else integer(0)
    } else {
        values  <- as.numeric(cd)
        quality <- integer(0)
    }

    units         <- attrs$units         %||% ""
    type          <- attrs$type          %||% ""
    save_as_float <- as.integer(attrs$save_as_float %||% 0L)

    status <- native_ts_store_irregular(
        dss, pathname, start_date_base_str,
        as.integer(int_times), as.integer(time_granularity_seconds),
        values, quality, save_as_float,
        units, type
    )
    if (status != 0L) {
        stop(sprintf("hec_dss_tsStoreIregular failed (status=%d) for: %s",
                     status, pathname))
    }
    invisible(status)
}
