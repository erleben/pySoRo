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
count_states = len(env.state_space)
count_actions = len(env.action_space)

model = Sequential()
model.add(InputLayer(batch_input_shape=(1, count_states)))
model.add(Dense(30, activation='sigmoid'))
model.add(Dense(count_actions, activation='linear'))
model.compile(loss='mse', optimizer='adam', metrics=['mae'])


# now execute the q learning
y = 0.95
eps = 0.5
decay_factor = 0.999
num_episodes = 10
r_avg_list = []

for i in range(num_episodes):
    s = env.reset()
    eps *= decay_factor
    if i % 2 == 0:
        print("Episode {} of {}".format(i + 1, num_episodes))
    done = False
    r_sum = 0
    while not done:
        if np.random.random() < eps:
            a = np.random.randint(0, 4)
        else:
            a = np.argmax(model.predict(np.identity(count_states)[s:s + 1]))
        new_s, r, done = env.new_step(a)
        target = r + y * np.max(model.predict(np.identity(count_states)[new_s:new_s + 1]))
        target_vec = model.predict(np.identity(count_states)[s:s + 1])[0]
        target_vec[a] = target
        model.fit(np.identity(count_states)[s:s + 1], target_vec.reshape(-1, count_actions), epochs=1, verbose=0)
        s = new_s
        r_sum += r
    r_avg_list.append(r_sum / 1000)
    
#INSTALL TENSOR FLOW ON ANACONDA