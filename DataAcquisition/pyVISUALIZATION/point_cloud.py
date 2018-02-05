from OpenGL.GL import *
import pyVISUALIZATION.core as CORE
import pyVISUALIZATION.texture as TEXTURE
from math import fabs
import numpy as np
import threading


OpenGL.ERROR_CHECKING = True
OpenGL.CHECK_CONTEXT = True
OpenGL.ARRAY_SIZE_CHECKING = True
OpenGL.FULL_LOGGING = True


class PointCloudVBO:

    def __init__(self):
        self.max_count = 1000000
        self.count = 0

        vertex_nbytes = self.max_count*4*5
        index_nbytes = self.max_count*4

        self.vbo = glGenBuffers(1)
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBufferData(GL_ARRAY_BUFFER, vertex_nbytes, None, GL_DYNAMIC_DRAW)

        self.ibo = glGenBuffers(1)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, index_nbytes, None, GL_DYNAMIC_DRAW)

    def bind(self):
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)

    def unbind(self):
        glBindBuffer(GL_ARRAY_BUFFER, 0)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

    def draw(self):
        glPointSize(10.0)
        glDrawArrays(GL_POINTS, 0, self.count)

    def update(self, vertex_array):
        #vertex_data = []
        #index_data = []
        #index = 0
        #for i in range(len(coordinates)):
        #    if fabs(coordinates[i][2]) > 0.0:
        #        vertex_data.append(coordinates[i][0])
        #        vertex_data.append(coordinates[i][1])
        #        vertex_data.append(coordinates[i][2])
        #        vertex_data.append(uvs[i][0])
        #        vertex_data.append(uvs[i][1])
        #        index_data.append(index)
        #        index += 1
        #vertex_array = np.array(vertex_data, dtype=np.float32)
        #index_array = np.array(index_data, dtype=np.uint32)
        self.count = vertex_array.shape[0]
        index_array = np.arange(self.count, dtype=np.uint32)

        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)
        glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_array.nbytes, vertex_array)
        glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, 0, index_array.nbytes, index_array)


class PointCloudRender:

    def __init__(self):
        self.vertex_array = None
        self.width = None
        self.height = None
        self.external_format = None
        self.external_type = None
        self.pixels = None
        self.image = None
        self.should_upload = False
        self.render_lock = threading.Lock()

        vertex_shader = CORE.Shader('pyVISUALIZATION/shaders/point_cloud_vertex.glsl', GL_VERTEX_SHADER)
        fragment_shader = CORE.Shader('pyVISUALIZATION/shaders/point_cloud_fragment.glsl', GL_FRAGMENT_SHADER)

        self.program = CORE.ShaderProgram([vertex_shader, fragment_shader])
        self.vao = CORE.VAO()
        self.vbo = PointCloudVBO()

        self.program.use()
        self.vao.bind()
        self.vbo.bind()

        self.position_location = self.program.get_attribute_location('position')
        glEnableVertexAttribArray(self.position_location)
        offset = ctypes.c_void_p(0)
        glVertexAttribPointer(
            self.position_location,      # Location of the attributes
            3,                           # Number of components per vertex
            GL_FLOAT,                    # Type of the components
            False,                       # Normalization
            5*4,                         # Number of bytes between two vertices
            offset                       # Offset into current bound GL_ARRAY_BUFFER
            )

        self.uv_location = self.program.get_attribute_location('uv')
        glEnableVertexAttribArray(self.uv_location)
        offset = ctypes.c_void_p(3*4)
        glVertexAttribPointer(
            self.uv_location,           # Location of the attributes
            2,                          # Number of components per vertex
            GL_FLOAT,                   # Type of the components
            False,                      # Normalization
            5*4,                        # Number of bytes between two vertices
            offset                      # Offset into current bound GL_ARRAY_BUFFER
            )

        self.vao.unbind()

    def render(self, camera):
        with self.render_lock:
            if self.should_upload:
                self.vbo.update(self.vertex_array)
                if self.image is None:
                        self.image = TEXTURE.Texture2D(self.width,
                                                   self.height,
                                                   self.external_format,
                                                   self.external_type,
                                                   self.pixels
                                                   )
                else:
                    self.image.update(self.width,
                                      self.height,
                                      self.external_format,
                                      self.external_type,
                                      self.pixels
                                    )
                self.should_upload = False

        view_matrix = camera.compute_view_matrix()
        projection_matrix = camera.compute_projection_matrix()
        model_matrix = np.identity(4, dtype=np.float32)

        self.program.use()
        self.program.set_uniform_matrix4('view_matrix', view_matrix)
        self.program.set_uniform_matrix4('projection_matrix', projection_matrix)
        self.program.set_uniform_matrix4('model_matrix', model_matrix)

        if self.image is not None:
            glActiveTexture(GL_TEXTURE0)
            self.image.bind()
            self.program.set_uniform_int("colormap", 0)

        self.vao.bind()
        self.vbo.draw()
        self.vao.unbind()
        self.program.stop()

    def copy_data(self, vertex_array, width, height, external_format, external_type, pixels):
        with self.render_lock:
            self.vertex_array = np.copy(vertex_array)
            self.pixels = np.copy(pixels)
            self.width = width
            self.height = height
            self.external_format = external_format
            self.external_type = external_type
            self.should_upload = True
