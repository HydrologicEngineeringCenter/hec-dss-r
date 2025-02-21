// example.cpp
// [[Rcpp::depends(Rcpp)]]
// [[Rcpp::plugins("cpp11")]]
#include <Rcpp.h>
#include <Windows.h>
#include <iostream>
#include "hecdss.h"
#include <ctime>

double DSS_UNDEFINED_VALUE = -340282346638528859811704183484516925440.000000;

// Function to format Rcpp::Datetime to string using strftime
std::string format_datetime(const Rcpp::Datetime& datetime, const char* format="%Y-%m-%d %H:%M:%S") {
    // char buffer[100];
    // std::time_t time = static_cast<std::time_t>(datetime.getFractionalTimestamp());
    // std::tm tm_info;
    // gmtime_s(&tm_info, &time); // Use gmtime_s for thread-safe conversion
    // std::strftime(buffer, sizeof(buffer), format, &tm_info);
    double timestamp = datetime.getFractionalTimestamp();
    time_t t = (time_t) timestamp;
    // Format datetime
    char buffer[80];
    strftime(buffer, sizeof(buffer), format, localtime(&t));
    return std::string(buffer);
}

// Function to convert from DSS integer datetime array to Rcpp::Datetime array
std::vector<Rcpp::Datetime> date_times_from_julian_array(const std::vector<int>& times_julian, 
                                                         int time_granularity_seconds, 
                                                         int julian_base_date) {
    if (times_julian.empty()) {
        Rcpp::stop("Time Series Times array was empty. Something didn't work right in DSS.");
    }

    std::vector<Rcpp::Datetime> times;
    Rcpp::Datetime baseDateTime("1900-01-01 00:00:00");
    baseDateTime = baseDateTime - Rcpp::Datetime(1 * 86400); // Subtract one day


    for (int t : times_julian) {
        double delta = 0;
        if (time_granularity_seconds == 1) {  // 1 second
            delta = t;
        } else if (time_granularity_seconds == 60) {  // 60 seconds per minute
            delta = static_cast<double>(t) * 60;
        } else if (time_granularity_seconds == 3600) {  // 3600 seconds per hour
            delta = static_cast<double>(t) * 3600;
        } else if (time_granularity_seconds == 86400) {  // 86400 seconds per day
            delta = static_cast<double>(t) * 86400;
        }

        Rcpp::Datetime datetime = baseDateTime + Rcpp::Datetime(delta) + Rcpp::Datetime(static_cast<double>(julian_base_date) * 86400);
        times.push_back(datetime);
    }

    return times;
}

// [[Rcpp::export]]
Rcpp::XPtr<dss_file> test_open(const char* filename){
    dss_file* dss12 = nullptr;
    hec_dss_open(filename, &dss12);

    return Rcpp::XPtr<dss_file>(dss12, true);
}

// [[Rcpp::export]]
int test_version(Rcpp::XPtr<dss_file> dss12){
    dss_file* dss1 = dss12.get();
    return hec_dss_getVersion(dss1);
}

// // [[Rcpp::export]]
// Rcpp::List retrieve_ts_info(Rcpp::XPtr<dss_file> dss, std::string pathname) {
//     const int unitsLength = 40;
//     const int typeLength = 40;
//     char units[unitsLength] = "";
//     char type[typeLength] = "";

//     int status = hec_dss_tsRetrieveInfo(dss.get(), pathname.c_str(), units, unitsLength, type, typeLength);
//     if (status != 0) {
//         Rcpp::stop("Error retrieving time series info");
//     }

//     return Rcpp::List::create(Rcpp::Named("units") = std::string(units),
//                               Rcpp::Named("type") = std::string(type));
// }

// [[Rcpp::export]]
Rcpp::List get_date_time_range_full(Rcpp::XPtr<dss_file> dss, std::string pathname, int boolFullSet) {
    int firstValidJulian = 0;
    int firstSeconds = 0;
    int lastValidJulian = 0;
    int lastSeconds = 0;

    int status = hec_dss_tsGetDateTimeRange(dss.get(), pathname.c_str(), boolFullSet, &firstValidJulian, &firstSeconds, &lastValidJulian, &lastSeconds);
    if (status != 0) {
        Rcpp::stop("Error retrieving full date-time range");
    }

    std::vector<int> firstSecondsVec = {firstSeconds};
    std::vector<int> lastSecondsVec = {lastSeconds};

    Rcpp::Datetime first = date_times_from_julian_array(firstSecondsVec, 1, firstValidJulian)[0];
    Rcpp::Datetime last = date_times_from_julian_array(lastSecondsVec, 1, lastValidJulian)[0];


    return Rcpp::List::create(Rcpp::Named("first") = first,
                              Rcpp::Named("last") = last);
}

