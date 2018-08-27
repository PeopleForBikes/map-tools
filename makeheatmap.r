# Creates printable version of BNA heat map visible on website https://bna.peopleforbikes.org/
# Inputs: List of BNA census blocks file(s) as json in WGS84 coordinate system <files>, or filepath to folder containing json files <fpath>.
# Outputs: JPEG image of heatmap identical to BNA website but with an equal interval scale across 10 bins.
# NOTE: Because this script builds a map with equal intervals, the results will not precisly mirror the maps on the BNA website, 
#       which are not equal interval


# Load Libraries
library(leaflet)
library(geojsonio)
library(mapview)
library(dplyr)
library(tools)

# Set working directory as default filepath
fpath = getwd()

# Create list of files from filepath, gatering any json files in folder
files <- list.files(fpath, pattern="*.json", full.names=T, recursive=FALSE)

# Args
#  fpath - path to folder containing json files*
#  files - list of file name(s) as character vector*
#  width - number in pixels, optional
#  height - number in pixels, optional
#  * Requires fpath or files list. If both are supplied, the files list will be prioritized.

heatmap <- function(fpath=NULL, files=NULL, width=1600, height=800) {
  
  # Status update
  print("Evaluating request") 
  
  # if list of files provided, use that and create directory from first listed file 
  if(!is.null(files)) {
    # check for single file case
    if (length(files) == 1) {
      fpath = dirname(files)
    }
    # check for file list case
    else {
      fpath = dirname(files[1])
    }
  } else if(!is.null(fpath)) {
    files <- list.files(fpath, pattern="*(.*)json", full.names=T, recursive=FALSE)
    # if no json files in folder, tell user
    if(length(files) == 0){
      return("No json files provided.")
    }
  } else if(is.null(fpath) && is.null(files)) {
    return("Must supply a list of file names or a file path to a folder containing json files.")
  }

  # Load waterblocks census data to remove blocks that have no land from the map
  print("Removing water blocks")
  waterblocks <- read.csv("/data/censuswaterblocks.csv")
  
  # Create color palette to match colors on BNA website. NOTE: Bins are equal interval, unlike website.
  pal <- colorBin(c("#FF3300", "#D04628", "#B9503C", "#A25A51", "#8B6465", "#736D79", "#5C778D", "#4581A2", "#2E8BB6", 
                    "#009FDF"), bins = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100), 0:100)
  
  # Status update
  print("Drawing map")
  
  # run map-making function across file list
  lapply(files, function(x) {
    # Load json file as spatial data
    area <- geojsonio::geojson_read(x, what = "sp") # load file
    
    #Remove blocks with no BNA score
    area <- subset(area, OVERALL_SC >= 0)
    
    # TO DO: Remove blocks that have no land area
    #area <- area[!area$BLOCKID10 %in% waterblocks$GEOID10, ]
    
    # Create map object containing Carto's Positron basemap
    m <- leaflet(area) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(stroke = FALSE, smoothFactor = 0, opacity = 0, fillOpacity = 1, color = ~pal(OVERALL_SC))
    
    # Status update
    print("Generating image file")
    
    # Generate jpeg (intermediary HTML file will be generated and automatically deleted)
    mapshot(m, file = file.path(fpath, paste(file_path_sans_ext(basename(x)), "_heatmap.jpeg", sep=""), fsep="/"), vwidth = width, vheight = height, delay = 0.5, zoom=3)
  })
}

