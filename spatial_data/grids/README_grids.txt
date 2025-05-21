README for Grids Created for VMS Pipeline Heatmap Generation

FILENAMES IN REPO
- master_2km_grid_tmer.shp
- master_5km_grid_tmer.shp
- fivekm_grid_polys_shore_lamb.shp
- ten_arcminute_grid_shore_lamb.shp
- five km grid polys shore METADATA.xlsx
- fivekm_raster_grid_lamb.tif

master_2km_grid_tmer.shp and master_5km_grid_tmer.shp are both vector format, Esri ArcGIS shapefiles, in a custom Transverse Mercator coordinate reference system (CRS). Note: this is not the same CRS as Universal Transverse Mercator and is not interchangeable. fivekm_grid_polys_shore_lamb.shp is a vector format, Esri ArcGIS shapefile, in a custom Lambert Conformal Conic CRS. fivekm_raster_grid_lamb.tif is a geotiff raster format grid with a custom Lambert Conformal Conic CRS. The boundaries of all the individual grid cells in the 5km vector and raster grids align perfectly, as do the attribute values for the grid cell IDs. Therefore, spatial and attribute level joining is conserved and fully integrated between the two data formats in the 5km grids. NOTE: fivekm_grid_polys_shore_lamb.shp has had the polygons that span the shoreline clipped to the shoreline and areas for those gridcells are <25km2.

DATA PROVENANCE
master_5km_grid_tmer.shp was created by Blake Feist on 29 Aug 2024, which was based on an existing vector-based 5km grid originally generated for Feist et al. 2021 (DOI:  10.1111/fme.12478). Said grid was created on 13 Dec 2017 and has the same custom Lambert Conformal Conic CRS as the 5km raster format geotiff. That grid was also used to generate the fivekm_raster_grid_lamb.tif geotiff

master_2km_grid_tmer.shp was created by Blake Feist on 19 Aug 2022, which was originally used for offshore wind energy fishing activity mapping by NMFS in support of NCCOS marine spatial planning modeling for BOEM.

fivekm_grid_polys_shore_lamb.shp was created by Blake Feist on 31 Mar 2021, which was originally used by Leena Riekkola in Riekkola et al. 2023 (DOI: 10.1016/j.biocon.2022.109880). Updated 16 Apr 2025 with numerous additional attributes, useful for summarizing the gridded data across multiple spatial extents and not just coastwide. Refer to "five km grid polys shore METADATA.xlsx" for detailed information.

ten_arcminute_grid_shore_lamb.shp was created by Blake Feist on 21 May 2025. This grid can be used for spatial correspondence testing between landings information reported on fish tickets for catch landed at California ports, with VMS Pipeline based fishing activity. Use the fish ticket "CDFW_AREA_BLOCK" attribute for joining to the "BLOCK10_ID" attribute in the grid attribute table. CAUTION: CDFW blocks that are further offshore are a coarser spatial grain, varying from groupings of 3 to 12, 10-arcminute grid cells. The "BLOCK10_n" attribute flags these larger blocks in the CDFW data. BLOCK10_n = 1 is a single 10-arcminute grid cell, but those >=3 should be grouped accordingly when joining to fish tickets. For example, 9, 10-arcminute grid cells will have a BLOCK10_ID = 138, so a fish ticket listing CDFW_AREA_BLOCK = 138 will be attributed to 9 grid cells, so the value of each of those 9 grid cells should be multiplied by 1/9. While this shapefile spans the entire EEZ of the US West Coast, the boundaries of the individual grid cells that overlap with the CDFW block grid cells align perfectly. The spatial resolution of this "grid" in spherical geometry is 10-arcminute, or ~10 nautical miles (~18.5km) at the Equator and the polygons that span the shoreline are clipped to the shoreline. The grid was generated in a geographic coordinate system and then transformed to Cartesian for area calculations. NOTE: Across the US West Coast, the distance between the meridians decreases with increasing latitude, so the actual area of these grid cells is not constant across space. The attribute named "Area_m2" has the area calculated in Cartesian space for each grid cell and should be referenced for all calculations, especially those involving density.

five km grid polys shore METADATA.xlsx is an Excel spreadsheet that provides details about the fivekm_grid_polys_shore_lamb.shp geospatial data layer. Spreadsheet has two worksheets, "General", which covers what the fivekm_grid_polys_shore_lamb.shp is and "Attributes", with details about the various demographic data that are now incorporated in the grid.

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