// [[Rcpp::export]]
Rcpp::List get_ts_sizes(Rcpp::XPtr<dss_file> dss, std::string pathname, 
                        std::string startDate, std::string startTime, 
                        std::string endDate, std::string endTime) {
    int numberValues = 0;
    int qualityElementSize = 0;

    int status = hec_dss_tsGetSizes(dss.get(), pathname.c_str(), 
                                    startDate.c_str(), startTime.c_str(), 
                                    endDate.c_str(), endTime.c_str(), 
                                    &numberValues, &qualityElementSize);
    if (status != 0) {
        Rcpp::stop("Error retrieving time series sizes");
    }

    return Rcpp::List::create(Rcpp::Named("numberValues") = numberValues,
                              Rcpp::Named("qualityElementSize") = qualityElementSize);
}

// [[Rcpp::export]]
Rcpp::DataFrame get_timeseries(Rcpp::XPtr<dss_file> dss, std::string pathname, 
                               Rcpp::Nullable<Rcpp::Datetime> startDateTime = R_NilValue, 
                               Rcpp::Nullable<Rcpp::Datetime> endDateTime = R_NilValue) {
    Rcpp::Datetime startDateTimeVal;
    Rcpp::Datetime endDateTimeVal;

    // Retrieve date-time range if startDateTime or endDateTime is not provided
    if (startDateTime.isNull() || endDateTime.isNull()) {
        Rcpp::List date_time_range = get_date_time_range_full(dss, pathname, 1);
        
        if (startDateTime.isNull()) {
            startDateTimeVal = date_time_range["first"];
        } else {
            startDateTimeVal = Rcpp::Datetime(startDateTime);
        }
        if (endDateTime.isNull()) {
            endDateTimeVal = date_time_range["last"];
        } else {
            endDateTimeVal = Rcpp::Datetime(endDateTime);
        }
    } else {
        startDateTimeVal = Rcpp::Datetime(startDateTime);
        endDateTimeVal = Rcpp::Datetime(endDateTime);
    }
    // Rcpp::Rcout << "Start Time Val: " << startDateTimeVal << std::endl;
    // Rcpp::Rcout << "End Date Val: " << endDateTimeVal << std::endl;

    std::string startDate = format_datetime(startDateTimeVal , "%d%b%Y");
    std::string startTime = format_datetime(startDateTimeVal , "%H:%M:%S");
    std::string endDate = format_datetime(endDateTimeVal , "%d%b%Y");
    std::string endTime = format_datetime(endDateTimeVal , "%H:%M:%S");

    // Retrieve time series sizes
    Rcpp::List ts_sizes = get_ts_sizes(dss, pathname, startDate, startTime, endDate, endTime);
    int arraySize = Rcpp::as<int>(ts_sizes["numberValues"]);

    std::vector<int> timeArray(arraySize);
    std::vector<double> valueArray(arraySize);
    int numberValuesRead = 0;
    std::vector<int> quality(arraySize);
    int julianBaseDate = 0;
    int timeGranularitySeconds = 0;
    char units[50];
    char type[50];

    // // Retrieve time series info
    // Rcpp::List tsInfo = retrieve_ts_info(dss, pathname);
    // std::string units = Rcpp::as<std::string>(tsInfo["units"]);
    // std::string type = Rcpp::as<std::string>(tsInfo["type"]);

    // Debugging output
    Rcpp::Rcout << "Array Sizes: " << arraySize << std::endl;
    Rcpp::Rcout << "Start Time: " << startTime << std::endl;
    Rcpp::Rcout << "Start Date: " << startDate << std::endl;
    Rcpp::Rcout << "End Time: " << endTime << std::endl;
    Rcpp::Rcout << "End Date: " << endDate << std::endl;

    int status = hec_dss_tsRetrieve(dss.get(), pathname.c_str(), 
                                    startDate.c_str(), startTime.c_str(), 
                                    endDate.c_str(), endTime.c_str(), 
                                    timeArray.data(), valueArray.data(), arraySize, 
                                    &numberValuesRead, quality.data(), arraySize, 
                                    &julianBaseDate, &timeGranularitySeconds, 
                                    units, 40, type, 40);

    if (status != 0) {
        Rcpp::Rcout << "Error code: " << status << std::endl;
        Rcpp::Rcout << "Pathname: " << pathname << std::endl;
        Rcpp::Rcout << "Start Date: " << startDate << std::endl;
        Rcpp::Rcout << "Start Time: " << startTime << std::endl;
        Rcpp::Rcout << "End Date: " << endDate << std::endl;
        Rcpp::Rcout << "End Time: " << endTime << std::endl;
        Rcpp::stop("Error retrieving time series data");
    }

    // Convert timeArray to Rcpp::Datetime
    std::vector<Rcpp::Datetime> datetimeArray = date_times_from_julian_array(timeArray, timeGranularitySeconds, julianBaseDate);

    // Filter out undefined values
    std::vector<Rcpp::Datetime> filteredTimeArray;
    std::vector<double> filteredValueArray;
    for (int i = 0; i < numberValuesRead; ++i) {
        //if (valueArray[i] != DSS_UNDEFINED_VALUE) {
            filteredTimeArray.push_back(datetimeArray[i]);
            filteredValueArray.push_back(valueArray[i]);
        //}
    }

    Rcpp::DataFrame df = Rcpp::DataFrame::create(Rcpp::Named("Time") = filteredTimeArray,
                                                 Rcpp::Named("Value") = filteredValueArray);

    // Set Units and Type as attributes
    df.attr("Units") = units;
    df.attr("Type") = type;

    return df;
    
}

