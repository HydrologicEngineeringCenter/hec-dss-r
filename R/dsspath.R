# Port of hec-dss-python/src/hecdss/dsspath.py.
# A DSS pathname has six parts: /A/B/C/D/E/F/.

#' Parse a DSS pathname.
#'
#' @param path Raw DSS pathname starting and ending with "/".
#' @param rec_type Optional record type name (see RECORD_TYPE).
#' @return An object of class "dss_path" with fields A,B,C,D,E,F,rec_type.
#' @export
parse_dss_path <- function(path, rec_type = "Unknown") {
    if (!is.character(path) || length(path) != 1L) {
        stop("path must be a single character string")
    }
    p <- trimws(path)
    if (nchar(p) < 7L || substr(p, 1L, 1L) != "/" ||
        substr(p, nchar(p), nchar(p)) != "/") {
        stop(sprintf("Invalid DSS path: '%s'", path))
    }
    inner <- substr(p, 2L, nchar(p) - 1L)
    parts <- strsplit(inner, "/", fixed = TRUE)[[1L]]
    if (length(parts) < 6L) {
        parts <- c(parts, rep("", 6L - length(parts)))
    }
    structure(
        list(
            A = parts[1L], B = parts[2L], C = parts[3L],
            D = parts[4L], E = parts[5L], F = parts[6L],
            rec_type = rec_type
        ),
        class = "dss_path"
    )
}

#' Format a dss_path back to its string form.
#' @param p dss_path object.
#' @export
format_dss_path <- function(p) {
    if (!inherits(p, "dss_path")) stop("Not a dss_path object")
    paste0("/", p$A, "/", p$B, "/", p$C, "/", p$D, "/", p$E, "/", p$F, "/")
}

#' Return the path with the D (date) part blanked out.
#' @param p dss_path object.
#' @export
path_without_date <- function(p) {
    if (!inherits(p, "dss_path")) p <- parse_dss_path(p)
    p$D <- ""
    p
}

path_location_info <- function(p) {
    if (!inherits(p, "dss_path")) p <- parse_dss_path(p)
    p$D <- ""
    p$E <- ""
    p$F <- ""
    p
}

#' @export
print.dss_path <- function(x, ...) {
    cat(format_dss_path(x), "  [", x$rec_type, "]\n", sep = "")
    invisible(x)
}

is_time_series_path <- function(p) {
    is_time_series_type(p$rec_type)
}
