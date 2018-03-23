from MotorControl import api as MC
from matplotlib.pyplot import imshow, show, colorbar
import matplotlib.pyplot as plt
from skimage.io import imread

import numpy as np

mc = MC.Motorcontrol()

mc.setup()

def init_pos_binary(mc):
    mc.setPos([0,0])
    frames = pipeline.wait_for_frames()
    color = frames.get_color_frame()
    
    ## Binary search for initial position. Stop search when color-color_i< thresh
    


pos = [0,0]
max_pos = [100, 1000]

v = [55,666]
new_pos = pos



        

for nr in range(2):
    h = max_pos[nr]
    l = pos[nr]
    while True:
        
        mid = np.ceil((h+l)/2)
        pos[nr] = mid
        mc.setPos(pos)

        # Stopping condition. 
        # Look into what happens when solution does not exist
        if l>=(h-2):
            break
        
        if mid < v[nr]:
            l = mid
        if mid > v[nr]:
            h = mid
        
        new_pos[nr] = mid
        print(mid)
        
        
# np.sum(np.abs(AG.astype(int)-BG.astype(int))>120)

