# -*- coding: utf-8 -*-
"""
Created on Wed Nov 21 16:09:55 2018

@author: kerus
"""

import pyrealsense2 as rs
import numpy as np
import cv2
import sys
sys.path.extend(['../'])
import time
import matplotlib.pyplot as plt
from matplotlib.colors import hsv_to_rgb


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

#test part for detecting red color
frame = pipeline.wait_for_frames()
col_obj=frame.get_color_frame()
dep_obj=frame.get_depth_frame()
        
points = pointcloud.calculate(dep_obj)
        
col = np.asanyarray(col_obj.get_data())
vertices = np.asanyarray(points.get_vertices())
        
width = col_obj.get_width()      
img = cv2.medianBlur(col,5)

#img = cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
#cv2.imshow('color img',img)

#mask for color segmentation (blue because we work in BGR regim)
hsv_img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
lower_blue = np.array([70,60,170])
upper_blue = np.array([130,255,255])
mask = cv2.inRange(hsv_img, lower_blue, upper_blue)

# in order to get rid of noise object outside the cube we set borders for mask
mask = np.array(mask)
tr=100
mask[:tr,:] = 0
mask[:,1280-tr:] = 0
mask[720-tr:,:] = 0
mask[:,:tr] = 0

result = cv2.bitwise_and(img, img, mask=mask)
#cv2.imshow('segment',result)

#getting rid of noise
img_bw = 255*(cv2.cvtColor(result, cv2.COLOR_BGR2GRAY) > 5).astype('uint8')

se1 = cv2.getStructuringElement(cv2.MORPH_RECT, (35,35))
se2 = cv2.getStructuringElement(cv2.MORPH_RECT, (20,20))
mask = cv2.morphologyEx(img_bw, cv2.MORPH_CLOSE, se1)
mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, se2)
mask = np.dstack([mask, mask, mask]) / 255
out = (result * mask).astype('uint8')
cv2.imshow('Output', out)

#get contours from image
grayimg = cv2.cvtColor(out,cv2.COLOR_BGR2GRAY)
ret,thresh = cv2.threshold(grayimg,125,255,0)
#ret,thresh = cv2.threshold(cimg,135,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
im2,contours,hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

cnt = contours[0]
M = cv2.moments(cnt)
cx = int(M['m10']/M['m00'])
cy = int(M['m01']/M['m00'])
tip_coord = [cx,cy]

print('centroid of red tip: {}'.format(tip_coord))

cv2.drawContours(img,contours,-1,(0,255,0),3)
cv2.circle(img,(tip_coord[0],tip_coord[1]),3,(0,0,255),2)
cv2.imshow('contours',img)



#end of test part

# keep looping 
try:
    while True:
    	# grab the current frame
        frame = pipeline.wait_for_frames()
        col_obj=frame.get_color_frame()
        dep_obj=frame.get_depth_frame()
        
        points = pointcloud.calculate(dep_obj)
        
        col = np.asanyarray(col_obj.get_data())
        vertices = np.asanyarray(points.get_vertices())
        
        width = col_obj.get_width()
        
        # Detect circle
        img = cv2.medianBlur(col,5)
        cimg = cv2.cvtColor(img,cv2.COLOR_RGB2GRAY)
        circles = cv2.HoughCircles(cimg,cv2.HOUGH_GRADIENT,1,20,
                                param1=50,param2=30,minRadius=20,maxRadius=35)
    
        # Draw circle
        if circles is not None:
            
            circles = np.uint16(np.around(circles))
            i = circles[0,0]
            # draw the outer circle
            cv2.circle(cimg,(i[0],i[1]),i[2],(0,255,0),2)
            # draw the center of the circle
            cv2.circle(cimg,(i[0],i[1]),2,(0,0,255),3)
            
            #put out from blok if
            #cv2.imshow('detected circles',cimg)
            m = i[0]
            n = i[1]
            d_ind = n*width + m
            pt = np.asanyarray(vertices[d_ind]).tolist()
            pts = [pt[0], pt[1], pt[2]+0.017]
    
    
        #Detect red tip
        #Konstantin todo:
        # Attach red tape to tip of robot
        # Find out how to segment the tip and get the mean cordinate of the red area
        
        
        #mask for color segmentation (blue because we work in BGR regim)
        hsv_img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
        lower_blue = np.array([70,60,170])
        upper_blue = np.array([130,255,255])
        mask = cv2.inRange(hsv_img, lower_blue, upper_blue)
        
        # in order to get rid of noise object outside the cube we set borders for mask
        mask = np.array(mask)
        tr=150
        mask[:tr,:] = 0
        mask[:,1280-tr:] = 0
        mask[720-tr:,:] = 0
        mask[:,:tr] = 0
        
        result = cv2.bitwise_and(img, img, mask=mask)
        #cv2.imshow('segment',result)
        
        #getting rid of noise
        img_bw = 255*(cv2.cvtColor(result, cv2.COLOR_BGR2GRAY) > 5).astype('uint8')
        
        se1 = cv2.getStructuringElement(cv2.MORPH_RECT, (35,35))
        se2 = cv2.getStructuringElement(cv2.MORPH_RECT, (20,25))
        mask = cv2.morphologyEx(img_bw, cv2.MORPH_CLOSE, se1)
        mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, se2)
        mask = np.dstack([mask, mask, mask]) / 255
        out = (result * mask).astype('uint8')
        
        #get contours from image
        grayimg = cv2.cvtColor(out,cv2.COLOR_BGR2GRAY)
        ret,thresh = cv2.threshold(grayimg,130,255,0)
        #ret,thresh = cv2.threshold(cimg,135,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
        im2,contours,hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
        
        contours.sort(key=lambda x: x.shape[0])
        cnt = contours[0]
        M = cv2.moments(cnt)
        if(M['m00']>0):
            cx = int(M['m10']/M['m00'])
            cy = int(M['m01']/M['m00'])
            tip_coord = [cx,cy]
            cv2.drawContours(cimg,contours,-1,(0,255,0),3)
            cv2.circle(cimg,(tip_coord[0],tip_coord[1]),3,(0,0,255),2)

        #print('centroid of red tip: {}'.format(tip_coord))
        
        
        
        
        cv2.imshow('detected circles',cimg)
    
        key = cv2.waitKey(1) & 0xFF
    
    	# if the 'q' key is pressed, stop the loop
        if key == ord("q"):
            break

# cleanup the camera and close any open windows
finally:
    cv2.destroyAllWindows()
    pipeline.stop()
