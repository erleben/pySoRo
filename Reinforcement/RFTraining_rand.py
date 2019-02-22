# -*- coding: utf-8 -*-
"""
Created on Wed Jan 16 13:06:33 2019

@author: kerus
"""

# -*- coding: utf-8 -*-
"""
Created on Wed Dec  5 16:42:01 2018

@author: kerus
"""
from random import randint
import numpy as np
import ReinforcementControl as RC
from keras.layers import InputLayer, Dense
from keras.models import Sequential

env = RC.ReinforcementControl()
env.load_coordinate_space()
count_states = len(env.state_space)
count_unit_states = len(env.unit_state_space)
count_actions = len(env.action_space)

count_var = len(env.variance_state_space)

model = Sequential()
#model.add(InputLayer(batch_input_shape=(1, count_states)))
model.add(InputLayer(batch_input_shape=(1, count_var)))
model.add(Dense(200, activation='sigmoid'))
model.add(Dense(50, activation='sigmoid'))
model.add(Dense(count_actions, activation='linear'))
model.compile(loss='mse', optimizer='adam', metrics=['mae'])


y = 0.95
decay_factor = 0.999
num_episodes = 600
eps = 0.5

fin_count = count_var*num_episodes
#decrease from 400 to 63

for i in range(fin_count):
    # train for each possible ball position
        ind_red = randint(0,count_unit_states-1)
        ind_ball = randint(0,count_unit_states-1)
        s,var = env.simulate_state_env(ind_red,ind_ball)
     
        done = False
        r_sum = 0
        
        if(i % 1000 == 0):
            eps = 0.5
        
        while not done:
            if np.random.random() < eps:
                a = np.random.randint(0, 4)
            else:
                a = np.argmax(model.predict(np.identity(count_var)[var:var + 1]))
                
            new_s, r,new_var, done = env.new_step(a)
            target = r + y * np.max(model.predict(np.identity(count_var)[new_var:new_var + 1]))
            target_vec = model.predict(np.identity(count_var)[var:var + 1])[0]
            target_vec[a] = target
            #model.fit(np.identity(count_states)[s:s + 1], target_vec.reshape(-1, count_actions), epochs=1, verbose=0)
            model.fit(np.identity(count_var)[var:var + 1], target_vec.reshape(-1, count_actions), epochs=1, verbose=0)
            s = new_s
            var = new_var
            r_sum += r
        eps *= decay_factor
        if i % 300 == 0:
            print("Episode {} of {},fing_state = {}, ball_state = {}, reward sum = {}\n".format(i + 1, fin_count,ind_red,ind_ball, r_sum))

    
#env.reset_env()


# serialize weights to HDF5
#work version
#model.save_weights("model_weights_rand_opt_collfree2.h5")
model.save_weights("_".join([env.model,"model_weights"]))

print("Model is trained")
print("Saved model to disk")
