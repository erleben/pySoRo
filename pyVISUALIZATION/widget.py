from OpenGL.GL import *
import numpy as np
import xml.etree.ElementTree as ET
from PyQt5.QtWidgets import QApplication
from PyQt5.QtWidgets import QOpenGLWidget
from PyQt5.QtCore import QTimer
from PyQt5.QtGui import QSurfaceFormat
from PyQt5.QtGui import QOpenGLVersionProfile
from PyQt5.QtCore import Qt
import pyUTILITY.util as UTIL
import pyVISUALIZATION.xml as XML
import pyVISUALIZATION.core as CORE
import pyVISUALIZATION.grid as GRID
import pyVISUALIZATION.point_cloud as PC

OpenGL.ERROR_CHECKING = True
OpenGL.CHECK_CONTEXT = True
OpenGL.ARRAY_SIZE_CHECKING = True
OpenGL.FULL_LOGGING = True


class RenderWidget(QOpenGLWidget):

    def __init__(self, point_cloud_render_lock, sensor_thread):
        super(QOpenGLWidget, self).__init__()
        self.resize(400, 400)
        self.m_update_timer = QTimer()
        self.m_update_timer.timeout.connect(self.timer_event)

        self.gl = 0

        self.camera = None
        self.grid = None
        self.clear_color = None

        self.sensor_thread = sensor_thread
        self.point_cloud_render_lock = point_cloud_render_lock
        self.point_cloud_render = None
        self.grid_render = None

        self.trackball = CORE.Trackball()   # A track ball used to convert mouse move events into rotations
        self.dolly_mode = False             # If on then up-down mouse moves make one moves back and forth towards target
        self.pan_mode = False               # If on then one translates in the screen space
        self.trackball_mode = False         # If on then one rotates around the camera center
        self.fpv_mode = False               # If on then one rotates around the camera position
        self.dolly_sensitivity = 0.025
        self.pan_sensitivity = 0.025
        self.anchor_x = None                # Original x-position when doing a mouse operation
        self.anchor_y = None                # Original t-position when doing a mouse operation
        self.anchor_eye = None
        self.anchor_center = None
        self.anchor_up = None
        self.height = None                 # Used to convert from window space into screen space when clicking inside the window

    def compute_normalized_device_coordinates(self, sx, sy):
        viewport = glGetFloatv(GL_VIEWPORT)
        ratio = self.devicePixelRatio()
        nx = (2.0 * ratio * sx) / viewport[2] - 1.0
        ny = (2.0 * ratio * sy) / viewport[3] - 1.0
        nx = max(-1.0, min(1.0, nx))
        ny = max(-1.0, min(1.0, ny))
        return nx, ny

    def initializeGL(self):
        version_profile = QOpenGLVersionProfile()
        version_profile.setVersion(4, 1)
        version_profile.setProfile(QSurfaceFormat.CoreProfile)
        self.gl = self.context().versionFunctions(version_profile)
        if not self.gl:
            raise RuntimeError("unable to apply OpenGL version profile")
        self.gl.initializeOpenGLFunctions()

        self.open_file('resources/default_scene.xml')

        self.point_cloud_render = PC.PointCloudRender(self.point_cloud_render_lock)
        self.sensor_thread.connect(self.point_cloud_render)

        glClearColor(self.clear_color[0], self.clear_color[1], self.clear_color[2], 0.0)
        glEnable(GL_DEPTH_TEST)
        glDepthFunc(GL_LESS)
        glEnable(GL_CULL_FACE)

    def paintGL(self):
        print('paintGL invoked')
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        if self.grid_render is not None:
            self.grid_render.render(self.camera)

        #if self.point_cloud_render is not None:
        #    self.point_cloud_render.render(self.camera)
        print('paintGL done')

    def resizeGL(self, width, height):
        glViewport(0, 0, width, height)
        self.height = height

    def mouseMoveEvent(self, e):
        x = e.x()
        y = self.height - e.y()

        nx, ny = self.compute_normalized_device_coordinates(x, y)

        left = (int(e.buttons()) & Qt.LeftButton) != 0
        middle = (int(e.buttons()) & Qt.MidButton) != 0
        right = (int(e.buttons()) & Qt.RightButton) != 0
        ctrl = (int(QApplication.keyboardModifiers()) & Qt.ControlModifier) != 0
        shift = (int(QApplication.keyboardModifiers()) & Qt.ShiftModifier) != 0
        alt = (int(QApplication.keyboardModifiers()) & Qt.AltModifier) != 0

        self.camera.update(self.anchor_eye, self.anchor_center, self.anchor_up)

        if self.dolly_mode:
            distance = self.dolly_sensitivity * (y - self.anchor_y)
            self.camera.dolly(-distance)

        if self.pan_mode:
            x_distance = self.pan_sensitivity * (x - self.anchor_x)
            y_distance = self.pan_sensitivity * (y - self.anchor_y)
            self.camera.pan(-x_distance, -y_distance)

        if self.trackball_mode:
            self.trackball.move_to(nx, ny)
