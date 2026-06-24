# Spatial Interpolation of Total Precipitation Using IDW and Kriging in R

## Project Overview

This exercise compares two spatial interpolation methods, Inverse Distance Weighting (IDW) and ordinary kriging, for total precipitation. The interpolated surfaces are generated from precipitation station data and then cropped and masked to the boundary of Aragon. The project also includes a direct comparison between the two interpolations.

## Objectives

- Interpolate total precipitation using IDW.
- Interpolate total precipitation using ordinary kriging.
- Create a raster prediction surface for each method.
- Adapt the interpolated outputs to the extent of `Aragon.shp`.
- Crop and mask the rasters to the study area boundary.
- Compare the two resulting surfaces.

## Data

- `prec.shp` — precipitation station points.
- `Aragon.shp` — boundary polygon for the study area.

## Methodology

### Data Preparation
- Loaded the precipitation station layer.
- Loaded the Aragon boundary polygon.
- Ensured both layers shared the same coordinate reference system.

### Interpolation Grid
- Created a regular raster grid covering the extent of Aragon.
- Converted the grid to points for interpolation.
- Kept only the grid points inside the study area.

### IDW Interpolation
- Applied inverse distance weighting using precipitation station values.
- Converted the interpolated points to a raster surface.
- Cropped and masked the output to the Aragon boundary.

### Kriging Interpolation
- Computed the empirical variogram.
- Fitted a theoretical variogram model.
- Performed ordinary kriging on the same grid.
- Cropped and masked the kriging output to the Aragon boundary.

### Comparison
- Generated a ratio raster between IDW and kriging.
- Generated a difference raster between IDW and kriging.

## Main Outputs

- IDW precipitation map
- Kriging precipitation map
- IDW/Kriging ratio map
- IDW-Kriging difference map
- Cropped rasters restricted to Aragon

## Skills Demonstrated

- Spatial interpolation
- Raster and vector data handling
- Variogram analysis
- Ordinary kriging
- IDW interpolation
- Boundary masking and cropping
- Comparative spatial analysis
- Reproducible scripting in R
