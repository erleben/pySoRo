import sys
from pyVISUALIZATION.widget import *


def main():
    initialize_opengl()

    app = QApplication(sys.argv)
    widget = RenderWidget()
    widget.show()

    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
