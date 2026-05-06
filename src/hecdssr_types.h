#ifndef HECDSSR_TYPES_H
#define HECDSSR_TYPES_H

// Rcpp's compileAttributes() automatically #include's any header named
// src/<pkg>_types.h into the generated RcppExports.cpp, which is how we
// make our custom DssPtr typedef visible to the auto-generated wrappers.
// Add any other user types that appear in [[Rcpp::export]] signatures here.

#include "dss_ptr.h"

#endif
