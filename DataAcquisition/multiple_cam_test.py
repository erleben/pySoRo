import sys
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs

context = rs.context()

devices = context.query_devices()

pipelines =[]
for dev in devices:
    p = rs.pipeline()
    pipelines.append(p)
    
    serial_number = dev.get_info(rs.camera_info(1))
    print(serial_number)
    
    config = rs.config()
    config.enable_device(serial_number)
    config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
    config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)
    
    p.start(config)
    
running = True

while running:

    for pipe in pipelines:
        frames = pipe.wait_for_frames()
        print('frame number: ', frames.frame_number) 
        if frames.frame_number > 100:
            running = False

for pipeline in pipelines:
    pipeline.stop()

