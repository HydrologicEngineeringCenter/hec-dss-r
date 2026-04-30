.onLoad <- function(libname, pkgname) {
    libs_path <- file.path(libname, pkgname, "libs")

    if (.Platform$OS.type == "windows") {
        current_path <- Sys.getenv("PATH")
        Sys.setenv(PATH = paste(libs_path, current_path, sep = ";"))
    } else {
        ld_path <- Sys.getenv("LD_LIBRARY_PATH")
        Sys.setenv(LD_LIBRARY_PATH = paste(libs_path, ld_path, sep = ":"))
    }
}
