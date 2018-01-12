from OpenGL.GL import *
import os.path
import numpy as np
import pyMESH.mesh as MESH
import pyMATH.quaternion as Q
import pyMATH.vector3 as V3


class Shader:

    def __init__(self, filename, type):
        self.shader = glCreateShader(type)
        self.source = open(filename, "r").read()
        glShaderSource(self.shader, self.source)
        glCompileShader(self.shader)
        if glGetShaderiv(self.shader, GL_COMPILE_STATUS) != GL_TRUE:
            raise RuntimeError(glGetShaderInfoLog(self.shader))


class ShaderProgram:

    def __init__(self, shaders):
        self.program = glCreateProgram()
        for item in shaders:
            glAttachShader(self.program, item.shader)
        glLinkProgram(self.program)
        glValidateProgram(self.program)
        if glGetProgramiv(self.program, GL_LINK_STATUS) != GL_TRUE:
            raise RuntimeError(glGetProgramInfoLog(self.program))

    def use(self):
        glUseProgram(self.program)

    def stop(self):
        glUseProgram(0)

    def get_attribute_location(self, attribute_name):
        return glGetAttribLocation(self.program, attribute_name)

    def set_uniform_matrix4(self, variable_name, matrix4):
        location = glGetUniformLocation(self.program, variable_name)
        # OpenGL assumes that values are given in column major order.
        # However, we use numpy which stores values as row major
        # order. So we ask OpenGL to transpose the matrix.
        glUniformMatrix4fv(location, 1, GL_TRUE, matrix4)

    def set_uniform_vector3(self, variable_name, vector3):
        location = glGetUniformLocation(self.program, variable_name)
        glUniform3fv(location, 1, vector3)

    def set_uniform_uint(self, variable_name, value):
        location = glGetUniformLocation(self.program, variable_name)
        glUniform1ui(location, value)

    def set_uniform_int(self, variable_name, value):
        location = glGetUniformLocation(self.program, variable_name)
        glUniform1i(location, value)

    def set_uniform_float(self, variable_name, value):
        location = glGetUniformLocation(self.program, variable_name)
        glUniform1f(location, value)

    def set_uniform_light_setup(self, light_setup):
        self.set_uniform_int('number_of_lights', len(light_setup.lights))
        for light in light_setup.lights:
            self.set_uniform_vector3('lights['+str(light.index)+'].position', light.position)
            self.set_uniform_vector3('lights['+str(light.index)+'].target', light.target)
            self.set_uniform_float('lights['+str(light.index)+'].cutoff_angle', light.cutoff_angle)
            self.set_uniform_float('lights['+str(light.index)+'].attenuation', light.attenuation)
            self.set_uniform_vector3('lights['+str(light.index)+'].Ia', light.Ia)
            self.set_uniform_vector3('lights['+str(light.index)+'].Id', light.Id)
            self.set_uniform_vector3('lights['+str(light.index)+'].Is', light.Is)

    def set_uniform_material(self, material):
        self.set_uniform_float('material.wire_thickness', material.wire_thickness)
        self.set_uniform_vector3('material.wire_color', material.wire_color)
        self.set_uniform_vector3('material.Ks', material.Ks)
        self.set_uniform_vector3('material.Kd', material.Kd)
        self.set_uniform_vector3('material.Ka', material.Ka)
        self.set_uniform_float('material.specular_exponent', material.specular_exponent)


class VAO:

    def __init__(self):
        self.vao = glGenVertexArrays(1)
        glBindVertexArray(self.vao)

    def bind(self):
        glBindVertexArray(self.vao)

    def unbind(self):
        glBindVertexArray(0)


