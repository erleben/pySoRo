import serial
import time
import json
import numpy as np


class Motorcontrol:

    def __init__(self):
        self.num_boards = 2
        self.position = [0]*self.num_boards
        self.portname = '/dev/cu.usbserial-DN02Z6PY'
        self.board_io = None
        self.positionGenerator = None
        self.pipeline = None
        self.offset = [0]*self.num_boards
        self.upper_b = [300]*self.num_boards

    def update(self):
        self.position = [0]*self.num_boards
        self.offset = [0]*self.num_boards



    def establishConnection(self):
        while True:
            try:
                board_io = serial.Serial(self.portname, 9600)
                time.sleep(2)
                break
            except serial.SerialException:
                pass
                time.sleep(1)

        self.board_io = board_io
        # Confirm that Serial comunication is working
        self.board_io.write(b'5')
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')

        if msg == 'Connected!\r\n':
            print('ok: A connected')
        else:
            raise RedboardException('Could not confirm connection')

    def sanityCheck(self):
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')
        if msg == '0\r\n':
            raise RedboardException('Motor config failed. Check hardware setup')
        else:
            print('Configuration successful!')

    def uploadConfig(self):
        config = self.makeConfig()
        
        self.board_io.write(config.encode('utf-8'))
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')

        if msg == 'Received!\r\n':
            print('ok: Arduino received data')
        else:
            raise RedboardException('Uploading configuration file failed')

# This is a separate function in case we want
# to add more to the config later
    def makeConfig(self):
        config = {}
        config['num_boards'] = self.num_boards
        return json.dumps(config)


    def nextPos(self):
        (pos, isDone) = self.positionGenerator.increment()
        
        self.position = np.add(pos, self.offset).tolist()
        
        if isDone:
            self.setPos(self.offset)
            raise RedboardException('Final position reached')
            
        positionStr = json.dumps({'position': self.position})
        self.board_io.write(positionStr.encode('utf-8'))
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')
        if msg == '0\r\n':
            raise RedboardException('Redboard could not read position')
        else:
            return pos

    def setPos(self, pos):
           
        self.position = pos
        positionStr = json.dumps({'position': self.position})
        self.board_io.write(positionStr.encode('utf-8'))
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')
        if msg == '0\r\n':
            raise RedboardException('Redboard could not read position')
        else:
            return self.position
        
        
    def find_init_pos(self):
        frames = self.pipeline.wait_for_frames()
        color = frames.get_color_frame()
        non_deformed = np.asanyarray(color.get_data())
        pos = [0]*self.num_boards
        return self.binarySearch(non_deformed, pos)

    
    
    def is_deformed(self, non_deformed, thrs):
        frames = self.pipeline.wait_for_frames()
        color = frames.get_color_frame()
        pixels = np.asanyarray(color.get_data())
        II = np.abs(non_deformed.astype(int)-pixels.astype(int))
        d = II[:,:,1]>100
        return np.sum(d)>10
        
    
    ## Binary search for initial position. Stop search when color-color_i< thresh
    
    def binarySearch(self, non_deformed, pos):
        for nr in range(1,2):
            while ~self.is_deformed(non_deformed, 10):
                pos[nr] += 100
                self.setPos(pos)
                if pos[nr]> self.upper_b[nr]:
                    break
                
            h = pos[nr] + 100
            l = pos[nr] - 100
            while True:
                
                mid = int(np.ceil((h+l)/2))
                pos[nr] = mid
                self.setPos(pos)
        
                # Stopping condition. 
                # Look into what happens when solution does not exist
                if l>=(h-2):
                    break
                
                if self.is_deformed(non_deformed, 10):
                    h = mid
                else:
                    l = mid
                
        return pos


    def setup(self):
        self.update()
        self.establishConnection()
        self.uploadConfig()
        self.sanityCheck()
        if self.pipeline is not None:
            self.offset = self.find_init_pos()

class RedboardException(Exception):
    pass
