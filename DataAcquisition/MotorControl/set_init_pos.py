

def init_pos_binary(mc, pipeline):
    mc.setPos([0,0])
    frames = pipeline.wait_for_frames()
    color = frames.get_color_frame()
    
    ## Binary search for initial position. Stop search when color-color_i< thresh
    