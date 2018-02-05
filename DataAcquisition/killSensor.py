import sys
import time
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs

pipe=rs.pipeline()
pipe.start()
pipe.stop()