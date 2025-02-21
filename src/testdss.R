library(pointr)
library(Rcpp)
options(scipen = 0)
Sys.setenv(PKG_LIBS = paste0("-L", file.path("C:", "projects", "R-Dss"), " -lhecdss"))
Sys.setenv(PKG_CPPFLAGS = paste0("-I", file.path("C:", "projects", "R-Dss", "include")))
sourceCpp("native.cpp")

filename <- "C:/Users/q0hecoah/Documents/data/examples-all-data-types.dss"

dss <- test_open(filename)
print(dss)
# result2 <- test_version(result)
# print(result2)

path <- "/regular-time-series/GAPT/FLOW//6Hour/forecast1/"
# startdate <- '01Sep2021'
# starttime <- '06:00:00'
# enddate <- '01Nov2021'
# endtime <- '00:00:00'
# arraysize <- 244
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