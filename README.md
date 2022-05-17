# Memo
## HDF2nc.py
[TRMM](https://gpm.nasa.gov/missions/trmm) was a research satellite in operation from 1997 to 2015. By covering the tropical and sub-tropical regions of the Earth, TRMM provided much needed information on rainfall and its associated heat release that helps to power the global atmospheric circulation that shapes both weather and climate.

Below use **TRMM Rainfall Estimate L3 3 hour 0.25 degree x 0.25 degree V7 (TRMM_3B42)** dataset as an example.

The data can be downloaded via [wget](https://disc.gsfc.nasa.gov/datasets/TRMM_3B42_7/summary).

+ Format: HDF
+ Spatial Coverage: -180.0 - 180.0, -50.0 - 50.0. More specific, -179.875 - 179.875, -49.875 - 49.875. (1440 $\times$ 400)
+ Temporal Coverage: 1997-12-31 to 2020-0101
+ File Size: 530 KB per file, *with one time step each file*.

The code below convert TRMM dataset (3680 files) into netCDF4 (precipitation.nc, one file) and txt (trmm_15_19.txt, one file). The Temporal coverage is from 2015 - 2019 JJA, and the spatial coverage remains unchange. The size of txt file is **50G**, and netCDF4 file is **16G**.
