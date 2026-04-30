# Port of hec-dss-python/src/hecdss/record_type.py.
# DSS record type integer codes from the C API mapped to symbolic names.

#' DSS record type names
#' @export
RECORD_TYPE <- c(
    Unknown                   = 0L,
    RegularTimeSeriesProfile  = 1L,
    RegularTimeSeries         = 2L,
    IrregularTimeSeries       = 3L,
    PairedData                = 4L,
    Text                      = 5L,
    Grid                      = 6L,
    Tin                       = 7L,
    LocationInfo              = 8L,
    Array                     = 9L
)

#' Convert a raw integer record type from the DSS API to a symbolic name.
#'
#' Mirrors RecordType.RecordTypeFromInt in hec-dss-python.
#'
#' @param rec_type integer raw record type from hec_dss_recordType / catalog.
#' @return character: one of names(RECORD_TYPE).
#' @export
record_type_from_int <- function(rec_type) {
    rt <- as.integer(rec_type)
    if (is.na(rt)) return("Unknown")
    if (rt >= 90L  && rt <= 93L)        return("Array")
    if (rt >= 100L && rt <  110L) {
        if (rt == 102L || rt == 107L)   return("RegularTimeSeriesProfile")
        return("RegularTimeSeries")
    }
    if (rt >= 110L && rt <  200L)       return("IrregularTimeSeries")
    if (rt >= 200L && rt <  300L)       return("PairedData")
    if (rt >= 300L && rt <  400L)       return("Text")
    if (rt >= 400L && rt <  450L)       return("Grid")
    if (rt == 450L)                     return("Tin")
    if (rt == 20L)                      return("LocationInfo")
    "Unknown"
}

is_time_series_type <- function(name) {
    name %in% c("RegularTimeSeries", "IrregularTimeSeries", "RegularTimeSeriesProfile")
}
