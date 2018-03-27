import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from skimage.io import imsave
import numpy as np
import time

config = rs.config()
pipeline = rs.pipeline()
config.enable_stream(rs.stream.depth, 640, 480, rs.format.z16, 10)
config.enable_stream(rs.stream.color, 640, 480, rs.format.rgb8, 10)

pipeline.start(config)

times = np.zeros(400)
for i in range(400):
    
    frames = pipeline.wait_for_frames()
    times[i] = time.time()
    
    depth = frames.get_depth_frame()
    color = frames.get_color_frame()
    
    depth = np.asanyarray(depth.get_data())
    color = np.asanyarray(color.get_data())
    
    fname_d = 'depth_'+str(i)+'.tif'
    fname_c = 'color'+str(i)+'.tif'
    imsave('../../../data/distortion/'+fname_d, depth)
    imsave('../../../data/distortion/'+fname_c, color)
    
np.savetxt('../../../data/distortion/times.csv',times,'%10.5f',',')
pipeline.stop()