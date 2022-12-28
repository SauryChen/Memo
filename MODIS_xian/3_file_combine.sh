#!/bin/bash
#date=$1
days="001 017 033 049 065 081 097"
for year in $(seq 2015 2021)
do
    for day in $days
    do
        date=$year$day
        echo "\033[36mProcessing $date\033[0m"
        filedir="..."
        savedir="..."
        file1=$filedir"MOD13Q1.A"$date".h26v05.tif"
        file2=$filedir"MOD13Q1.A"$date".h27v05.tif"
        vrt=$savedir$date".vrt"
        mergefile=$savedir$date"_merge.tif"
        projectfile=$savedir$date"_project.tif"
        savefile=$savedir$date".tif"
        shapefile=".../xian.shp"

        gdalbuildvrt $vrt $file1 $file2
        gdal_translate -co COMPRESS=LZW -co BIGTIFF=YES --config GDAL_VRT_ENABLE_PYTHON YES $vrt $mergefile
        gdalwarp -t_srs EPSG:4326 $mergefile $projectfile
        gdalwarp -ts 1079 524 -cutline $shapefile -crop_to_cutline $projectfile $savefile
        rm $vrt $mergefile $projectfile
    done
done
