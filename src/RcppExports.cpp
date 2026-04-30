// Hand-written to match Rcpp::compileAttributes() output.
// Regenerate via: Rcpp::compileAttributes() in the package root.

#include <Rcpp.h>
#include "dss_ptr.h"

using namespace Rcpp;

// native_open
DssPtr native_open(const std::string& filename);
RcppExport SEXP _hecdssr_native_open(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< const std::string& >::type filename(filenameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_open(filename));
    return rcpp_result_gen;
END_RCPP
}
// native_close
int native_close(DssPtr dss);
RcppExport SEXP _hecdssr_native_close(SEXP dssSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    rcpp_result_gen = Rcpp::wrap(native_close(dss));
    return rcpp_result_gen;
END_RCPP
}
// native_get_version
int native_get_version(DssPtr dss);
RcppExport SEXP _hecdssr_native_get_version(SEXP dssSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    rcpp_result_gen = Rcpp::wrap(native_get_version(dss));
    return rcpp_result_gen;
END_RCPP
}
// native_get_file_version
int native_get_file_version(const std::string& filename);
RcppExport SEXP _hecdssr_native_get_file_version(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< const std::string& >::type filename(filenameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_get_file_version(filename));
    return rcpp_result_gen;
END_RCPP
}
// native_record_count
int native_record_count(DssPtr dss);
RcppExport SEXP _hecdssr_native_record_count(SEXP dssSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    rcpp_result_gen = Rcpp::wrap(native_record_count(dss));
    return rcpp_result_gen;
END_RCPP
}
// native_set_value
int native_set_value(const std::string& name, int value);
RcppExport SEXP _hecdssr_native_set_value(SEXP nameSEXP, SEXP valueSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< const std::string& >::type name(nameSEXP);
    Rcpp::traits::input_parameter< int >::type value(valueSEXP);
    rcpp_result_gen = Rcpp::wrap(native_set_value(name, value));
    return rcpp_result_gen;
END_RCPP
}
// native_set_string
int native_set_string(const std::string& name, const std::string& value);
RcppExport SEXP _hecdssr_native_set_string(SEXP nameSEXP, SEXP valueSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< const std::string& >::type name(nameSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type value(valueSEXP);
    rcpp_result_gen = Rcpp::wrap(native_set_string(name, value));
    return rcpp_result_gen;
END_RCPP
}
// native_catalog
Rcpp::List native_catalog(DssPtr dss, std::string filter);
RcppExport SEXP _hecdssr_native_catalog(SEXP dssSEXP, SEXP filterSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< std::string >::type filter(filterSEXP);
    rcpp_result_gen = Rcpp::wrap(native_catalog(dss, filter));
    return rcpp_result_gen;
END_RCPP
}
// native_record_type
int native_record_type(DssPtr dss, const std::string& pathname);
RcppExport SEXP _hecdssr_native_record_type(SEXP dssSEXP, SEXP pathnameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_record_type(dss, pathname));
    return rcpp_result_gen;
END_RCPP
}
// native_data_type
int native_data_type(DssPtr dss, const std::string& pathname);
RcppExport SEXP _hecdssr_native_data_type(SEXP dssSEXP, SEXP pathnameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_data_type(dss, pathname));
    return rcpp_result_gen;
