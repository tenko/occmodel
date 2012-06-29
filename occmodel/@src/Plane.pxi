# -*- coding: utf-8 -*-

cdef class Plane:
    '''
    Class representing a mathematical infinite plane.
    '''
    cdef readonly Point origin
    cdef readonly Vector xaxis
    cdef readonly Vector yaxis
    cdef readonly Vector zaxis
    
    cdef readonly double a
    cdef readonly double b
    cdef readonly double c
    cdef readonly double d
    
    def __init__(self, origin = Point(), xaxis = Vector(-1.,0.,0.),
                 yaxis = Vector(0.,-1.,0.)):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        self.origin = Point(origin)
        
        self.xaxis = Vector(xaxis)
        self.xaxis.unit()
        
        self.yaxis = Vector(yaxis)
        self.yaxis.set(self.yaxis - dot(self.yaxis, self.xaxis) * self.xaxis)
        self.yaxis.unit()
        
        self.zaxis = cross(self.xaxis, self.yaxis)
        self.zaxis.unit()
        
        self._UpdateEquation()
        
    def __repr__(self):
        """Return string representation of a plane.
        """
        return '%s(%s, %s, %s)' % (self.__class__.__name__, str(self.origin), str(self.xaxis), str(self.yaxis))
    
    def __str__(self):
        """Return string representation of a plane.
        """
        return '(%s, %s, %s)' % (str(self.origin), str(self.xaxis), str(self.yaxis))
    
    cpdef ValueAt(self, pnt):
        return self.a*pnt[0] + self.b*pnt[1] + self.c*pnt[2] + self.d
        
    cpdef _UpdateEquation(self):
        cdef Point P
        cdef double a,b,c,d
        
        P = self.origin
        a,b,c = self.zaxis
        
        d = -(a*P.x + b*P.y + c*P.z)
        
        self.a, self.b = a, b
        self.c, self.d = c, d

    cpdef double distanceTo(self, pnt):
        """
        Signed distance from plane to pnt
        """
        return dot(Vector(Point(pnt) - self.origin), self.zaxis)
    
    cpdef Point closestPoint(self, pnt):
        """
        Return closest point on plane
        """
        cdef Vector v
        cdef Point ret = Point.__new__(Point)
        
        v = Vector(Point(pnt) - self.origin)
        s = dot(v, self.xaxis)
        t = dot(v, self.yaxis)
        v = s*self.xaxis + t*self.yaxis
        
        ret.x = self.origin.x + v.x
        ret.y = self.origin.y + v.y
        ret.z = self.origin.z + v.z
        
        return ret
        
    cpdef intersectLine(self, start, end):
        """
        Find intersection with line defined
        by the points start and end
        """
        cdef double a,b
        cdef double t,s
        cdef double x,y,z
        
        a = self.ValueAt(start)
        b = self.ValueAt(end)
        
        if a - b == 0.:
            return None
            
        t = a/(a - b)
        s = 1. - t
        
        x = s*start[0] + t*end[0]
        y = s*start[1] + t*end[1]
        z = s*start[2] + t*end[2]
        
        return (x,y,z)
    
    cpdef flip(self):
        """
        Flip direction of normal
        """
        self.xaxis, self.yaxis = self.yaxis, self.xaxis
        self.zaxis = -self.zaxis
        
        self._UpdateEquation()
    
    cpdef transform(self, Transform trans):
        """
        Transform plane
        """
        cdef Vector origin, xaxis, yaxis
        
        if trans is None:
            raise TypeError('Expected transform object')
            
        origin = Vector(trans.map(self.origin))
        xaxis = Vector(trans.map(Vector(self.origin) + self.xaxis)) - origin
        yaxis = Vector(trans.map(Vector(self.origin) + self.yaxis)) - origin
        
        # fromFrame inline
        self.origin.set(origin)
        
        self.xaxis.set(xaxis)
        self.xaxis.unit()
        
        self.yaxis.set(yaxis - dot(yaxis, self.xaxis) * self.xaxis)
        self.yaxis.unit()
        
        self.zaxis.set(cross(self.xaxis, self.yaxis))
        self.zaxis.unit()
        
        self._UpdateEquation()
        
    def fromFrame(cls, origin, xaxis, yaxis):
        cdef Plane ret = cls()
        
        ret.origin.set(origin)
        
        ret.xaxis.set(xaxis)
        ret.xaxis.unit()
        
        ret.yaxis.set(yaxis)
        ret.yaxis.set(ret.yaxis - dot(ret.yaxis, ret.xaxis) * ret.xaxis)
        ret.yaxis.unit()
        
        ret.zaxis.set(cross(ret.xaxis, ret.yaxis))
        ret.zaxis.unit()
        
        ret._UpdateEquation()
        
        return ret
    
    fromFrame = classmethod(fromFrame)
    
    def fromNormal(cls, origin, normal):
        cdef Plane ret = cls()
        
        ret.origin.set(origin)
        
        ret.zaxis.set(normal)
        ret.zaxis.unit()
        
        ret.xaxis.set(perpendicular(ret.zaxis))
        ret.xaxis.unit()
        
        ret.yaxis.set(cross(ret.zaxis, ret.xaxis))
        ret.yaxis.unit()
        
        ret._UpdateEquation()
        
        return ret
    
    fromNormal = classmethod(fromNormal)