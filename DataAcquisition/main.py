import sys
from pyVISUALIZATION.widget import *
import pySENSOR.api as API
import pySENSOR.xml as XML


def main_no_gui():
    sensor_thread = XML.load('settings.xml')
    #sensor_thread = API.RealSenseThread(1, 'RealSenseThread')
    motor_control = MCXML.load('settings.xml')
    sensor_thread.motor_control = motor_control
        
    message_bot = MBXML.load('settings.xml')
    if message_bot is not None:
            message_bot.sensor = sensor_thread
            message_bot.start()
            sensor_thread.bot = message_bot
    sensor_thread.start()
    sensor_thread.join()


def main_with_gui():
    initialize_opengl()
    app = QApplication(sys.argv)
    widget = RenderWidget()
    widget.show()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main_no_gui()
    #main_with_gui()
