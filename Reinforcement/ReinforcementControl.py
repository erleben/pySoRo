# -*- coding: utf-8 -*-
"""
Created on Fri Nov 30 11:44:16 2018

@author: kerus
"""
import sys
sys.path.append('../DataAcquisition')
from MotorControl import api as MC
import numpy as np
import pandas as pd
import CameraStream as CS
import time

class ReinforcementControl():


    def __init__(self):
        self.max_pos = [0,300, 2100]
        self.min_pos = [0,0,0]
        self.model = 'TestModel'
        self.min_dist = 70
        
        self.mc = MC.Motorcontrol()
        self.mc.setup()
        
        self.grabPos = [0]
        
        self.step = [0,100,525]

        self.state_space = np.array([[0,rob1,rob2,0,ball1,ball2] for rob1 in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for rob2 in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])\
                      for ball1 in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for ball2 in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])])
    
        self.unit_state_space = np.array([[0,row,col] for row in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for col in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])])
        self.action_space = [0,1,2,3] #['forward','backward','bend','unbend']
        #in the future probably we can add complex action like 'forward+bend'
        self.reward = 0
        self.reward_sum = 0
        self.done = False
        self.cam_stream = CS.CameraStream()
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            self.curr_distance = cam_data[2]
        else:
            self.curr_distance = self.min_dist * 10
        #self.reward_table = {act:[(1.0,[0,350])] for act in self.action_space}
    
    def collect_coordinates_of_states(self):
        
        # don't forget to write results in json file
        # establish collecting 2-3 times and get mean values
        count_collect = 3
        pos = [0,0,0]
        coord_space = np.zeros((count_collect,self.unit_state_space.shape[0],2))
        
        for num in range(count_collect):
            for i,state in enumerate(self.unit_state_space):
                pos = [int(state[0]),int(state[1]),int(state[2])]
                print(pos)
                self.mc.setPos(pos)
                cam_data = self.cam_stream.get_data()
                if(cam_data):
                    coord_space[num,i] = cam_data[0]
                else:
                    print('Failed collecting coordinates on parameters (0,{}, {})'.format(state[1],state[2]))
            print('Coordinate space. Collecting {}'.format(num))
            print(coord_space[num])
        med_coord_space = np.median(coord_space,axis=0)
        df = pd.DataFrame(med_coord_space,columns=['x','y'])
        df.to_csv('coord_motor_space.csv')
        
        return True
        
    
    def calculate_reward(self,curr_dist,new_dist):
        dif = curr_dist - new_dist
        #k = 0.3
        #reward = k*dif
        if(dif > 0):
            reward = 1
        else:
            reward = -1
        return reward
    
    def new_step(self,action):
        
        # rewrite according to moving through the matrix of states!!!
        self.done = False
        new_pos = self.currPos.copy()

        if(action == 0):
            new_pos[2] = new_pos[2]+self.step[2]
            if(new_pos[2] > self.max_pos[2]):
                new_pos[2] = self.max_pos[2]

        elif(action== 1):
            new_pos[2] = new_pos[2]-self.step[2]
            if(new_pos[2] < self.min_pos[2]):
                new_pos[2] = self.min_pos[2]
        elif(action== 2):
            new_pos[1] = new_pos[1]+self.step[1]
            if(new_pos[1] > self.max_pos[1]):
                new_pos[1] = self.max_pos[1]
        elif(action == 3):
            new_pos[1] = new_pos[1]-self.step[1]
            if(new_pos[1] < self.min_pos[1]):
                new_pos[1] = self.min_pos[1]
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
                self.curr_distance = new_distance
                
                if(new_distance<=self.min_dist):
                    self.done = True
            
            self.currPos = new_pos
            self.currStInd = state_ind
            
            
        else:
            rew = -5
        print(self.currStInd,rew,self.done)
        
        return self.currStInd,rew,self.done
    
    def reset_env(self):
        self.currStInd = 0
        self.currPos = [0,0,0]
        self.reward_sum = 0
        self.reward = 0
        self.mc.setPos(self.currPos)
        
                  
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            new_distance = cam_data[2]                
            self.curr_distance = new_distance
        else:
            self.curr_distance = self.min_dist * 10
            
        #if(new_distance<=self.min_dist):
        #    self.done = True
        
        return self.currStInd
        
    
        
#env = ReinforcementControl()
#env.collect_coordinates_of_states()
#env.mc.setPos([0,0,750])
#print('plus step 1')
#time.sleep(5)
#env.mc.setPos([0,0,375])
#print('minus step 2')
#env.reset_env()
#count_states = len(env.state_space)
#count_actions = len(env.action_space)
#print(RF.state_space)
#print(RF.action_space)


    