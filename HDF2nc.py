from mpl_toolkits.basemap import Basemap, cm
import matplotlib.pyplot as plt
import numpy as np
from pyhdf.SD import SD, SDC
import netCDF4 as nc

def read_file(year, month, day, hour):
    if (day < 10):
        file_name = 'TRMM/' + str(year) + '/3B42.' + str(year) + '0' + str(month) + '0' + str(day) + '.' + hour + '.7.HDF'
    elif (day >= 10):
        file_name = 'TRMM/' + str(year) + '/3B42.' + str(year) + '0' + str(month) + str(day) + '.' + hour + '.7.HDF'
    dataset = SD(file_name, SDC.READ)

    return dataset

def read_prec(dataset):
    precip = dataset.select('precipitation')
    precip = precip[:]
    precip = np.transpose(precip)
    np.putmask(precip, precip<0, 0)
    precip_t = np.flip(precip, 0)

    return precip_t

def write_nc(data, count):
    print(data.shape)
    f_w = nc.Dataset('precipitation.nc', 'w', format = 'NETCDF4')
    f_w.set_fill_off()
    f_w.createDimension('time', count)
    f_w.createDimension('lat', 400)
    f_w.createDimension('lon', 1440)
    
    f_w.createVariable('time', 'i4', ('time'))
    f_w.createVariable('lat', 'f4', ('lat'))
    f_w.createVariable('lon', 'f4', ('lon'))
    f_w.createVariable('precipitation', np.float64, ('time','lat','lon'))

    f_w.variables['time'][:] = np.arange(1, count + 1)
    f_w.variables['lat'][:] = np.arange(49.875,-50,-0.25)
    f_w.variables['lon'][:] = np.arange(-179.875,180,0.25)
    f_w.variables['precipitation'][:] = data

    #lon.units = 'degrees east'
    #lat.units = 'degrees north'
    #precp.units = 'mm/h'

    f_w.close()

def basemap_plot_txt(data):
    data = np.flip(data, 0)
    theLats = np.arange(-49.875,50,0.25)
    theLons = np.arange(-179.875,180,0.25)
    fig = plt.figure(dpi = 300)
    latcorners = ([-50, 50])
    loncorners = ([-180, 180])
    m = Basemap(projection='cyl', llcrnrlat=latcorners[0],urcrnrlat=latcorners[1],llcrnrlon=loncorners[0],urcrnrlon=loncorners[1])
    m.drawcoastlines()
    m.drawstates()
    m.drawcountries()
    clevs = np.arange(0,5.01,0.5)
    x, y = np.float32(np.meshgrid(theLons, theLats))
    cs = m.contourf(x,y,data,clevs,cmap=cm.GMT_drywet,latlon=True)
    parallels = np.arange(-50.,51,25.)
    m.drawparallels(parallels,labels=[True,False,True,False])
    meridians = np.arange(-180.,180.,60.)
    m.drawmeridians(meridians,labels=[False,False,False,True])

    cbar = m.colorbar(cs,location='right',pad="5%")
    cbar.set_label('mm/h')
    plt.savefig('mean_txt.png',dpi=300)

def basemap_plot_nc(data):
    data = np.flip(data, 0)
    theLats = np.arange(-49.875,50,0.25)
    theLons = np.arange(-179.875,180,0.25)
    fig = plt.figure(dpi = 300)
    latcorners = ([-50, 50])
    loncorners = ([-180, 180])
    m = Basemap(projection='cyl', llcrnrlat=latcorners[0],urcrnrlat=latcorners[1],llcrnrlon=loncorners[0],urcrnrlon=loncorners[1])
    m.drawcoastlines()
    m.drawstates()
    m.drawcountries()
    clevs = np.arange(0,5.01,0.5)
    x, y = np.float32(np.meshgrid(theLons, theLats))
    cs = m.contourf(x,y,data,clevs,cmap=cm.GMT_drywet,latlon=True)
    parallels = np.arange(-50.,51,25.)
    m.drawparallels(parallels,labels=[True,False,True,False])
    meridians = np.arange(-180.,180.,60.)
    m.drawmeridians(meridians,labels=[False,False,False,True])

    cbar = m.colorbar(cs,location='right',pad="5%")
    cbar.set_label('mm/h')
    plt.savefig('mean_nc.png',dpi=300)


years = [2015, 2016, 2017, 2018, 2019]
months = [6, 7, 8]
hours = ['00', '03', '06', '09', '12', '15', '18', '21']
count = 0
for year in years:
    for month in months:
        print(year, month)
        if (month == 6):
            for day in range(1, 31):
                for hour in hours:
                    dataset = read_file(year, month, day, hour)
                    precip_t = read_prec(dataset)
                    #print(precip_t.shape)
                    if(count == 0):
                        precipitation = precip_t
                    elif(count > 0):
                        precipitation = np.concatenate((precipitation, precip_t), axis = 0)
                    count += 1
        elif(month == 7 or month == 8):
            for day in range(1, 32):
                for hour in hours:
                    dataset = read_file(year, month, day, hour)
                    precip_t = read_prec(dataset)
                    #print(precip_t.shape)
                    if(count == 0):
                        precipitation = precip_t
                    elif(count > 0):
                        precipitation = np.concatenate((precipitation, precip_t), axis = 0)
                    count += 1                    
        else:
            print('Error: Wrong month.')
        
print("precipitation shape: ", precipitation.shape)
np.savetxt('trmm_15_19.txt', precipitation)

#precipitation = np.loadtxt('trmm_15_19.txt')
print("count = ", count)

precipitation = precipitation.reshape(count, 400, 1440)
print("precipitation shape: ", precipitation.shape)
write_nc(precipitation, count)
print("write_nc DONE.")

prec_mean = np.nanmean(precipitation, axis = 0)
basemap_plot_txt(prec_mean)


filename = 'precipitation.nc'
f = nc.Dataset(filename)
pre_data = f['precipitation'][:][:][:]
p = np.array(pre_data)
print(p.shape)
p_nc_mean = np.nanmean(precipitation, axis = 0)
basemap_plot_nc(p_nc_mean)