class VBO:

    def __init__(self, vertices, indices, make_static=True, make_triangles=True, elements_per_vertex=6):
        print('Creating new VBO')
        self.is_triangles = make_triangles
        self.is_static = make_static
        self.elements_per_vertex = elements_per_vertex
        self.vertex_count = vertices.size / elements_per_vertex
        self.index_count = indices.size
        self.vbo = glGenBuffers(1)
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        if make_static:
            glBufferData(GL_ARRAY_BUFFER, vertices.nbytes, vertices, GL_STATIC_DRAW)
        else:
            glBufferData(GL_ARRAY_BUFFER, vertices.nbytes, vertices, GL_DYNAMIC_DRAW)
        self.ibo = glGenBuffers(1)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.nbytes, indices, GL_STATIC_DRAW)

    def update(self, vertices):
        if self.vertex_count != vertices.size / self.elements_per_vertex:
            raise RuntimeError('vertices.size had wrong value')
        if not self.is_static:
            glBufferData(GL_ARRAY_BUFFER, vertices.nbytes, vertices, GL_DYNAMIC_DRAW)

    def bind(self):
        glBindBuffer(GL_ARRAY_BUFFER, self.vbo)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.ibo)

    def unbind(self):
        glBindBuffer(GL_ARRAY_BUFFER, 0)
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

    def draw(self):
        if self.is_triangles:
            glDrawArrays(GL_TRIANGLES, 0, self.index_count)
        else:
            glDrawArrays(GL_LINES, 0, self.index_count)


def create_mesh_array_data(mesh):
    index_data = []
    vertex_data = []
    index = 0
    for fh in mesh.faces():
        (n, w) = MESH.compute_face_plane(mesh, fh)
        first_index = index
        for vh in mesh.fv(fh):
            index_data.append(index)
            v = MESH.get_vertex_coords(mesh, vh)
            vertex_data.append(v[0])
            vertex_data.append(v[1])
            vertex_data.append(v[2])
            vertex_data.append(n[0])
            vertex_data.append(n[1])
            vertex_data.append(n[2])
            index += 1
        if index - first_index != 3:
            raise RuntimeError('create_mesh_arary_data() expected triangle mesh input')

    vertex_array = np.array(vertex_data, dtype=np.float32)
    index_array = np.array(index_data, dtype=np.uint32)
    return vertex_array, index_array


def create_cube_array_data():
    """

        7 o-----------------------o 6
         /                       /|
        /                       / |
    4  o--+--------------------+5 |
       |  |                    |  |
       |  |                    |  |
       |  |                    |  |
       |3 o--------------------+--o 2
       | /                     | /
       |/                      |/
    0  o-----------------------o  1


    """
    raw_vertices = (
        (-1.0, -1.0, -1.0)
        , (1.0, -1.0, -1.0)
        , (1.0, 1.0, -1.0)
        , (-1.0, 1.0, -1.0)
        , (-1.0, -1.0, 1.0)
        , (1.0, -1.0, 1.0)
        , (1.0, 1.0, 1.0)
        , (-1.0, 1.0, 1.0)
    )

    raw_indices = (
        (0, 2, 1)  # Bottom
        , (0, 3, 2)  # Bottom
        , (0, 1, 5)  # Front
        , (0, 5, 4)  # Front
        , (1, 2, 6)  # Right
        , (1, 6, 5)  # Right
        , (3, 0, 4)  # Left
        , (3, 4, 7)  # Left
        , (4, 5, 6)  # Top
        , (4, 6, 7)  # Top
        , (2, 3, 7)  # Back
        , (2, 7, 6)  # Back
    )

    raw_normals = (
        (0.0, 0.0, -1.0)  # Bottom
        , (0.0, 0.0, -1.0)  # Bottom
        , (0.0, -1.0, 0.0)  # Front
        , (0.0, -1.0, 0.0)  # Front
        , (1.0, 0.0, 0.0)  # Right
        , (1.0, 0.0, 0.0)  # Right
        , (-1.0, 0.0, 0.0)  # Left
        , (-1.0, 0.0, 0.0)  # Left
        , (0.0, 0.0, 1.0)  # Top
        , (0.0, 0.0, 1.0)  # Top
        , (0.0, 1.0, 0.0)  # Back
        , (0.0, 1.0, 0.0)  # Back
    )

    k = 0
    index_data = []
    vertex_data = []
    for i in range(len(raw_indices)):
        tri = raw_indices[i]
        n = raw_normals[i]
        p0 = raw_vertices[tri[0]]
        p1 = raw_vertices[tri[1]]
        p2 = raw_vertices[tri[2]]
        vertex_data.append(p0[0])
        vertex_data.append(p0[1])
        vertex_data.append(p0[2])
        vertex_data.append(n[0])
        vertex_data.append(n[1])
        vertex_data.append(n[2])
        index_data.append(k)
        k += 1
        vertex_data.append(p1[0])
        vertex_data.append(p1[1])
        vertex_data.append(p1[2])
        vertex_data.append(n[0])
        vertex_data.append(n[1])
        vertex_data.append(n[2])
        index_data.append(k)
        k += 1
        vertex_data.append(p2[0])
        vertex_data.append(p2[1])
        vertex_data.append(p2[2])
        vertex_data.append(n[0])
        vertex_data.append(n[1])
        vertex_data.append(n[2])
        index_data.append(k)
        k += 1

    vertex_data = np.array(vertex_data, dtype=np.float32)
    index_data = np.array(index_data, dtype=np.uint32)
    return vertex_data, index_data


