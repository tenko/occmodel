# -*- coding: utf-8 -*-

cdef class Vector(Point):
    property length:
        'Calculate lenght of vector'
        def __get__(self):
            return _length(self.x, self.y, self.z)
    
    property lengthSquared:
        'Calculate squared lenght of vector'
        def __get__(self):
            return self.x * self.x + self.y * self.y + self.z * self.z
    
    def __mul__(lhs, rhs):
        """Vector multiplication
        We accept multiplication by a scalar,
        and a 4x4 transformation matrix.
        """
        cdef Vector u, v, ret
        
        cdef double s, x, y, z
        cdef int tlhs, trhs
        
        tlhs = isinstance(lhs, Vector)
        trhs = isinstance(rhs, Vector)
        
        if not tlhs: # Lhs scalar
            cls = rhs.__class__
            ret = cls.__new__(cls)
            s = lhs
            u = rhs
            ret.x = s * u.x
            ret.y = s * u.y
            ret.z = s * u.z
            return ret
            
        elif not trhs: # Not Vector
            cls = lhs.__class__
            ret = cls.__new__(cls)
            u = lhs
            try:
                s = rhs
                ret.x = s * u.x
                ret.y = s * u.y
                ret.z = s * u.z
                return ret
                
            except TypeError:
                # Matrix
                ret.x = rhs[0,0]*u.x + rhs[0,1]*u.y + rhs[0,2]*u.z + rhs[0,3]
                ret.y = rhs[1,0]*u.x + rhs[1,1]*u.y + rhs[1,2]*u.z + rhs[1,3]
                ret.z = rhs[2,0]*u.x + rhs[2,1]*u.y + rhs[2,2]*u.z + rhs[2,3]
                return ret
        else:
            u = lhs
            v = rhs
            return u.x * v.x + u.y * v.y + u.z * v.z
            
    cpdef Vector unit(self):
        """Normalize the vector (arg.lenght = 1.)
        """
        cdef double d
        d = self.length
        if d > 0.:
            d = 1. / d
            self.x = d * self.x
            self.y = d * self.y
            self.z = d * self.z
        return self

cpdef double dot(Vector a, Vector b):
    """Dot product"""
    assert a is not None and not b is None
    return a.x * b.x + a.y * b.y + a.z * b.z
    
cpdef Vector cross(Vector a, Vector b):
    """Cross product"""
    assert a is not None and not b is None
    return Vector(a.y * b.z - b.y * a.z, a.z * b.x - b.z * a.x, a.x * b.y - b.x * a.y)

cpdef int isParallell(Vector v1, Vector v2):
    """'
    Return 1 if parallell, -1 if anti-parallell and 0 if not parallell.'
    """
    assert v1 is not None and not v2 is None
    ll = _length(v1.x, v1.y, v1.z) * _length(v2.x, v2.y, v2.z)
    if ll > 0.:
        cosa = (v1.x * v2.x + v1.y * v2.y + v1.z * v2.z) / ll
        cos_tol = cos(DEFAULT_ANGLE_TOLERANCE)
        if cosa >= cos_tol:
            return 1
        elif cosa <= -cos_tol:
            return -1
    return 0

cpdef bint isPerpendicular(Vector v1, Vector v2):
    """
    Return 1 if perpendicular and 0 if not perpendicular.
    """
    assert v1 is not None and not v2 is None
    ll = _length(v1.x, v1.y, v1.z) * _length(v2.x, v2.y, v2.z)
    if ll > 0.:
        if fabs(v1.x * v2.x + v1.y * v2.y + v1.z * v2.z) / ll <= sin(DEFAULT_ANGLE_TOLERANCE):
            return True
    return False

cpdef Vector perpendicular(Vector v):
    """
    Create a vector perpendicular to v
    """
    cdef Vector ret
    cdef int i,j,k
    cdef double a,b
    
    k = 2
    if abs(v.y) > abs(v.x):
        if abs(v.z) > abs(v.y):
          # |v.z| > |v.y| > |v.x|
          i = 2
          j = 1
          k = 0
          a = v.z
          b = -v.y
          
        elif abs(v.z) >= abs(v.x):
            # |v.y| >= |v.z| >= |v.x|
            i = 1
            j = 2
            k = 0
            a = v.y
            b = -v.z
            
        else:
            # v.y| > |v.x| > |v.z|
            i = 1
            j = 0
            k = 2
            a = v.y
            b = -v.x
    
    elif abs(v.z) > abs(v.y):
        # |v.x| >= |v.z| > |v.y|
        i = 0
        j = 2
        k = 1
        a = v.x
        b = -v.z
    
    else:
        # |v.x| >= |v.y| >= |v.z|
        i = 0
        j = 1
        k = 2
        a = v.x
        b = -v.y
    
    ret = Vector()
    vals = [None,]*3
    vals[i] = b
    vals[j] = a
    vals[k] = 0.
    
    ret.set(vals)
    return ret
    
X = Vector(1.,0.,0.)
Y = Vector(0.,1.,0.)
Z = Vector(0.,0.,1.)