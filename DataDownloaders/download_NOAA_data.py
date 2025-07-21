# -*- coding: utf-8 -*-
"""
download_NOAA_data.py

Example code to download air pressure and water level data from 
NOAA station #8761724 in Barataria Bay and save to a csv file. 

Created on: Jun 17 2025
Last Edited: July 18 2025

@author: caitlin r. r. turner
"""

from noaa_coops import Station
import pandas as pd
   
    
## Water Level
station_name = "Grand_Isle"
station_id = "8761724"
begin_date = "20250513"
end_date = "20250719"
product = "water_level"
units = "metric"
datum = "MLLW"
time_zone = "lst"

df = Station(id=station_id)
df = df.get_data(begin_date = begin_date,
                 end_date = end_date,
                 product = product,
                 units = units,
                 datum = datum,
                 time_zone = time_zone)

water_level_6min = pd.DataFrame({"water_level": df.v})
water_level_6min.to_csv(f'{station_name}_ID-{station_id}_{begin_date}_{end_date}_{product}_{units}_{time_zone}_6min.csv')
water_level_1hr = water_level_6min.resample('h').mean()
water_level_1hr.to_csv(f'{station_name}_ID-{station_id}_{begin_date}_{end_date}_{product}_{units}_{time_zone}_1hr.csv')



## Air Pressure
station_name = "Grand_Isle"
station_id = "8761724"
begin_date = "20250513"
end_date = "20250719"
product = "air_pressure"
units = "metric"
time_zone = "lst"

df = Station(id=station_id)
df = df.get_data(begin_date=begin_date,
                 end_date=end_date,
                 product=product,
                 units=units,
                 time_zone=time_zone)


pressure_6min = pd.DataFrame({"air": df.v})
pressure_6min.to_csv(f'{station_name}_ID-{station_id}_{begin_date}_{end_date}_{product}_{units}_{time_zone}_6min.csv')
pressure_1hr = pressure_6min.resample('h').mean()
pressure_1hr.to_csv(f'{station_name}_ID-{station_id}_{begin_date}_{end_date}_{product}_{units}_{time_zone}_1hr.csv')