def create_quad_array_data():
    # Quad spanning from near to far cliping plane
    #vertex_data = np.array([-10, -10, -6, 1.0, 0.0, 0.0,
    #                         10, -10, -6, 0.0, 1.0, 0.0,
    #                          1,   1,  3, 0.0, 0.0, 1.0,
    #                          1,   1,  3, 0.0, 0.0, 1.0,
    #                         -1,   1,  3, 0.0, 1.0, 0.0,
    #                        -10, -10, -6, 1.0, 0.0, 0.0], dtype=np.float32)
    # Quad in near clipping plane
    #vertex_data = np.array([-1, -1, 3, 1.0, 0.0, 0.0,
    #                         1, -1, 3, 0.0, 1.0, 0.0,
    #                          1,   1,  3, 0.0, 0.0, 1.0,
    #                          1,   1,  3, 0.0, 0.0, 1.0,
    #                         -1,   1,  3, 0.0, 1.0, 0.0,
    #                        -1, -1, 3, 1.0, 0.0, 0.0], dtype=np.float32)
    # Quad in far cliping plane
    #vertex_data = np.array([ -10, -10, -5.99, 1.0, 0.0, 0.0,
    #                          10, -10, -5.99, 0.0, 1.0, 0.0,
    #                          10,   10,  -5.99, 0.0, 0.0, 1.0,
    #                          10,   10,  -5.99, 0.0, 0.0, 1.0,
    #                         -10,   10,  -5.99, 0.0, 1.0, 0.0,
    #                         -10, -10, -5.99, 1.0, 0.0, 0.0], dtype=np.float32)
    # Quad in between far and near clipping planes
    vertex_data = np.array([ -5, -5, 0.0, 1.0, 0.0, 0.0,
                              5, -5, 0.0, 0.0, 1.0, 0.0,
                              5,  5, 0.0, 0.0, 0.0, 1.0,
                              5,  5, 0.0, 0.0, 0.0, 1.0,
                             -5,  5, 0.0, 0.0, 1.0, 0.0,
                             -5, -5, 0.0, 1.0, 0.0, 0.0], dtype=np.float32)
    index_data = np.array([0, 1, 2, 3, 4, 5], dtype=np.uint32)
    return vertex_data, index_data


class ShapeNode:

    def __init__(self, program, vao, vbo):
        self.program = program
        self.vao = vao
        self.vbo = vbo

        self.program.use()

        self.position_location = self.program.get_attribute_location('position')
        self.normal_location = self.program.get_attribute_location('normal')

        self.vao.bind()
        self.vbo.bind()

        glEnableVertexAttribArray(self.position_location)
        glEnableVertexAttribArray(self.normal_location)

        offset = ctypes.c_void_p(0)
        glVertexAttribPointer(
            self.position_location,      # Location of the attributes
            3,                           # Number of components per vertex
            GL_FLOAT,                    # Type of the components
            False,                       # Normalization
            6*4,                         # Number of bytes between two vertices
            offset                       # Offset into current bound GL_ARRAY_BUFFER
            )

        offset = ctypes.c_void_p(4*3)
        glVertexAttribPointer(
            self.normal_location,       # Location of the attributes
            3,                          # Number of components per vertex
            GL_FLOAT,                   # Type of the components
            False,                      # Normalization
            6*4,                        # Number of bytes between two vertices
            offset                      # Offset into current bound GL_ARRAY_BUFFER
            )

        self.vao.unbind()

    def draw(self):
        self.vao.bind()
        self.vbo.draw()
        self.vao.unbind()


