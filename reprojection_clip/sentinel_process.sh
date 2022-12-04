#!/bin/bash
source_dir=".."
save_dir=".."
dem_file=".."
source_list=`ls $source_dir`

for file in $source_list
do
        src_img=$source_dir$file
        shpfile1="${save_dir}${file%%.tif*}.shp"
        shpfile2="${shpfile1%%.shp*}_3031.shp"
        dst_file1="${shpfile1%%.shp*}_3031.tif"
        dst_file2="${dst_file1%%.tif*}_clip.tif"
        dem_dst="${dst_file2%%.tif*}_dem.tif"

        echo "\033[32mProcessing ********** ${file} **********\033[0m"
        # step 1 create shapefile from original sentinel-1 Tiff
        echo "\033[36mCreating shapefile\033[0m"
        gdaltindex $shpfile1 $src_img

        # step 2 change shapefile projection
        echo "\033[36mChanging shapefile\033[0m"
        ogr2ogr -t_srs EPSG:3031 $shpfile2 $shpfile1

        # step 3 reproject + clip
        echo "\033[36mReprojection + Clipping\033[0m"
        python rasterio_reprojection_clip.py $src_img $dst_file1 $dst_file2 $shpfile2

        # step 4 cut TanDEM
        echo "\033[36mClip TanDEM\033[0m"
        python rasterio_DEM.py $dem_file $dem_dst $shpfile2

        rm $shpfile1 ${shpfile1%%.shp*}.dbf ${shpfile1%%.shp*}.prj ${shpfile1%%.shp*}.shx $dst_file1
done