END_RCPP
}
// native_delete
int native_delete(DssPtr dss, const std::string& pathname);
RcppExport SEXP _hecdssr_native_delete(SEXP dssSEXP, SEXP pathnameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_delete(dss, pathname));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_retrieve_info
Rcpp::List native_ts_retrieve_info(DssPtr dss, const std::string& pathname);
RcppExport SEXP _hecdssr_native_ts_retrieve_info(SEXP dssSEXP, SEXP pathnameSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_retrieve_info(dss, pathname));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_get_sizes
Rcpp::List native_ts_get_sizes(DssPtr dss, const std::string& pathname, const std::string& startDate, const std::string& startTime, const std::string& endDate, const std::string& endTime);
RcppExport SEXP _hecdssr_native_ts_get_sizes(SEXP dssSEXP, SEXP pathnameSEXP, SEXP startDateSEXP, SEXP startTimeSEXP, SEXP endDateSEXP, SEXP endTimeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startDate(startDateSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startTime(startTimeSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type endDate(endDateSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type endTime(endTimeSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_get_sizes(dss, pathname, startDate, startTime, endDate, endTime));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_get_date_time_range
Rcpp::List native_ts_get_date_time_range(DssPtr dss, const std::string& pathname, int boolFullSet);
RcppExport SEXP _hecdssr_native_ts_get_date_time_range(SEXP dssSEXP, SEXP pathnameSEXP, SEXP boolFullSetSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< int >::type boolFullSet(boolFullSetSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_get_date_time_range(dss, pathname, boolFullSet));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_retrieve
Rcpp::List native_ts_retrieve(DssPtr dss, const std::string& pathname, const std::string& startDate, const std::string& startTime, const std::string& endDate, const std::string& endTime, int arraySize, int qualityWidth);
RcppExport SEXP _hecdssr_native_ts_retrieve(SEXP dssSEXP, SEXP pathnameSEXP, SEXP startDateSEXP, SEXP startTimeSEXP, SEXP endDateSEXP, SEXP endTimeSEXP, SEXP arraySizeSEXP, SEXP qualityWidthSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startDate(startDateSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startTime(startTimeSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type endDate(endDateSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type endTime(endTimeSEXP);
    Rcpp::traits::input_parameter< int >::type arraySize(arraySizeSEXP);
    Rcpp::traits::input_parameter< int >::type qualityWidth(qualityWidthSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_retrieve(dss, pathname, startDate, startTime, endDate, endTime, arraySize, qualityWidth));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_store_regular
int native_ts_store_regular(DssPtr dss, const std::string& pathname, const std::string& startDate, const std::string& startTime, Rcpp::NumericVector values, Rcpp::IntegerVector quality, int saveAsFloat, const std::string& units, const std::string& type, const std::string& timeZoneName, int storageFlag);
RcppExport SEXP _hecdssr_native_ts_store_regular(SEXP dssSEXP, SEXP pathnameSEXP, SEXP startDateSEXP, SEXP startTimeSEXP, SEXP valuesSEXP, SEXP qualitySEXP, SEXP saveAsFloatSEXP, SEXP unitsSEXP, SEXP typeSEXP, SEXP timeZoneNameSEXP, SEXP storageFlagSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startDate(startDateSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startTime(startTimeSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type values(valuesSEXP);
    Rcpp::traits::input_parameter< Rcpp::IntegerVector >::type quality(qualitySEXP);
    Rcpp::traits::input_parameter< int >::type saveAsFloat(saveAsFloatSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type units(unitsSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type type(typeSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type timeZoneName(timeZoneNameSEXP);
    Rcpp::traits::input_parameter< int >::type storageFlag(storageFlagSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_store_regular(dss, pathname, startDate, startTime, values, quality, saveAsFloat, units, type, timeZoneName, storageFlag));
    return rcpp_result_gen;
END_RCPP
}
// native_ts_store_irregular
int native_ts_store_irregular(DssPtr dss, const std::string& pathname, const std::string& startDateBase, Rcpp::IntegerVector times, int timeGranularitySeconds, Rcpp::NumericVector values, Rcpp::IntegerVector quality, int saveAsFloat, const std::string& units, const std::string& type);
RcppExport SEXP _hecdssr_native_ts_store_irregular(SEXP dssSEXP, SEXP pathnameSEXP, SEXP startDateBaseSEXP, SEXP timesSEXP, SEXP timeGranularitySecondsSEXP, SEXP valuesSEXP, SEXP qualitySEXP, SEXP saveAsFloatSEXP, SEXP unitsSEXP, SEXP typeSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< DssPtr >::type dss(dssSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type pathname(pathnameSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type startDateBase(startDateBaseSEXP);
    Rcpp::traits::input_parameter< Rcpp::IntegerVector >::type times(timesSEXP);
    Rcpp::traits::input_parameter< int >::type timeGranularitySeconds(timeGranularitySecondsSEXP);
    Rcpp::traits::input_parameter< Rcpp::NumericVector >::type values(valuesSEXP);
    Rcpp::traits::input_parameter< Rcpp::IntegerVector >::type quality(qualitySEXP);
    Rcpp::traits::input_parameter< int >::type saveAsFloat(saveAsFloatSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type units(unitsSEXP);
    Rcpp::traits::input_parameter< const std::string& >::type type(typeSEXP);
    rcpp_result_gen = Rcpp::wrap(native_ts_store_irregular(dss, pathname, startDateBase, times, timeGranularitySeconds, values, quality, saveAsFloat, units, type));
    return rcpp_result_gen;
END_RCPP
}
// native_julian_to_ymd
Rcpp::IntegerVector native_julian_to_ymd(int julian);
RcppExport SEXP _hecdssr_native_julian_to_ymd(SEXP julianSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< int >::type julian(julianSEXP);
    rcpp_result_gen = Rcpp::wrap(native_julian_to_ymd(julian));
    return rcpp_result_gen;
END_RCPP
}
// native_date_to_julian
int native_date_to_julian(const std::string& date);
RcppExport SEXP _hecdssr_native_date_to_julian(SEXP dateSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::traits::input_parameter< const std::string& >::type date(dateSEXP);
    rcpp_result_gen = Rcpp::wrap(native_date_to_julian(date));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_hecdssr_native_open", (DL_FUNC) &_hecdssr_native_open, 1},
    {"_hecdssr_native_close", (DL_FUNC) &_hecdssr_native_close, 1},
    {"_hecdssr_native_get_version", (DL_FUNC) &_hecdssr_native_get_version, 1},
    {"_hecdssr_native_get_file_version", (DL_FUNC) &_hecdssr_native_get_file_version, 1},
    {"_hecdssr_native_record_count", (DL_FUNC) &_hecdssr_native_record_count, 1},
    {"_hecdssr_native_set_value", (DL_FUNC) &_hecdssr_native_set_value, 2},
    {"_hecdssr_native_set_string", (DL_FUNC) &_hecdssr_native_set_string, 2},
    {"_hecdssr_native_catalog", (DL_FUNC) &_hecdssr_native_catalog, 2},
    {"_hecdssr_native_record_type", (DL_FUNC) &_hecdssr_native_record_type, 2},
    {"_hecdssr_native_data_type", (DL_FUNC) &_hecdssr_native_data_type, 2},
    {"_hecdssr_native_delete", (DL_FUNC) &_hecdssr_native_delete, 2},
    {"_hecdssr_native_ts_retrieve_info", (DL_FUNC) &_hecdssr_native_ts_retrieve_info, 2},
    {"_hecdssr_native_ts_get_sizes", (DL_FUNC) &_hecdssr_native_ts_get_sizes, 6},
    {"_hecdssr_native_ts_get_date_time_range", (DL_FUNC) &_hecdssr_native_ts_get_date_time_range, 3},
    {"_hecdssr_native_ts_retrieve", (DL_FUNC) &_hecdssr_native_ts_retrieve, 8},
    {"_hecdssr_native_ts_store_regular", (DL_FUNC) &_hecdssr_native_ts_store_regular, 11},
    {"_hecdssr_native_ts_store_irregular", (DL_FUNC) &_hecdssr_native_ts_store_irregular, 10},
    {"_hecdssr_native_julian_to_ymd", (DL_FUNC) &_hecdssr_native_julian_to_ymd, 1},
    {"_hecdssr_native_date_to_julian", (DL_FUNC) &_hecdssr_native_date_to_julian, 1},
    {NULL, NULL, 0}
};

RcppExport void R_init_hecdssr(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
