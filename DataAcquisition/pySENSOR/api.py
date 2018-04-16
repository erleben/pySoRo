import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import numpy as np
from skimage.io import imsave
from OpenGL.GL import *
import threading
import csv
import time
import set_advanced as advanced


class RealSenseThread (threading.Thread):

    def __init__(self, threadID, thread_name):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = thread_name
        self.render = None
        self.motor_control = None
        self.save_color = False
        self.save_texture = False
        self.save_ply = False
        self.save_depth = False
        self.prefix_filename = '../../../data/'
        self.postfix_filename = ''
        self.bot = None
        self.motor_filename = ''

    def connect(self, render):
        self.render = render

    def run(self):
        try:

            ofile = open(self.prefix_filename + 'alphamap.csv', 'w')
            writer = csv.writer(ofile)
            
            print('Real sense thread is starting up')
            advanced.set_adv()
            pipeline = rs.pipeline()
            cnt = rs.context()
            devs = cnt.query_devices()
            d = devs.front()
            print(devs.size())
            serial_no = d.get_info(rs.camera_info(1))
            print(serial_no)
            config = rs.config()
            config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 15)
            config.enable_stream(rs.stream.color, 1280, 720, rs.format.rgb8, 15)
            #config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
            #config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)

            time.sleep(1)
            pipeline.start(config)
            print('Camera is warming up')
            time.sleep(4)
            
            pointcloud = rs.pointcloud()
            
            #Make an align object. Allows us to align depth to color
            align_to = rs.stream.color
            align = rs.align(align_to)
            
            print('Done initializing real sense pipeline')

            if self.motor_control is not None:
                print('Initializing Arduino board')
                self.motor_control.pipeline = pipeline
                self.motor_control.setup()
                print('Done initializing Arduino board')


            count = 1
            while True:

                if self.motor_control is not None:
                    pos = self.motor_control.nextPos()
                    print('Motor 1: ' + str(pos[0]) + ' Motor 2:' + str(pos[1]))
                    self.motor_filename = str(count) +'_' + serial_no
                    
                    writer.writerow([count] + pos)

                frames = pipeline.wait_for_frames()

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
                    filename = self.prefix_filename + self.motor_filename + self.postfix_filename

                if self.save_color:
                    imsave(filename + 'color.tif', pixels)

                if self.save_texture:
                    texture = np.asanyarray(points.get_texture_coordinates_EXT())
                    imsave(filename + 'texture.tif', texture)
                    
                if self.save_ply:
                    points.export_to_ply(filename + '.ply', color)
                    
                if self.save_depth:
                    is_aligned = False
                    while not is_aligned:
                        aligned_frames = align.process(frames)
                        try:
                            aligned_depth_frame = aligned_frames.get_depth_frame() 
                            depth_image = np.asanyarray(aligned_depth_frame.get_data())
                            is_aligned = True
                        except:
                            pass
                            
                    imsave(filename + 'depth.tif', depth_image)
                    
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
                    if self.bot is not None:
                        self.bot.end('')
                    return

        except Exception as e:
            print(e)
            pipeline.stop()
            ofile.close()
            if self.bot is not None:
                self.bot.end(e)
            return
