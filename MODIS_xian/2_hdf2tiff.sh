#!/bin/bash

# to run the program: bash modis_process.sh
source_dir="/ceph-data/cmx/xian/data/xian_data_cmx/"
save_dir="/ceph-data/cmx/xian/data/xian_data_cmx/data_process/"

for file in `ls $source_dir`
do
    if [[ "${file##*.}" == "hdf" ]];then
        echo $file
	gdal_translate $file -sds ${save_dir}${file: 0: 23}.tif
	gdal_merge.py -separate -o ${save_dir}${file: 0: 23}.tif ${save_dir}${file: 0: 23}_01.tif ${save_dir}${file: 0: 23}_02.tif ${save_dir}${file: 0: 23}_03.tif ${save_dir}${file: 0: 23}_04.tif ${save_dir}${file: 0: 23}_05.tif ${save_dir}${file: 0: 23}_06.tif ${save_dir}${file: 0: 23}_07.tif ${save_dir}${file: 0: 23}_08.tif ${save_dir}${file: 0: 23}_09.tif ${save_dir}${file: 0: 23}_10.tif ${save_dir}${file: 0: 23}_11.tif ${save_dir}${file: 0: 23}_12.tif
	rm -rf ${save_dir}*h26v05_*.tif ${save_dir}*h27v05_*.tif
    fi
done
