import sys
from pyVISUALIZATION.widget import *
import pySENSOR.api as API


def main_no_gui():
    sensor_thread = API.RealSenseThread(1, 'RealSenseThread')
    sensor_thread.start()
    sensor_thread.join()

def main_with_gui():
    initialize_opengl()
    app = QApplication(sys.argv)
    widget = RenderWidget()
    widget.show()
    sys.exit(app.exec_())

if __name__ == '__main__':
    #main_no_gui()
    main_with_gui()
