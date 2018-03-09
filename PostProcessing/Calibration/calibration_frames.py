import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from skimage.io import imsave
import numpy as np

def main():
    
    back_then_fore = False
    prefix = '../../data/calibration/'
    postfix = '4'
    
    (pipelines, serial_numbers) = setup(back_then_fore)
    
    # Get data without foreground
    capture(back_then_fore, pipelines, serial_numbers, True, prefix, postfix)
    # Get images with foreground
    capture(not back_then_fore, pipelines, serial_numbers, False, prefix, postfix)

    # Might be neccesary to shut down lasers in between due to interference
    # Shut down sensors
    cleanup(pipelines)


def setup(back_then_fore):
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
    
    return (pipelines, serial_numbers)
    

def capture(isBack, pipelines, serial_numbers, isFirst, prefix, postfix):
    if isBack:
        ground = 'back'
    else:
        ground = 'fore'
        pc = rs.pointcloud()
        points = rs.points()
        
            
    for camNo, pipe in enumerate(pipelines):
        frames = pipe.wait_for_frames()
        
        depth_frame = frames.get_depth_frame()
        color_frame = frames.get_color_frame()
        
        color_image = np.asanyarray(color_frame.get_data())
        
        if not isBack:
            pc.map_to(color_frame)
            points = pc.calculate(depth_frame)
            points.export_to_ply(prefix + str(serial_numbers[camNo]) + '_' + postfix + ground + '.ply',color_frame)
        
            tex_coor = np.asanyarray(points.get_texture_coordinates_EXT())
            imsave(prefix + str(serial_numbers[camNo]) + '_' + postfix + 'texture_' + ground + '.tif', tex_coor)
        
            print('Foreground pointcloud and texture coordinates saved for camera with serial number ', serial_numbers[camNo])

        
        imsave(prefix + str(serial_numbers[camNo]) + '_' + postfix + 'color_' + ground+'.tif', color_image)
        print(ground +'ground color image saved for camera with serial number ', serial_numbers[camNo])

        
        if isFirst:
            input("Place balls in the box and press enter")


def cleanup(pipelines):
    for pipeline in pipelines:
        pipeline.stop()
        
if __name__ == "__main__":
    main()
