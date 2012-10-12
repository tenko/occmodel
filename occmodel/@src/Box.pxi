# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
cdef class Box:
    '''
    Class representing a bounding box
    '''
    cdef public Point near
    cdef public Point far
    
    def __init__(self, near = (-.5, .5, -.5), far = (.5, -.5, .5)):
        self.near = Point(near)
        self.far = Point(far)
        
    def __repr__(self):
        """Return string representation of a box.
        """
        return '(%s, %s)' % (str(self.near), str(self.far))
    
    def __str__(self):
        """Return string representation of a box.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
    
    def __richcmp__(a, b, int op):
        """Rich comparison self == other & self != other"""
        cdef Box pa, pb
        
        if (not isinstance(a, Box) or not isinstance(b, Box)):
            if op==3:
                return 1
            else:
                return 0
                
        pa = a
        pb = b
        
        # ==
        if op == 2:
            return pa.near == pb.near and pa.far == pb.far
        # !=
        elif op == 3:
            return pa.near != pb.near and pa.far != pb.far
        else:
            raise NotImplementedError()
    
    cpdef bint isValid(self):
        """Check validity
        """
        cdef Point near, far
        
        near = self.near
        far = self.far
        return near.x <= far.x and near.y >= far.y and near.z <= far.z
    
    property diagonal:
        'Return diagonal as a vector'
        def __get__(self):
            return Vector(self.far - self.near)
    
    property center:
        'Calculate center of box'
        def __get__(self):
            return .5*(self.near + self.far)
    
    property radius:
        'Return radius of the sphere enclosing the box'
        def __get__(self):
            cdef Point near, far
        
            near = self.near
            far = self.far
            return .5 *sqrt(3. * fmax3(far.x - near.x, near.y - far.y, far.z - near.z) ** 2.)
    
    property volume:
        'Calculate volume of box'
        def __get__(self):
            cdef double dx, dy, dz
            
            if self.isValid():
                dx = self.far.x - self.near.x
                dy = self.far.y - self.near.y
                dz = self.far.z - self.near.z
                
                return fabs(dx * dy * dz)
            else:
                return 0.
    
    cpdef bint isPointIn(self, pnt, bint strictlyIn = False):
        '''
        Check if point is inside box.
        '''
        cdef Point near, far
        cdef double x, y, z
        
        x, y, z = pnt
        
        near = self.near
        far = self.far
        
        if strictlyIn:
            return near.x < x and x < far.x and \
                   near.y > y and y > far.y and \
                   near.z < z and z < far.z 
        else:
            return near.x <= x and x <= far.x and \
                   near.y >= y and y >= far.y and \
                   near.z <= z and z <= far.z 
        
    cpdef addPoint(self, pnt):
        """
        Adjust bounds to include point.
        """
        cdef double x, y, z
        
        x, y, z = pnt
        
        self.near.x = fmin(self.near.x, x)
        self.near.y = fmax(self.near.y, y)
        self.near.z = fmin(self.near.z, z)
        
        self.far.x = fmax(self.far.x, x)
        self.far.y = fmin(self.far.y, y)
        self.far.z = fmax(self.far.z, z)
    
    cpdef addPoints(self, pnts):
        """
        Adjust bounds to include point.
        """
        cdef double x, y, z
        
        for pnt in pnts:
            x, y, z = pnt
            
            self.near.x = fmin(self.near.x, x)
            self.near.y = fmax(self.near.y, y)
            self.near.z = fmin(self.near.z, z)
            
            self.far.x = fmax(self.far.x, x)
            self.far.y = fmin(self.far.y, y)
            self.far.z = fmax(self.far.z, z)
    
    def union(cls, Box a, Box b):
        """Return a new bounding box which is a union of
            the arguments.
        """
        cdef Box c = Box.__new__(Box)
        
        if a.isValid() and b.isValid():
            c.near.x, c.near.y, c.near.z = b.near.x, b.near.y, b.near.z
            c.far.x, c.far.y, c.far.z = b.far.x, b.far.y, b.far.z
            
            if a.near.x <= b.near.x: c.near.x = a.near.x
            if a.near.y >= b.near.y: c.near.y = a.near.y
            if a.near.z >= b.near.z: c.near.z = a.near.z
            
            if a.far.x >= b.far.x: c.far.x = a.far.x
            if a.far.y <= b.far.y: c.far.y = a.far.y
            if a.far.z <= b.far.z: c.far.z = a.far.z
        return c
        
    union = classmethod(union)