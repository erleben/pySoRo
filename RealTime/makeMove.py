import matlab.engine as me
import sys
sys.path.append('../DataAcquisition')
from MotorControl import api as MC
import numpy as np

class makeMove():


    def __init__(self):
        self.mod_name = 'model2.mat'
        self.max_pos = [300, 1750]
        self.min_pos = [0,0]
        self.engine = me.start_matlab()
        self.model = self.engine.ModelLoader(self.mod_name)
        self.mc = MC.Motorcontrol()
        self.mc.setup()
        self.grabPos = [0]
        self.currPos = [0,0]
    

    def getConfig(self, pts):
        print(pts)
        
        alpha = self.engine.getAlpha(self.model, pts)
        print(alpha)
        
        conf = np.asanyarray(alpha)
        print(conf)
        return conf
    
    def getConfig_path(self, pts):
        print(self.model, self.currPos, pts, pts, 0.025)
        alpha = self.engine.getAlphaPath(self.model, self.currPos, pts, pts, 0.03)
        conf = np.asanyarray(alpha)
        return conf

    
    def move(self, pts):
        alpha = self.getConfig(pts)
        a = np.round(list(alpha[0])).astype('int')
        a1 = np.minimum(self.max_pos, a)
        a2 = np.maximum(self.min_pos, a1).tolist()
        a2 = [0] + a2
        self.mc.setPos(a2)
        self.currPos =  a2
        
    def move_path(self, pts):
        alpha = self.getConfig_path(pts)
        print(alpha)
        if alpha != []:
            a = np.round(list(alpha)).astype('int')
            a1 = np.minimum(self.max_pos, a)
            a2 = np.maximum(self.min_pos, a1).tolist()
            print(a2)
            self.currPos =  a2[-1]
            a2 = [self.grabPos + p  for p in a2]
            print(a2)
            for i in range(int(np.ceil(len(a2)/6))):
                self.mc.setPos(a2[i*6:(i+1)*6])
            
    def goToStart(self):
        self.mc.setPos([0,0])
        self.currPos = [0,0]
        

        
    def end(self):
        self.mc.setPos([0,0,0])
        
