library(Rcpp)
options(scipen = 0)
Sys.setenv(PKG_LIBS = paste0("-L", file.path("C:", "projects", "hec-dss-r"), " -lhecdss"))

sourceCpp("src/hecdssManager.cpp")

filename <- "C:/Users/q0hecoah/Documents/data/examples-all-data-types.dss"

dss <- openHecDss(filename)
print(dss)

path <- "/regular-time-series/GAPT/FLOW/01Sep2021/6Hour/forecast1/"
df <- getDataFrame(dss, path)

print(df)

attr(df, "PathName") <- "/regular-time-series/GAPT/FLOW//6Hour/forecast1_newR/"

putDataFrame(dss, df)

# Call the close function
closeHecDss(dss)