%% water_level_butterworth_filter_matlab.m
% This script analyszes data water depth puts it through a
% butterworth filter. 

% Make sure signal processing package is downloaded. If butterworth cant be
% found, this is why. Go to Apps, Get More Apps, then search Signal
% Processing Toolbox. That will fix it. 

% Date Created: February 2, 2020
% Date Edited: July 18, 2025

%% Load Water Level Data
% Excel filename 
filename = "Grand_Isle_ID-8761724_20250513_20250719_water_level_metric_lst_6min.csv";
% File was created with with DataDownloaders/download_NOAA_data.py
% Samples are taken every 6 minutes. 

% Read table 
T = readtable(filename);

% Convert first column to datetime if needed 
% (If downloaded using python, I usually need this)
if ~isdatetime(T{:,1})
    T.date_time = datetime(T{:,1}, 'InputFormat', 'M/d/yyyy H:mm');
else
    T.date_time = T{:,1};
end

% Assign time and water level series
t = T.date_time(:);                            % make sure its a column vector
water_level_m = T.water_level(:);              % make sure its a vector 

% Handle missing values 
if any(ismissing(water_level_m))
    water_level_m = fillmissing(water_level_m, 'linear', 'EndValues', 'nearest');
end

%% Lowpass Filter for Water Level (Butterworth)
% Defined Filter Parameters
filter_order = 6;                    % Butterworth filter order (6th order is suggested by NOAA)

cutoff_cycles_per_day = 6;           % Cutoff frequency: 4 cycles per day (this means, it removes anything that occurs 
                                     % anything that happens at a higher frequency, i.e, more than 4 times per day)

% Compute time step and cutoff frequency (You shouldn't need to mess with these)
dt_seconds = seconds(t(2) - t(1));                 % sampling interval in seconds
cutoff_hz = cutoff_cycles_per_day / (24 * 3600);   % convert cycles/day to Hz
nyquist = 1 / (2 * dt_seconds);                    % Nyquist frequency (This is standard, I dont rememeber what it means)
Wn = cutoff_hz / nyquist;                          % normalized cutoff frequency (0 < Wn < 1)

% Design Butterworth Lowpass Filter 
[b, a] = butter(filter_order, Wn);

% Apply Filter
water_level_filt = filtfilt(b, a, water_level_m);


%% Plot Original and Filtered Water Levels
figure('Color', 'w')
plot(t, water_level_m, 'LineStyle', '-', 'LineWidth', 1.5, 'DisplayName', 'Actual water level')
hold on
plot(t, water_level_filt, 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'Filtered water level')
ylabel('Water Level (m, MLLW)', 'FontSize', 11)
legend('Location', 'best', 'Box', 'off', 'FontSize', 10)
set(gca, 'FontSize', 10, 'LineWidth', 1, 'Box', 'off', 'TickDir', 'out', 'XColor', 'k', 'YColor', 'k')
xlim([t(1), t(end)])
ylim([-0.25, 0.65])


% This is for two days. It is easier to see the impacts of the filter when
% zommed in. You can see that it is removing small disturbances like boats,
% short-term winds, etc. 
figure('Color', 'w')
plot(t, water_level_m, 'LineStyle', '-', 'LineWidth', 2.5, 'DisplayName', 'Actual water level')
hold on
plot(t, water_level_filt, 'LineStyle', '--', 'LineWidth', 2.5, 'DisplayName', 'Filtered water level')
ylabel('Water Level (m, MLLW)', 'FontSize', 11)
legend('Location', 'best', 'Box', 'off', 'FontSize', 10)
set(gca, 'FontSize', 10, 'LineWidth', 1.5, 'Box', 'off', 'TickDir', 'out', 'XColor', 'k', 'YColor', 'k')
xlim([t(1), t(10*24*4)])
ylim([-0.25, 0.65])

%% NOTES
% This is how I had the methods written in my paper (Turner & Hiatt, 2025). The only thing you would 
% have to change is the location and change the wording a bit.

% Methods:
% Water surface elevation data from the USGS gauge at Mississippi Sound 
% near Grand Pass (site #300722089150100) were used to define the ocean boundary conditions (USGS, 2024). 
% The time series was down-sampled using a sixth-order low-pass Butterworth filter with a 
% cutoff frequency of four cycles per day, following the approach recommended in the 
% Manual of Tide Observations to reduce short-term meteorological 
% variability (Parker, 2007; USCGS, 1965).

% Sources
% National Oceanic and Atmospheric Adiminstration. (2024). Tides and Currents [Dataset].
% Turner, C. R. R., & Hiatt, M. (2025). Water exposure time distributions controlled by freshwater releases in a semi‐enclosed estuary. Water Resources Research, 61, e2025WR040287. https://doi.org/10.1029/2025WR040287 
% Parker, B. (2007). Tidal Analysis and Prediction. Silver Spring, MD: NOAA NOS Center for Operational Oceanographic Products and Services.
% U.S. Geological Survey (2024). USGS Water Data for the Nation [dataset].
% U.S. Coast and Geodetic Survey (1965). Manual of Tide Observations. United States Government Printing Office.

% This document is also helpful: 
% (https://tidesandcurrents.noaa.gov/publications/techrpt085.pdf)
