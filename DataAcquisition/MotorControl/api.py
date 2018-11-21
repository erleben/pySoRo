## This is the MotorControl class, which allows you to control each actuator without having to worry about the underlying communication protocols. 

import serial
import time
import json
import numpy as np


class Motorcontrol:

    def __init__(self):
        self.num_boards = 3
        self.position = [0]*self.num_boards
        self.portname = 'COM3'
        self.board_io = None
        self.positionGenerator = None
        self.offset = [0]*self.num_boards
        self.upper_b = [300]*self.num_boards

    def update(self):
        self.position = [0]*self.num_boards
        self.offset = [0]*self.num_boards

    def establishConnection(self):
        count = 0
        while True:
            try:
                board_io = serial.Serial(self.portname, 9600)
                time.sleep(2)
                break
            except serial.SerialException:
                pass
                count = count + 1
                if count % 7 == 0:
                    print("Check that portname is correct and that arduino is powered and connected. You can find the portname in Arduino IDE -> tools -> port")
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
        if isinstance(pos[0], list):
            self.position = pos[-1]
            positionStr = json.dumps({'path': pos})
        else:
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


    def setup(self):
        self.update()
        self.establishConnection()
        self.uploadConfig()
        self.sanityCheck()

class RedboardException(Exception):
    pass
