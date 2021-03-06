import numpy as np

class Uniform:

    def __init__(self):
        self.num_boards = 3
        self.stepsize = [2]*self.num_boards
        self.startpos = [0]*self.num_boards
        self.stoppos = [10]*self.num_boards
        self.counter = np.divide(self.startpos, self.stepsize).astype('int')

    # You have to update the counter if you change startpos or stepsize 
    # from the default
    
    def setStartPos(self, start_p):
        self.startpos = start_p
        
    def setStopPos(self, stop_p):
        self.stoppos = stop_p
        
    def setNumBoards(self, num_b):
        self.num_boards = num_b
        
    def setStepSize(self, step_s):
        self.stepsize = step_s
        
        
    def update(self):
        self.counter = np.divide(self.startpos, self.stepsize).astype('int')
        
    def getPos(self):
        position = np.multiply(self.counter, self.stepsize).tolist()
        isDone = (position[0] > self.stoppos[0])
        return (position, isDone)

    # Increments a odometer where each entry is the position of a motor 
    # divided by the stepsize
    def incrementCounter(self):
        self.counter[self.num_boards - 1] += 1
        
        for bd in range(self.num_boards-1, 0, -1):
            if self.counter[bd]*self.stepsize[bd] > self.stoppos[bd]:
                self.counter[bd] = self.startpos[bd]
                self.counter[bd-1] += 1
                
    def increment(self):
        pos = self.getPos()
        self.incrementCounter()
        return pos