import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import numpy as np
from skimage.io import imsave
import threading
import csv
import time
import pyCALIBRATE.set_advanced as advanced


class RealSenseThread (threading.Thread):

    def __init__(self, threadID, thread_name):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = thread_name
        self.motor_control = None
        self.save_color = False
        self.save_texture = False
        self.save_ply = False
        self.save_depth = False
        self.prefix_filename = '../../../data/'
        self.postfix_filename = ''
        self.motor_filename = ''

    def connect(self, render):
        self.render = render

    def run(self):
        try:

            if self.motor_control is not None:
                ofile = open(self.prefix_filename + 'alphamap.csv', 'w')
                writer = csv.writer(ofile)
            
            print('Real sense thread is starting up')
                        
            
            advanced.set_adv()
            
            context = rs.context()
            
            devices = context.query_devices()
            print(devices.size(), 'connected cameras')
            
            configs = []
            serial_numbers = []
            for dev in devices:
            
                camera_name = dev.get_info(rs.camera_info(0))
                print('Camera name:', camera_name)
                if camera_name == 'Platform Camera':
                    continue
                if camera_name != 'Intel RealSense D415':
                    continue
            
                serial_number = dev.get_info(rs.camera_info.serial_number)
                print('Serial number:', serial_number)
                serial_numbers.append(serial_number)
                config = rs.config()
                config.enable_device(serial_number)
                config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 15)
                config.enable_stream(rs.stream.color, 1280, 720, rs.format.rgb8, 15)
                print('Config set up:', config)
                configs.append(config)
            
            print('Configuration is done for', len(configs), 'devices')
            
            pipelines = []
            time.sleep(1)
            for cfg in configs:
                pipe = rs.pipeline()
                time.sleep(1)
                pipe.start(cfg)
                pipelines.append(pipe)
            
            
            print(len(pipelines), 'Pipelines are started')
            print('Camera is warming up')
            time.sleep(6)
                        
            #Make an align object. Allows us to align depth to color
            align_to = rs.stream.color
            align = rs.align(align_to)
            
            print('Done initializing real sense pipeline')

            if self.motor_control is not None:
                print('Initializing Arduino board')
                self.motor_control.setup()
                print('Done initializing Arduino board')


            count = 1
            while True:

                
                if self.motor_control is not None:
                    pos = self.motor_control.nextPos()
                    for (m_nr, p) in enumerate(pos):
                        print('Motor', m_nr,': ', p)
    
                    writer.writerow([count] + pos)
                    
                for camNo, pipeline in enumerate(pipelines):     
               
                    self.motor_filename = str(count) +'_' + serial_numbers[camNo]
                    frames = pipeline.wait_for_frames()
    
                    depth = frames.get_depth_frame()
                    color = frames.get_color_frame()
                    
                    pointcloud = rs.pointcloud()
                    pointcloud.map_to(color)
                    points = rs.points()
                    points = pointcloud.calculate(depth)
                    
                    pixels = np.asanyarray(color.get_data())
                    # 2018-01-14 Kenny: This is the old librealsense2 interface
                    #coordinates = np.asanyarray(points.get_vertices())
                    #uvs = np.asanyarray(points.get_texture_coordinates())
    
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


                print('frame', count, 'done')
                count = count + 1

                if not threading.main_thread().is_alive():
                    print('Main thread is dead, closing down sensor')
                    ofile.close()
                    pipeline.stop()
                    return

        except Exception as e:
            print(e)
            pipeline.stop()
            ofile.close()
            return
