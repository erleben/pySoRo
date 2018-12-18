# -*- coding: utf-8 -*-
"""
Created on Wed Dec  5 16:42:01 2018

@author: kerus
"""
import numpy as np
import ReinforcementControl as RC
from keras.layers import InputLayer, Dense
from keras.models import Sequential

env = RC.ReinforcementControl()
env.load_coordinate_space()
count_states = len(env.state_space)
count_unit_states = len(env.unit_state_space)
count_actions = len(env.action_space)

model = Sequential()
model.add(InputLayer(batch_input_shape=(1, count_states)))
model.add(Dense(600, activation='sigmoid'))
model.add(Dense(200, activation='sigmoid'))
model.add(Dense(count_actions, activation='linear'))
model.compile(loss='mse', optimizer='adam', metrics=['mae'])


# now execute the q learning
y = 0.95
decay_factor = 0.98
num_episodes = 1000
#r_avg_list = []

for ind_red in range(count_unit_states):
    # train for each possible ball position
    print("Robot state {} of {}\n".format(ind_red, count_unit_states))
    for ind_ball in range(count_unit_states):
        eps = 0.5
        print("Ball state {} of {}\n".format(ind_ball, count_unit_states))
        for i in range(num_episodes):
            s = env.simulate_state_env(ind_red,ind_ball)
            eps *= decay_factor
            
            done = False
            r_sum = 0
            while not done:
                if np.random.random() < eps:
                    a = np.random.randint(0, 4)
                    #print('action (random): ',a)
                else:
                    a = np.argmax(model.predict(np.identity(count_states)[s:s + 1]))
                    #print('action (model): ',a)
                
                new_s, r, done = env.new_step(a)
                target = r + y * np.max(model.predict(np.identity(count_states)[new_s:new_s + 1]))
                target_vec = model.predict(np.identity(count_states)[s:s + 1])[0]
                target_vec[a] = target
                #print('Target vector for fitting Keras model: ',target_vec)
                model.fit(np.identity(count_states)[s:s + 1], target_vec.reshape(-1, count_actions), epochs=1, verbose=0)
                s = new_s
                r_sum += r
            if i % 200 == 0:
                print("Episode {} of {}, reward sum = {}\n".format(i + 1, num_episodes,r_sum))
            #r_avg_list.append(r_sum / num_episodes)
        #print(r_avg_list)
    
#env.reset_env()

# serialize model to JSON
#model_json = model.to_json()
#with open("model.json", "w") as json_file:
#    json_file.write(model_json)
# serialize weights to HDF5
model.save_weights("model_weights_mult_init.h5")
print("Model is trained")
print("Saved model to disk")
