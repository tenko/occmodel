# -*- coding: utf-8 -*-

cdef class Point:
    '''
    Class representing a 3D point in space
    '''
    cdef public double x, y, z
    
    def __init__(self, *args):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        self.x = 0.
        self.y = 0.
        self.z = 0.
        self.set(*args)
        
    def __repr__(self):
        """Return string representation of a point.
        """
        return '(%s, %s, %s)' % (str(self.x), str(self.y), str(self.z))
    
    def __str__(self):
        """Return string representation of a point.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
    
    def __getitem__(self, int key):
        """Override the list __getitem__ function to
        return a new point rather than a list.
        """
        if key == 0:
            return self.x
        elif key == 1:
            return self.y
        elif key == 2:
            return self.z
        raise IndexError('index out of range')
    
    def __len__(self):
        "Length of sequence"
        return 3
    
    def __richcmp__(a, b, int op):
        cdef Point pa, pb
        
        if (not isinstance(a, Point) or not isinstance(b, Point)):
            if op==3:
                return 1
            else:
                return 0
                
        pa = a
        pb = b
        
        # <
        if op == 0:
            return pa.x < pb.x and pa.y < pb.y and pa.z < pb.z
        # <=
        elif op == 1:
            return pa.x - EPSILON <= pb.x or \
                   pa.y - EPSILON <= pb.y or \
                   pa.z - EPSILON <= pb.z
        # ==
        elif op == 2:
            return fabs(pa.x - pb.x) <= EPSILON and \
                   fabs(pa.y - pb.y) <= EPSILON and \
                   fabs(pa.z - pb.z) <= EPSILON
        # !=
        elif op == 3:
            return fabs(pa.x - pb.x) > EPSILON or \
                   fabs(pa.y - pb.y) > EPSILON or \
                   fabs(pa.z - pb.z) > EPSILON
        # >
        elif op == 4:
            return pa.x > pb.x and pa.y > pb.y and pa.z > pb.z
        # >=
        else:
            return pa.x + EPSILON >= pb.x or \
                   pa.y + EPSILON >= pb.y or \
                   pa.z + EPSILON >= pb.z
            
    def __abs__(self):
        """Return absolute value of point: abs(v)
        """
        cdef Point ret = Point.__new__(Point)
        
        ret.x = fabs(self.x)
        ret.y = fabs(self.y)
        ret.z = fabs(self.z)
        
        return ret

    def __neg__(self):
        """Return negated value of point: -v
        """
        cls = self.__class__
        cdef Point ret = cls.__new__(cls)
        
        ret.x = -self.x
        ret.y = -self.y
        ret.z = -self.z
        
        return ret

    def __pos__(self):
        """Return positive value of point: +v
        """
        cls = self.__class__
        cdef Point ret = cls.__new__(cls)
        
        ret.x = self.x
        ret.y = self.y
        ret.z = self.z
        
        return ret
        
    def __add__(Point self, Point rhs not None):
        """Point addition
        The arguments must be of same length
        """
        cls = self.__class__
        cdef Point ret = cls.__new__(cls)
        
        ret.x = self.x + rhs.x
        ret.y = self.y + rhs.y
        ret.z = self.z + rhs.z
        
        return ret
    
    def __iadd__(self, Point rhs not None):
        """Inline Point addition ( p1 += p2)
        The arguments must be of same length
        """
        self.x += rhs.x
        self.y += rhs.y
        self.z += rhs.z
        return self
    
    def __sub__(Point self, Point rhs not None):
        """Point subtraction
        The arguments must be of same length
        """
        cls = self.__class__
        cdef Point ret = cls.__new__(cls)
        
        ret.x = self.x - rhs.x
        ret.y = self.y - rhs.y
        ret.z = self.z - rhs.z
        
        return ret
    
    def __isub__(self, Point rhs not None):
        """Inline Point subtraction ( p1 -= p2)
        The arguments must be of same length
        """
        self.x -= rhs.x
        self.y -= rhs.y
        self.z -= rhs.z
        return self
    
    def __mul__(lhs, rhs):
        """Point multiplication
        We accept multiplication by a scalar,
        and a 4x4 transformation matrix.
        """
        cdef Transform m
        cdef Point p
        cdef double s, w, x, y, z
        cdef int tlhs, trhs
        cdef Point ret
        
        tlhs = isinstance(lhs, Point)
        trhs = isinstance(rhs, Point)
        
        if not tlhs: # Lhs scalar
            cls = rhs.__class__
            ret = cls.__new__(cls)
            s = lhs
            p = rhs
            ret.x = s * p.x
            ret.y = s * p.y
            ret.z = s * p.z
            
        elif not trhs: # Not point
            cls = lhs.__class__
            ret = cls.__new__(cls)
            p = lhs
            try:
                s = rhs
                ret.x = s * p.x
                ret.y = s * p.y
                ret.z = s * p.z
                
            except TypeError:
                m = rhs
                ret.x = m.m[0][0]*p.x + m.m[0][1]*p.y + m.m[0][2]*p.z + m.m[0][3]
                ret.y = m.m[1][0]*p.x + m.m[1][1]*p.y + m.m[1][2]*p.z + m.m[1][3]
                ret.z = m.m[2][0]*p.x + m.m[2][1]*p.y + m.m[2][2]*p.z + m.m[2][3]
        
        return ret

    def __imul__(self, rhs):
        """Inline Point multiplication (v1 *= s1)
        We accept multiplication by scalar and
        a 4x4 transformation matrix.
        """
        cdef double s, x, y, z
        
        try:
            s = rhs
            self.x *=s
            self.y *= s
            self.z *= s
        except TypeError:
            x = rhs[0][0]*self.x + rhs[0][1]*self.y + rhs[0][2]*self.z + rhs[0][3]
            y = rhs[1][0]*self.x + rhs[1][1]*self.y + rhs[1][2]*self.z + rhs[1][3]
            z = rhs[2][0]*self.x + rhs[2][1]*self.y + rhs[2][2]*self.z + rhs[2][3]
            self.x = x
            self.y = y
            self.z = z
        
        return self
    
    def __div__(lhs, rhs):
        """Point division by scalar.
        """
        cdef Point ret
        cdef double s
        
        try:
            s = lhs
            cls = rhs.__class__
            ret = cls.__new__(cls)
            ret.x = s / rhs.x
            ret.y = s / rhs.y
            ret.z = s / rhs.z
        except:
            s = rhs
            cls = lhs.__class__
            ret = cls.__new__(cls)
            ret.x = lhs.x / s
            ret.y = lhs.y / s
            ret.z = lhs.z / s
        
        return ret

    def __idiv__(self, double rhs):
        """Inline Point division by scalar. (p1 /= 2.)
        """
        self.x /= rhs
        self.y /= rhs
        self.z /= rhs
        return self
    
    def set(self, *args):
        """Set one or more coordinates.
        accept both multiple argument and
        sequence like arguments.
        """
        cdef int l
        
        if len(args) == 1:
            args = args[0]
            if isinstance(args, float) or isinstance(args, int):
                args  = (args,)
        
        l = len(args)
        if l == 3:
            self.x, self.y, self.z = args
        elif l == 2:
            self.x, self.y = args
        elif l == 1:
            self.x = args[0]
        elif l != 0:
            raise ValueError("Expected one, two or three numbers.")
        
    cpdef bint isZero(self):
        """Check if arg is all zeros.
        """
        if self.x <= ZERO_TOLERANCE and self.y <= ZERO_TOLERANCE and self.z <= ZERO_TOLERANCE:
            return True
        else:
            return False
        
    cpdef int maximumCoordinateIndex(self):
        if fabs(self.y) > fabs(self.x):
            if fabs(self.z) > fabs(self.y):
                return 2
            else:
                return 1
        elif fabs(self.z) > fabs(self.x):
            return 2
        else:
            return 0
    
    cpdef double maximumCoordinate(self):
        cdef double c
        c = fabs(self.x)
        if fabs(self.y) > c:
            c = fabs(self.y)
        if fabs(self.z) > c:
            c = fabs(self.z)
        return c
        
    cpdef double distanceTo(self, Point arg):
        """Compute distance between 2 points.
        """
        if arg is None:
            raise TypeError("Expected 'Point' argument")
            
        return _length(arg.x - self.x, arg.y - self.y, arg.z - self.z)
            
def Polar(*args):
    """
    Create a 3d point from polar coords.
    We accept both multiple argument
    and sequence like arguments.
    """
    cdef int l
    cdef double rho, theta, phi, r, z
    
    rho = 0.
    theta = 0.
    phi = 0.
    
    if len(args) == 1:
        args = args[0]
        if isinstance(args, float) or isinstance(args, int):
            args  = (args,)
    
    l = len(args)
    if l == 3:
        rho, theta, phi = args
    elif l == 2:
        rho, theta = args
    else:
        raise ValueError("Expected two or three numbers.")
            
    r = rho * cos(phi)
    z = rho * sin(phi)
    return Point(r * cos(theta), r * sin(theta), z)

cpdef double distance(Point u, Point v):
    """Compute distance between 2 points.
    """
    if u is None or v is None:
        raise TypeError("Expected 'Point' argument")
            
    return _length(v.x - u.x, v.y - u.y, v.z - u.z)