from OpenGL.GL import *
import pyVISUALIZATION.core as CORE
import numpy as np


class Grid:

    def __init__(self):
        self.start_x = -10.0
        self.end_x = 10.0
        self.cells_x = 50
        self.start_z = -10.0
        self.end_z = 10.0
        self.cells_z = 50
        self.on = True


def create_wire_grid_data(grid_info):
    index_data = []
    vertex_data = []
    index = 0

    dx = (grid_info.end_x - grid_info.start_x) / grid_info.cells_x
    dz = (grid_info.end_z - grid_info.start_z) / grid_info.cells_z
    y = 0
    nx = 0
    ny = 1
    nz = 0

    for j in range(grid_info.cells_z+1):
        z = j*dz + grid_info.start_z
        for i in range(grid_info.cells_x):
            x0 = i*dx + grid_info.start_x
            x1 = x0 + dx
            vertex_data.append(x0)
            vertex_data.append(y)
            vertex_data.append(z)
            vertex_data.append(nx)
            vertex_data.append(ny)
            vertex_data.append(nz)
            index_data.append(index)
            index += 1
            vertex_data.append(x1)
            vertex_data.append(y)
            vertex_data.append(z)
            vertex_data.append(nx)
            vertex_data.append(ny)
            vertex_data.append(nz)
            index_data.append(index)
            index += 1

    for i in range(grid_info.cells_x+1):
        x = i*dx + grid_info.start_x
        for j in range(grid_info.cells_z):
            z0 = j*dz + grid_info.start_z
            z1 = z0 + dz
            vertex_data.append(x)
            vertex_data.append(y)
            vertex_data.append(z0)
            vertex_data.append(nx)
            vertex_data.append(ny)
            vertex_data.append(nz)
            index_data.append(index)
            index += 1
            vertex_data.append(x)
            vertex_data.append(y)
            vertex_data.append(z1)
            vertex_data.append(nx)
            vertex_data.append(ny)
            vertex_data.append(nz)
            index_data.append(index)
            index += 1

    vertex_array = np.array(vertex_data, dtype=np.float32)
    index_array = np.array(index_data, dtype=np.uint32)
    return vertex_array, index_array


class GridRender:

    def __init__(self, grid):
        vertex_data, index_data = create_wire_grid_data(grid)
        vertex_shader = CORE.Shader('pyVISUALIZATION/shaders/grid_vertex.glsl', GL_VERTEX_SHADER)
        fragment_shader = CORE.Shader('pyVISUALIZATION/shaders/grid_fragment.glsl', GL_FRAGMENT_SHADER)

        self.program = CORE.ShaderProgram([vertex_shader, fragment_shader])

        # 2018-01-04 Kenny: Change material or change/add more lights
        self.material = CORE.Material('grid')
        self.light_setup = CORE.LightSetup()
        self.light_setup.lights.append(CORE.SpotLight(0))

        self.vao = CORE.VAO()
        self.vbo = CORE.VBO(vertex_data, index_data, make_triangles=False)

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
            6*4,                         # Number of bytes between two vertices
            offset                       # Offset into current bound GL_ARRAY_BUFFER
            )

        self.uv_location = self.program.get_attribute_location('normal')
        glEnableVertexAttribArray(self.uv_location)
        offset = ctypes.c_void_p(3*4)
        glVertexAttribPointer(
            self.uv_location,           # Location of the attributes
            2,                          # Number of components per vertex
            GL_FLOAT,                   # Type of the components
            False,                      # Normalization
            6*4,                        # Number of bytes between two vertices
            offset                      # Offset into current bound GL_ARRAY_BUFFER
            )

        self.vao.unbind()

    def render(self, camera):
        view_matrix = camera.compute_view_matrix()
        projection_matrix = camera.compute_projection_matrix()
        model_matrix = np.identity(4, dtype=np.float32)

        self.program.use()
        self.program.set_uniform_matrix4('view_matrix', view_matrix)
        self.program.set_uniform_matrix4('projection_matrix', projection_matrix)
        self.program.set_uniform_matrix4('model_matrix', model_matrix)

        self.program.set_uniform_material(self.material)
        self.program.set_uniform_light_setup(self.light_setup)

        self.vao.bind()
        self.vbo.draw()
        self.vao.unbind()
        self.program.stop()
