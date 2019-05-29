load("Calculations_Carl.m");
load("WRF_Reader_Carl.m");

% USER INITIAL VARIABLES % 
radius_parachute = 0.28; %m for GRAW red parachute
% Balloon Info: http://kaymontballoons.com/Weather_Forecasting.html
radius_balloon = 0.59436; %m (200g balloon has radius of 1.95 ft)
mass_balloon = 350; %g
mass_payload = 168; %g

% PREDICTION %
function [points] = Prediction(wrf, start_lat, start_lon, ...
    start_alt, max_alt)
ascent = true;
done = false;
points = []; 

% arbitrary initial rise rate %
rise_rate = 5.0; %m/s
hour_duration = 0;
current_lat = start_lat;
current_lon = start_lon;
current_alt = start_alt;
latLonAlt = [current_lat, current_lon, current_alt, rise_rate];
points = [points; [current_lat current_lon current_alt]];

% CONSTANTS %
Alt_Increment = 150.0; %m

% PREDICTION PROCESS %
x = findNetCDFLatLonIndex(wrf, current_lon);
y = findNetCDFLatLonIndex(wrf, current_lat);
z = findNetCDFAltIndex(wrf, x, y, current_alt);
P_surface = getPressure(wrf, x, y, z);
T_surface = getTemperature(wrf, x, y, z);

    while (not done)
        x = findNetCDFLatLonIndex(wrf, current_lon);
        y = findNetCDFLatLonIndex(wrf, current_lat);
        z = findNetCDFAltIndex(wrf, x, y, current_alt);
    
        w_spd = getWindSpeedAndDirection(wrf, x, y, z);
        w_dir = getWindSpeedAndDirection(wrf, x, y, z);
        w_vert = getWindSpeedAndDirection(wrf, x, y, z);
        terrain_height = getTerrainHeight(wrf, x, y);
    
        P = getPressure(wrf, x, y, z);
        T = getTemperature(wrf, x, y, z);
    
        rise_time = 1/abs(rise_rate) *Alt_Increment;
        distance = rise_time * w_spd;
    
        hour_duration = hour_duration + rise_time;
        if hour_duration >= 3600 %seconds
            wrf_time = int(wrf_file(22:24)) + 1;
            wrf_file = wrf_file(:22) + str(wrf_time) + wrf_file(24:);
            wrf = wrf;
            hour_duration = 0;
    
        current_lat = destination(distance/1000, w_dir, ... 
            current_lat, current_lon);
        current_lon = destination(distance/1000, w_dir, ... 
            current_lat, current_lon);
        
        if(ascent)
            current_alt = current_alt + Alt_Increment;
            %rise_rate = getAscentRate(P_surface,T_surface,P,T,
            %radius_balloon,float(mass_balloon)/1000.0,
            %float(mass_payload)/1000.0);
            rise_rate = rise_rate + w_vert;
            if(current_alt >= max_alt)
                print('burst');
                ascent = false;
            end
        else
            current_alt = current_alt - Alt_Increment;
            %rise_rate = getDescentRate(P,T,float(radius_parachute),
            %float(mass_balloon)/1000,float(mass_payload)/1000);
            rise_rate = rise_rate + w_vert;
            if(current_alt <= terrain_height)
                done = true
                current_alt = terrain_height;
        latLongAlt = [current_lat, current_lon, current_alt, rise_rate]
        points = [points; [current_lat current_lon current_alt]];
            end
        end
        end    
        end
end          