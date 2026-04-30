// hecdss R package - thin Rcpp FFI shim over the hecdss C API.
// One function per hec_dss_* entry point. No business logic — date math,
// path parsing, record-type interpretation, and xts assembly all live in R.
// Mirrors hec-dss-python/src/hecdss/native.py.

#include <Rcpp.h>
#include <string>
#include <vector>

#include "dss_ptr.h"

static const int PATH_BUFFER_SIZE = 400;
static const int UNITS_BUFFER_SIZE = 40;
static const int TYPE_BUFFER_SIZE = 40;

// ---- open / close / metadata ---------------------------------------------

// [[Rcpp::export]]
DssPtr native_open(const std::string& filename) {
    dss_file* dss = nullptr;
    int status = hec_dss_open(filename.c_str(), &dss);
    if (status != 0 || dss == nullptr) {
        Rcpp::stop("hec_dss_open failed (status=%d) for: %s", status, filename);
    }
    return DssPtr(dss, true);
}

// [[Rcpp::export]]
int native_close(DssPtr dss) {
    if (dss.get() == nullptr) return 0;
    int status = hec_dss_close(dss.get());
    dss.release();  // prevent finalizer double-close
    return status;
}

// [[Rcpp::export]]
int native_get_version(DssPtr dss) {
    return hec_dss_getVersion(dss.get());
}

// [[Rcpp::export]]
int native_get_file_version(const std::string& filename) {
    return hec_dss_getFileVersion(filename.c_str());
}

// [[Rcpp::export]]
int native_record_count(DssPtr dss) {
    return hec_dss_record_count(dss.get());
}

// [[Rcpp::export]]
int native_set_value(const std::string& name, int value) {
    return hec_dss_set_value(name.c_str(), value);
}

// [[Rcpp::export]]
int native_set_string(const std::string& name, const std::string& value) {
    return hec_dss_set_string(name.c_str(), value.c_str());
}

// ---- catalog -------------------------------------------------------------

// [[Rcpp::export]]
Rcpp::List native_catalog(DssPtr dss, std::string filter = "") {
    int count = hec_dss_record_count(dss.get());
    if (count <= 0) {
        return Rcpp::List::create(
            Rcpp::Named("paths") = Rcpp::CharacterVector(),
            Rcpp::Named("record_types") = Rcpp::IntegerVector()
        );
    }

    std::vector<char> path_buffer(static_cast<size_t>(count) * PATH_BUFFER_SIZE, '\0');
    std::vector<int> record_types(count, 0);

    const char* filter_ptr = filter.empty() ? nullptr : filter.c_str();

    int n = hec_dss_catalog(
        dss.get(), path_buffer.data(), record_types.data(),
        filter_ptr, count, PATH_BUFFER_SIZE
    );
    if (n < 0) {
        Rcpp::stop("hec_dss_catalog failed (status=%d)", n);
    }

    Rcpp::CharacterVector paths(n);
    Rcpp::IntegerVector rtypes(n);
    for (int i = 0; i < n; ++i) {
        // Each path is a null-terminated string in its slot.
        paths[i] = std::string(path_buffer.data() + i * PATH_BUFFER_SIZE);
        rtypes[i] = record_types[i];
    }

    return Rcpp::List::create(
        Rcpp::Named("paths") = paths,
        Rcpp::Named("record_types") = rtypes
    );
}

// [[Rcpp::export]]
int native_record_type(DssPtr dss, const std::string& pathname) {
    return hec_dss_recordType(dss.get(), pathname.c_str());
}

// [[Rcpp::export]]
int native_data_type(DssPtr dss, const std::string& pathname) {
    return hec_dss_dataType(dss.get(), pathname.c_str());
}

// [[Rcpp::export]]
int native_delete(DssPtr dss, const std::string& pathname) {
    return hec_dss_delete(dss.get(), pathname.c_str());
}

// ---- time series: info & sizes -------------------------------------------

// [[Rcpp::export]]
Rcpp::List native_ts_retrieve_info(DssPtr dss, const std::string& pathname) {
    char units[UNITS_BUFFER_SIZE] = {0};
    char type[TYPE_BUFFER_SIZE] = {0};

    int status = hec_dss_tsRetrieveInfo(
        dss.get(), pathname.c_str(),
        units, UNITS_BUFFER_SIZE,
        type, TYPE_BUFFER_SIZE
    );

    return Rcpp::List::create(
        Rcpp::Named("status") = status,
        Rcpp::Named("units") = std::string(units),
        Rcpp::Named("type") = std::string(type)
    );
}

// [[Rcpp::export]]
Rcpp::List native_ts_get_sizes(DssPtr dss, const std::string& pathname,
                               const std::string& startDate, const std::string& startTime,
                               const std::string& endDate, const std::string& endTime) {
    int numberValues = 0;
    int qualityElementSize = 0;

    int status = hec_dss_tsGetSizes(
        dss.get(), pathname.c_str(),
        startDate.c_str(), startTime.c_str(),
        endDate.c_str(), endTime.c_str(),
        &numberValues, &qualityElementSize
    );

    return Rcpp::List::create(
        Rcpp::Named("status") = status,
        Rcpp::Named("number_values") = numberValues,
        Rcpp::Named("quality_element_size") = qualityElementSize
    );
}

