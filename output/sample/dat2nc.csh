#!/bin/csh -f
rm -f *.nc
cdo -b F64 -f nc import_binary output.t42.ctl output.3hourly.nc
cdo daymean output.3hourly.nc output.daily.nc
cdo monmean output.daily.nc output.monthly.nc

rm -f output.3hourly.nc
rm -f output.daily.nc

