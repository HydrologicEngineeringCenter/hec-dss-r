# Regular and irregular time-series retrieval and storage.
# Both record families share the same hec_dss_tsRetrieve native call;
# the differences are in storage (tsStoreRegular vs tsStoreIregular).

DSS_UNDEFINED_VALUE <- -340282346638528859811704183484516925440.000000

# Internal: read a TS (regular or irregular) by pathname, returning an xts.
get_timeseries <- function(dss, pathname, start_datetime = NULL,
                           end_datetime = NULL, trim = FALSE,
                           tz = "UTC") {
    pathname <- as.character(pathname)

    # Resolve start/end window.
    if (is.null(start_datetime) || is.null(end_datetime)) {
        rng <- native_ts_get_date_time_range(dss, pathname, 1L)
        if (rng$status != 0L) {
            stop(sprintf("hec_dss_tsGetDateTimeRange failed (status=%d) for: %s",
                         rng$status, pathname))
        }
        if (is.null(start_datetime)) {
            start_datetime <- date_times_from_julian_array(
                rng$first_seconds, 1L, rng$first_julian, tz = tz)
        }
        if (is.null(end_datetime)) {
            end_datetime <- date_times_from_julian_array(
                rng$last_seconds, 1L, rng$last_julian, tz = tz)
        }
    }

    start_datetime <- as.POSIXct(start_datetime, tz = tz)
    end_datetime   <- as.POSIXct(end_datetime,   tz = tz)
    s <- dss_datetime_strings_from_datetime(start_datetime)
    e <- dss_datetime_strings_from_datetime(end_datetime)

    # How many values, and what quality width?
    sizes <- native_ts_get_sizes(dss, pathname, s$date, s$time, e$date, e$time)
    if (sizes$status != 0L) {
        stop(sprintf("hec_dss_tsGetSizes failed (status=%d) for: %s",
                     sizes$status, pathname))
    }
    n <- sizes$number_values
    if (n <= 0L) {
        empty <- xts::xts(numeric(0), order.by = as.POSIXct(character(0), tz = tz))
        xtsAttributes(empty) <- list(
            pathname = pathname, units = "", type = "", interval_seconds = NA_integer_)
        return(empty)
    }

    qw <- sizes$quality_element_size
    res <- native_ts_retrieve(dss, pathname, s$date, s$time, e$date, e$time, n, qw)
    if (res$status != 0L) {
        stop(sprintf("hec_dss_tsRetrieve failed (status=%d) for: %s",
                     res$status, pathname))
    }

    times <- date_times_from_julian_array(
        res$times, res$time_granularity_seconds, res$julian_base_date, tz = tz)
    values <- res$values

    if (isTRUE(trim)) {
        keep <- values != DSS_UNDEFINED_VALUE
        times <- times[keep]
        values <- values[keep]
        if (length(res$quality) > 0L) res$quality <- res$quality[keep]
    }

    if (length(res$quality) > 0L) {
        mat <- cbind(value = values, quality = as.numeric(res$quality))
        out <- xts::xts(mat, order.by = times)
    } else {
        out <- xts::xts(values, order.by = times)
        colnames(out) <- "value"
    }

    interval_seconds <- if (length(times) >= 2L) {
        as.integer(difftime(times[[2L]], times[[1L]], units = "secs"))
    } else NA_integer_

    xtsAttributes(out) <- list(
        pathname                 = pathname,
        units                    = res$units,
        type                     = res$type,
        interval_seconds         = interval_seconds,
        julian_base_date         = res$julian_base_date,
        time_granularity_seconds = res$time_granularity_seconds
    )
    out
}

#' Store an xts as a regular DSS time series.
#'
#' @param dss DssPtr from native_open / open_dss.
#' @param ts xts. Index is POSIXct; first column is the value.
#'   Metadata (units, type, time_zone_name, save_as_float, storage_flag)
#'   is read from xtsAttributes(ts), with the pathname coming from
#'   xtsAttributes(ts)$pathname or the `pathname` argument.
#' @param pathname Optional pathname override.
#' @export
store_regular_timeseries <- function(dss, ts, pathname = NULL) {
    if (!xts::is.xts(ts)) stop("ts must be an xts object")
    attrs <- xtsAttributes(ts)
    pathname <- pathname %||% attrs$pathname
    if (is.null(pathname) || !nzchar(pathname)) {
        stop("pathname is required (set via xtsAttributes(ts)$pathname or argument)")
    }

    times <- zoo::index(ts)
    if (length(times) == 0L) stop("ts is empty")
    s <- dss_datetime_strings_from_datetime(times[[1L]])

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

    units            <- attrs$units            %||% ""
    type             <- attrs$type             %||% ""
    time_zone_name   <- attrs$time_zone_name   %||% ""
    save_as_float    <- as.integer(attrs$save_as_float    %||% 0L)
    storage_flag     <- as.integer(attrs$storage_flag     %||% 0L)

    status <- native_ts_store_regular(
        dss, pathname, s$date, s$time,
        values, quality, save_as_float,
        units, type, time_zone_name, storage_flag
    )
    if (status != 0L) {
        stop(sprintf("hec_dss_tsStoreRegular failed (status=%d) for: %s",
                     status, pathname))
    }
    invisible(status)
}

`%||%` <- function(a, b) if (is.null(a)) b else a
