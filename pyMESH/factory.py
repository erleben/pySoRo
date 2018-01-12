import sys

sys.path.append('/usr/local/lib/python/')


import openmesh as OM
import pyMESH.mesh as MESH
import pyMATH.quaternion as Q
import pyMATH.vector3 as V3
from math import pi
#from pyhull.convex_hull import ConvexHull
#
#
# def make_convex_hull(points):
#     mesh = OM.TriMesh()
#
#     H = ConvexHull(points)
#
#     vhandle = []
#     for p in H.points:
#         vhandle.append(mesh.add_vertex(OM.TriMesh.Point(p[0], p[1], p[2])))
#
#     for v in H.vertices:
#         vi = vhandle[v[0]]
#         vj = vhandle[v[1]]
#         vk = vhandle[v[2]]
#         mesh.add_face(vi, vk, vj)
#
#     mesh.request_face_normals()
#     mesh.update_face_normals()
#
#     return mesh


def profile_sweep(profile, slices):
    mesh = OM.TriMesh()

    N = len(profile)
    J = slices

    if N <= 2:
        raise RuntimeError('profile_sweep(): Profile must have at least 3 points')

    if J <= 2:
        raise RuntimeError('profile_sweep(): Sweep must have at least 3 slices to be a proper volume.')

    K = (N-2)*J + 2   # Total number of vertices
    bottom = K-1      # Index to bottom vertex
    top = K-2         # Index to top vertex
    H = N-2           # Number of latitude circles
    F = 2*J*(N-1)     # Total number of triangle faces

    vhandles = []

    # Make a 2D grid of vertices by sweeping profile around y-axis
    dtheta = 2.0 * pi / J     # The angle of each slice

    for j in range(J):
        theta = j * dtheta
        R = Q.Ru(theta, V3.j())
        for i in range(H):
            p = Q.rotate(R, profile[i+1])
            vh = mesh.add_vertex(OM.TriMesh.Point(p[0], p[1], p[2]))
            vhandles.append(vh)

    # Now fill in top and bottom vertices
    vh = mesh.add_vertex(OM.TriMesh.Point(profile[N - 1][0], profile[N - 1][1], profile[N - 1][2]))
    vhandles.append(vh)

    vh = mesh.add_vertex(OM.TriMesh.Point(profile[0][0], profile[0][1], profile[0][2]))
    vhandles.append(vh)

    # Make faces for bottom-ring
    for j in range(J):
        #
        #  V  = {c1} {c2} ... {cJ}  b t
        #
        # b c1.0 c2.0 | b c2.0 c3.0| ... | b cJ.0 c1.0
        # b 0 (N-2) | b (N-2) 2*(N-2)
        #
        left = j
        right = ((j+1) % J)
        vi = vhandles[bottom]
        vj = vhandles[H*right]
        vk = vhandles[H*left]
        mesh.add_face(vi, vj, vk)

    # Make faces for middle-rings
    for i in range(H-1):     # ring number
        for j in range(J):   # slice number
            left = j
            right = (j+1) % J
            up = i+1
            down = i

            vi = vhandles[left*H + down]
            vj = vhandles[right*H + down]
            vk = vhandles[right*H + up]
            vm = vhandles[left*H + up]

            mesh.add_face(vi, vj, vk)
            mesh.add_face(vi, vk, vm)

    # Make faces for top - ring
    for j in range(J):
        offset = (N - 3)
        left = j
        right = (j + 1) % J

        vi = vhandles[top]
        vj = vhandles[left * H + offset]
        vk = vhandles[right * H + offset]

        mesh.add_face(vi, vj, vk)

    mesh.request_face_normals()
    mesh.update_face_normals()

    return mesh


def make_cylinder(radius, height, slices):
    profile = [
        V3.make(0.0, -height/2.0, 0.0),
        V3.make(radius, -height/2.0, 0.0),
        V3.make(radius, height/2.0, 0.0),
        V3.make(0.0, height/2.0, 0.0)
    ]
    return profile_sweep(profile, slices)


def make_cone(radius, height, slices):
    profile = [
        V3.make(0.0, 0.0, 0.0),
        V3.make(radius, 0.0, 0.0),
        V3.make(0.0, height, 0.0)
    ]
    return profile_sweep(profile, slices)


def make_conical(bottom_radius, top_radius, height, slices):
    profile = [
        V3.make(0.0, 0.0, 0.0),
        V3.make(bottom_radius, 0.0, 0.0),
        V3.make(top_radius, height, 0.0),
        V3.make(0.0, height, 0.0)
    ]
    return profile_sweep(profile, slices)


