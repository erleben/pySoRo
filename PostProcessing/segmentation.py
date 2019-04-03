import numpy as np
from open3d import *
import pandas as pd
from pySegment.api import *
import plyfile as pl

#########################################
# CONFIGURATION FOR SEGMENTATION IMAGES #
#########################################

settings = {
    "folder": "/Users/NewUser/Documents/experiment1/",
    "serials": ["821312062271", "732612060774"]
    }

if __name__ == "__main__":
    print("Fetching: " + settings["folder"] + "alphamap.csv")
    alphamap = pd.read_csv(settings["folder"] + "alphamap.csv", header=None)
    experiments = alphamap.values
    print(experiments[0])
    paths = construct_filepath(settings, experiments[0])
    #pcloud = 
    segment_image(paths[0])
    # print(pcloud.elements)
    # print(pcloud.elements[0].name)
    # print(pcloud['vertex']['x'])
    # print(pcloud['vertex']['y'])
    # print(pcloud['vertex']['z'])
    # print(pcloud['vertex']['red'])
    # print(pcloud['vertex']['green'])
    # print(pcloud['vertex']['blue'])

    
                               

