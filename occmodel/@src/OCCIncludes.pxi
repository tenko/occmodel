# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
from cython cimport view
from libc.stdlib cimport malloc, free
from libc.math cimport fmin, fmax, fabs, copysign
from libc.math cimport M_PI, sqrt, sin, cos, tan

cdef extern from "math.h":
    bint isnan(double x)

from OCCModelLib cimport *

import sys
import itertools

from geotools cimport Transform, Plane, Point, Vector, AABBox
from geotools import Transform, Plane, Point, Vector, AABBox

# constants
cdef double EPSILON = 2.2204460492503131e-16
cdef double SQRT_EPSILON = 1.490116119385000000e-8
cdef double ZERO_TOLERANCE = 1.0e-12
cdef double DEFAULT_ANGLE_TOLERANCE = M_PI/180.