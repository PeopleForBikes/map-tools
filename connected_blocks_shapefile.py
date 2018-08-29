'''
Combines census blocks shapefile and connected census blocks csv to create a 
bikeshed shapefile for a designated census block. 

Inputs: BNA census blocks shapefile, corresponding BNA connected census blocks csv
        name of output file, number of target census block
Outputs: Shapefile for census blocks coded for access to a specific census
         block within the bikeshed
'''
# Import packages
import pandas as pd
import geopandas as gpd
import numpy as np
import os

# Name output file
name = 'boulder_central'
# Insert census block number for source block
source_id = 80130122043022
# File path for connected census blocks csv
conn_path = os.getcwd() + "/neighborhood_connected_census_blocks.csv"
# File path for census bocks shapefile
blocks_path = os.getcwd() + "/neighborhood_census_blocks.shp"

# Function to filter shapefile based on csv info for source block
def join_tables(name, source_id, conn_path, blocks_path):
    
    # Upload connected census blocks csv
    connect = pd.read_csv(conn_path)
    
    # Upload census blocks shapefile
    shape_raw = gpd.read_file(blocks_path)
    
    # Remove blocks that didn't receive a BNA score (outside bikeshed)
    shape = shape_raw[shape_raw.OVERALL_SC >= 0]

    # Convert blockid10 var in shapefile from string to integer, to match connected census blocks file
    shape.BLOCKID10 = pd.to_numeric(shape.BLOCKID10)

    # Filter connected census blocks for records that match source_id
    source_only = connect[connect.source_blockid10 == source_id]
    
    # Create list of blocks to include in shapefile
    # Get list of target blocks associated with source block 
    # Andd append source block id to list [as series]
    source_pairs = source_only.target_blockid10.append(pd.Series(np.int64(source_id)))
    
    # Filter shapefile to only contain source block and its related target blocks
    bikeshed = shape[shape.BLOCKID10.isin(source_pairs)]
    
    # Identify source block in new file
    bikeshed.loc[bikeshed.BLOCKID10 == source_id, 'stress'] = "source"
    
    # Loop through census blocks in bikeshed of source block and 
    # set stress level for each
    for block in bikeshed.BLOCKID10:
    
        # Check if block connection is low 
        if source_pairs[source_pairs.target_blockid10==block].low_stress.values[0] == 'f':
        
            # If high (low_stress==false), set stress to high
            bikeshed.loc[bikeshed.BLOCKID10 == block, 'stress'] = "high"
        
        else:
        
            # Otherwise, set as low stress
            bikeshed.loc[bikeshed.BLOCKID10 == block, 'stress'] = "low"

    return bikeshed

# run function
bikeshed = join_tables(name, source_id, conn_path, blocks_path)

# write bikeshed to file
bikeshed.to_file(os.getcwd() + "/" + name + "_bikeshed.shp")

