import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from skimage.io import imsave
import numpy as np

def setup(path):
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
        serial_number = dev.get_info(rs.camera_info.serial_number)
        print('Serial number:', serial_number)
        serial_numbers.append(serial_number)
        config = rs.config()
        config.enable_device(serial_number)
        config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
        config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)
        print('Config set up:', config)
        configs.append(config)
    
    print('Configuration is done for', len(configs), 'devices')
    
    pipelines = []
    for cfg in configs:
        pipe = rs.pipeline()
        pipelines.append(pipe)
        pipe.start(cfg)
    
    print(len(pipelines), 'Pipelines are started')
    
    print('Camera is warming up')
    time.sleep(8)
    
    
    # Capture pointcloud
    capture(pipelines, serial_numbers, path)
    
    # Might be neccesary to shut down lasers in between due to interference
    # Shut down sensors
    cleanup(pipelines)

def capture(pipelines, serial_numbers, path):

    pc = rs.pointcloud()
    points = rs.points()
    for camNo, pipe in enumerate(pipelines):
        frames = pipe.wait_for_frames()
        
        depth_frame = frames.get_depth_frame()
        color_frame = frames.get_color_frame()
                
        pc.map_to(color_frame)
        points = pc.calculate(depth_frame)
        points.export_to_ply(path + str(serial_numbers[camNo])+'.ply',color_frame)
        
        print('Pointcloud saved for camera with serial number', serial_numbers[camNo])

        color_image = np.asanyarray(color_frame.get_data())
        imsave(path+ str(serial_numbers[camNo])+'color_fore.tif', color_image)
        
        tex_coor = np.asanyarray(points.get_texture_coordinates_EXT())
        imsave(path+ str(serial_numbers[camNo])+'texture_fore.tif', tex_coor)

def cleanup(pipelines):
    for pipeline in pipelines:
        pipeline.stop()
        
if __name__ == "__main__":
    path = 'pointclouds/'
    setup(path)