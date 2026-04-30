#ifndef HECDSS_R_DSS_PTR_H
#define HECDSS_R_DSS_PTR_H

#include <Rcpp.h>

extern "C" {
#include "hecdss.h"
}

inline void dss_finalizer(dss_file* p) {
    if (p != nullptr) {
        hec_dss_close(p);
    }
}

typedef Rcpp::XPtr<dss_file, Rcpp::PreserveStorage, dss_finalizer> DssPtr;

#endif
