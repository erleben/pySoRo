import sys
import threading
import pySENSOR.api as API
from pyVISUALIZATION.widget import *


def main():
    point_cloud_render_lock = threading.Lock()
    sensor_thread = API.RealSenseThread(1, 'RealSenseThread')

    initialize_opengl()

    app = QApplication(sys.argv)
    widget = RenderWidget(point_cloud_render_lock, sensor_thread)
    sensor_thread.start()
    widget.show()

    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
