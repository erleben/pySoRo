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
        #file in which will be saved coordinates of each motor state
        #self.coord_state_path = 'coord_motor_space.csv'
        self.coord_state_path = 'coord_motor_space1.csv'
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
        
        #calculating variance space
        var_list = []
        for state in self.state_space:
            var_list.append((0,state[1]-state[4],state[2]-state[5]))
        self.variance_state_space = np.array(list(set(var_list)))
        
        #Experimental part
        #Here we can add new policy as element of the list
        self.policies = ['collision-free']
        #Experimental part
        
        self.action_space = [0,1,2,3] #['forward','backward','bend','unbend']
        #in the future probably we can add complex action like 'forward+bend'
        self.unit_coord_space = np.array([])
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
    
    def collect_coordinate_space(self):
        
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
        df = pd.read_csv(self.coord_state_path)
        self.unit_coord_space = np.array(df[['x','y']])
        return True
    
    def get_ball_state(self):
        
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
    
    def calculate_reward(self,curr_dist,new_dist):
        dif = curr_dist - new_dist
        #k = 0.3
        #reward = k*dif
        if(len(self.policies)>0):
            for policy in self.policies:
                #here we can add a realisation for each policy
                if (policy == 'collision-free'):
                    #if bending motor parameter for the ball less than bending motor parameter for the robot
                    if((self.currVar[1] >= 0) and (dif > 0)):
                        reward = 0.5
                    elif(dif > 0):
                        reward = 1
                    else:
                        reward = -1       
        else:    
            if(dif > 0):
                reward = 1
            else:
                reward = -1
        return reward
    
    def new_step(self,action,train=True):
        
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
        #print(new_pos,'new pos')
        #print(self.currPos,'curr pos')
        
        if(new_pos != self.currPos):
            state_ind = np.argwhere(np.all(self.state_space==new_pos,axis=(1))).ravel()
            
            if(len(state_ind)==0):
                print('Wrong state. Check rules for actions, or settings of step')
                return False
        
            state_ind = state_ind[0]
            
            #experimental part
            self.currVar = [0,new_pos[1]-new_pos[4],new_pos[2]-new_pos[5]]
            varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
            self.currVarInd = varid[0]
            #experimental part
            
            if(train):
                tip_u_state_ind = np.argwhere(np.all(self.unit_state_space==new_pos[:3],axis=(1))).ravel()
                tip_u_state_ind = tip_u_state_ind[0]
                
                coord_tip = self.unit_coord_space[tip_u_state_ind]
                coord_ball = self.unit_coord_space[self.currBall_UnitInd]
                
                new_distance = np.sqrt(((coord_tip[0]-coord_ball[0])**2)+((coord_tip[1]-coord_ball[1])**2))
                
                rew = self.calculate_reward(self.curr_distance,new_distance)
                
            else:
                self.mc.setPos(new_pos[:3])
                cam_data = self.cam_stream.get_data()
                if(cam_data):
                    new_distance = cam_data[2]
                    rew = self.calculate_reward(self.curr_distance,new_distance)
                    #here we can add check for changing position of the ball !!!
                    
            
            self.curr_distance = new_distance
                    
            #if(new_distance<=self.min_dist):
            #    self.done = True
            if(new_pos[:3] == new_pos[3:]):
                self.done = True
            
            self.currPos = new_pos
            self.currStInd = state_ind
            
            
        else:
            rew = -5
        if(not(train)):
            print(self.currStInd,rew,self.done)
            print(self.currPos)
        
        return self.currStInd,rew,self.currVarInd, self.done
    
    def new_situation_env(self):
        
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
        
        #experimental part
        self.currVar = [0,self.currPos[1]-self.currPos[4],self.currPos[2]-self.currPos[5]]
        varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
        self.currVarInd = varid[0]
        #experimental part 
            
        #if(new_distance<=self.min_dist):
        #    self.done = True
        
        return self.currStInd,self.currVarInd
    
    def reset_env(self):
        
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
        
        #experimental part
        self.currVar = [0,self.currPos[1]-self.currPos[4],self.currPos[2]-self.currPos[5]]
        varid = np.argwhere(np.all(self.variance_state_space==self.currVar,axis=(1))).ravel()
        self.currVarInd = varid[0]
        #experimental part  
            
        #if(new_distance<=self.min_dist):
        #    self.done = True
        
        return self.currStInd,self.currVarInd
    
    def simulate_state_env(self,red_ind,ball_ind):
        
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
        #experimental part    
        
        #if(new_distance<=self.min_dist):
        #    self.done = True
        
        return self.currStInd,self.currVarInd
        
if __name__ == '__main__':
    env = ReinforcementControl()
    env.collect_coordinate_space()
        
#env = ReinforcementControl()
#env.load_coordinate_space()
#env.collect_coordinate_space()
#env.mc.setPos([0,0,750])
#print('plus step 1')
#time.sleep(5)
#env.mc.setPos([0,0,375])
#print('minus step 2')
#print(env.reset_env())
#count_states = len(env.state_space)
#count_actions = len(env.action_space)
#print(RF.state_space)
#print(RF.action_space)


    