# -*- coding: utf-8 -*-

JOINTYPE_ARC = 0
JOINTYPE_TANGENT = 1
JOINTYPE_INTERSECTION = 2

cdef class Base:
    '''
    Definition of virtual base object
    '''
    cdef void *thisptr
    
    def __str__(self):
        return 'Base%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
        
    def __richcmp__(self, other, int op):
        if op == 2:
            return self.isEqual(other)
        elif op == 3:
            return not self.isEqual(other)
        else:
            raise TypeError('operation not supported')
            
    cpdef CheckPtr(self):
        if self.thisptr == NULL:
            raise TypeError('Base object not initialized')
    
    cpdef hashCode(self):
        '''
        Shape hash code.
        
        Orientation is not included in the hash calculation.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.hashCode()
        
    cpdef bint isEqual(self, Base other):
        '''
        Check object for equallity
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isEqual(<c_OCCBase *>other.thisptr)
    
    cpdef bint isNull(self):
        '''
        Check if object is empty.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isNull()
        
    cpdef bint isValid(self):
        '''
        Return if object is valid
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isValid()
    
    cpdef bint hasPlane(self, Point origin = None, Vector normal = None, double tolerance = 1e-12):
        '''
        Check if object has plane defined.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef double corigin[3], cnormal[3]
        
        if occ.findPlane(corigin, cnormal, tolerance) == 1:
            return False
        
        if not normal is None:
            normal.set(cnormal[0], cnormal[1], cnormal[2])
        
        if not origin is None:
            origin.set(corigin[0], corigin[1], corigin[2])
            
        return True
        
    cpdef Box boundingBox(self, double tolerance = 1e-12):
        '''
        Return bounding box
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox(tolerance)
        cdef Box ret = Box.__new__(Box, None)
        
        ret.near = Point(bbox[0], bbox[1], bbox[2])
        ret.far = Point(bbox[3], bbox[4], bbox[5])
        return ret
    
    cpdef transform(self, Transform mat, bint copy = False):
        '''
        Apply transformation matrix to object.
        
        mat - Transformation matrix
        
        If copy is false the object is transformed in place otherwise
        a transformed shallow copy of the object returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cmat
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cmat.push_back(mat.m[0][0])
        cmat.push_back(mat.m[0][1])
        cmat.push_back(mat.m[0][2])
        cmat.push_back(mat.m[0][3])
        
        cmat.push_back(mat.m[1][0])
        cmat.push_back(mat.m[1][1])
        cmat.push_back(mat.m[1][2])
        cmat.push_back(mat.m[1][3])
        
        cmat.push_back(mat.m[2][0])
        cmat.push_back(mat.m[2][1])
        cmat.push_back(mat.m[2][2])
        cmat.push_back(mat.m[2][3])
        
        ret = occ.transform(cmat, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError('Failed to transform object')
            
        return target
        
    cpdef translate(self, delta, bint copy = False):
        '''
        Translate object.
        
        delta - (dx,dy,dz)
        
        If copy is false the object is transformed in place otherwise
        a transformed shallow copy of the object returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cdelta
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cdelta.push_back(delta[0])
        cdelta.push_back(delta[1])
        cdelta.push_back(delta[2])
        
        ret = occ.translate(cdelta, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError('Failed to translate object')
            
        return target
    
    cpdef rotate(self, p1, p2, angle, bint copy = False):
        '''
        Rotate object in place.
        
        p1 - axis start point
        p2 - axis end point
        angle - rotation angle in radians
        
        If copy is false the object is transformed in place otherwise
        a transformed shallow copy of the object returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cp1, cp2
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.rotate(cp1, cp2, angle, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError('Failed to rotate object')
            
        return target

    cpdef scale(self, pnt, double scale, bint copy = False):
        '''
        Scale object in place.
        
        pnt - reference point
        scale - scale factor
        
        If copy is false the object is transformed in place otherwise
        a transformed shallow copy of the object returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cpnt
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.scale(cpnt, scale, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError('Failed to scale object')
            
        return target
    
    cpdef mirror(self, Plane plane, bint copy = False):
        '''
        Mirror object inplace
        
        plane - mirror plane
        
        If copy is false the object is transformed in place otherwise
        a transformed shallow copy of the object returned.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef Base target
        cdef vector[double] cpnt, cnor
        cdef int ret
        
        if copy:
            target = self.__class__()
        else:
            target = self
            
        cpnt.push_back(plane.origin.x)
        cpnt.push_back(plane.origin.y)
        cpnt.push_back(plane.origin.z)
        
        cnor.push_back(plane.zaxis.x)
        cnor.push_back(plane.zaxis.y)
        cnor.push_back(plane.zaxis.z)
        
        ret = occ.mirror(cpnt, cnor, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError('Failed to mirror object')
            
        return target
