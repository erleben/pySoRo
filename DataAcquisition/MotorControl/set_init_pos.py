import numpy as np


def find_init_pos(pipeline, mc, upper_b):
    frames = pipeline.wait_for_frames()
    color = frames.get_color_frame()
    non_deformed = np.asanyarray(color.get_data())
    pos = [0,0]
    return binarySearch(pipeline, mc, non_deformed, pos, upper_b)

    
    
def is_deformed(pipeline, non_deformed, thrs):
    frames = pipeline.wait_for_frames()
    color = frames.get_color_frame()
    pixels = np.asanyarray(color.get_data())
    II = np.abs(non_deformed.astype(int)-pixels.astype(int))
    d = II[:,:,1]>100
    print(np.sum(d))
    return np.sum(d)>10
    

## Binary search for initial position. Stop search when color-color_i< thresh

def binarySearch(pipeline, mc, non_deformed, pos, upper_b):
    for nr in range(1,2):
        while ~is_deformed(pipeline, non_deformed, 10):
            pos[nr] += 100
            mc.setPos(pos)
            if pos[nr]> upper_b[nr]:
                break
            
        h = pos[nr] + 100
        l = pos[nr] - 100
        while True:
            
            mid = np.ceil((h+l)/2)
            pos[nr] = mid
            mc.setPos(pos)
    
            # Stopping condition. 
            # Look into what happens when solution does not exist
            if l>=(h-2):
                break
            
            if is_deformed(pipeline, non_deformed, 10):
                h = mid
            else:
                l = mid
            
            #print(mid, l, h, pos,is_deformed(pipeline, non_deformed, 10))
    return pos