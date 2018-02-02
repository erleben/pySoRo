import serial
import json
import time

def establishConnection():
    while True:
        try:
            ser = serial.Serial('/dev/cu.usbserial-DN02Z6PY',9600)
            time.sleep(2)
            break
        except:
            pass
            time.sleep(1)

 # Confirm that Serial comunication is working
    ser.write(b'5')
    while ser.in_waiting==0:
        pass
    
    msg = ser.readline().decode("utf-8")
    
    if msg == 'Connected!\r\n':
        print('ok: A connected')
        return ser
    else:
        raise RedboardException("Could not confirm connection")
    
    
def sanityCheck(ser):
    while ser.in_waiting==0:
      pass
    
    msg = ser.readline().decode("utf-8")
    if (msg == '0\r\n'):
      raise RedboardException("Configurating the motors failed. Check hardware setup")
    else:
      print("Configuration successful!")
    
    
def uploadConfig(ser):
    config = getConfig()  
  
    
    time.sleep(1) 
    ser.write(config.encode("utf-8"))
    while ser.in_waiting==0:
        pass
    
    msg = ser.readline().decode("utf-8")
    
    if msg == 'Received!\r\n':
        print('ok: Arduino received data')
    else:
        raise RedboardException("Uploading configuration file failed")

def getConfig():
    config = {'NumBoards' : 2,
              'Board0' : {'StartStep' : 0,
                          'StepSize' : 40,
                          'StopStep' : 200},
              'Board1' : {'StartStep' : 0,
                          'StepSize' : 40,
                          'StopStep' : 200},
              'LastAlpha' : [0, 0]}
    return json.dumps(config)

    
def nextPos(ser): 
    ser.write(b'1');
    while ser.in_waiting==0:
      pass
    
    msg = ser.readline().decode("utf-8")
    if (msg == 'Done!\r\n'):
      raise RedboardException("Program has ended")
    else:
      return(msg)
      
def setup():
    ser = establishConnection()
    uploadConfig(ser)
    sanityCheck(ser)
    return ser
    
class RedboardException(Exception):
    pass
