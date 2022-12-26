#!/bin/bash
source_dir="/data1/zjp/MODIS/xian_data_cmx/"
save_dir="/data1/zjp/MODIS/xian_data_cmx/data_process/"

for file in `ls $source_dir`
do
    if [[ "${file##*.}" == "hdf" ]];then
        echo $file
        gdal_translate $file -sds ${save_dir}${file: 0: 23}.tif
        gdal_merge.py -separate -o ${save_dir}${file: 0: 23}.tif ${save_dir}${file: 0: 23}_*.tif
        rm -rf ${save_dir}*h26v05_*.tif ${save_dir}*h27v05_*.tif
    fi
done
