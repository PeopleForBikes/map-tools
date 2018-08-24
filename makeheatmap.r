'''
Last edited: 8/24/18
Creates printable version of BNA heat map visible on website https://bna.peopleforbikes.org/
Inputs: List of BNA census blocks file(s) as json in WGS84 projection <files>, or filepath to folder containing json files <fpath>
Outputs: jpeg or png image of heatmap identical to BNA website but with a scale of 10 equal intervals
NOTE: This scripts builds an equal interval map, unlike the heat map on the website which contains natural breaks.
'''

# Load Libraries
library(leaflet)
library(geojsonio)
library(mapview)
library(dplyr)

# Set working directory as default filepath
fpath = getwd()

# Create list of files from filepath, gatering any json files in folder
files <- list.files(fpath, pattern="*.json", full.names=T, recursive=FALSE)

"""
Args
 fpath - path to folder containing json files*
 files - list of file name(s) as character vector*
 width - number in pixels, optional
 height - number in pixels, optional
 * Requires fpath or files list. If both are supplied, the files list will be prioritized.
"""
heatmap <- function(fpath=NULL, files=NULL, width=1600, height=800) {
  
  # Status update
  print("Evaluating request") 
  
  # if list of files provided, use that and create directory from first listed file 
  if(!is.null(files)) {
    # check for single file case
    if (length(files) == 1){
      fpath = dirname(files)
    }
    # check for file list case
    else {
      fpath = dirname(files[1])
  # if file path provided, create list of json files within
  elif(!is.null(fpath)) {
    files <- list.files(fpath, pattern="*.json", full.names=T, recursive=FALSE)
    # if no json files in folder, tell user
    if length(files) == 0:
      return("No json files provided.")
  # inform user if neither fpath or files are specified
  elif(is.null(fpath) && is.null(files)){
    return("Must supply a list of file names or a file path to a folder containing json files.")

  # TO DO: Load waterblocks census data to remove blocks that have no land from the map
  #print("Removing water blocks")
  #waterblocks <- read.csv("C://Users/rebec/Documents/bna/census_block_files/censuswaterblocks.csv")
  
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
    
    # Generate jpeg (intermediary HTML file will be generated)
    mapshot(m, file = file.path(fpath, paste(substring(basename(x), 1, nchar(basename(x))-5), "_heatmap.jpeg", sep=""), fsep="/"), vwidth = width, vheight = height, delay = 0.5, zoom=3)
  })
  
}
