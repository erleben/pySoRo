# -*- coding: utf-8 -*-
"""
Created on Fri Nov 30 11:44:16 2018

@author: kerus
"""
import sys
sys.path.append('../DataAcquisition')
from MotorControl import api as MC
import numpy as np

class ReinforcementControl():


    def __init__(self):
        self.max_pos = [350, 1750]
        self.min_pos = [0,0]
        self.model = 'TestModel'
        #self.mc = MC.Motorcontrol()
        #self.mc.setup()
        self.grabPos = [0]
        self.currPos = [0,0]
        self.step = [100,350]
        self.len_rows = (self.max_pos[1]-self.min_pos[1])/self.step[1]
        self.len_cols = (self.max_pos[0]-self.min_pos[0])/self.step[0]
        self.state_space = np.array([[row,col] for row in np.arange(self.min_pos[1],self.max_pos[1],self.step[1])\
                      for col in np.arange(self.min_pos[0],self.max_pos[0],self.step[0])])
        self.action_space = ['forward','backward','bend','unbend']
        self.reward = 0
        self.reward_sum = 0
        self.done = False
    
    def calculate_reward(self,tip_pts,ball_pts):
        distance = np.sqrt(((tip_pts[0]-ball_pts[0])**2)+((tip_pts[1]-ball_pts[1])**2))
        k = 0.1
        self.reward = k*distance
        return self.reward
    
    def step(self):
        pass
    
    def reset(self):
        pass
    
        
#RF = ReinforcementControl()
#print(RF.state_space)
#print(RF.action_space)


    