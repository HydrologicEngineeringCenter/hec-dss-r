// hecdss.cpp
// [[Rcpp::depends(Rcpp)]]
// [[Rcpp::plugins("cpp11")]]
#include <Rcpp.h>
#include <Windows.h>
#include <iostream>
#include "hecdss.h"

class HecDss {
public:

    HecDss(string filename){
        native = Native();
        native.hec_dss_open(filename);
        catalog = NULL;
        filename = filename;
        closed = false;
    }

    ~HecDss() {
        //close
    }

    void close() {
        native.hec_dss_close();
        closed = true;
    }

private:
    Native native;
    Catalog catalog;
    string filename;
    bool closed;

};

// [[Rcpp::export]]
Rcpp::XPtr<HecDss> openHecDss(String filename) {
    HecDss* ptr = new HecDss(filename);
    return Rcpp::XPtr<HecDss>(ptr, true);
}