// [[Rcpp::export]]
Rcpp::List native_ts_get_date_time_range(DssPtr dss, const std::string& pathname,
                                          int boolFullSet) {
    int firstJulian = 0, firstSeconds = 0;
    int lastJulian = 0, lastSeconds = 0;

    int status = hec_dss_tsGetDateTimeRange(
        dss.get(), pathname.c_str(), boolFullSet,
        &firstJulian, &firstSeconds,
        &lastJulian, &lastSeconds
    );

    return Rcpp::List::create(
        Rcpp::Named("status") = status,
        Rcpp::Named("first_julian") = firstJulian,
        Rcpp::Named("first_seconds") = firstSeconds,
        Rcpp::Named("last_julian") = lastJulian,
        Rcpp::Named("last_seconds") = lastSeconds
    );
}

// ---- time series: retrieve -----------------------------------------------

// Returns raw arrays + metadata. Date assembly happens in R.
//
// [[Rcpp::export]]
Rcpp::List native_ts_retrieve(DssPtr dss, const std::string& pathname,
                              const std::string& startDate, const std::string& startTime,
                              const std::string& endDate, const std::string& endTime,
                              int arraySize, int qualityWidth) {
    if (arraySize <= 0) {
        Rcpp::stop("arraySize must be positive (got %d)", arraySize);
    }
    if (qualityWidth < 0) qualityWidth = 0;

    std::vector<int> timeArray(arraySize, 0);
    std::vector<double> valueArray(arraySize, 0.0);
    int qSize = qualityWidth > 0 ? arraySize * qualityWidth : arraySize;
    std::vector<int> quality(qSize, 0);

    int numberValuesRead = 0;
    int julianBaseDate = 0;
    int timeGranularitySeconds = 0;
    char units[UNITS_BUFFER_SIZE] = {0};
    char type[TYPE_BUFFER_SIZE] = {0};

    int status = hec_dss_tsRetrieve(
        dss.get(), pathname.c_str(),
        startDate.c_str(), startTime.c_str(),
        endDate.c_str(), endTime.c_str(),
        timeArray.data(), valueArray.data(), arraySize,
        &numberValuesRead, quality.data(), qualityWidth,
        &julianBaseDate, &timeGranularitySeconds,
        units, UNITS_BUFFER_SIZE, type, TYPE_BUFFER_SIZE
    );

    // Trim to numberValuesRead.
    int n = numberValuesRead < 0 ? 0 : numberValuesRead;
    if (n > arraySize) n = arraySize;

    Rcpp::IntegerVector r_times(n);
    Rcpp::NumericVector r_values(n);
    for (int i = 0; i < n; ++i) {
        r_times[i] = timeArray[i];
        r_values[i] = valueArray[i];
    }

    Rcpp::IntegerVector r_quality;
    if (qualityWidth > 0) {
        r_quality = Rcpp::IntegerVector(n);
        for (int i = 0; i < n; ++i) r_quality[i] = quality[i];
    }

    return Rcpp::List::create(
        Rcpp::Named("status") = status,
        Rcpp::Named("times") = r_times,
        Rcpp::Named("values") = r_values,
        Rcpp::Named("quality") = r_quality,
        Rcpp::Named("julian_base_date") = julianBaseDate,
        Rcpp::Named("time_granularity_seconds") = timeGranularitySeconds,
        Rcpp::Named("units") = std::string(units),
        Rcpp::Named("type") = std::string(type)
    );
}

// ---- time series: store --------------------------------------------------

// [[Rcpp::export]]
int native_ts_store_regular(DssPtr dss, const std::string& pathname,
                            const std::string& startDate, const std::string& startTime,
                            Rcpp::NumericVector values,
                            Rcpp::IntegerVector quality,
                            int saveAsFloat,
                            const std::string& units,
                            const std::string& type,
                            const std::string& timeZoneName,
                            int storageFlag) {
    int n = values.size();
    int qn = quality.size();

    return hec_dss_tsStoreRegular(
        dss.get(), pathname.c_str(),
        startDate.c_str(), startTime.c_str(),
        REAL(values), n,
        qn > 0 ? INTEGER(quality) : nullptr, qn,
        saveAsFloat,
        units.c_str(), type.c_str(),
        timeZoneName.c_str(), storageFlag
    );
}

// [[Rcpp::export]]
int native_ts_store_irregular(DssPtr dss, const std::string& pathname,
                              const std::string& startDateBase,
                              Rcpp::IntegerVector times,
                              int timeGranularitySeconds,
                              Rcpp::NumericVector values,
                              Rcpp::IntegerVector quality,
                              int saveAsFloat,
                              const std::string& units,
                              const std::string& type) {
    int n = values.size();
    int qn = quality.size();

    if (times.size() != n) {
        Rcpp::stop("times and values must have the same length (got %d and %d)",
                   times.size(), n);
    }

    return hec_dss_tsStoreIregular(
        dss.get(), pathname.c_str(),
        startDateBase.c_str(),
        INTEGER(times), timeGranularitySeconds,
        REAL(values), n,
        qn > 0 ? INTEGER(quality) : nullptr, qn,
        saveAsFloat,
        units.c_str(), type.c_str()
    );
}

// ---- date helpers exported for convenience -------------------------------

// [[Rcpp::export]]
Rcpp::IntegerVector native_julian_to_ymd(int julian) {
    int year = 0, month = 0, day = 0;
    hec_dss_julianToYearMonthDay(julian, &year, &month, &day);
    return Rcpp::IntegerVector::create(
        Rcpp::Named("year") = year,
        Rcpp::Named("month") = month,
        Rcpp::Named("day") = day
    );
}

// [[Rcpp::export]]
int native_date_to_julian(const std::string& date) {
    return hec_dss_dateToJulian(date.c_str());
}
