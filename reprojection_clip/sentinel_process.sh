# A Modified and complete version of sentinel processing

#!/bin/bash
source_dir="XXX"
save_dir="XXX"
dem_file="XXX"
source_list=`ls $source_dir`

for file in $source_list
do
	src_img=$source_dir$file
	shpfile="${save_dir}${file%%.tif*}_3031.shp"
	dst_file="${shpfile%%.shp*}.tif"
	dem_dst="${dst_file%%.tif*}_dem.tif"

	echo "\033[32mProcessing ********** ${file} **********\033[0m"
	echo "\033[45;37mDEM...\033[0m"

	# step 1 reprojection sentinel-1
	echo "\033[36mReprojecting Sentinel-1\033[0m"
	gdalwarp -t_srs EPSG:3031 -tr 40 40 -dstnodata -999 $src_img $dst_file

	# step 2 Creating shapefile from sentinel-1 reprojection
	echo "\033[36mCreating shapefile for reprojection Tiff\033[0m"
	gdaltindex $shpfile $dst_file
	
	# step 3 Clipping TanDEM
	echo "\033[36mClipping TanDEM\033[0m"
	gdalwarp -dstnodata -999 -cutline $shpfile -crop_to_cutline $dem_file $dem_dst
	
	# Start processing ADD shapefile
	echo "\033[45;37mADD...\033[0m"
	add_shp="${shpfile%%.shp*}_add.shp"
	add_src="/home/cmx/ceph-data/antarctica_data/add_coastline_high_res_line_v7_5/add_coastline_high_res_line_v7_5.shp"
	add_small_root="${save_dir}temp_file/"
	largelabel="${dst_file%%.tif*}_large_label.tif"
	label="${dst_file%%.tif*}_label.tif"
	
	# step 4 Clip ADD shapefile
	echo "\033[36mClipping ADD shapefile according to sentinel image\033[0m"
	ogr2ogr -clipsrc $shpfile $add_shp $add_src

	# step 5 Separate ADD attributes
	echo "\033[36mSeparating ADD attributes into small shapefiles\033[0m"
	mkdir $add_small_root
	python /home/cmx/ceph-data/antarctica_ice_shelf/amery_demo/add_process.py $add_shp $add_small_root

	# step 6 Convert attributes shapefiles into tiff
	echo "\033[36mRasterizing shapefiles\033[0m"
	cd $add_small_root
	gdal_rasterize -l grounding_line -burn 0 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff grounding_line.shp grounding_line.tif
	gdal_rasterize -l ice_coastline -burn 1 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff ice_coastline.shp ice_coastline.tif
	gdal_rasterize -l ice_rumples -burn 2 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff ice_rumples.shp ice_rumples.tif
	gdal_rasterize -l ice_shelf_and_front -burn 3 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff  ice_shelf_and_front.shp ice_shelf_and_front.tif
	gdal_rasterize -l rock_against_ice_shelf -burn 4 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff rock_against_ice_shelf.shp rock_against_ice_shelf.tif
	gdal_rasterize -l rock_coastline -burn 5 -tr 40 40 -a_nodata -999 -ot Float32 -of GTiff rock_coastline.shp rock_coastline.tif

	# step 7 merge tiff and clip
	echo "\033[36mMerge small tifs and Clip\033[0m"
	echo "gdalbuildvrt"
	gdalbuildvrt label_merge.vrt *.tif
	echo "gdal_translate"
	gdal_translate -co COMPRESS=LZW -co BIGTIFF=YES --config GDAL_VRT_ENABLE_PYTHON YES label_merge.vrt $largelabel
	echo "gdalwarp"
	gdalwarp -cutline $shpfile -crop_to_cutline $largelabel $label

	cd ../..
	rm -rf $add_small_root
	rm $add_shp ${add_shp%%.shp*}.dbf ${add_shp%%.shp*}.prj ${add_shp%%.shp*}.shx
	rm $largelabel
	

done
