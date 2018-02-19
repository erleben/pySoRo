import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import numpy as np
from scipy.misc import imsave
from OpenGL.GL import *
import threading
from MotorControl import api as MC


class RealSenseThread (threading.Thread):

    def __init__(self, threadID, thread_name):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = thread_name
        self.render = None
        self.motor_control = None
        self.save_png = False
        self.save_ply = False
        self.prefix_filename = '../../../data/'
        self.postfix_filename = ''

    def connect(self, render):
        self.render = render

    def run(self):
        try:

            print('Real sense thread is starting up')
            pipeline = rs.pipeline()
            align_to = rs.stream.color
            align = rs.align(align_to)

            config = rs.config()
            config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
            config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)

            pipeline.start(config)
            
            pointcloud = rs.pointcloud()
            print()
            print('Done initializing real sense pipeline')

            if self.motor_control is not None:
                print('Initializing Arduino board')
                self.motor_control.setup()
                print('Done initializing Arduino board')

            count = 1
            while True:

                if self.motor_control is not None:
                    pos = self.motor_control.nextPos()
                    print('Motor 1: ' + str(pos[0]) + ' Motor 2:' + str(pos[1]))
                    motor_filename = 'm1_' + str(pos[0]) + 'm2_' + str(pos[1])

                frames = pipeline.wait_for_frames()

                #aligned_frames = align.proccess(frames)
                #depth = aligned_frames.get_depth_frame()
                #color = aligned_frames.get_color_frame()

                depth = frames.get_depth_frame()
                color = frames.get_color_frame()
                
                pointcloud.map_to(color)
                points = pointcloud.calculate(depth)
                
                width = color.get_width()
                height = color.get_height()

                external_format = GL_RGB
                if color.get_profile().format() is rs.format.y8:
                    external_format = GL_LUMINANCE

                external_type = GL_UNSIGNED_BYTE
                pixels = np.asanyarray(color.get_data())
                # 2018-01-14 Kenny: This is the old librealsense2 interface
                #coordinates = np.asanyarray(points.get_vertices())
                #uvs = np.asanyarray(points.get_texture_coordinates())

                coords = np.asanyarray(points.get_vertices_EXT(), dtype=np.float32)
                texs = np.asanyarray(points.get_texture_coordinates_EXT(), dtype=np.float32)
                vertex_array = np.hstack((coords, texs))

                filename = self.prefix_filename + 'frame' + str(count) + self.postfix_filename
                if self.motor_control is not None:
                    filename = self.prefix_filename + motor_filename + self.postfix_filename

                # TODO: Save as tif. Add option to save texture
                if self.save_png:
                    imsave(filename + '.png', pixels)
                if self.save_ply:
                    points.export_to_ply(filename + '.ply', color)

                if self.render is not None:
                    self.render.copy_data(
                        vertex_array,
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
                    pipeline.stop()
                    return

        except Exception as e:
            print(e)
            pipeline.stop()
            return

