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


# now execute the q learning
y = 0.95
decay_factor = 0.999
num_episodes = 500
eps = 0.5
#r_avg_list = []

# for i in episodes
# ind_red= random_ball_state
# ind_ball=random_unit_state
#  s = env.simulate_state_env(ind_red,ind_ball)
# oswin.krause@di.ku.dk

#about 2m 42s per 300 episodes
# about 22,6 hours per training
fin_count = count_var*num_episodes
#decrease from 400 to 63

for i in range(fin_count):
    # train for each possible ball position
        ind_red = randint(0,count_unit_states-1)
        ind_ball = randint(0,count_unit_states-1)
        #s = env.simulate_state_env(ind_red,ind_ball)
        s,var = env.simulate_state_env(ind_red,ind_ball)
            
        done = False
        r_sum = 0
        
        if(i % 1000 == 0):
            eps = 0.5
        
        while not done:
            if np.random.random() < eps:
                a = np.random.randint(0, 4)
                #print('action (random): ',a)
            else:
                a = np.argmax(model.predict(np.identity(count_var)[var:var + 1]))
                #a = np.argmax(model.predict(np.identity(count_states)[s:s + 1]))
                #print('action (model): ',a)
                
            #new_s, r, done = env.new_step(a)
            new_s, r,new_var, done = env.new_step(a)
            #target = r + y * np.max(model.predict(np.identity(count_states)[new_s:new_s + 1]))
            target = r + y * np.max(model.predict(np.identity(count_var)[new_var:new_var + 1]))
            #target_vec = model.predict(np.identity(count_states)[s:s + 1])[0]
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
            #print("eps = {}".format(eps))
        #r_avg_list.append(r_sum / num_episodes)
        #print(r_avg_list)
    
#env.reset_env()

# serialize model to JSON
#model_json = model.to_json()
#with open("model.json", "w") as json_file:
#    json_file.write(model_json)
# serialize weights to HDF5
model.save_weights("model_weights_rand_opt_collfree2.h5")
#work version
#model.save_weights("model_weights_rand_opt.h5")
print("Model is trained")
print("Saved model to disk")
