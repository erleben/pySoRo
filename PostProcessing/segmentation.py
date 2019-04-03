import numpy as np
from open3d import *
import pandas as pd

#############################################
# Pre requisites for loading in files       #
# is the settings prior to running program. #
#############################################

folder = "~/Documents/experiment1/"
camera_serials = [""]


if __name__ == "__main__":
    alphamap = pd.read_csv(folder + "alphamap.csv")
    print (alphamap)
