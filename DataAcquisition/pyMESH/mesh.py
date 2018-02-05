import sys

sys.path.append('/usr/local/lib/python/')

import numpy as np
import openmesh as OM
import pyMATH.vector3 as V3
import pyMATH.quaternion as Q


def read_obj(filename):
    mesh = OM.TriMesh()
    options = OM.Options()
    ok = OM.read_mesh(mesh, filename, options)
    mesh.request_face_normals()
    mesh.update_face_normals()
    if not ok:
        raise RuntimeError('read_obj() failed to read file: '+filename)
    return mesh


def compute_face_plane(mesh, fh):
    p = []
    for vh in mesh.fv(fh):
        r = mesh.point(vh)
        p.append(np.array(list(r), dtype=np.float64))
    if len(p) != 3:
        raise RuntimeError('compute_face_plane() expected triangle surface')
    n = V3.unit(V3.cross(p[1]-p[0], p[2]-p[0]))
    p_avg = (p[0]+p[1]+p[2])/3.0
    w = - np.dot(n, p_avg)
    return n, w


def get_face_normal(mesh, fh):
    if not mesh.has_face_normals():
        raise RuntimeError('get_face_normal() no normals found')
    n = mesh.normal(fh)
    return np.array(list(n), dtype=np.float64)


def get_vertex_coords(mesh, vh):
    r = mesh.point(vh)
    return np.array(list(r), dtype=np.float64)


def translate(mesh, r):
    for vh in mesh.vertices():
        p = get_vertex_coords(mesh, vh) + r
        mesh.set_point(vh, OM.TriMesh.Point(p[0], p[1], p[2]))
    return mesh


def rotate(mesh, q):
    for vh in mesh.vertices():
        p = Q.rotate(q, get_vertex_coords(mesh, vh))
        mesh.set_point(vh, OM.TriMesh.Point(p[0], p[1], p[2]))
    return mesh


def scale(mesh, a, b, c):
    for vh in mesh.vertices():
        p = get_vertex_coords(mesh, vh)
        mesh.set_point(vh, OM.TriMesh.Point(a*p[0], b*p[1], c*p[2]))
    return mesh


def aabb(mesh):
    l = None
    u = None
    for vh in mesh.vertices():
        p = get_vertex_coords(mesh, vh)
        if l is None:
            l = p
        if u is None:
            u = p
        l = np.minimum(l, p)
        u = np.maximum(u, p)
    return l, u


def join(mesh_list):
    mesh = OM.TriMesh()
    for part in mesh_list:
        lut = dict()
        for vh in part.vertices():
            p = get_vertex_coords(part, vh)
            lut[vh.idx()] = mesh.add_vertex(OM.TriMesh.Point(p[0], p[1], p[2]))

        for fh in part.faces():
            vhandle = []
            for vh in part.fv(fh):
                vhandle.append(lut[vh.idx()])
            mesh.add_face(vhandle[0], vhandle[1], vhandle[2])

    mesh.request_face_normals()
    mesh.update_face_normals()
    return mesh