def make_sphere(radius, slices, segments):
    profile = [V3.zero() for _ in range(segments)]
    dtheta = pi / (segments-1)
    for i in range(segments):
        theta = dtheta*i
        R = Q.Ru(theta, V3.k())
        profile[i] = Q.rotate(R, V3.make(0.0, -radius, 0.0))
    return profile_sweep(profile, slices)


def make_ellipsoid(a, b, c, slices, segments):
    mesh = make_sphere(1.0,  slices, segments)
    MESH.scale(mesh, a, b, c)
    return mesh


def make_capsule(radius, height, slices, segments):
    profile = [V3.zero() for _ in range(segments)]
    dtheta = pi / (segments-1)
    for i in range(segments):
        theta = dtheta*i
        R = Q.Ru(theta, V3.k())
        dh = -height/2.0 if i < (segments/2) else height/2.0
        profile[i] = Q.rotate(R, V3.make(0.0, -radius, 0.0)) + V3.make(0.0, dh, 0.0)
    return profile_sweep(profile, slices)


def make_tetrahedron(p0, p1, p2, p3):
    mesh = OM.TriMesh()

    vi = mesh.add_vertex(OM.TriMesh.Point(p0[0], p0[1], p0[2]))
    vj = mesh.add_vertex(OM.TriMesh.Point(p1[0], p1[1], p1[2]))
    vk = mesh.add_vertex(OM.TriMesh.Point(p2[0], p2[1], p2[2]))
    vm = mesh.add_vertex(OM.TriMesh.Point(p3[0], p3[1], p3[2]))

    mesh.add_face(vi, vk, vj)
    mesh.add_face(vi, vj, vm)
    mesh.add_face(vj, vk, vm)
    mesh.add_face(vk, vi, vm)

    mesh.request_face_normals()
    mesh.update_face_normals()

    return mesh


def make_cuboid(p0, p1, p2, p3, p4, p5, p6, p7):
    """
    Creates a cuboid like object. The ccw-order front face is given by [p0 p1 p2 p3], the ccw-order back-face is given
     by [p4, p7, p6, p5]

    :param p0:
    :param p1:
    :param p2:
    :param p3:
    :param p4:
    :param p5:
    :param p6:
    :param p7:
    :return:
    """
    mesh = OM.TriMesh()

    v0 = mesh.add_vertex(OM.TriMesh.Point(p0[0], p0[1], p0[2]))
    v1 = mesh.add_vertex(OM.TriMesh.Point(p1[0], p1[1], p1[2]))
    v2 = mesh.add_vertex(OM.TriMesh.Point(p2[0], p2[1], p2[2]))
    v3 = mesh.add_vertex(OM.TriMesh.Point(p3[0], p3[1], p3[2]))
    v4 = mesh.add_vertex(OM.TriMesh.Point(p4[0], p4[1], p4[2]))
    v5 = mesh.add_vertex(OM.TriMesh.Point(p5[0], p5[1], p5[2]))
    v6 = mesh.add_vertex(OM.TriMesh.Point(p6[0], p6[1], p6[2]))
    v7 = mesh.add_vertex(OM.TriMesh.Point(p7[0], p7[1], p7[2]))

    quads = [
      [v0, v1, v2, v3],  # front face
      [v4, v7, v6, v5],  # back face
      [v4, v0, v3, v7],  # left face
      [v1, v5, v6, v2],  # right face
      [v7, v3, v2, v6],  # top face
      [v5, v1, v0, v4],  # bottom face
    ]

    for i in range(6):
        vi = quads[i][0]
        vj = quads[i][1]
        vk = quads[i][2]
        vm = quads[i][3]
        mesh.add_face(vi, vj, vk)
        mesh.add_face(vi, vk, vm)

    mesh.request_face_normals()
    mesh.update_face_normals()

    return mesh


def make_box(width, height, depth):
    p0 = V3.make(-width, -height, depth) * 0.5
    p1 = V3.make(width, -height, depth) * 0.5
    p2 = V3.make(width, height, depth) * 0.5
    p3 = V3.make(-width, height, depth) * 0.5
    p4 = p0 - V3.make(0.0, 0.0, depth)
    p5 = p1 - V3.make(0.0, 0.0, depth)
    p6 = p2 - V3.make(0.0, 0.0, depth)
    p7 = p3 - V3.make(0.0, 0.0, depth)
    return make_cuboid(p0, p1, p2, p3, p4, p5, p6, p7)
