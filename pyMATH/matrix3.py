import numpy as np
from math import cos, sin

def identity():
    return np.identity(3, dtype=np.float64)


def diag_from_array(v):
    return np.array([[v[0], 0, 0], [0, v[1], 0], [0, 0, v[2]]], dtype=np.float64)


def diag(a, b, c):
    return np.array([[a, 0, 0], [0, b, 0], [0, 0, c]], dtype=np.float64)


def zero():
    return np.zeros((3, 3), dtype=np.float64)


def ones():
    return np.ones((3, 3), dtype=np.float64)


def make(A00, A01, A02, A10, A11, A12, A20, A21, A22):
    return np.array([[A00, A01, A02], [A10, A11, A12], [A20, A21, A22]], dtype=np.float64)


def make_from_rows( row0, row1, row2):
    return np.array([row0, row1, row2], dtype=np.float64)


def star(v):
    """
    Changes a vector cross-product into a matrix multiplication, a x b = (a*)b = b(a*)

    :param v:
    :return:
    """
    return np.array([[0, -v[2], v[1]], [v[2], 0, -v[0]], [-v[1], v[0], 0]], dtype=np.float64)


def ortonormalize(A):
    row0 = A[0, :]
    row1 = A[1, :]
    l0 = np.linalg.norm(row0)
    if l0 > 0.0:
        row0 /= l0
    row1 -= np.dot(row0, row1) * row0
    l1 = np.linalg.norm(row1)
    if l1 > 0.0:
        row1 /= l1
    row2 = np.cross(row0, row1, axis=0)
    return np.vstack((row0, row1, row2))


def Ru(radians, axis):
    c = cos(radians)
    s = sin(radians)
    u = axis / np.linalg.norm(axis)
    R = zero()
    # Foley p. 227(5.76)
    R[0, 0] = u[0] * u[0] + c * (1.0 - u[0] * u[0])
    R[0, 1] = u[0] * u[1] * (1.0 - c) - s * u[2]
    R[0, 2] = u[0] * u[2] * (1.0 - c) + s * u[1]
    R[1, 0] = u[0] * u[1] * (1.0 - c) + s * u[2]
    R[1, 1] = u[1] * u[1] + c * (1.0 - u[1] * u[1])
    R[1, 2] = u[1] * u[2] * (1.0 - c) - s * u[0]
    R[2, 0] = u[0] * u[2] * (1.0 - c) - s * u[1]
    R[2, 1] = u[1] * u[2] * (1.0 - c) + s * u[0]
    R[2, 2] = u[2] * u[2] + c * (1.0 - u[2] * u[2])
    return R


def Rx(radians):
    c = cos(radians)
    s = sin(radians)
    return np.array([[1.0, 0.0, 0.0], [0.0, c, -s], [0.0, s, c]], dtype=np.float64)


def Ry(radians):
    c = cos(radians)
    s = sin(radians)
    return np.array([[c, 0.0, s], [0.0, 1.0, 0.0], [-s, 0.0, c]], dtype=np.float64)


def Rz(radians):
    c = cos(radians)
    s = sin(radians)
    return np.array([[c, -s, 0.0], [s, c, 0.0], [0.0, 0.0, 1.0]], dtype=np.float64)

