README for Grids Created for VMS Pipeline Heatmap Generation

FILENAMES IN REPO
- master_2km_grid_tmer.shp
- master_5km_grid_tmer.shp
- fivekm_raster_grid_lamb.tif

master_2km_grid_tmer.shp and master_5km_grid_tmer.shp are both vector format, Esri ArcGIS shapefiles, in a custom Transverse Mercator coordinate reference system (CRS). Note: this is not the same CRS as Universal Transverse Mercator and is not interchangeable. fivekm_raster_grid_lamb.tif is a geotiff raster format grid with a custom Lambert Conformal Conic CRS. The boundaries of all the individual grid cells in the 5km vector and raster grids align perfectly, as do the attribute values for the grid cell IDs. Therefore, spatial and attribute level joining is conserved and fully integrated between the two data formats in the 5km grids.

DATA PROVENANCE
master_5km_grid_tmer.shp was created by Blake Feist on 29 Aug 2024, which was based on an existing vector-based 5km grid originally generated for Feist et al. 2021 (DOI:  10.1111/fme.12478). Said grid was created on 13 Dec 2017 and has the same custom Lambert Conformal Conic CRS as the 5km raster format geotiff. That grid was also used to generate the fivekm_raster_grid_lamb.tif geotiff

master_2km_grid_tmer.shp was created by Blake Feist on 19 Aug 2022, which was originally used for offshore wind energy fishing activity mapping by NMFS in support of NCCOS marine spatial planning modeling for BOEM.

fivekm_raster_grid_lamb.tif was created by Blake Feist on 20 Feb 2020 and was originally named “fivekm_g_lamb.tif”. Subsequent file names for that grid have included “fivekm_grid.tif” and possibly others.

COORDINATE REFERENCE SYSTEMS

Lambert Conformal Conic (LAMB)

CA_Curr_Lamb_Azi_Equal_Area
Authority: Custom

Projection: Lambert_Azimuthal_Equal_Area
False_Easting: 1000000.0
False_Northing: 0.0
Central_Meridian: -122.6
Latitude_Of_Origin: 30.5
Linear Unit: Meter (1.0)

Geographic Coordinate System: GCS_WGS_1984
Angular Unit: Degree (0.0174532925199433)
Prime Meridian: Greenwich (0.0)
Datum: D_WGS_1984
  Spheroid: WGS_1984
    Semimajor Axis: 6378137.0
    Semiminor Axis: 6356752.314245179
    Inverse Flattening: 298.257223563

-------------------------------------------------------

Transverse Mercator (TMER)

WGS_1984_Transverse_Mercator
Authority: Custom

Projection: Transverse_Mercator
False_Easting: 390000.0
False_Northing: 0.0
Central_Meridian: -121.6
Scale_Factor: 1.0
Latitude_Of_Origin: 31.96
Linear Unit: Meter (1.0)

Geographic Coordinate System: GCS_WGS_1984
Angular Unit: Degree (0.0174532925199433)
Prime Meridian: Greenwich (0.0)
Datum: D_WGS_1984
  Spheroid: WGS_1984
    Semimajor Axis: 6378137.0
    Semiminor Axis: 6356752.314245179
    Inverse Flattening: 298.257223563
