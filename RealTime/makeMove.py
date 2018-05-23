import matlab.engine as me
import sys
sys.path.append('../DataAcquisition')
from MotorControl import api as MC
import numpy as np

class makeMove():


    def __init__(self):
        self.mod_name = 'model.mat'
        self.max_pos = [450, 1500]
        self.min_pos = [0, 0]
        self.engine = me.start_matlab()
        self.model = self.engine.ModelLoader(self.mod_name)
        self.mc = MC.Motorcontrol()
        self.mc.setup()
    

    def getConfig(self, pts):
        alpha = self.engine.getAlpha(self.model, pts)
        conf = np.asanyarray(alpha)
        return conf
    
    
    def move(self, pts):
        alpha = self.getConfig(pts)
        a = np.round(list(alpha[0])).astype('int')
        a1 = np.minimum(self.max_pos, a)
        a2 = np.maximum(self.min_pos, a1).tolist()
        self.mc.setPos(a2)
        
    def end(self):
        self.mc.setPos([0,0])
        