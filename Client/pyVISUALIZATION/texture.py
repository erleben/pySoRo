from OpenGL.GL import *
import pyVISUALIZATION.core as CORE
import PIL.Image as Image
import numpy as np


class Texture2D:

    def __init__(self, width, height, external_format, external_type, pixels):
        self.texture_ID = glGenTextures(1)
        glBindTexture(GL_TEXTURE_2D, self.texture_ID)

        glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
        glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
        border_color = [0.8, 0.8, 0.8, 1.0]
        glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border_color)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER)
        #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
        #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
        #glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

        glTexImage2D(
            GL_TEXTURE_2D,
            0,
            GL_RGB,
            width,
            height,
            0,
            external_format,
            external_type,
            pixels
            )

        glGenerateMipmap(GL_TEXTURE_2D)

    def bind(self):
        glBindTexture(GL_TEXTURE_2D, self.texture_ID)

    def unbind(self):
        glBindTexture(GL_TEXTURE_2D, 0)

    def update(self, width, height, external_format, external_type, pixels):
        glBindTexture(GL_TEXTURE_2D, self.texture_ID)
        glTexSubImage2D(GL_TEXTURE_2D,
                        0,
                        0,
                        0,
                        width,
                        height,
                        external_format,
                        external_type,
                        pixels
                        )
        glGenerateMipmap(GL_TEXTURE_2D)


def create_texture_quad_data(x, y, width, height):
    z = 0
    vertex_data = np.array([ x,       y,        z, 0.0, 0.0,
                             x+width, y,        z, 1.0, 0.0,
                             x+width, y+height, z, 1.0, 1.0,
                             x+width, y+height, z, 1.0, 1.0,
                             x,       y+height, z, 0.0, 1.0,
                             x,       y,        z, 0.0, 0.0], dtype=np.float32)

    index_data = np.array([0, 1, 2, 3, 4, 5], dtype=np.uint32)
    return vertex_data, index_data


def load_texture_from_file(filename):
    img = Image.open(filename)
    img.load()
    #pixels = np.divide(np.asarray(img, dtype=np.float32), 255.0)
    #external_format = GL_RGBA
    #external_type = GL_FLOAT

    pixels = np.asarray(img, dtype=np.uint8)
    external_format = GL_RGBA
    external_type = GL_UNSIGNED_BYTE

    texture = Texture2D(img.width, img.height, external_format, external_type, pixels)
    return texture


class TextureRender:

    def __init__(self, texture):
        self.texture = texture

        vertex_shader = CORE.Shader('pyVISUALIZATION/shaders/texture_vertex.glsl', GL_VERTEX_SHADER)
        fragment_shader = CORE.Shader('pyVISUALIZATION/shaders/texture_fragment.glsl', GL_FRAGMENT_SHADER)
        program = CORE.ShaderProgram([vertex_shader, fragment_shader])
        self.program = program

        vertex_data, index_data = create_texture_quad_data(-1.0, -1.0, 2.0, 2.0)

        self.vao = CORE.VAO()
        self.vbo = CORE.VBO(vertex_data, index_data, elements_per_vertex=5)

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

    def render(self):
        self.program.use()

        glActiveTexture(GL_TEXTURE0)
        self.texture.bind()
        self.program.set_uniform_int("image", 0)

        self.vao.bind()
        self.vbo.draw()
        self.vao.unbind()

        self.texture.unbind()
        self.program.stop()