#            self.trackball.move_to(x, y)
            self.camera.orbit(self.trackball.rotation_matrix.transpose())

        if self.fpv_mode:
            self.trackball.move_to(nx, ny)
            self.camera.rotate(self.trackball.rotation_matrix)

        if not self.m_update_timer.isActive():
            self.update()

    def mousePressEvent(self, e):
        x = e.x()
        y = self.height - e.y()

        nx, ny = self.compute_normalized_device_coordinates(x, y)

        left = (int(e.buttons()) & Qt.LeftButton) != 0
        middle = (int(e.buttons()) & Qt.MidButton) != 0
        right = (int(e.buttons()) & Qt.RightButton) != 0
        ctrl = (int(QApplication.keyboardModifiers()) & Qt.ControlModifier) != 0
        shift = (int(QApplication.keyboardModifiers()) & Qt.ShiftModifier) != 0
        alt = (int(QApplication.keyboardModifiers()) & Qt.AltModifier) != 0

        if alt and left:
            self.dolly_mode = True
        elif shift and left:
            self.pan_mode = True
            self.camera.center_locked = False
        elif ctrl and left:
            self.selection_mode = True
        elif left:
            self.trackball_mode = True
        elif right:
            self.fpv_mode = True
            self.camera.center_locked = False

        self.trackball.reset()
        self.anchor_x = x
        self.anchor_y = y
        self.anchor_eye = np.copy(self.camera.eye)
        self.anchor_center = np.copy(self.camera.center)
        self.anchor_up = np.copy(self.camera.up)

        if self.trackball_mode:
            self.trackball.click_at(nx, ny)

        if self.fpv_mode:
            self.trackball.click_at(nx, ny)

    def mouseReleaseEvent(self, e):
        #if self.selection_mode:
        #   self.select_tool.deselect()
        self.dolly_mode = False
        self.pan_mode = False
        self.trackball_mode = False
        self.fpv_mode = False
        self.camera.center_locked = True

    def timer_event(self):
        self.update()

    def open_file(self, filename):
        xml = ET.parse(filename)
        root = xml.getroot()

        camera, clear_color, grid = XML.load_from_elementtree(root)

        self.camera = camera
        self.clear_color = clear_color
        self.grid = grid

        if self.grid.on:
            self.grid_render = GRID.GridRender(self.grid)

        glClearColor(self.clear_color[0], self.clear_color[1], self.clear_color[2], 0.0)

        fps = 60-0
        self.m_update_timer.start(1000/fps)

        self.update()

    def save_file(self, filename):
        root = ET.Element('scene')

        XML.save_to_elementtree(self.camera,
                                   self.clear_color,
                                   self.grid,
                                   root
                                   )

        UTIL.xml_pretty_indent(root)
        tree = ET.ElementTree(root)
        tree.write(filename)


def initialize_opengl():
    format = QSurfaceFormat()
    format.setProfile(QSurfaceFormat.CoreProfile)
    format.setVersion(4, 5)
    format.setSamples(4)
    QSurfaceFormat.setDefaultFormat(format)

