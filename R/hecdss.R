# Top-level HecDss R6 class. Mirrors hec-dss-python/src/hecdss/hecdss.py.

#' HecDss: open and interact with a DSS file.
#'
#' Phase 1 supports regular and irregular time series records. Other record
#' types (paired data, gridded data, etc.) will be added in later phases.
#'
#' @examples
#' \dontrun{
#'   dss <- HecDss$new("examples-all-data-types.dss")
#'   cat <- dss$get_catalog()
#'   ts  <- dss$get("/regular-time-series/GAPT/FLOW/01Sep2021/6Hour/forecast1/")
#'   plot(ts)
#'   dss$close()
#' }
#' @export
HecDss <- R6::R6Class(
    "HecDss",
    public = list(
        filename = NULL,

        initialize = function(filename) {
            self$filename <- filename
            private$.handle <- native_open(filename)
            private$.closed <- FALSE
            private$.catalog <- NULL
            invisible(self)
        },

        close = function() {
            if (!private$.closed) {
                native_close(private$.handle)
                private$.closed <- TRUE
                private$.handle <- NULL
            }
            invisible(NULL)
        },

        get_version = function() {
            private$.assert_open()
            native_get_version(private$.handle)
        },

        record_count = function() {
            private$.assert_open()
            native_record_count(private$.handle)
        },

        get_catalog = function(filter = "", refresh = FALSE) {
            private$.assert_open()
            if (refresh || is.null(private$.catalog)) {
                raw <- native_catalog(private$.handle, filter)
                private$.catalog <- build_catalog(raw$paths, raw$record_types)
            }
            private$.catalog
        },

        get_record_type = function(pathname) {
            self$get_catalog()$get_record_type(pathname)
        },

        get = function(pathname, start_datetime = NULL, end_datetime = NULL,
                       trim = FALSE, tz = "UTC") {
            private$.assert_open()
            pathname <- as.character(pathname)
            rt <- self$get_record_type(pathname)
            if (rt %in% c("RegularTimeSeries", "IrregularTimeSeries")) {
                # If pathname has a non-pattern D-part, retrieve full condensed record.
                p <- parse_dss_path(pathname, rt)
                lookup_path <- pathname
                if (tolower(p$D) != "ts-pattern") {
                    lookup_path <- format_dss_path(path_without_date(p))
                } else if (rt == "IrregularTimeSeries") {
                    stop("ts-pattern is not supported for irregular time series")
                }
                ts <- get_timeseries(private$.handle, lookup_path,
                                     start_datetime = start_datetime,
                                     end_datetime = end_datetime,
                                     trim = trim, tz = tz)
                xtsAttributes(ts) <- c(
                    xtsAttributes(ts),
                    list(record_type = rt)
                )
                return(ts)
            }
            stop(sprintf("Record type '%s' is not yet supported in this phase.", rt))
        },

        put = function(ts, pathname = NULL, type = c("regular", "irregular"),
                       time_granularity_seconds = 60L) {
            private$.assert_open()
            type <- match.arg(type)
            if (type == "regular") {
                store_regular_timeseries(private$.handle, ts, pathname = pathname)
            } else {
                store_irregular_timeseries(
                    private$.handle, ts, pathname = pathname,
                    time_granularity_seconds = time_granularity_seconds
                )
            }
        },

        delete = function(pathname) {
            private$.assert_open()
            native_delete(private$.handle, pathname)
        },

        set_debug_level = function(level) {
            native_set_value("mlvl", as.integer(level))
        },

        is_open = function() !private$.closed
    ),

    private = list(
        .handle = NULL,
        .closed = TRUE,
        .catalog = NULL,

        .assert_open = function() {
            if (private$.closed) stop("DSS file is closed.")
        },

        finalize = function() {
            try(self$close(), silent = TRUE)
        }
    )
)

#' Convenience wrapper around HecDss$new().
#' @export
open_dss <- function(filename) {
    HecDss$new(filename)
}
