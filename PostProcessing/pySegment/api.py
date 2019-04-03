from open3d import *
import plyfile as pl
import numpy as np


def construct_filepath(settings, alphas):
    return (settings["folder"] + str(alphas[0]) + "_" + settings["serials"][0] + ".ply", 
            settings["folder"] + str(alphas[0]) + "_" + settings["serials"][0] + "texture.tif", 
            settings["folder"] + str(alphas[0]) + "_" + settings["serials"][0] + "color.tif", 
            settings["folder"] + str(alphas[0]) + "_" + settings["serials"][1] + ".ply", 
            settings["folder"] + str(alphas[0]) + "_" + settings["serials"][1] + "texture.tif", 
            settings["folder"] + str(alphas[0]) + "_" + settings["serials"][1] + "color.tif")

           

def segment_image(pointcloud_path):
    pcloud = pl.PlyData.read(pointcloud_path)
    pcloud_location = np.array([pcloud['vertex'].data['x'],
                              pcloud['vertex'].data['y'],
                              pcloud['vertex'].data['z']])
    pcloud_color = np.array([pcloud['vertex'].data['red'],
                             pcloud['vertex'].data['green'],
                             pcloud['vertex'].data['blue']])

    print(pcloud_location.T)
#read_point_cloud(pointcloud_path,)