class InstanceNode:

    def __init__(self, shape_node, material, rigid_body = None):
        self.shape_node = shape_node
        self.material = material
        self.model_matrix = np.identity(4, dtype=np.float32)
        self.rigid_body = rigid_body

    def update_transform(self, r, q):
        self.model_matrix[0:3, 0:3] = Q.to_matrix(q)
        self.model_matrix[0:3, 3] = r

    def update_position(self, r):
        self.model_matrix[0:3, 3] = r

    def update_rotation(self, q):
        self.model_matrix[0:3, 0:3] = Q.to_matrix(q)

    def update_from_rigid_body(self):
        if self.rigid_body is not None:
            self.update_transform(self.rigid_body.r, self.rigid_body.q)

    def draw(self):
        self.update_from_rigid_body()
        self.shape_node.program.set_uniform_matrix4('model_matrix', self.model_matrix)
        self.shape_node.program.set_uniform_material(self.material)
        self.shape_node.draw()


class Trackball:

    def __init__(self):
        self.reset()

    def reset(self):
        self.radius = 1.0
        self.anchor_position = np.zeros((3, ), dtype=np.float32)
        self.current_position = np.zeros((3, ), dtype=np.float32)
        self.angle = 0.0
        self.axis = np.zeros((3, ), dtype=np.float32)
        self.rotation_matrix = np.identity(3, dtype=np.float32)
        self.project_onto_surface(self.anchor_position)
        self.project_onto_surface(self.current_position)

    def click_at(self, nx, ny):
        '''

        :param nx:  Normalized x device coordinate [-1..1]
        :param ny:  Normalized y device coordinate [-1..1]
        :return:
        '''
        self.angle = 0.0
        self.axis = np.zeros((3,), dtype=np.float32)
        self.rotation_matrix = np.identity(3, dtype=np.float32)
        self.anchor_position = np.array([nx, ny, 0.0], dtype=np.float32)
        self.current_position = np.array([nx, ny, 0.0], dtype=np.float32)
        self.project_onto_surface(self.anchor_position)
        self.project_onto_surface(self.current_position)

    def move_to(self, nx, ny):
        '''

        :param nx:  Normalized x device coordinate [-1..1]
        :param ny:  Normalized y device coordinate [-1..1]
        :return:
        '''
        self.current_position = np.array([nx, ny, 0.0], dtype=np.float32)
        self.project_onto_surface(self.current_position)
        self.compute_rotation_matrix()

    def project_onto_surface(self, p):
        r2 = self.radius * self.radius
        l2 = p[0]*p[0] + p[1]*p[1]
        if l2 <= (r2 / 2.0):
            p[2] = np.sqrt(r2 - l2)
        else:
            p[2] = r2 / (2.0 * np.sqrt(l2))
            l = np.sqrt(l2 + p[2]*p[2])
            p /= l
        p /= np.linalg.norm(p)

    def compute_rotation_matrix(self):
        self.angle = 0.0
        self.rotation_matrix = np.identity(3, dtype=np.float32)
        self.axis = np.cross(self.anchor_position, self.current_position)
        s = np.linalg.norm(self.axis)
        c = np.dot(self.anchor_position, self.current_position)
        if s > 0:
            self.axis /= s
            self.angle = np.arctan2(s, c)
            # Foley p. 227(5.76)
            self.rotation_matrix[0, 0] = self.axis[0] * self.axis[0] + c * (1.0 - self.axis[0] * self.axis[0])
            self.rotation_matrix[0, 1] = self.axis[0] * self.axis[1] * (1.0 - c) - s * self.axis[2]
            self.rotation_matrix[0, 2] = self.axis[0] * self.axis[2] * (1.0 - c) + s * self.axis[1]
            self.rotation_matrix[1, 0] = self.axis[0] * self.axis[1] * (1.0 - c) + s * self.axis[2]
            self.rotation_matrix[1, 1] = self.axis[1] * self.axis[1] + c * (1.0 - self.axis[1] * self.axis[1])
            self.rotation_matrix[1, 2] = self.axis[1] * self.axis[2] * (1.0 - c) - s * self.axis[0]
            self.rotation_matrix[2, 0] = self.axis[0] * self.axis[2] * (1.0 - c) - s * self.axis[1]
            self.rotation_matrix[2, 1] = self.axis[1] * self.axis[2] * (1.0 - c) + s * self.axis[0]
            self.rotation_matrix[2, 2] = self.axis[2] * self.axis[2] + c * (1.0 - self.axis[2] * self.axis[2])


