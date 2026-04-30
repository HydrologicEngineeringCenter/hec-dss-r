library(pointr)
library(Rcpp)
options(scipen = 0)
Sys.setenv(PKG_LIBS = paste0("-L", file.path("C:", "projects", "hec-dss-r"), " -lhecdss"))

sourceCpp("src/native.cpp")

filename <- "C:/Users/q0hecoah/Documents/data/examples-all-data-types.dss"

dss <- test_open(filename)
print(dss)

path <- "/regular-time-series/GAPT/FLOW//6Hour/forecast1/"
df <- get_timeseries(dss, path)

print(df)

# Print specific attributes
print(attr(df, "Units"))
print(attr(df, "Type"))

pathname <- "/regular-time-series/GAPT/FLOW//6Hour/forecast_R/"
saveAsFloat <- 1
store_dataframe(dss, pathname, df, saveAsFloat)

# Close the DSS file
close_dss(dss)