test_that("date_times_from_julian_array reproduces 1900-01-01 anchor", {
    # julian_base_date = 1 maps to 1900-01-01 + 0 seconds.
    out <- date_times_from_julian_array(0L, 1L, 1L, tz = "UTC")
    expect_equal(format(out, "%Y-%m-%d %H:%M:%S"), "1900-01-01 00:00:00")
})

test_that("dss_datetime_strings handles 24:00 midnight rule", {
    midnight <- as.POSIXct("2023-08-25 00:00:00", tz = "UTC")
    s <- dss_datetime_strings_from_datetime(midnight)
    expect_equal(s$date, "24Aug2023")
    expect_equal(s$time, "24:00:00")

    afternoon <- as.POSIXct("2023-08-25 14:30:00", tz = "UTC")
    s <- dss_datetime_strings_from_datetime(afternoon)
    expect_equal(s$date, "25Aug2023")
    expect_equal(s$time, "14:30:00")
})

test_that("interval_string_to_sec round-trips", {
    expect_equal(interval_string_to_sec("1Hour"),   3600L)
    expect_equal(interval_string_to_sec("6Hour"),   21600L)
    expect_equal(interval_string_to_sec("1Day"),    86400L)
    expect_equal(sec_to_interval_string(3600L),     "1Hour")
    expect_equal(sec_to_interval_string(86400L),    "1Day")
})
