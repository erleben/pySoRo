# -*- coding: utf-8 -*-
"""
Created on Wed Nov 21 16:09:55 2018

@author: kerus
"""

#import pyrealsense2 as rs
import numpy as np
import cv2
import sys
sys.path.extend(['../'])
#import time
#import matplotlib.pyplot as plt
#from matplotlib.colors import hsv_to_rgb
import ReinforcementControl as RC

from keras.layers import InputLayer, Dense
from keras.models import Sequential
#from keras.models import load_model
#from keras.models import model_from_json

env = RC.ReinforcementControl()
env.load_coordinate_space()
count_states = len(env.state_space)
count_unit_states = len(env.unit_state_space)
count_actions = len(env.action_space)

weights_path = 'model_weights_full_2.h5'

# this model is pupposed to be the same as was in training stage !!!
model = Sequential()
model.add(InputLayer(batch_input_shape=(1, count_states)))
model.add(Dense(600, activation='sigmoid'))
model.add(Dense(200, activation='sigmoid'))
model.add(Dense(count_actions, activation='linear'))

model.load_weights(weights_path)
print("Loaded model weights from disk")
model.compile(loss='mse', optimizer='adam', metrics=['mae'])


isPaused = False

phase = 0



#s = env.reset_env()
# keep looping 
try:
    while True:
    	# grab the current frame
        cimg = env.cam_stream.get_data(True)
        if(type(cimg) is not bool):       
            cv2.imshow('detected circles',cimg)
                       
        key = cv2.waitKey(1) & 0xFF
        
    	# if the 'q' key is pressed, stop the loop
        if key == ord("q"):
            env.reset_env()
            break
        if key == ord("m"):
            done = False
            r_sum = 0
            if(phase > 0):
                s = env.new_situation_env()
            else:                
                s = env.reset_env()           
            while not done:
               a = np.argmax(model.predict(np.identity(count_states)[s:s + 1]))
               print('action: ',a)   
               s, r, done = env.new_step(a,False)
               r_sum += r
            print('Final reward = {}'.format(r_sum))
            phase += 1
            

# cleanup the camera and close any open windows
finally:
    cv2.destroyAllWindows()
    env.cam_stream.finish_stream()
    #pipeline.stop()
