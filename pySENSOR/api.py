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
        try:
            print('Real sense thread is starting up')
            pipeline = rs.pipeline()
            pipeline.start()
            pointcloud = rs.pointcloud()
            print('Done initializing real sense pipeline')

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
                    self.render.copy_data(
                        coordinates,
                        uvs,
                        width,
                        height,
                        external_format,
                        external_type,
                        pixels
                    )

                print('frame', count, 'done')
                count = count + 1

                if not threading.main_thread().is_alive():
                    print('Main thread is dead, closing down sensor')
                    return
        except Exception as e:
            print(e)
            return
