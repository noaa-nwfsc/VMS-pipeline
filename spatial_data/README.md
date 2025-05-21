# Spatial Data Introduction

Brooke wrote this document to give a high level introduction of what's in this `spatial_data` folder, so you know where to look for what, depending on your use case.
There are many useful files in this directory, which is created and maintained by Blake Feist.
Blake maintains detailed README and METADATA files in each of these subdirectories, so check those for additional information.
If you have questions that aren't addressed here or in the README/METADATA, then talk to Blake.

## `bathymetry`

* `composite_bath`: raster data, high resolution bathymetry grid used to assign depth to each VMS ping and to filter out VMS points that are too deep or on land in steps 3 and 6. Since this is a large file, we don't upload it to GitHub (it's in the `.gitignore`) - see the link in `README_bathymetry-file-link.txt` to find where to download it.
* `fathom_30to40`: vector data, lines or polygons, 30 and 40 fathom isobaths used to plot common depth restrictions used to manage Dungeness crab fishing.

## `grids`

* `fivekm_grid_polys_shore_lamb`: vector data, multi-polygon *5km* grid used to summarize and map fishing activity. This includes more columns than other grids such as relevant management zones for each state, has been spatially intersected with the shoreline (grid cells intersecting shoreline will be < 25km<sup>2</sup> in area) and combines grid cells split across the shore (one grid cell will have one record).
* `fivekm_raster_grid_lamb`: raster data, identical inter-grid cell boundaries as above, but includes fewer columns and was not intersected with shoreline.
* `master_2km_grid_tmer`: vector data, polygon *2km* grid used to summarize and map fishing activity, includes fewer columns, and has not been spatially intersected with the shoreline, so all grid cells are 4km<sup>2</sup>.

## `map_rotation`
* `fivekm_grid_extent_rect_21`: vector data, extent of the 5km fishing grid in a projection that is rotated 21 degrees to efficiently view the US West Coast in a rectangular figure
* `fivekm_grid_extent_rect_30`: vector data, same as above but rotated 30 degrees to efficiently view the CA Coast in a rectangular figure
* `Rectified_Skew_Orthomorphic_Center_21deg_rotation`: well-known text, specifies the coordinate reference system in `fivekm_grid_extent_rect_21`
* `Rectified_Skew_Orthomorphic_Center_30deg_rotation`: well-known text, specifies the coordinate reference system in `fivekm_grid_extent_rect_30`

## `port_coordinates`
* `port_coords_fromBlake_edited`: CSV, port coordinates are used in step 5 of the pipeline to filter out VMS points that are close to ports and likely represent transit activity rather than fishing activity
