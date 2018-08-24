# Creates BNA heatmap like the website map
# Inputs: List of BNA census blocks file(s) as json in WGS84 projection, or filepath to folder containing json files
# Outputs: jpeg or png image of heatmap identical to BNA website but with a scale of 10 equal intervals

# Load Libraries
library(leaflet)
library(geojsonio)
library(mapview)
library(dplyr)

fpath = getwd()

files <- list.files(fpath, pattern="*.json", full.names=T, recursive=FALSE)

# Args
# *fpath - path to folder containing json files
# *files - file name(s) as character vector
# width - numeric, in pixels
# height - numeric, in pixels
# * Must include fpath or files, but not both
heatmap <- function(fpath=NULL, files=NULL, width=1600, height=800) {
  
  print("Evaluating request")
  if(!is.null(fpath)) {
    files <- list.files(fpath, pattern="*.json", full.names=T, recursive=FALSE)
  }
  else if(!is.null(files)) {
    if (length(files) == 1){
      fpath = dirname(files)
    }
    else {
      fpath = dirname(files[1])
    }
  }
  else if(is.null(fpath) && is.null(files)){
    return("Must supply a path to files or file name")
  }
  else if (!is.null(fpath) && !is.null(files)){
    return("You can only supply the directory path or files list, not both")
  }
  
  # Load waterblocks data to remove blocks that have no land from the map
  print("Removing water blocks")
  waterblocks <- read.csv("C://Users/rebec/Documents/bna/census_block_files/censuswaterblocks.csv")
  
  pal <- colorBin(c("#FF3300", "#D04628", "#B9503C", "#A25A51", "#8B6465", "#736D79", "#5C778D", "#4581A2", "#2E8BB6", 
                    "#009FDF"), bins = c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100), 0:100)
  
  print("Drawing map")
  lapply(files, function(x) {
    bigjumparea <- geojsonio::geojson_read(x, what = "sp") # load file
    
    #Remove blocks with no score
    bigjumparea <- subset(bigjumparea, OVERALL_SC >= 0)
    
    # Remove blocks that have no land area
    bigjumparea <- bigjumparea[!bigjumparea$BLOCKID10 %in% waterblocks$GEOID10, ]
    
    # Display map with Positron basemap
    m <- leaflet(bigjumparea) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addPolygons(stroke = FALSE, smoothFactor = 0, opacity = 0, fillOpacity = 1, color = ~pal(OVERALL_SC))
    
    print("Generating image file")
    # Generate jpeg (intermediary html file will be generated)
    mapshot(m, file = file.path(fpath, paste(substring(basename(x), 1, nchar(basename(x))-5), "_heatmap.jpeg", sep=""), fsep="/"), vwidth = width, vheight = height, delay = 0.5, zoom=3)
  })
  
}

