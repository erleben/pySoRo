import serial
import time
import json


class Motorcontrol:

    def __init__(self):
        self.num_boards = 2
        self.position = [0]*self.num_boards
        self.portname = '/dev/cu.usbserial-DN02Z6PY'
        self.distribution = 'uniform'
        self.board_io = None

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

        time.sleep(1) #check if needed

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
        nextPosStr = self.positionGenerator()
        self.board_io.write(nextPosStr.encode('utf-8'))
        while self.board_io.in_waiting == 0:
            pass

        msg = self.board_io.readline().decode('utf-8')
        if msg == '0':
            raise RedboardException('Redboard could not read position')
        else:
            return nextPosStr

    def positionGenerator(self):
        if self.distribution == 'uniform':
            #increment position
            print('jo')

        pos = {'position': self.position}
        return json.dumps(pos)
    
    def setup(self):
        self.establishConnection()
        self.uploadConfig()
        self.sanityCheck()


class RedboardException(Exception):
    pass
