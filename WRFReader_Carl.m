% CONSTANTS %
g = 9.81; %m/s^2
Earth_Radius = 6371.0; %km
Degrees_to_Radians = pi/180.0;
Radians_to_Degrees = 180.0/pi;

% WRF time index %
time = 0;

% Get wrfout lat long index %
wrf = 'wrfout_d01_2019-05-29_12:00:00';

function [index_i, index_j] = findNetCDFLatLonIndex(wrf, lat, lon)
time_tmp = time(time,:,:); %temporary variable for indexing lat lon
lats = time_tmp(ncread(wrf, 'XLAT'));
lons = time_tmp(ncread(wrf, 'XLONG'));
error_lat = 0;
error_lon = 0;
previous_error_lat = 9999;
previous_error_lon = 9999;
index_i = 0;
index_j = 0;

for j=1:size(lats)
    for i=1:size(lats(j))
        error_lat = abs(lat-lats(j, i));
        error_lon = abs(lon-lons(j, i));
        if ((error_lat + error_lon) < ...
                (previous_error_lat + previous_error_lon))
            index_i = i;
            index_j = j;
            previous_error_lat = error_lat;
            previous_error_lon = error_lon;
        end
    end
end
end

% Get wrfout alt index %
function [index_k] = findNetCDFAltIndex(wrf, index_i, index_j, alt)
%temporary variable for indexing pressure
time_tmp = time(time,:,index_j,index_i); 
PH = time_tmp(ncread(wrf, 'PH'));
PHB = time_tmp(ncread(wrf, 'PHB'));
for i=1:size(PH)
    ALT = ((0.5 * (PHB(i) + PH(i) + PH(i+1) + PHB(i+1))/g));
end    
error = 0;
previous_error = 9999;
index_k = 0;
for k=1:size(ALT)
    error = abs(alt-ALT(k));
    if error < previous_error
        index_k = k;
        previous_error = error;
    end    
end
end
% Get wind speed and direction %
  %Website for unstaggering
  %http://www.openwfm.org/wiki/How_to_interpret_WRF_variables
function [windSpd, windDir, windVertical] = getWindSpeedAndDirection ...
    (wrf, index_i, index_j, index_k)
%temporary variables for indexing wind
time_tmp = time(time, index_k, index_j, index_i); 
time_tmp_u = time(time, index_k, index_j, index_i +1);
time_tmp_v = time(time, index_k, index_j +1, index_i); 
time_tmp_w = time(time, index_k +1, index_j, index_i);
%
U = time_tmp(ncread(wrf, 'U')) + time_tmp_u(ncread(wrf, 'U'))*0.5;
V = time_tmp(ncread(wrf, 'V')) + time_tmp_v(ncread(wrf, 'V'))*0.5;
W = time_tmp(ncread(wrf, 'W')) + time_tmp_w(ncread(wrf, 'W'))*0.5;
%temporary variable for indexing cos and sin alpha
time_tmp2 = time(time, index_j, index_i); 
COSALPHA = time_tmp2(ncread(wrf, 'COSALPHA'));
SINALPHA = time_tmp2(ncread(wrf, 'SINALPHA'));
U = U*COSALPHA - V*SINALPHA;
V = V*COSALPHA + U*SINALPHA;
windDir = Radians_to_Degrees*atan2(U,V);
windSpd = sqrt(U^2 + V^2);
windVertical = W;
end
% Get terrain height %
function [HGT] = getTerrainHeight(wrf, index_i, index_j)
%temporary variable for indexing height
time_tmp = time(time, index_j, index_i); 
HGT = time_tmp(ncread(wrf, 'HGT'));
end
% Get hyd pressure %
function [pressure] = getHydPressure(wrf, index_i, index_j, index_k)
%temporary variable for indexing hyd pressure
time_tmp = time(time, index_k, index_j, index_i); 
P_HYD = time_tmp(ncread(wrf, 'P_HYD')); %Pa
pressure = P_HYD; %Pa
end
% Get pressure %
function [pressure] = getPressure(wrf, index_i, index_j, index_k)
%temporary variable for indexing pressure
time_tmp = time(time, index_k, index_j, index_i); 
P = time_tmp(ncread(wrf, 'P')); %perturbation pressure
PB = time_tmp(ncread(wrf, 'PB'));
pressure = P + PB; %Pa
end
% Get temperature %
   % Convert from perturbation potential temperature to temperature
   % http://mailman.ucar.edu/pipermail/wrf-users/2010/001896.html
   % Step 1: convert to potential temperature by adding 300
   % Step 2: convert potential temperatuer to temperature
   % https://en.wikipedia.org/wiki/Potential_temperature
   % Note: p_0 = 1000. hPa and R/c_p = 0.286 for dry air
function [temperature] = getTemperature(wrf, index_i, index_j, index_k)
%temporary variable for indexing temperature
time_tmp = time(time, index_k, index_j, index_i);
T = time_tmp(ncread(wrf, 'T')); %perturbation potential temperature
potential_temp = T + 300; %K
pressure = getPressure(wrf, index_i, index_j, index_k);
temperature = potential_temp * (pressure/100000)^(0.286); %K
end