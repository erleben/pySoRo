import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from skimage.io import imsave
import numpy as np


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

pc = rs.pointcloud()
points = rs.points()

time.sleep(8)
real_depth = np.zeros((640, 480))

align_to = rs.stream.color
align = rs.align(align_to)

# Get images without foreground
for camNo, pipe in enumerate(pipelines):
    frames = pipe.wait_for_frames()
    
    aligned_frames = align.proccess(frames)
    
    depth_frame = aligned_frames.get_depth_frame()
    color_frame = aligned_frames.get_color_frame()
    
    depth_image = np.asanyarray(depth_frame.get_data())
    color_image = np.asanyarray(color_frame.get_data())
    
    pc.map_to(color_frame)
    points = pc.calculate(depth_frame)
    points.export_to_ply('data/'+ str(serial_numbers[camNo])+'back.ply',color_frame)
    
    print('Background depth and color saved for camera with serial number ', serial_numbers[camNo])
    
    imsave('data/'+ str(serial_numbers[camNo])+'color_back.tif', color_image)
    
    for i in range(depth_frame.width):
        for j in range(depth_frame.height):
            real_depth[i,j] = depth_frame.get_distance(i,j)
            
    imsave('data/'+ str(serial_numbers[camNo])+'depth_back.tif', real_depth)
  
    
input("Place balls in the box and press enter")

for camNo, pipe in enumerate(pipelines):
    frames = pipe.wait_for_frames()
    
    aligned_frames = align.proccess(frames)
    
    depth_frame = aligned_frames.get_depth_frame()
    color_frame = aligned_frames.get_color_frame()
    
    depth_image = np.asanyarray(depth_frame.get_data())
    color_image = np.asanyarray(color_frame.get_data())
    
    pc.map_to(color_frame)
    points = pc.calculate(depth_frame)
    points.export_to_ply('data/'+ str(serial_numbers[camNo])+'fore.ply',color_frame)
    
    print('Foreground depth and color saved for camera with serial number ', serial_numbers[camNo])
    
    imsave('data/'+ str(serial_numbers[camNo])+'color_fore.tif', color_image)
    
    for i in range(depth_frame.width):
        for j in range(depth_frame.height):
            real_depth[i,j] = depth_frame.get_distance(i,j)
            
    imsave('data/'+ str(serial_numbers[camNo])+'depth_fore.tif', real_depth)


for pipeline in pipelines:
    pipeline.stop()