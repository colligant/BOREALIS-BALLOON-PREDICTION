load("WRFPrediction_Carl.m")
load("Calculations_Carl.m")

start_lat = 46.8601; %decimal degrees (46.8601 for UM Oval)
start_lon = -113.9852; %decimal degrees (-113.9852 for UM Oval)
start_alt = 978.0; %m
max_alt = 29000.0; %m

% WRF FILE AND DIRECTORY %
wrf_file = 'wrfout_d01_2019-05-29_12:00:00'; % UTC hour required

% PREDICTIONS %
points = Prediction(wrf_file, start_lat, start_lon, start_alt, max_alt);

% PLOTTING %
%Calculations.Plotting(points, 400000, 400000) %python code. matlab
%equivalent?

% WRITE FILE %
%np.savetxt('WRFtest.txt', points, fmt='%9.8f', delimiter='\t', 
%header='Latitude\tLongitude\tAltitude(m)\tRise Rate(m/s)')
% python code. matlab equivalent?




