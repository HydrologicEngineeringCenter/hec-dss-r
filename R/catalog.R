# Port of hec-dss-python/src/hecdss/catalog.py.
# Condenses time-series records with identical A/B/C/E/F parts but different
# D (date) parts into a single condensed entry.

#' Build a condensed DSS catalog from native_catalog() output.
#'
#' @param uncondensed_paths character vector of raw pathnames.
#' @param raw_record_types integer vector of raw record-type codes.
#' @return A "dss_catalog" object (an environment) with fields:
#'   items, record_type_dict, raw_paths, plus method get_record_type(path).
build_catalog <- function(uncondensed_paths, raw_record_types) {
    self <- new.env(parent = emptyenv())
    self$uncondensed_paths <- as.character(uncondensed_paths)
    self$raw_record_types  <- as.integer(raw_record_types)

    # Map lowercased key path → list(rec_type=<name>, raw_path=<original>).
    record_type_dict <- list()
    raw_paths_dict   <- list()
    # For TS: lowercased path-without-date → character vector of raw D-parts
    # (kept as strings to avoid POSIXct class/tz quirks across c() chains).
    ts_d_parts <- list()

    items <- list()

    for (i in seq_along(self$uncondensed_paths)) {
        raw <- self$uncondensed_paths[[i]]
        rt_name <- record_type_from_int(self$raw_record_types[[i]])
        path <- parse_dss_path(raw, rt_name)

        if (is_time_series_path(path)) {
            clean <- format_dss_path(path_without_date(path))
            key <- tolower(clean)
            raw_paths_dict[[key]] <- raw
            record_type_dict[[key]] <- rt_name
            if (grepl("^\\d{2}[A-Za-z]{3}\\d{4}$", path$D)) {
                ts_d_parts[[key]] <- c(ts_d_parts[[key]], path$D)
            }
        } else if (rt_name %in% c("PairedData", "Grid", "Text", "LocationInfo", "Array")) {
            key <- tolower(format_dss_path(path))
            raw_paths_dict[[key]] <- raw
            record_type_dict[[key]] <- rt_name
            items[[length(items) + 1L]] <- path
        } else {
            warning("Unsupported record type: ", rt_name, " for ", raw)
        }
    }

    # Build condensed entries for time-series groups: parse D-parts to POSIXct
    # only to determine sort order, then keep the original strings.
    for (key in names(ts_d_parts)) {
        d_parts <- ts_d_parts[[key]]
        parsed  <- as.POSIXct(d_parts, format = "%d%b%Y", tz = "UTC")
        ok <- !is.na(parsed)
        if (!any(ok)) next
        d_parts <- d_parts[ok]
        parsed  <- parsed[ok]
        ord     <- order(parsed)
        d_parts <- d_parts[ord]

        condensed_d <- d_parts[1L]
        if (length(d_parts) > 1L) {
            condensed_d <- paste0(condensed_d, "-", d_parts[length(d_parts)])
        }
        rt_name <- record_type_dict[[key]]
        p <- parse_dss_path(raw_paths_dict[[key]], rt_name)
        p$D <- condensed_d
        items[[length(items) + 1L]] <- p
    }

    self$items <- items
    self$record_type_dict <- record_type_dict
    self$raw_paths <- raw_paths_dict

    self$get_record_type <- function(pathname) {
        key <- tolower(pathname)
        if (!is.null(self$record_type_dict[[key]])) {
            return(self$record_type_dict[[key]])
        }
        p <- parse_dss_path(pathname)
        no_date <- tolower(format_dss_path(path_without_date(p)))
        if (!is.null(self$record_type_dict[[no_date]])) {
            return(self$record_type_dict[[no_date]])
        }
        loc <- tolower(format_dss_path(path_location_info(p)))
        if (!is.null(self$record_type_dict[[loc]])) {
            return(self$record_type_dict[[loc]])
        }
        "Unknown"
    }

    class(self) <- c("dss_catalog", "environment")
    self
}

#' @export
print.dss_catalog <- function(x, ...) {
    cat("DSS catalog: ", length(x$items), " condensed records\n", sep = "")
    for (item in x$items) {
        cat("  ", format_dss_path(item), "  [", item$rec_type, "]\n", sep = "")
    }
    invisible(x)
}

#' Convert a dss_catalog to a data.frame for inspection.
#' @export
as.data.frame.dss_catalog <- function(x, row.names = NULL, optional = FALSE, ...) {
    if (length(x$items) == 0L) {
        return(data.frame(
            pathname    = character(0),
            record_type = character(0),
            part_a = character(0), part_b = character(0), part_c = character(0),
            part_d = character(0), part_e = character(0), part_f = character(0),
            stringsAsFactors = FALSE
        ))
    }
    # Use lowercase / suffixed names: avoid conflicts with R's logical
    # constants `T` and `F` and reserved-ish single letters when printing.
    data.frame(
        pathname    = vapply(x$items, format_dss_path,                character(1L)),
        record_type = vapply(x$items, function(p) p$rec_type,         character(1L)),
        part_a = vapply(x$items, function(p) p$A, character(1L)),
        part_b = vapply(x$items, function(p) p$B, character(1L)),
        part_c = vapply(x$items, function(p) p$C, character(1L)),
        part_d = vapply(x$items, function(p) p$D, character(1L)),
        part_e = vapply(x$items, function(p) p$E, character(1L)),
        part_f = vapply(x$items, function(p) p$F, character(1L)),
        stringsAsFactors = FALSE
    )
}
