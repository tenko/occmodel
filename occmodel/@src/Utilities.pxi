# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

cdef inline double fmax3(double a, double b, double c):
    if a < b:
        if b < c: return c
        return b
    return a

cdef inline double fmin3(double a, double b, double c):
    if a > b:
        if b > c: return c
        return b
    return a
    
cdef inline _cross(double x1, double y1, double z1,
                   double x2, double y2, double z2,
                   double *rx, double *ry, double *rz):
    rx[0] = y1 * z2 - y2 * z1
    ry[0] = z1 * x2 - z2 * x1
    rz[0] = x1 * y2 - x2 * y1
    
cdef inline double _length(double x, double y, double z):
    # Scaling to avoid overflow e.g.: Vector(1e200,1e200,1e200).length
    cdef double l
    cdef double fx, fy, fz
    
    fx = fabs(x)
    fy = fabs(y)
    fz = fabs(z)
    
    if fy >= fx and fy >= fz:
        l = fx; fx = fy; fy = l;
    elif fz >= fx and fz >= fy:
        l = fx; fx = fz; fz = l;
    
    if fx > 0.:
        l = 1. / fx
        fy = fy * l
        fz = fz * l
        l = fx * sqrt(1. + fy * fy + fz * fz)
    else:
        l = 0.
    return l