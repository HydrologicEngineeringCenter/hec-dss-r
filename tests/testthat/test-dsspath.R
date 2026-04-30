test_that("parse_dss_path round-trips and exposes parts", {
    p <- parse_dss_path("/A/B/C/01JAN2024/1Hour/F/", "RegularTimeSeries")
    expect_equal(p$A, "A")
    expect_equal(p$B, "B")
    expect_equal(p$C, "C")
    expect_equal(p$D, "01JAN2024")
    expect_equal(p$E, "1Hour")
    expect_equal(p$F, "F")
    expect_equal(format_dss_path(p), "/A/B/C/01JAN2024/1Hour/F/")
})

test_that("path_without_date blanks the D part", {
    p  <- parse_dss_path("/A/B/C/01JAN2024/1Hour/F/", "RegularTimeSeries")
    p2 <- path_without_date(p)
    expect_equal(p2$D, "")
    expect_equal(format_dss_path(p2), "/A/B/C//1Hour/F/")
})

test_that("invalid paths raise", {
    expect_error(parse_dss_path("not-a-path"))
    expect_error(parse_dss_path("/too/short/"))
})