// [[Rcpp::export]]
void store_timeseries(Rcpp::XPtr<dss_file> dss, std::string pathname, 
                      std::string startDate, std::string startTime, 
                      Rcpp::NumericVector valueArray, 
                      Rcpp::IntegerVector qualityArray, 
                      int saveAsFloat, std::string units, std::string type) {
    int valueArraySize = valueArray.size();
    int qualityArraySize = qualityArray.size();

    if (valueArraySize != qualityArraySize) {
        Rcpp::stop("Value array and quality array must have the same size");
    }

    int status = hec_dss_tsStoreRegular(dss.get(), pathname.c_str(), 
                                        startDate.c_str(), startTime.c_str(), 
                                        valueArray.begin(), valueArraySize, 
                                        qualityArray.begin(), qualityArraySize, 
                                        saveAsFloat, units.c_str(), type.c_str());

    if (status != 0) {
        Rcpp::stop("Error storing time series data");
    }
}

// [[Rcpp::export]]
void store_dataframe(Rcpp::XPtr<dss_file> dss, std::string pathname, Rcpp::DataFrame df, int saveAsFloat) {
    // Extract the first Datetime object from the data frame
    Rcpp::DatetimeVector timeVector = df["Time"];
    Rcpp::Datetime startDateTime = timeVector[0];

    // Format the Datetime object to get the start date and time
    std::string startDate = format_datetime(startDateTime, "%d%b%Y");
    std::string startTime = format_datetime(startDateTime, "%H:%M:%S");

    Rcpp::Rcout << "startDate: " << startDate << std::endl;
    Rcpp::Rcout << "startTime: " << startTime << std::endl;

    // Extract the values and quality arrays from the data frame
    Rcpp::NumericVector valueArray = df["Value"];
    Rcpp::IntegerVector qualityArray = df.containsElementNamed("Quality") ? df["Quality"] : Rcpp::IntegerVector(valueArray.size(), 0);

    // Extract units and type from the DataFrame attributes
    std::string units = Rcpp::as<std::string>(df.attr("Units"));
    std::string type = Rcpp::as<std::string>(df.attr("Type"));

    // Call the store_timeseries function to store the data in the DSS file
    store_timeseries(dss, pathname, startDate, startTime, valueArray, qualityArray, saveAsFloat, units, type);
}

// [[Rcpp::export]]
void close_dss(Rcpp::XPtr<dss_file> dss) {
    dss_file* dss1 = dss.get();
    hec_dss_close(dss1);
}