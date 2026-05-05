#!/usr/bin/env Rscript
# Helper script to retrieve the native HEC-DSS shared libraries.
#
# Mirrors the role of `src/hecdss/download_hecdss.py` in the hec-dss-python
# project: it fetches the platform-specific archive from the HEC Maven Nexus
# and drops the shared library into `inst/libs/` (where `src/Makevars` and
# `src/Makevars.win` look for it).
#
# Note: the C header `inst/include/hecdss.h` is vendored in-tree from the
# HydrologicEngineeringCenter/hec-dss repo and is NOT downloaded here. Bump
# both HECDSS_VERSION below and the vendored header together when the C API
# changes.
#
# Usage (from the package root):
#   Rscript tools/download_hecdss.R
#
# Or from an interactive R session:
#   source("tools/download_hecdss.R")
#
# The downloaded binaries are gitignored. Run this once after cloning the
# repo, then again whenever HECDSS_VERSION changes.

# Pinned native HEC-DSS release. The vendored header `inst/include/hecdss.h`
# MUST track this same tag — re-vendor from
# HydrologicEngineeringCenter/hec-dss at this tag whenever you bump it.
HECDSS_VERSION <- "7-JA-7"

BASE_URL <- paste0(
  "https://www.hec.usace.army.mil/nexus/repository/maven-public/",
  "mil/army/usace/hec/hecdss/"
)

platform_tag <- function() {
  sysname <- Sys.info()[["sysname"]]
  arch <- Sys.info()[["machine"]]
  arch_tag <- if (arch %in% c("x86_64", "AMD64", "x86-64")) "x86_64" else arch
  os_tag <- switch(
    sysname,
    Windows = "win",
    Linux   = "linux",
    Darwin  = stop("macOS binaries are not published on the HEC Nexus."),
    stop("Unsupported platform: ", sysname)
  )
  paste(os_tag, arch_tag, sep = "-")
}

download_and_unzip <- function(url, destination_dir) {
  if (!dir.exists(destination_dir)) {
    dir.create(destination_dir, recursive = TRUE)
  }
  message("Downloading ", url)
  zip_path <- tempfile(fileext = ".zip")
  on.exit(unlink(zip_path, force = TRUE), add = TRUE)

  status <- utils::download.file(url, zip_path, mode = "wb", quiet = FALSE)
  if (status != 0L) {
    stop("Download failed (status ", status, ") for ", url)
  }

  files <- utils::unzip(zip_path, exdir = destination_dir)
  message("Extracted ", length(files), " file(s) to ", destination_dir)
  invisible(files)
}

# Sort extracted files into inst/libs (shared/static libs, import libs) and
# inst/include (headers). The Maven zip layout is flat enough that a simple
# extension-based sort works on every platform we ship.
organize_artifacts <- function(staging_dir, libs_dir, include_dir) {
  dir.create(libs_dir,    recursive = TRUE, showWarnings = FALSE)
  dir.create(include_dir, recursive = TRUE, showWarnings = FALSE)

  all_files <- list.files(staging_dir, recursive = TRUE, full.names = TRUE)
  lib_exts <- c("dll", "so", "a", "lib", "dylib")
  hdr_exts <- c("h", "hpp")

  move <- function(src, dest_dir) {
    dest <- file.path(dest_dir, basename(src))
    ok <- file.rename(src, dest)
    if (!ok) {
      file.copy(src, dest, overwrite = TRUE)
      unlink(src)
    }
    dest
  }

  for (f in all_files) {
    ext <- tolower(tools::file_ext(f))
    if (ext %in% lib_exts) {
      move(f, libs_dir)
    } else if (ext %in% hdr_exts) {
      move(f, include_dir)
    }
  }
}

main <- function() {
  # Resolve the package root regardless of where the script is invoked from.
  this_file <- tryCatch(
    normalizePath(sys.frame(1)$ofile, mustWork = FALSE),
    error = function(e) NA_character_
  )
  if (is.na(this_file) || !nzchar(this_file)) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- sub("^--file=", "", grep("^--file=", args, value = TRUE))
    this_file <- if (length(file_arg)) normalizePath(file_arg) else getwd()
  }
  pkg_root <- normalizePath(file.path(dirname(this_file), ".."))

  libs_dir    <- file.path(pkg_root, "inst", "libs")
  include_dir <- file.path(pkg_root, "inst", "include")

  tag <- platform_tag()
  archive <- sprintf("hecdss-%s-%s.zip", HECDSS_VERSION, tag)
  url <- sprintf("%s%s-%s/%s", BASE_URL, HECDSS_VERSION, tag, archive)

  staging <- tempfile("hecdss-")
  dir.create(staging)
  on.exit(unlink(staging, recursive = TRUE, force = TRUE), add = TRUE)

  download_and_unzip(url, staging)
  organize_artifacts(staging, libs_dir, include_dir)

  message(
    "Done. HEC-DSS ", HECDSS_VERSION, " (", tag, ") installed to:\n",
    "  libs:    ", libs_dir, "\n",
    "  include: ", include_dir
  )
}

if (sys.nframe() == 0L) {
  main()
}
