import os
import sys
import fiona
import numpy as np
import rasterio as rio
import rasterio.mask
from rasterio import crs 
from rasterio.warp import calculate_default_transform, reproject

src_img = sys.argv[1]
dst_img1 = sys.argv[2]
dst_img2 = sys.argv[3]
shpdatafile = sys.argv[4]

dst_crs = crs.CRS.from_epsg(3031)

def reprojectRaster(src_img, dst_img, dst_crs):
    with rio.open(src_img) as src_ds:
        profile = src_ds.profile
        
        dst_transform, dst_width, dst_height = calculate_default_transform(
            src_ds.crs, dst_crs, src_ds.width, src_ds.height, *src_ds.bounds
            )

        profile.update({
        'crs': dst_crs,
        'transform': dst_transform,
        'width': dst_width,
        'height': dst_height,
        'nodata': -999
        })
        
        with rio.open(dst_img,'w', **profile, num_threads=20) as dst_ds:
            assert src_ds.count == 1, 'Error: More than one band.'
            src_array = src_ds.read(1)
            dst_array = np.empty((dst_height, dst_width), dtype = profile['dtype'])
            
            print("Reprojecting to {}".format(os.path.split(dst_img)[1]))
            reproject(
                source = src_array,
                src_crs = src_ds.crs,
                src_transform = src_ds.transform,
                destination = dst_array,
                dst_transform = dst_transform,
                dst_crs = dst_crs,
                num_threads = 20
            )
            
            print("Writing to {}".format(os.path.split(dst_img)[1]))
            dst_ds.write(dst_array, 1)
            
def clipRasterByShapefile(src_img, shpdatafile, dst_img, nodata = -999):
    with fiona.open(shpdatafile, "r") as shapefile:
        features = [feature['geometry'] for feature in shapefile]
    print("Types: {}, features number: {}, coordinates number: {}".format(features[0]['type'],len(features), len(features[0]['coordinates'][0])))
    
    src = rio.open(src_img) # 读取原始影像
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

    
reprojectRaster(src_img=src_img, dst_img=dst_img1, dst_crs=dst_crs)
clipRasterByShapefile(src_img=dst_img1, shpdatafile=shpdatafile, dst_img=dst_img2)

        
        
        
