#' hecdssr: R Interface to HEC-DSS
#'
#' R bindings for the HEC-DSS C library, mirroring the architecture of
#' \href{https://github.com/HydrologicEngineeringCenter/hec-dss-python}{hec-dss-python}:
#' a thin Rcpp shim over the hecdss C API with all higher-level logic in R.
#'
#' The package is named `hecdssr` (not `hecdss`) to avoid a Windows
#' DLL-name collision with the underlying HEC C library `hecdss.dll`.
#'
#' @keywords internal
#' @useDynLib hecdssr, .registration = TRUE
#' @importFrom Rcpp evalCpp
#' @importFrom R6 R6Class
#' @importFrom xts xts xtsAttributes xtsAttributes<-
#' @importFrom zoo index index<- coredata coredata<-
#' @importFrom stats setNames
"_PACKAGE"
