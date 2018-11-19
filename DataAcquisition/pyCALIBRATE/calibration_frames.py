# A script to capture data from multiple sensors. The data can be used to find the rigid
# transformation between two sensor coordinate systems

import pyrealsense2 as rs
import time
from skimage.io import imsave
import numpy as np
import set_advanced as sa
import os
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

def main():
    
    prefix = "..\\..\\..\\data\\calibration\\"
    postfix = '1'
    
    # Custom settings for D415
    if os.path.isdir(prefix):
    
        happy = False
        abort = False
        sa.set_adv()
        
        (pipelines, serial_numbers) = setup()
        
        while happy == False:
            check_view(pipelines, serial_numbers)
            # Get data without foreground
            cmd = input("Press y to continue, press n to try again, press a to abort")
            if cmd == "y":
                happy = True
            elif cmd == "a":
                abort = True
                happy = True
        
        if  not abort:
            capture_foreground(pipelines, serial_numbers, prefix, postfix)
        
            input("Clear the box and press enter")
            # Get images with foreground
            capture_background(pipelines, serial_numbers, prefix, postfix)

        # Shut down sensors
        cleanup(pipelines)
    else:
        print('Error: You should set prefix to existing folder')
    
    


def setup():
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

    return (pipelines, serial_numbers)
    
def check_view(pipelines, serial_numbers):
    images = []
    depths = []
    color_map = rs.colorizer()
    for camNo, pipe in enumerate(pipelines):
        frames = pipe.wait_for_frames()
        color_frame = frames.get_color_frame()
        depth_frame = frames.get_depth_frame()
        color_image = np.asanyarray(color_frame.get_data())
        depth_image = np.asanyarray(color_map.colorize(depth_frame).get_data())
        images.append(color_image)
        depths.append(depth_image)

    length = len(serial_numbers)
    fig = plt.figure()    
    
    for camNo, ser in enumerate(serial_numbers):
        a=fig.add_subplot(2,length, camNo+1)
        a.set_title(ser)
        plt.axis("off")
        plt.imshow(images[camNo])
        
    for camNo, ser in enumerate(serial_numbers):
        a=fig.add_subplot(2,length, camNo+1 + length)
        plt.axis("off")
        plt.imshow(depths[camNo])
        
    plt.show()
  


def capture_foreground(pipelines, serial_numbers, prefix, postfix):

    ground = 'fore'
    
    for camNo, pipe in enumerate(pipelines):
        pc = rs.pointcloud()
        points = rs.points()
        frames = pipe.wait_for_frames()
        
        depth_frame = frames.get_depth_frame()
        color_frame = frames.get_color_frame()
        
        color_image = np.asanyarray(color_frame.get_data())

        pc.map_to(color_frame)
        points = pc.calculate(depth_frame)
        points.export_to_ply(prefix + str(serial_numbers[camNo]) + '_' + postfix + ground + '.ply',color_frame)
        
        tex_coor = np.asanyarray(points.get_texture_coordinates_EXT())
        imsave(prefix + str(serial_numbers[camNo]) + '_' + postfix + 'texture_' + ground + '.tif', tex_coor)
    
        print('Foreground pointcloud and texture coordinates saved for camera with serial number ', serial_numbers[camNo])

        imsave(prefix + str(serial_numbers[camNo]) + '_' + postfix + 'color_' + ground+'.tif', color_image)
        print(ground +'ground color image saved for camera with serial number ', serial_numbers[camNo])
        
def capture_background(pipelines, serial_numbers, prefix, postfix):    
    for camNo, pipe in enumerate(pipelines):
        frames = pipe.wait_for_frames()
        color_frame = frames.get_color_frame()
        color_image = np.asanyarray(color_frame.get_data())
        imsave(prefix + str(serial_numbers[camNo]) + '_' + postfix + 'color_back.tif', color_image)
        print('Background color image saved for camera with serial number ', serial_numbers[camNo])


def cleanup(pipelines):
    for pipeline in pipelines:
        pipeline.stop()
        
if __name__ == "__main__":
    main()
