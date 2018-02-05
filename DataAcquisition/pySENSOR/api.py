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
        self.use_motor_control = False
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

            config = rs.config()
            config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
            config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)

            profile = pipeline.start(config)
            pointcloud = rs.pointcloud()
            print()
            print('Done initializing real sense pipeline')

            motor_control = None
            if self.use_motor_control:
                print('Initializing Arduino board')
                motor_control = MC.setup()
                print('Done initializing Arduino board')

            count = 1
            while True:

                if self.use_motor_control:
                    msg = MC.nextPos(motor_control)
                    pos = msg.split(',')
                    print('Motor 1: '+ str(pos[0]) + ' Motor 2:' + str(pos[1]))
                    motor_filename = 'm1_'+str(pos[0]+'m2_'+str(pos[1]))

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
                # 2018-01-14 Kenny: This is the old librealsense2 interface
                #coordinates = np.asanyarray(points.get_vertices())
                #uvs = np.asanyarray(points.get_texture_coordinates())

                coords = np.asanyarray(points.get_vertices_EXT(), dtype=np.float32)
                texs = np.asanyarray(points.get_texture_coordinates_EXT(), dtype=np.float32)
                vertex_array = np.hstack((coords, texs))

                filename = self.prefix_filename + 'frame' + str(count) + self.postfix_filename
                if self.use_motor_control:
                    filename = self.prefix_filename + motor_filename + self.postfix_filename

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

