# ==========================================================
# Interpolation of total precipitation using IDW and Kriging
# ==========================================================

rm(list = ls())

# ----------------------------------------------------------
# 1. Load required packages
# ----------------------------------------------------------

library(sf)
library(sp)
library(terra)
library(gstat)
library(ggplot2)
library(tidyterra)

# ----------------------------------------------------------
# 2. Load precipitation stations and study area
# ----------------------------------------------------------

# Read precipitation stations
pstations <- st_read("prec.shp", quiet = TRUE)

# Read Aragon boundary
aragon <- st_read("Aragon.shp", quiet = TRUE)

# Make sure both layers use the same CRS
aragon <- st_transform(aragon, st_crs(pstations))

# ----------------------------------------------------------
# 3. Create interpolation grid
# ----------------------------------------------------------

# Use a 5 km resolution grid over the study area
resol <- 5000

# Create a raster template from the Aragon extent
template <- rast(
  ext(aragon),
  res = resol,
  crs = st_crs(pstations)$wkt
)

# Convert raster cells to points
grid_pts <- as.points(template, values = FALSE)
grid_sf <- st_as_sf(grid_pts)

# Keep only points inside Aragon
grid_sf <- grid_sf[st_intersects(grid_sf, aragon, sparse = FALSE), ]

# Convert to Spatial object for gstat
grid_sp <- as(grid_sf, "Spatial")
pstations_sp <- as(pstations, "Spatial")

# ----------------------------------------------------------
# 4. IDW interpolation
# ----------------------------------------------------------

idw_pred <- idw(
  Total ~ 1,
  locations = pstations_sp,
  newdata = grid_sp,
  nmax = 20,
  idp = 3
)

# Convert IDW predictions to raster
idw_rast <- rasterize(
  vect(idw_pred),
  template,
  field = "var1.pred"
)

# Crop and mask to Aragon
idw_crop <- crop(idw_rast, vect(aragon))
idw_mask <- mask(idw_crop, vect(aragon))

# Plot IDW result
plot(idw_mask, main = "IDW interpolation of total precipitation")
plot(st_geometry(aragon), add = TRUE)

# ----------------------------------------------------------
# 5. Kriging interpolation
# ----------------------------------------------------------

# Compute the empirical variogram
v_emp <- variogram(Total ~ 1, pstations_sp)

# Fit a theoretical variogram model
v_fit <- fit.variogram(v_emp, vgm(model = "Sph"))

# Perform ordinary kriging
krige_pred <- krige(
  Total ~ 1,
  locations = pstations_sp,
  newdata = grid_sp,
  model = v_fit
)

# Convert kriging predictions to raster
krige_rast <- rasterize(
  vect(krige_pred),
  template,
  field = "var1.pred"
)

# Crop and mask to Aragon
krige_crop <- crop(krige_rast, vect(aragon))
krige_mask <- mask(krige_crop, vect(aragon))

# Plot kriging result
plot(krige_mask, main = "Kriging interpolation of total precipitation")
plot(st_geometry(aragon), add = TRUE)

# ----------------------------------------------------------
# 6. Compare IDW and Kriging
# ----------------------------------------------------------

# Ratio of the two interpolations
ratio_rast <- idw_mask / krige_mask
plot(ratio_rast, main = "IDW / Kriging ratio")

# Difference between the two interpolations
diff_rast <- idw_mask - krige_mask
plot(diff_rast, main = "IDW - Kriging difference")

# ----------------------------------------------------------
# 7. Save outputs
# ----------------------------------------------------------

writeRaster(idw_mask, "precipitation_idw_aragon.tif", overwrite = TRUE)
writeRaster(krige_mask, "precipitation_kriging_aragon.tif", overwrite = TRUE)
writeRaster(ratio_rast, "idw_kriging_ratio.tif", overwrite = TRUE)
writeRaster(diff_rast, "idw_kriging_difference.tif", overwrite = TRUE)