import WRFPrediction
import Calculations
import numpy as np

start_lat = -30.240776 #decimal degrees (46.8601 for UM Oval)
start_lon = -71.085250 #decimal degrees (-113.9852 for UM Oval)
start_alt = 1020.0 #m
max_alt = 32000.0 #m
#WRF FILE AND DIRECTORY
wrf_file = 'wrfout_d02_2017-07-02_17:00:00' # UTC hour required
main_directory = '/home/wrf_user/WRF/WRFV3/eclipse_wrf/WRFV3/run/July_2_2017/'

#Predictions
points = WRFPrediction.Prediction(wrf_file, main_directory, start_lat, start_lon, start_alt, max_alt)

#Plotting
Calculations.Plotting(points, 400000, 400000)

#Write file
np.savetxt('WRF_test_July_02_2017_2000_Andacollo.txt', points, fmt='%9.8f', delimiter='\t', header='Latitude\tLongitude\tAltitude(m)\tRise Rate(m/s)')
