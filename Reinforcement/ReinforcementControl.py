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
        self.model = 'TreatTest'
        #file in which will be saved coordinates of each motor state
        #self.coord_state_path = 'coord_motor_space.csv'
        self.coord_state_path = 'coord_motor_space1.csv'
        self.min_dist = 70
        
        self.mc = MC.Motorcontrol()
        self.mc.setup()
        
        self.grabPos = [0]
        
        self.step = [0,100,525]
        
        # generation of the whole state space
        self.state_space = np.array([[0,rob1,rob2,0,ball1,ball2] for rob1 in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for rob2 in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])\
                      for ball1 in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for ball2 in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])])
        
        #generation of unique states (possible parameters of the motor)
        self.unit_state_space = np.array([[0,row,col] for row in np.arange(self.min_pos[1],self.max_pos[1]+self.step[1],self.step[1])\
                      for col in np.arange(self.min_pos[2],self.max_pos[2]+self.step[2],self.step[2])])
        
        #calculating variance space 
        # from absolute measures to relative ones
        var_list = []
        for state in self.state_space:
            var_list.append((0,state[1]-state[4],state[2]-state[5]))
        self.variance_state_space = np.array(list(set(var_list)))
        
        #Here we can add new goal as element of the list
        self.goals = ['treat']
        #self.goals = ['push']
        
        self.action_space = [0,1,2,3] #['forward','backward','bend','unbend']
        #we can modify it adding complex action
        self.unit_coord_space = np.array([])
        self.reward = 0
        self.reward_sum = 0
        self.done = False
        # launch camera stream
        self.cam_stream = CS.CameraStream()
        #obtain first image data
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            self.curr_distance = cam_data[2]
        else:
            self.curr_distance = self.min_dist * 10

    
    def collect_coordinate_space(self):
    #this method is used for collecting coordinates for each possible state of the robot
    #in accordance with current configuration
    #Run it only if you change configuration (step size, min/max parameters)
        
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
        self.mc.setPos([0,0,0])
        med_coord_space = np.median(coord_space,axis=0)
        df = pd.DataFrame(med_coord_space,columns=['x','y'])
        df.to_csv(self.coord_state_path,index=False)
        
        return True
        
    def load_coordinate_space(self):
    # this method is used for upload saved coordinates for each state
        df = pd.read_csv(self.coord_state_path)
        self.unit_coord_space = np.array(df[['x','y']])
        return True
    
    def get_ball_state(self):
    #this method is used to get current ball state (motor parameters)    
        nearest_2_best = False
        
        cam_data = self.cam_stream.get_data()
        if(cam_data):
            ball_coord = cam_data[1]
            # calculating euclidean distance between ball and states
            eucl = np.sqrt((self.unit_coord_space[:,0]-ball_coord[0]-ball_coord[2])**2 + (self.unit_coord_space[:,1]-ball_coord[1]-ball_coord[2])**2)
            eucl_sort = pd.DataFrame(eucl,columns=['dist']).sort_values(by=['dist'])
            eucl_ind = eucl_sort.index.values
            if(nearest_2_best):
                ball_state = self.unit_state_space[eucl_ind[1]]
                ball_ind = eucl_ind[1]
            else:
                ball_state = self.unit_state_space[eucl_ind[0]]
                ball_ind = eucl_ind[0]
            
            return ball_state,ball_ind
        else:
            return False
    
    def calculate_reward(self,curr_pos,new_pos,new_coord=False):

        if(len(self.goals)>0):
            
            #getting new coordinates of the robot
            if(type(new_coord)!=bool):
            # if model works in real time (test stage)
                coord_tip = new_coord
            else:
            # if model works in real time (train stage)
                tip_u_state_ind = np.argwhere(np.all(self.unit_state_space==new_pos[:3],axis=(1))).ravel()
                tip_u_state_ind = tip_u_state_ind[0]                
                coord_tip = self.unit_coord_space[tip_u_state_ind]
            
            #getting current coordinates of the robot
            old_tip_u_state_ind = np.argwhere(np.all(self.unit_state_space==curr_pos[:3],axis=(1))).ravel()
            old_tip_u_state_ind = old_tip_u_state_ind[0]                
            old_coord_tip = self.unit_coord_space[old_tip_u_state_ind]
            
            #here we can add a realisation for each desirable goal
            if('treat' in self.goals):               
                #getting preferable coordinates of the robot
                pref_u_state_ind = np.argwhere(np.all(self.unit_state_space==[0,max(new_pos[4]-self.step[1],0),new_pos[5]],axis=(1))).ravel()
                pref_u_state_ind = pref_u_state_ind[0]                
                coord_pref = self.unit_coord_space[pref_u_state_ind]
                
                #calculating current and new distance 
                old_distance = np.sqrt(((old_coord_tip[0]-coord_pref[0])**2)+((old_coord_tip[1]-coord_pref[1])**2))
                new_distance = np.sqrt(((coord_tip[0]-coord_pref[0])**2)+((coord_tip[1]-coord_pref[1])**2))
                
                if((new_pos[:3] == [0,max(new_pos[4]-self.step[1],0),new_pos[5]]) and ((new_pos[2] - new_pos[5]) == 0)):
                    reward = 5
                elif((old_distance-new_distance) > 0):
                    reward = 1
                else:
                    reward = -1
            
            elif('push' in self.goals):
                #getting preferable coordinates of the robot
                pref_u_state_ind = np.argwhere(np.all(self.unit_state_space==new_pos[3:],axis=(1))).ravel()
                pref_u_state_ind = pref_u_state_ind[0]                
                coord_pref = self.unit_coord_space[pref_u_state_ind]
                
                #calculating current and new distance 
                old_distance = np.sqrt(((old_coord_tip[0]-coord_pref[0])**2)+((old_coord_tip[1]-coord_pref[1])**2))
                new_distance = np.sqrt(((coord_tip[0]-coord_pref[0])**2)+((coord_tip[1]-coord_pref[1])**2))
                
                if(new_pos[:3] == new_pos[3:]):
                    reward = 5
                elif((old_distance-new_distance) > 0):
                    reward = 1
                else:
                    reward = -1
               
            
        return reward
    
    def new_step(self,action,train=True):
    # this method returned new robot state, variance between current and new state, reward
    #in accordance with taken action    
        
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

        
        if(new_pos != self.currPos):
            state_ind = np.argwhere(np.all(self.state_space==new_pos,axis=(1))).ravel()
            
            if(len(state_ind)==0):
                print('Wrong state. Check rules for actions, or settings of step')
                return False
        
            state_ind = state_ind[0]
            
            # new variance between states
            newVar = [0,new_pos[1]-new_pos[4],new_pos[2]-new_pos[5]]
            varid = np.argwhere(np.all(self.variance_state_space==newVar,axis=(1))).ravel()
            
            
            
            if(train):
            # if traing stage
                rew = self.calculate_reward(self.currPos,new_pos)
                
            else:
            # if real-time
                self.mc.setPos(new_pos[:3])
                cam_data = self.cam_stream.get_data()
                if(cam_data):
                    new_coord = cam_data[1]
                    rew = self.calculate_reward(self.currPos,new_pos,new_coord)
                    
            # condions for finishing episode
            if('treat' in self.goals):
                if(new_pos[:3] == [0,max(new_pos[4]-self.step[1],0),new_pos[5]]):
                    self.done = True
            else:    
                if(new_pos[:3] == new_pos[3:]):
                    self.done = True
            
            self.currPos = new_pos
            self.currStInd = state_ind
            self.currVar = newVar
            self.currVarInd = varid[0]
            
            
        else:
        #if robot reached the wall and tries to go further
            rew = -5
        if(not(train)):
            print(self.currStInd,rew,self.done)
            print(self.currPos)
        
        return self.currStInd,rew,self.currVarInd, self.done
    
    def new_situation_env(self):
        # method for launching new situation where robot or the ball are placed in other position
        self.reward_sum = 0
        self.reward = 0
               
        ball_state,ball_ind = self.get_ball_state()
        print('Ball state: 0,{},{}'.format(ball_state[1],ball_state[2]))
        
        self.currPos = [0,self.currPos[1],self.currPos[2],0,int(ball_state[1]),int(ball_state[2])]
        state_ind = np.argwhere(np.all(self.state_space==self.currPos,axis=(1))).ravel()
        if(len(state_ind)==0):
            print('Wrong state. Check rules for actions, or settings of step')
            return False
        
        self.currStInd = state_ind[0]
        
        self.currBall_UnitInd = ball_ind
                          
        self.curr_distance = self.min_dist * 10
        
        self.currVar = [0,self.currPos[1]-self.currPos[4],self.currPos[2]-self.currPos[5]]
        varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
        self.currVarInd = varid[0]

        
        return self.currStInd,self.currVarInd
    
    def reset_env(self):
        # reset to initial state
        self.reward_sum = 0
        self.reward = 0
        self.mc.setPos([0,0,0])
               
        ball_state,ball_ind = self.get_ball_state()
        print('Ball state: 0,{},{}'.format(ball_state[1],ball_state[2]))
        
        self.currPos = [0,0,0,0,int(ball_state[1]),int(ball_state[2])]
        state_ind = np.argwhere(np.all(self.state_space==self.currPos,axis=(1))).ravel()
        if(len(state_ind)==0):
            print('Wrong state. Check rules for actions, or settings of step')
            return False
        
        self.currStInd = state_ind[0]
        
        self.currBall_UnitInd = ball_ind
                          
        self.curr_distance = self.min_dist * 10
        
        self.currVar = [0,self.currPos[1]-self.currPos[4],self.currPos[2]-self.currPos[5]]
        varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
        self.currVarInd = varid[0]
        
        return self.currStInd,self.currVarInd
    
    def simulate_state_env(self,red_ind,ball_ind):
        # method for launching new situation where robot or the ball are placed in other position
        # only for training stage due to simulation
        self.reward_sum = 0
        self.reward = 0
        
        ball_state = self.unit_state_space[ball_ind]
        red_state = self.unit_state_space[red_ind]
        
        self.currPos = [0,int(red_state[1]),int(red_state[2]),0,int(ball_state[1]),int(ball_state[2])]
        state_ind = np.argwhere(np.all(self.state_space==self.currPos,axis=(1))).ravel()
        if(len(state_ind)==0):
            print('Wrong state. Check rules for actions, or settings of step')
            return False
        
        self.currStInd = state_ind[0]
        
        self.currBall_UnitInd = ball_ind
                          
        self.curr_distance = self.min_dist * 10
        
        #experimental part
        self.currVar = [0,self.currPos[1]-self.currPos[4],self.currPos[2]-self.currPos[5]]
        varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
        self.currVarInd = varid[0]

        
        return self.currStInd,self.currVarInd
        
if __name__ == '__main__':
    env = ReinforcementControl()
    env.collect_coordinate_space()
        



    