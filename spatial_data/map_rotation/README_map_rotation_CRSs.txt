README for custom Coordinate Reference Systems (CRS) created for VMS Pipeline thematic mapping in R, which allows planar rotation of maps.

Blake Feist, 25 Apr 2025

FILENAMES IN REPO
- fivekm_grid_extent_rect_30.shp
- fivekm_grid_extent_rect_21.shp
- Rectified_Skew_Orthomorphic_Center_30deg_rotation.wkt
- Rectified_Skew_Orthomorphic_Center_21deg_rotation.wkt

fivekm_grid_extent_rect_30.shp and fivekm_grid_extent_rect_21.shp are both vector format, Esri ArcGIS shapefiles, in a custom Rectified Skew Orthomorphic coordinate reference system (CRS). Each shapefile is a polygon defined by the spatial extent of the 5km grid used for generating heatmaps. These CRS with their planar axis rotated by 21 and 30 degrees can be used for generating thematic maps in R that are rotated by 21 or 30 degrees. The CRS for these shapefiles can be read in to R using either the shapefiles themselves (corresponding .prj files), or by reading in the corresponding Rectified_Skew_Orthomorphic_Center_30deg_rotation.wkt or Rectified_Skew_Orthomorphic_Center_21deg_rotation.wkt well known text (wkt) files.

NOTE: In theory, you can change the rotation to any angle you wish by changing this line

PARAMETER["Angle from Rectified to Skew Grid",30,

from 30 to the angle of your choice in the .wkt file.

COORDINATE REFERENCE SYSTEMS

Rectified Skew Orthomorphic
https://pro.arcgis.com/en/pro-app/latest/help/mapping/properties/rectified-skew-orthomorphic.htm

21 degree rotation - for zoomed out to west coast wide maps

CA_Curr_Rect_Skew_Ortho_21deg

Authority: Custom

Projection: Rectified_Skew_Orthomorphic_Center
False_Easting: 1000000.0
False_Northing: 0.0
Scale_Factor: 1.0
Azimuth: 0.0
Longitude_Of_Center: -122.6
Latitude_Of_Center: 40.0
XY_Plane_Rotation: 21.0
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

30 degree rotation - for zoomed in portions of California coast maps

CA_Curr_Rect_Skew_Ortho_30deg

Authority: Custom

Projection: Rectified_Skew_Orthomorphic_Center
False_Easting: 1000000.0
False_Northing: 0.0
Scale_Factor: 1.0
Azimuth: 0.0
Longitude_Of_Center: -122.6
Latitude_Of_Center: 40.0
XY_Plane_Rotation: 30.0
Linear Unit: Meter (1.0)

Geographic Coordinate System: GCS_WGS_1984
Angular Unit: Degree (0.0174532925199433)
Prime Meridian: Greenwich (0.0)
Datum: D_WGS_1984
  Spheroid: WGS_1984
    Semimajor Axis: 6378137.0
    Semiminor Axis: 6356752.314245179
    Inverse Flattening: 298.257223563