class Camera:

    def __init__(self):
        self.eye    = np.array([0, 0,  4], dtype=np.float32)    # Viewer Position (Placement of Camera in Model Space. \
        self.center = np.array([0, 0,  0], dtype=np.float32)    # Viewer Target, the spot in the model space we are looking at. \
        self.up     = np.array([0, 1,  0], dtype=np.float32)    # Viewer Up, the direction in model space that is upwards.
        self.dof = np.array([0, 0, 0], dtype=np.float32)        # Direction of Flight, i.e. the direction in model space we are moving forward in....
        self.right = np.array([0, 0, 0], dtype=np.float32)      # Direction to the right in model space.
        self.center_locked = True                               # Boolean flag indicating whether target positions is locked (ie. we allways look at the same spot)
        self.update(self.eye, self.center, self.up)
        self.z_near = 0.1
        self.z_far = 50.0
        self.fovy = np.pi/2.0                                   # Field of view of screen in y-direction, initially 45 degrees

    def update(self, eye, center, up):
        # First determine transform from local camera frame to world
        # coordinate system, i.e.
        #
        #     H = | R T |  =   | X Y Z T |=   | right  up' -dof position |
        #         | 0 1 |      | 0 0 0 1 |    |   0     0    0    1      |
        #
        #
        #   |q|       |p|
        #   |1|  =  H |1|    or    q = R*p + T
        #
        self.eye = np.copy(eye)
        self.center = np.copy(center)
        self.up = np.copy(up)
        self.dof = self.center - self.eye
        self.dof /= np.linalg.norm(self.dof)
        self.right = np.cross(self.dof, self.up)
        self.right /= np.linalg.norm(self.right)
        self.up = np.cross(self.right, self.dof)

    def depth(self, r):
        return np.dot(self.dof, (r - self.eye))

    def rotate(self, R):
        '''

        :param R:    Rotation of camera given in camera space
        :return:
        '''
        Rc2w = np.identity(3, dtype=np.float32)
        Rc2w[:, 0] = self.right
        Rc2w[:, 1] = self.up
        Rc2w[:, 2] = -self.dof
        Rw2c = Rc2w.transpose()

        Rw = Rc2w.dot(R.dot(Rw2c))

        if not self.center_locked:
            self.center =Rw.dot(self.center - self.eye) + self.eye

        self.up = Rw.dot(self.up)
        self.update(self.eye, self.center, self.up)

    def orbit(self, R):
        '''

        :param R:    Rotation of camera given in camera space
        :return:
        '''
        Rc2w = np.identity(3, dtype=np.float32)
        Rc2w[:, 0] = self.right
        Rc2w[:, 1] = self.up
        Rc2w[:, 2] = -self.dof
        Rw2c = Rc2w.transpose()

        Rw = Rc2w.dot(R.dot(Rw2c))

        self.eye = Rw.dot(self.eye - self.center) + self.center
        self.up = Rw.dot(self.up)

        self.update(self.eye, self.center, self.up)

    def pan(self, dx, dy):
        move_x = dx * self.right
        move_y = dy * self.up
        self.eye += move_x
        self.eye += move_y
        if not self.center_locked:
            self.center += move_x
            self.center += move_y
        self.update(self.eye, self.center, self.up)

    def dolly(self, distance):
        upper_bound = 0.9*np.inner((self.center - self.eye), self.dof)
        safe_distance = upper_bound if distance > upper_bound else distance
        self.eye += self.dof*safe_distance
        if not self.center_locked:
            self.center += self.dof*safe_distance
        self.update(self.eye, self.center, self.up)

    def compute_view_matrix(self):
        view_matrix = np.identity(4, dtype=np.float32)
        view_matrix[0, 0:3] = self.right
        view_matrix[1, 0:3] = self.up
        view_matrix[2, 0:3] = -self.dof
        view_matrix[0, 3] = - np.inner(self.right, self.eye)
        view_matrix[1, 3] = - np.inner(self.up, self.eye)
        view_matrix[2, 3] =   np.inner(self.dof, self.eye)
        #print(view_matrix)
        return view_matrix

    def compute_projection_matrix(self):
        viewport = glGetFloatv(GL_VIEWPORT)
        width = viewport[2]*1.0
        height = viewport[3]*1.0
        aspect = width / height
        tan_fovy_half = np.tan(self.fovy / 2.0)
        projection_matrix = np.zeros((4, 4), dtype=np.float32)
        projection_matrix[0][0] = 1.0 / (aspect * tan_fovy_half)
        projection_matrix[1][1] = 1.0 / tan_fovy_half
        projection_matrix[2][2] = -(self.z_far + self.z_near) / (self.z_far - self.z_near)
        projection_matrix[2][3] = -(2.0 * self.z_far * self.z_near) / (self.z_far - self.z_near)
        projection_matrix[3][2] = -1.0
        #print(projection_matrix)
        return projection_matrix

    def get_ray(self, nx, ny):
        '''

        :param nx:  Normalized x device coordinate [-1..1]
        :param ny:  Normalized y device coordinate [-1..1]
        :return:
        '''
        nz = 1.0

        view_matrix = self.compute_view_matrix()
        projection_matrix = self.compute_projection_matrix()

        ray_nds = np.array([nx, ny, nz], dtype=np.float32)                        # Normalized device space
        ray_clip = np.array([nx, ny, -1.0, 1.0], dtype=np.float32)                 # Clip space
        ray_eye = np.linalg.inv(projection_matrix).dot(ray_clip)                     # Eye space
        ray_eye = np.array([ray_eye[0], ray_eye[1], -1.0, 0.0], dtype=np.float32) # Manually set to forward direction vector
        ray_world = np.linalg.inv(view_matrix).dot(ray_eye)
        ray_world /= np.linalg.norm(ray_world)
        return self.eye, ray_world


