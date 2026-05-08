# Open / close / reopen lifecycle tests for HecDss.
# Each test copies the bundled example DSS into tempdir so the fixture is
# never modified, and closes its handle before returning so the finalizer
# is not racing against later tests.

example_dss_source <- function() {
    candidates <- c(
        # When testthat runs from tests/testthat/
        normalizePath("../../examples/examples-all-data-types.dss", mustWork = FALSE),
        # When run from the package root
        normalizePath("examples/examples-all-data-types.dss", mustWork = FALSE),
        # If installed alongside the package
        system.file("extdata", "examples-all-data-types.dss", package = "hecdssr")
    )
    hit <- candidates[file.exists(candidates) & nzchar(candidates)]
    if (!length(hit)) return(NA_character_)
    hit[[1L]]
}

fresh_dss_copy <- function() {
    src <- example_dss_source()
    if (is.na(src)) skip("example DSS fixture not available")
    dst <- tempfile(fileext = ".dss")
    stopifnot(file.copy(src, dst, overwrite = TRUE))
    dst
}

test_that("open_dss returns an open HecDss with a working handle", {
    path <- fresh_dss_copy()
    dss <- open_dss(path)
    expect_s3_class(dss, "HecDss")
    expect_true(dss$is_open())
    expect_equal(dss$filename, path)
    expect_true(nzchar(dss$get_version()))
    expect_gt(dss$record_count(), 0L)
    dss$close()
    unlink(path)
})

test_that("close() flips is_open and blocks further operations", {
    path <- fresh_dss_copy()
    dss <- open_dss(path)
    expect_true(dss$is_open())

    dss$close()
    expect_false(dss$is_open())

    expect_error(dss$get_version(),   "closed")
    expect_error(dss$record_count(),  "closed")
    expect_error(dss$get_catalog(),   "closed")
    expect_error(
        dss$get("/regular-time-series/GAPT/FLOW/01Sep2021/6Hour/forecast1/"),
        "closed"
    )
    unlink(path)
})

test_that("close() is idempotent", {
    path <- fresh_dss_copy()
    dss <- open_dss(path)
    expect_silent(dss$close())
    expect_silent(dss$close())
    expect_false(dss$is_open())
    unlink(path)
})

test_that("HecDss$new and open_dss yield equivalent results", {
    path <- fresh_dss_copy()

    a <- HecDss$new(path)
    version_a  <- a$get_version()
    nrecords_a <- a$record_count()
    a$close()

    b <- open_dss(path)
    expect_equal(b$get_version(),  version_a)
    expect_equal(b$record_count(), nrecords_a)
    b$close()

    unlink(path)
})

test_that("a file can be reopened after close and reads match", {
    path <- fresh_dss_copy()

    dss1 <- open_dss(path)
    version1  <- dss1$get_version()
    nrecords1 <- dss1$record_count()
    catalog1  <- as.data.frame(dss1$get_catalog())
    dss1$close()
    expect_false(dss1$is_open())

    dss2 <- open_dss(path)
    expect_true(dss2$is_open())
    expect_equal(dss2$get_version(),  version1)
    expect_equal(dss2$record_count(), nrecords1)
    expect_equal(as.data.frame(dss2$get_catalog()), catalog1)
    dss2$close()

    unlink(path)
})

test_that("reopen survives multiple open/close cycles", {
    path <- fresh_dss_copy()

    d <- open_dss(path)
    baseline_version <- d$get_version()
    baseline_n       <- d$record_count()
    d$close()

    for (i in seq_len(3)) {
        d <- open_dss(path)
        expect_true(d$is_open())
        expect_equal(d$get_version(),  baseline_version)
        expect_equal(d$record_count(), baseline_n)
        d$close()
        expect_false(d$is_open())
    }

    unlink(path)
})
