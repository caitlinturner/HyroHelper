# -*- coding: utf-8 -*-
"""

@author: cturn
"""
import os
import numpy as np
import xarray as xr
from matplotlib import pyplot as plt
from scipy.stats import describe
from scipy.spatial import cKDTree
from matplotlib.cm import ScalarMappable
from matplotlib.colors import Normalize
from pyproj import Proj

## Set up directories and impoort Data
file_nc = os.path.join('LPLM_grid_net.nc')
file_nc_map = os.path.join(file_nc)
map_xr = xr.open_dataset(file_nc_map)

## Model Resolution Calculation
edge_x_long = map_xr['mesh2d_edge_x'].values.astype(np.float32) # Units: [long]
edge_y_lat = map_xr['mesh2d_edge_y'].values.astype(np.float32) # Units: [lat]
def decimal_degrees_to_utm(lat, lon):
    utm_proj = Proj(proj='utm', zone=15, ellps='WGS84')
    return utm_proj(lon, lat)
edge_x_utm, edge_y_utm = decimal_degrees_to_utm(edge_y_lat, edge_x_long)

coordinates = np.vstack((edge_x_utm, edge_y_utm)).T
tree = cKDTree(coordinates)
dist, idx = tree.query(coordinates, k=2)
nndist = dist[:, 1] 
nnidx = idx[:, 1]

# Statistical Analysis
stats = describe(nndist)
print(f"Grid Resolution (m) \nMean: {stats.mean:.2f} \nMin: {stats.minmax[0]} \nMax: {stats.minmax[1]}")


# Check if it looks right
norm = Normalize(vmin=np.min(nndist), vmax=np.max(nndist))
cmap = plt.get_cmap('Greys')  
sm = ScalarMappable(norm=norm, cmap=cmap)
fig, ax = plt.subplots(figsize=(10, 6))  
for i, index in enumerate(nnidx):
    distance = nndist[i]
    color = sm.to_rgba(distance)
    ax.plot([coordinates[i][0], coordinates[index][0]], 
            [coordinates[i][1], coordinates[index][1]], 
            color=color)
cbar = fig.colorbar(sm, ax=ax)
cbar.set_label('Distance (m)')
plt.show()
