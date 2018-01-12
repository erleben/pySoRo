import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import numpy as np
from scipy.misc import imsave
from OpenGL.GL import *
import threading


class RealSenseThread (threading.Thread):

    def __init__(self, threadID, name):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.render = None

    def connect(self, render):
        self.render = render

    def run(self):
        print('Running thread', self.name)
        try:
            pipeline = rs.pipeline()
            pipeline.start()
            pointcloud = rs.pointcloud()
        except Exception as e:
            print(e)
            return
        print('done initializing real sense pipeline')

        count = 1
        while True:

            frames = pipeline.wait_for_frames()

            depth = frames.get_depth_frame()
            points = pointcloud.calculate(depth)
            color = frames.get_color_frame()
            pointcloud.map_to(color)
            width = color.get_width()
            height = color.get_height()

            external_format = GL_RGB
            if color.get_profile().format() is rs.format.y8:
                external_format = GL_LUMINANCE

            external_type = GL_UNSIGNED_BYTE
            pixels = np.asanyarray(color.get_data())
            coordinates = np.asanyarray(points.get_vertices())
            uvs = np.asanyarray(points.get_texture_coordinates())

            #imsave('test.png', pixels)
            #points.export_to_ply("test.ply", color)

            if self.render is not None:
                print('  trying to update render with frame', count)
                self.render.update(
                    coordinates,
                    uvs,
                    width,
                    height,
                    external_format,
                    external_type,
                    pixels
                )
                print('    render was updated with frame', count)

            print('frame', count, 'done')
            count = count + 1
