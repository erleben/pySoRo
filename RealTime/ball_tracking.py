# This script detects balls and finds the xyz coordinate of its center. 
# Press q to close window, press m to make the robot go to those coorinates

# import the necessary packages
from collections import deque
import numpy as np
import argparse
import imutils
import cv2
import sys
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import time
from matplotlib.pyplot import axis, colorbar, imshow, show, figure, subplot, title, plot, ylabel, xlabel
import makeMove as MM

mm = MM.makeMove()
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


time.sleep(1)
pipeline.start(config)
print('Camera is warming up')
time.sleep(3)

pointcloud = rs.pointcloud()
time.sleep(2)

isPaused = False

# keep looping
while True:
	# grab the current frame
    frame = pipeline.wait_for_frames()
    col_obj=frame.get_color_frame()
    dep_obj=frame.get_depth_frame()
    
    points = pointcloud.calculate(dep_obj)
    
    col = np.asanyarray(col_obj.get_data())
    vertices = np.asanyarray(points.get_vertices())
    
    width = col_obj.get_width()
    
    img = cv2.medianBlur(col,5)
    cimg = cv2.cvtColor(img,cv2.COLOR_RGB2GRAY)

    circles = cv2.HoughCircles(cimg,cv2.HOUGH_GRADIENT,1,20,
                            param1=50,param2=30,minRadius=20,maxRadius=35)

    if circles is not None:
        
        circles = np.uint16(np.around(circles))
        i = circles[0,0]
        # draw the outer circle
        cv2.circle(cimg,(i[0],i[1]),i[2],(0,255,0),2)
        # draw the center of the circle
        cv2.circle(cimg,(i[0],i[1]),2,(0,0,255),3)
    
        cv2.imshow('detected circles',cimg)
        m = i[0]
        n = i[1]
        d_ind = n*width + m
        pt = np.asanyarray(vertices[d_ind]).tolist()
        pts = [pt[0], pt[1], pt[2]+0.017]
        print(pts)
    
    


    mm.move(pts)
    key = cv2.waitKey(1) & 0xFF

	# if the 'q' key is pressed, stop the loop
    if key == ord("q"):
        break
    if key == ord("m"):
        mm.move(pts)
    if key == ord("g"):
        mm.grab()
    if key == ord("p"):
        isPaused = True
        while isPaused:
            time.sleep(1)
            key = cv2.waitKey(1) & 0xFF
            if key == ord("p"):
                isPaused = False

# cleanup the camera and close any open windows
cv2.destroyAllWindows()
pipeline.stop()
mm.end()
