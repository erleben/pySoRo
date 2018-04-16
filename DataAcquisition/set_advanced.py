#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 16 14:16:43 2018

@author: FredrikHolsten
"""

import sys
# Kenny Add pyrealsense2 library path to current system path
sys.path.extend(['/usr/local/lib'])
import pyrealsense2 as rs
import numpy as np
import time

def set_adv():
    context = rs.context()
    devs = context.query_devices()
    d = devs.front()
    adv = rs.rs400_advanced_mode(d)
    
    curr = adv.get_depth_table()
    curr.disparityShift=25
    curr.depthUnits = 100
    curr.depthClampMax = 6500
    curr.depthClampMin = 5000
    curr.disparityShift
    adv.set_depth_table(curr)
    
    
    curr = adv.get_depth_control()
    curr.textureDifferenceThreshold = 500
    curr.textureCountThreshold = 0
    adv.set_depth_control(curr)
    
    curr = adv.get_rau_support_vector_control()
    curr.minEast = 6
    curr.minWest = 4
    curr.minSouth = 1
    curr.minNorth = 1
    curr.minWEsum = 8
    curr.minNSsum = 1
    curr.uShrink = 4
    curr.vShrink = 1
    adv.set_rau_support_vector_control(curr)
    
    curr = adv.get_hdad()
    curr.lambdaCensus = 39
    curr.lambdaAD = 2000
    adv.set_hdad(curr)
    
    curr = adv.get_census()
    curr.uDiameter = 9
    curr.vDiameter = 3
    adv.set_census(curr)

    print('D')
    time.sleep(1)
    for s in d.sensors:
        time.sleep(0.2)
        if (s.get_info(rs.camera_info(0))=='Stereo Module'):
            time.sleep(0.2)
            print(s.get_option(rs.option.enable_auto_exposure))
            time.sleep(0.2)
            s.set_option(rs.option.enable_auto_exposure,0)
            time.sleep(0.2)
            print(s.get_option(rs.option.enable_auto_exposure))
            time.sleep(0.2)
            print(s.get_option(rs.option.exposure))
            s.set_option(rs.option.exposure,66000.0)
            time.sleep(0.2)
            print(s.get_option(rs.option.exposure))
            
