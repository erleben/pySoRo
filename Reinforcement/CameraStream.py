# -*- coding: utf-8 -*-
"""
Created on Mon Dec  3 14:13:43 2018

@author: kerus
"""

import pyrealsense2 as rs
import numpy as np
import cv2
import sys
sys.path.extend(['../'])
import time

class CameraStream():


    def __init__(self):
        self.pipeline = rs.pipeline()
        self.cnt = rs.context()
        self.devs = self.cnt.query_devices()
        self.d = self.devs.front()
        print(self.devs.size())
        self.serial_no = self.d.get_info(rs.camera_info(1))
        print(self.serial_no)
        self.config = rs.config()
        self.config.enable_stream(rs.stream.depth, 1280, 720, rs.format.z16, 15)
        self.config.enable_stream(rs.stream.color, 1280, 720, rs.format.rgb8, 15)
        
        self.min_area_tip = 600 #minimal area of contour for detecting red tip of finger
        self.max_area_tip = 2300 #maximal area of contour for detecting red tip of finger
        
        
        time.sleep(1)
        self.pipeline.start(self.config)
        print('Camera is warming up')
        time.sleep(3)
        
        self.pointcloud = rs.pointcloud()
        time.sleep(2)
        
    def get_data(self,image_need=False):
        
        num_att = 0
        max_att = 10
        attempt_success = False
        
        while (not(attempt_success) and (num_att <= max_att)):
            frame = self.pipeline.wait_for_frames()
            col_obj=frame.get_color_frame()
            dep_obj=frame.get_depth_frame()
            
            points = self.pointcloud.calculate(dep_obj)       
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
                ball_coord = circles[0,0]            
                #put out from blok if
                #cv2.imshow('detected circles',cimg)
                m = ball_coord[0]
                n = ball_coord[1]
                d_ind = n*width + m
                pt = np.asanyarray(vertices[d_ind]).tolist()
                pts = [pt[0], pt[1], pt[2]+0.017]
        
            
            
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
            ret,thresh = cv2.threshold(grayimg,130,255,2)
            #ret,thresh = cv2.threshold(cimg,135,255,cv2.THRESH_BINARY_INV+cv2.THRESH_OTSU)
            im2,contours,hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
            
            contours.sort(key=lambda x: x.shape[0])
            cnt = contours[0]
            area = cv2.contourArea(cnt)
            
            
            #if((area < self.min_area_tip)or(area > self.max_area_tip)):
            if(area <= 0):
                num_att += 1
                time.sleep(2)
                continue
                
            
            attempt_success = True
            M = cv2.moments(cnt)            
            cx = int(M['m10']/M['m00'])
            cy = int(M['m01']/M['m00'])
            tip_coord = [cx,cy]
                
            
            distance = np.sqrt(((tip_coord[0]-ball_coord[0])**2)+((tip_coord[1]-ball_coord[1])**2))
            
        if (not(attempt_success)):
            print('Wrong getting contour of a red tip. Probably there are problems with a camera')
            return False
            
        if(image_need):
            # draw the outer circle of ball
            cv2.circle(cimg,(ball_coord[0],ball_coord[1]),ball_coord[2],(0,255,0),2)
            # draw the center of the circle of ball
            cv2.circle(cimg,(ball_coord[0],ball_coord[1]),2,(0,0,255),3)
            cv2.drawContours(cimg,[cnt],-1,(0,255,0),3)
            cv2.circle(cimg,(tip_coord[0],tip_coord[1]),3,(0,0,255),2)
                
            return cimg
        
        return [tip_coord,ball_coord,distance]
        

