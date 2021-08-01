## Packages, also need to install gdal
library(raster)
library(rasterVis)
library(ncdf4)
library(lattice)

input_nc = 'atm_daymean_2020.nc'
ncfile = nc_open(input_nc)
names(ncfile$var) # print variables in the file

# choose a variable
wind_v = 'v10'

# create the output path
dir.output <- 'Desktop/wind_v/'

# if you would like to create one .tif for each day, use raster, and set band = i 
for (i in 1:366){
  # 366 days in 2020, with one .tif for each day
  nc2raster = raster(input_nc, varname = wind_v, band = i)
  output = paste(dir.output,'v_',i,'.tif', sep = '')
  writeRaster(nc2raster, output, format = 'GTiff', overwrite = TRUE)
}

# if you would like to create include 366 days in one .tif file, use stack
nc2raster = stack(input_nc,varname = wind_v)
writeRaster(nc2raster, output, format = 'GTiff', overwrite = TRUE)