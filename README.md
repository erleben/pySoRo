
# MotorCom
For this project, we are using a redboard to controll a chain of motor drivers. The redboard is programmed with arduino and runs a simplified version of C++. We use the serial interface (usb) between the computer and the redboard to synchronize the camera capture and the motor positions.

### Prerequisites
```
pip install josn
```
```
pip install pyserial
```
In the Arduino IDE package manager, add Arduino json

### Hardware setup
See https://learn.sparkfun.com/tutorials/getting-started-with-the-autodriver---v13?_ga=2.96138906.787908599.1517820663-1889163370.1513463701

## Redboard side
SerialCom is the program that will run on the redboard. 
Arduino programs consist of two parts. setup(), which will only be run once, and loop() which will run forever. In the setup part, the redboard constructs the nercessary variables for MAX_BOARDS number of boards. Then it sets up the serial interface, and waits for a ready signal from the computer. Then it starts listening for a json file from the serial interface. 

The json file contains the following information:

NUM_BOARDS: The number of boards that are set up in a chain
StartStep: The start position of the motor. Position 0 is the position of the motor at startup.
StepSize: The number of steps to be taken pr round. One step is 1.8 degrees, so 200 steps is one full revolution. 
StopStep: The end position of the motor.
LastAlpha: The position we want to start the motors from. For instance, if the program was ended in the midle of execution due to some unforseen error, we can just set LastAlpha to be the last recorded position.

The boards are then confugured and a simple sanity check is performed whether the configuration was successful. 

One loop goes as follows. The redboard listens for a ready signal. When it arrives, it sets the motors in the current position. Then it increments the position variable and sends a signal over the serial to tell the client that the object is ready for capture.
 
## Computer side
Client is the program that runs on the user side. 
The user can modify the configuration data that will be sent as a json sting to the redboard in config.txt.

Assuming correct harware setup, there are only two functions the user needs to know.
```
ser=setup()
```

This function establish a connection between the computer and the redboard, uploads the configuration file and asserts that the motors are working. ser is the serial interface we use to communicate with the redboard.
    
```
msg = nextPos(ser)
```
Increments the position on the motors. msg is a string containing the motor positions

