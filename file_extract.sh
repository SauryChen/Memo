#!/bin/bash

source_dir="/data1/zjp/MODIS/MOD13Q1"
source_list=`ls $source_dir`
save_dir="/data1/usr/MODIS/data"
st_year=2014
end_day=100

for file_list in $source_list
do
        filelistnum=$(($file_list))
        if [ $filelistnum -gt $st_year ];then
                echo $file_list
                for file in `ls "${source_dir}/${file_list}"`
                do
                        # Here is a bug. I would like to extract files with name less than 100.
                        # However, with #*0, names such as "305, 209" will include.
                        # If only use $((file)), an error like "shell Illegal number: 049" will be raised.
                        
                        filenum=$((${file#*0}))
                        if [ $filenum -lt $end_day ];then
                                echo $file
                                cp ${source_dir}/${file_list}/${file}/MOD13Q1.A*.h26v05*.hdf $save_dir
                                cp ${source_dir}/${file_list}/${file}/MOD13Q1.A*.h27v05*.hdf $save_dir
                        fi
                done    
        fi
done
