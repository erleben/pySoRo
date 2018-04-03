import numpy as np
from sklearn.cluster import KMeans

class PathSampling:

    def __init__(self):
        self.num_boards = 2
        self.minpos = [0]*self.num_boards
        self.maxpos = [300]*self.num_boards
        self.currpath = 0
        self.num_paths = 100
        self.num_iter = 1000
        (self.kmodel, self.RP) = self.getPathStart()
        self.points_in_section = self.RP[self.kmodel.predict(self.RP)==self.currpath]
        self.currpt = 0

    def update(self):
        (self.kmodel, self.RP) = self.getPathStart()
        self.points_in_section = [self.kmodel.cluster_centers_[self.currpath,:], self.RP[self.kmodel.predict(self.RP)==self.currpath]]
    
    def setMinPos(self, start_p):
        self.minpos = start_p
        
    def setMaxPos(self, stop_p):
        self.maxpos = stop_p
        
    def setNumBoards(self, num_b):
        self.num_boards = num_b
        
    def setNumPaths(self, step_s):
        self.stepsize = step_s
        
        
    def increment(self):
        isDone = False
                
        position = self.points_in_section[self.currpt,:]
        
        cpath = self.currpath
        self.currpt += 1
        if self.currpt >= self.points_in_section.shape[0]:
            self.currpt = 0
            self.currpath += 1
            if self.currpath >= self.num_paths:
                isDone = True
            else:
                self.points_in_section = self.RP[self.kmodel.predict(self.RP)==self.currpath]
                
        return (position, cpath, isDone)


    
    def getPathStart(self):
        roi = np.subtract(self.maxpos, self.minpos)
        RP = np.round(np.add(np.multiply(np.random.rand(self.num_iter, self.num_boards), roi), self.minpos))
        model = KMeans(self.num_paths)
        model.fit(RP)
        return (model, RP)
        
     
# Del = Delaunay(pp.kmodel.cluster_centers_)
# Ne=Del.vertices[np.logical_and((Del.vertices == 1), np.logical_not(Del.vertices == -1)).any(1)]
#Ne=Del.neighbors[np.logical_and((Del.neighbors == 183), np.logical_not(Del.neighbors == -1)).any(1)]
        
        