class SpotLight:

    def __init__(self, index):
        self.index = index
        self.position = V3.make(0.0, 100.0, 0.0)   # Position of light in world
        self.target = V3.make(0.0, 0.0, 0.0)       # Position of light target in world
        self.cutoff_angle = 45.0
        self.attenuation = 0.01
        self.Is = V3.make(1.0, 1.0, 1.0)  # Specular color
        self.Id = V3.make(0.7, 0.7, 0.7)  # Diffuse color
        self.Ia = V3.make(0.2, 0.2, 0.2)  # Ambient color


class LightSetup:

    def __init__(self):
        self.lights = []


class Material:

    def __init__(self, name):
        self.name = name
        self.Ks = V3.make(0.7, 0.7, 0.7)  # Specular color
        self.Kd = V3.make(0.7, 0.7, 0.7)  # Diffuse color
        self.Ka = V3.make(0.7, 0.7, 0.7)  # Ambient color
        self.specular_exponent = 100.0    # Specular power
        self.wire_color = V3.make(0.7, 0.0, 0.7)
        self.wire_thickness = 2.0


class SceneGraph:

    def __init__(self):
        self.camera = None
        self.light_setup = None
        self.shape_nodes = dict()
        self.instance_nodes = dict()
        self.program = None

    def render(self):
        view_matrix = self.camera.compute_view_matrix()
        projection_matrix = self.camera.compute_projection_matrix()
        self.program.use()
        self.program.set_uniform_matrix4('view_matrix', view_matrix)
        self.program.set_uniform_matrix4('projection_matrix', projection_matrix)
        self.program.set_uniform_light_setup(self.light_setup)

        for instance in self.instance_nodes.values():
            instance.draw()

        self.program.stop()


class MovieRecorder:

    def __init__(self):
        self.on = False
        self.frame = 0
        self.path = './'
        self.type = 'png'
        self.base_name = 'screen'

    def clear(self):
        self.frame = 0

    def record(self, widget):
        if self.on:

            if not os.path.exists(self.path):
                raise RuntimeError('movie path did not exist')

            filename = os.path.join(self.path, self.base_name + str(self.frame).zfill(5) + '.' + self.image_type)

            widget.grabFramebuffer().save(filename)

            self.frame += 1

    def set_state(self, is_on):
        self.on = is_on
        if self.on:
            print('Movie recording is on')
        else:
            print('Movie recording is off')
            self.clear()
