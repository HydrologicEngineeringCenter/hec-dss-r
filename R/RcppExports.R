# Hand-written to match Rcpp::compileAttributes() output.
# Regenerate via: Rcpp::compileAttributes() in the package root.

native_open <- function(filename) {
    .Call(`_hecdssr_native_open`, filename)
}

native_close <- function(dss) {
    .Call(`_hecdssr_native_close`, dss)
}

native_get_version <- function(dss) {
    .Call(`_hecdssr_native_get_version`, dss)
}

native_get_file_version <- function(filename) {
    .Call(`_hecdssr_native_get_file_version`, filename)
}

native_record_count <- function(dss) {
    .Call(`_hecdssr_native_record_count`, dss)
}

native_set_value <- function(name, value) {
    .Call(`_hecdssr_native_set_value`, name, value)
}

native_set_string <- function(name, value) {
    .Call(`_hecdssr_native_set_string`, name, value)
}

native_catalog <- function(dss, filter = "") {
    .Call(`_hecdssr_native_catalog`, dss, filter)
}

native_record_type <- function(dss, pathname) {
    .Call(`_hecdssr_native_record_type`, dss, pathname)
}

native_data_type <- function(dss, pathname) {
    .Call(`_hecdssr_native_data_type`, dss, pathname)
}

native_delete <- function(dss, pathname) {
    .Call(`_hecdssr_native_delete`, dss, pathname)
}

native_ts_retrieve_info <- function(dss, pathname) {
    .Call(`_hecdssr_native_ts_retrieve_info`, dss, pathname)
}

native_ts_get_sizes <- function(dss, pathname, startDate, startTime, endDate, endTime) {
    .Call(`_hecdssr_native_ts_get_sizes`, dss, pathname, startDate, startTime, endDate, endTime)
}

native_ts_get_date_time_range <- function(dss, pathname, boolFullSet) {
    .Call(`_hecdssr_native_ts_get_date_time_range`, dss, pathname, boolFullSet)
}

native_ts_retrieve <- function(dss, pathname, startDate, startTime, endDate, endTime, arraySize, qualityWidth) {
    .Call(`_hecdssr_native_ts_retrieve`, dss, pathname, startDate, startTime, endDate, endTime, arraySize, qualityWidth)
}

native_ts_store_regular <- function(dss, pathname, startDate, startTime, values, quality, saveAsFloat, units, type, timeZoneName, storageFlag) {
    .Call(`_hecdssr_native_ts_store_regular`, dss, pathname, startDate, startTime, values, quality, saveAsFloat, units, type, timeZoneName, storageFlag)
}

native_ts_store_irregular <- function(dss, pathname, startDateBase, times, timeGranularitySeconds, values, quality, saveAsFloat, units, type) {
    .Call(`_hecdssr_native_ts_store_irregular`, dss, pathname, startDateBase, times, timeGranularitySeconds, values, quality, saveAsFloat, units, type)
}

native_julian_to_ymd <- function(julian) {
    .Call(`_hecdssr_native_julian_to_ymd`, julian)
}

native_date_to_julian <- function(date) {
    .Call(`_hecdssr_native_date_to_julian`, date)
}
