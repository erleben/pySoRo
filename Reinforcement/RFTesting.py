# -*- coding: utf-8 -*-
"""
Created on Mon Dec 10 13:40:49 2018

@author: kerus
"""

import numpy as np
import ReinforcementControl as RC
from keras.layers import InputLayer, Dense
from keras.models import Sequential
from keras.models import load_model
from keras.models import model_from_json


env = RC.ReinforcementControl()
count_states = len(env.state_space)
count_actions = len(env.action_space)

weights_path = 'model_weights_2.h5'

#model = load_model(model_path)
# load json and create model
#json_file = open('model.json', 'r')
#loaded_model_json = json_file.read()
#json_file.close()
model = Sequential()
model.add(InputLayer(batch_input_shape=(1, count_states)))
model.add(Dense(60, activation='sigmoid'))
model.add(Dense(count_actions, activation='linear'))

#model = model_from_json(loaded_model_json)
#print(loaded_model)
# load weights into new model
model.load_weights(weights_path)
print("Loaded model weights from disk")
model.compile(loss='mse', optimizer='adam', metrics=['mae'])

done = False
r_sum = 0
s = env.reset_env()

while not done:
   a = np.argmax(model.predict(np.identity(count_states)[s:s + 1]))
   print('action: ',a)   
   s, r, done = env.new_step(a)
   r_sum += r
env.reset_env()
   
print('Final reward = {}'.format(r_sum))