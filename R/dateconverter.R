# Port of hec-dss-python/src/hecdss/dateconverter.py.
# DSS internal time = (julian_base_date in days since 1899-12-31) +
#                     (time_offset * time_granularity_seconds within day-epoch).

DSS_BASE_DATE <- as.POSIXct("1899-12-31 00:00:00", tz = "UTC")

# Lookup tables for DSS interval strings.
.dss_interval_seconds <- c(
    31536000L, 2592000L, 1296000L, 864000L, 604800L,
    86400L, 43200L, 28800L, 21600L, 14400L, 10800L, 7200L, 3600L,
    1800L, 1200L, 900L, 720L, 600L, 360L, 300L, 240L, 180L, 120L, 60L,
    30L, 20L, 15L, 10L, 6L, 5L, 4L, 3L, 2L, 1L, 0L
)
.dss_interval_strings <- c(
    "1Year", "1Month", "Semi-Month", "Tri-Month", "1Week",
    "1Day", "12Hour", "8Hour", "6Hour", "4Hour", "3Hour", "2Hour", "1Hour",
    "30Minute", "20Minute", "15Minute", "12Minute", "10Minute", "6Minute",
    "5Minute", "4Minute", "3Minute", "2Minute", "1Minute",
    "30Second", "20Second", "15Second", "10Second", "6Second", "5Second",
    "4Second", "3Second", "2Second", "1Second", "0Second"
)

#' Convert DSS integer time offsets to POSIXct.
#'
#' Mirrors DateConverter.date_times_from_julian_array.
#'
#' @param times_julian integer vector of time offsets within day-epoch.
#' @param time_granularity_seconds 1, 60, 3600, or 86400.
#' @param julian_base_date integer days since 1899-12-31.
#' @param tz timezone for the returned POSIXct.
#' @return POSIXct vector.
date_times_from_julian_array <- function(times_julian, time_granularity_seconds,
                                          julian_base_date, tz = "UTC") {
    if (is.null(times_julian)) {
        stop("Time series times array was NULL.")
    }
    base <- DSS_BASE_DATE + as.numeric(julian_base_date) * 86400
    out <- base + as.numeric(times_julian) * as.numeric(time_granularity_seconds)
    attr(out, "tzone") <- tz
    out
}

#' Convert a POSIXct vector to DSS integer time offsets.
#'
#' Mirrors DateConverter.julian_array_from_date_times.
#'
#' @param date_times POSIXct vector.
#' @param time_granularity_seconds default 60.
#' @param start_date_base POSIXct anchor (default 1900-01-01).
#' @return integer vector.
julian_array_from_date_times <- function(date_times, time_granularity_seconds = 60L,
                                          start_date_base = as.POSIXct("1900-01-01", tz = "UTC")) {
    if (length(date_times) == 0L) {
        stop("date_times is empty.")
    }
    base <- as.POSIXct(format(start_date_base, "%Y-%m-%d"), tz = "UTC") - 86400
    delta_seconds <- as.numeric(date_times) - as.numeric(base)
    as.integer(delta_seconds / time_granularity_seconds)
}

#' Convert POSIXct to DSS-style "DDmonYYYY HH:MM:SS" with the 24:00 midnight rule.
#' @return list(date, time).
dss_datetime_strings_from_datetime <- function(dt) {
    if (length(dt) != 1L) stop("dt must be a single POSIXct value")
    dt <- as.POSIXct(dt, tz = "UTC")
    h <- as.integer(format(dt, "%H"))
    m <- as.integer(format(dt, "%M"))
    s <- as.integer(format(dt, "%S"))
    if (h == 0L && m == 0L && s == 0L) {
        prev <- dt - 86400
        list(date = format(prev, "%d%b%Y"), time = "24:00:00")
    } else {
        list(date = format(dt, "%d%b%Y"), time = format(dt, "%H:%M:%S"))
    }
}

#' Parse a DSS-style "DDmonYYYY HH:MM[:SS]" string with the 24:00 rule.
datetime_from_dss_datetime_string <- function(s) {
    parts <- strsplit(trimws(s), " +")[[1L]]
    if (length(parts) != 2L) stop("Invalid DSS datetime string: ", s)
    date_part <- parts[1L]; time_part <- parts[2L]
    add_day <- FALSE
    if (substr(time_part, 1L, 5L) == "24:00") {
        add_day <- TRUE
        time_part <- sub("^24:00", "00:00", time_part)
    }
    if (nchar(time_part) == 5L) time_part <- paste0(time_part, ":00")
    dt <- as.POSIXct(paste(date_part, time_part), format = "%d%b%Y %H:%M:%S", tz = "UTC")
    if (add_day) dt <- dt + 86400
    dt
}

interval_string_to_sec <- function(interval) {
    if (is.character(interval)) {
        # Python uses .title() — capitalize first letter of each word.
        interval_norm <- tools::toTitleCase(tolower(interval))
        idx <- match(interval_norm, .dss_interval_strings)
        if (!is.na(idx)) return(.dss_interval_seconds[idx])
        idx2 <- match(interval, .dss_interval_strings)
        if (!is.na(idx2)) return(.dss_interval_seconds[idx2])
        return("empty")
    }
    if (is.numeric(interval) && interval %in% .dss_interval_seconds) {
        return(as.integer(interval))
    }
    "empty"
}

sec_to_interval_string <- function(seconds) {
    idx <- match(as.integer(seconds), .dss_interval_seconds)
    if (is.na(idx)) stop("Unsupported interval seconds: ", seconds)
    .dss_interval_strings[idx]
}
