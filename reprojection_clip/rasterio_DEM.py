import os
import sys
import fiona
import numpy as np
import rasterio as rio
import rasterio.mask
from rasterio import crs
from rasterio.warp import calculate_default_transform, reproject

src_img = sys.argv[1]
dst_img = sys.argv[2]
shpdatafile = sys.argv[3]

def clipRasterByShapefile(src_img, shpdatafile, dst_img, nodata = -999):
    with fiona.open(shpdatafile, "r") as shapefile:
        features = [feature['geometry'] for feature in shapefile]
    print("Types: {}, features number: {}, coordinates number: {}".format(features[0]['type'],len(features), len(features[0]['coordinates'][0])))
    
    src = rio.open(src_img)
    print("Clipping ...")
    out_image, out_transform = rio.mask.mask(src, features, all_touched = False, crop = True, nodata = nodata)
    out_meta = src.meta.copy()
    out_meta.update({"driver": "GTiff",
                     "height": out_image.shape[1],
                     "width": out_image.shape[2],
                     "transform": out_transform})
    
    output_file = rio.open(dst_img, "w", compress = "LZW", **out_meta, num_threads=20)
    output_file.write(out_image)
    print("Saved as {}".format(os.path.split(dst_img)[1]))
    output_file.close()

clipRasterByShapefile(src_img=src_img, dst_img=dst_img, shpdatafile=shpdatafile)
