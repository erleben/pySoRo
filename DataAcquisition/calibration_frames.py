import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from scipy.misc import imsave
import numpy as np


context = rs.context()

devices = context.query_devices()
print(devices.size(), 'connected cameras')

configs = []
for dev in devices:
    camera_name = dev.get_info(rs.camera_info(0))
    print('Camera name:', camera_name)
    if camera_name == 'Platform Camera':
        continue
    serial_number = dev.get_info(rs.camera_info(1))
    print('Serial number:', serial_number)
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

time.sleep(3)

for camNo, pipe in enumerate(pipelines):
    frames = pipe.wait_for_frames()
    print('camera number: ', camNo)
    pointcloud = rs.pointcloud()
    depth = frames.get_depth_frame()
    points = pointcloud.calculate(depth)
    color = frames.get_color_frame()
    pointcloud.map_to(color)
    pixels = np.asanyarray(color.get_data())
    
    imsave('col' + '.png', pixels)
    points.export_to_ply('dep' + '.ply', color)



for pipeline in pipelines:
    pipeline.stop()