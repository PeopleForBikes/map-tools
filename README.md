map-tools
=========
PeopleForBikes' Bike Network Analysis (BNA) scores cities and other geographic areas based on the quality of their low-stress bike network. The BNA generates output data that can be used to generate a variety of maps, including those visible on the BNA website. The `map-tools` repository provides resources to facilitate BNA data visualization and enhance the BNA's utility as a free, public resource for bike data analysis and advocacy.

### Prerequisites
Depending on the functions that you choose to use, you will need some portion of the following open-source resources:
* Python 3.6+
   * Python libraries: pandas, geopandas, numpy, os 
* R 3.4.3+
   * R libraries: leaflet, geojsonio, mapview, dplyr, tools
* QGIS

## Heat map

![Topeka, KA](images/topekaksheat.jpeg "Topeka, KS BNA Heat Map")

The heat map on the BNA website is the "Census blocks with access" map, which colors the map according to each census block's BNA score on a scale of 0 to 100. The map on the BNA website uses a scale with natural breaks, so the uppermost category is 54-100. The script included here creates a map with equal intervals of 10, so the resulting map will typically be more red/purple than the map on the website. You can see examples of the equal interval heat maps for BNA-rated cities on PeopleForBikes' [City Ratings website](https://cityratings.peopleforbikes.org/), on the downloadable PDF summary sheets available for each city. 

Example: [Santa Fe, NM City Ratings](https://cityratings.peopleforbikes.org/wp-content/uploads/2018/04/santafeNM.pdf)

To create a similar map using a GIS editing program, assign colors as follows and do not assign a color to blocks that do not have a BNA score.
 
| Block score   | Hex color  |
----------------|:----------:|
| 0-10          | #FF3300    |
| 10-20         | #D04628    |
| 20-30         | #B9503C    |
| 30-40         | #A25A51    |
| 40-50         | #8B6465    |
| 50-60         | #736D79    |
| 60-70         | #5C778D    |
| 70-80         | #4581A2    |
| 80-90         | #2E8BB6    |
| 90-100        | #009FDF    |

A QGIS layer style file `heatmap_equalint.qml` is included as a shortcut to make the map in the QGIS editing program.

To create the map programatically and output it as a jpeg image:
1. Convert the census blocks shapefile into a json or geoson file in the WGS84 projection. You can do this using a GIS program such as QGIS or ArcGIS, or you can do this programmatically. A Python script to do this programmatically for one or many files simultaneously will be added soon.
2. Run the `makeheatmap.r` script with the json or geojson file(s). The script is written in R to take advantage of the Leaflet for R library.

## Bikeshed map
 
TODO
