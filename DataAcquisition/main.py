import pySENSOR.xml as XML
import MotorControl.xml as MCXML

# The xml modules are used to
# 1) initialize the main thread and motor control
# 2) parse settings.xml and set corresponding values

if __name__ == '__main__':
    sensor_thread = XML.load('settings.xml')
    motor_control = MCXML.load('settings.xml')
    sensor_thread.motor_control = motor_control
    sensor_thread.start()
    sensor_thread.join()
