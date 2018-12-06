# -*- coding: utf-8 -*-
"""
Created on Fri Nov 30 11:44:16 2018

@author: kerus
"""
import sys
sys.path.append('../DataAcquisition')
from MotorControl import api as MC
import numpy as np
import CameraStream as CS

class ReinforcementControl():


    def __init__(self):
        self.max_pos = [300, 1750]
        self.min_pos = [0,0]
        self.model = 'TestModel'
        self.min_dist = 200
        
        self.mc = MC.Motorcontrol()
        self.mc.setup()
        
        self.grabPos = [0]
        
        self.step = [100,350]
        self.len_rows = (self.max_pos[1]-self.min_pos[1])/self.step[1]
        self.len_cols = (self.max_pos[0]-self.min_pos[0])/self.step[0]
        self.state_space = np.array([[row,col] for row in np.arange(self.min_pos[1],self.max_pos[1],self.step[1])\
                      for col in np.arange(self.min_pos[0],self.max_pos[0],self.step[0])])
        self.action_space = [0,1,2,3] #['forward','backward','bend','unbend']
        #in the future probably we can add complex action like 'forward+bend'
        self.reward = 0
        self.reward_sum = 0
        self.done = False
        self.cam_stream = CS.CameraStream()
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            self.curr_distance = cam_data[2]
        #self.reward_table = {act:[(1.0,[0,350])] for act in self.action_space}
        
    
    def calculate_reward(self,curr_dist,new_dist):
        dif = curr_dist - new_dist
        k = 0.05
        reward = k*dif
        return reward
    
    def new_step(self,action):
        
        # rewrite according to moving through the matrix of states!!!
        new_pos = self.currPos.copy()
        if(action == 0):
            new_pos[1] = new_pos[1]+self.step[1]
            if(new_pos[1] > self.max_pos[1]):
                new_pos[1] = self.max_pos[1]
        elif(action== 1):
            new_pos[1] = new_pos[1]-self.step[1]
            if(new_pos[1] < self.min_pos[1]):
                new_pos[1] = self.min_pos[1]
        elif(action== 2):
            new_pos[0] = new_pos[0]+self.step[0]
            if(new_pos[0] > self.max_pos[0]):
                new_pos[0] = self.max_pos[0]
        elif(action == 3):
            new_pos[0] = new_pos[0]-self.step[0]
            if(new_pos[0] < self.min_pos[0]):
                new_pos[0] = self.min_pos[0]
        print(new_pos,'new pos')
        print(self.currPos,'curr pos')
        if(new_pos != self.currPos):
            state_ind = np.argwhere(np.all(self.state_space==new_pos,axis=(1))).ravel()
            
            if(len(state_ind)==0):
                print('Wrong state. Check rules for actions, or settings of step')
                return False
            
            state_ind = state_ind[0]
            self.mc.setPos(new_pos)
            cam_data = self.cam_stream.get_data()
            if(cam_data):
                new_distance = cam_data[2]
                rew = self.calculate_reward(self.curr_distance,new_distance)
            
            self.currPos = new_pos
            self.currStInd = state_ind
            self.curr_distance = new_distance
            if(new_distance<=self.min_dist):
                self.done = True
        else:
            rew = 0
        print(self.currStInd,rew,self.done)
        
        return self.currStInd,rew,self.done
    
    def reset(self):
        self.currStInd = 0
        self.currPos = [0,0]
        self.reward_sum = 0
        self.reward = 0
        self.mc.setPos(self.currPos)
                  
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            new_distance = cam_data[2]
                
        self.curr_distance = new_distance
        if(new_distance<=self.min_dist):
            self.done = True
        
        return self.currStInd
        
    
        
#env = ReinforcementControl()
#count_states = len(env.state_space)
#count_actions = len(env.action_space)
#print(RF.state_space)
#print(RF.action_space)


    