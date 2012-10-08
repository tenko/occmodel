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
            
    cdef CheckPtr(self):
        if self.thisptr == NULL:
            raise TypeError('Base object not initialized')
    
    cpdef shapeType(self):
        '''
        Return class type or None if shape not known.
        '''
        self.CheckPtr()
        
        if self.isNull():
            raise OCCError('No type defined for Null shape')
            
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef c_TopAbs_ShapeEnum shapetype = occ.shapeType()
            
        if shapetype == TopAbs_COMPSOLID or \
           shapetype == TopAbs_SOLID:
               return Solid
        elif shapetype == TopAbs_SHELL or \
           shapetype == TopAbs_FACE:
               return Face
        elif shapetype == TopAbs_WIRE:
               return Wire
        elif shapetype == TopAbs_EDGE:
               return Edge
        elif shapetype == TopAbs_VERTEX:
               return Vertex
        else:
            return None
            
    cpdef hashCode(self):
        '''
        Shape hash code.
        
        Orientation is not included in the hash calculation. Instances of
        the same object therfore return the same hash code.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.hashCode()
        
    cpdef bint isEqual(self, Base other):
        '''
        Check object for equallity. Returns True only if both the
        underlying geometry and location is similar.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isEqual(<c_OCCBase *>other.thisptr)
    
    cpdef bint isNull(self):
        '''
        Check if object is Null.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isNull()
        
    cpdef bint isValid(self):
        '''
        Return if object is valid.
        '''
        self.CheckPtr()
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        return occ.isValid()
    
    cpdef bint hasPlane(self, Point origin = None, Vector normal = None, double tolerance = 1e-12):
        '''
        Check if object has plane defined. Optional pass origin and normal
        argument to fetch the plane definition.
        
        :param origin: Plane origin
        :param normal: Plane normal
        :param tolerance: Plane tolerance
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
        
        :param tolerance: Tolerance of calculation.
        '''
        self.CheckPtr()
            
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox(tolerance)
        cdef Box ret = Box.__new__(Box, None)
        
        ret.near = Point(bbox[0], bbox[4], bbox[2])
        ret.far = Point(bbox[3], bbox[1], bbox[5])
        return ret
    
    cpdef transform(self, Transform mat, bint copy = False):
        '''
        Apply transformation matrix to object.
        
        :param mat: Transformation matrix
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
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
            raise OCCError(errorMessage)
            
        return target
        
    cpdef translate(self, delta, bint copy = False):
        '''
        Translate object.
        
        :param delta: translation vector (dx,dy,dz)
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
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
            raise OCCError(errorMessage)
            
        return target
    
    cpdef rotate(self, double angle, axis, center = (0.,0.,0.), bint copy = False):
        '''
        Rotate object.
        
        :param angle: rotation angle in radians
        :param axis: axis vector
        :param center: rotation center
        :param copy: If True the object is transformed in place otherwise a
                     new transformed object is returned.
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
        
        axis = Vector(axis)
        p1 = Point(center)
        p2 = p1 + axis
        
        
        cp1.push_back(p1.x)
        cp1.push_back(p1.y)
        cp1.push_back(p1.z)
        
        cp2.push_back(p2.x)
        cp2.push_back(p2.y)
        cp2.push_back(p2.z)
        
        ret = occ.rotate(angle, cp1, cp2, <c_OCCBase *>target.thisptr)
        if ret != 0:
            raise OCCError(errorMessage)
            
        return target

    cpdef scale(self, pnt, double scale, bint copy = False):
        '''
        Scale object.
        
        :param pnt: reference point
        :param scale: scale factor
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
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
            raise OCCError(errorMessage)
            
        return target

    cpdef mirror(self, Plane plane, bint copy = False):
        '''
        Mirror object
        
        :param plane: mirror plane
        :param copy: If True the object is translated in place otherwise a
                     new translated object is returned.
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
            raise OCCError(errorMessage)
            
        return target
        
    cpdef toString(self):
        '''
        Seralize object to string.
        
        The format used is the OpenCASCADE internal BREP format.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef string res = string()
        
        occ.toString(&res)
        ret = str(res.c_str())
        
        return ret
    
    cpdef fromString(self, char *st):
        '''
        Restore shape from string.
        
        The format used is the OpenCASCADE internal BREP format.
        '''
        self.CheckPtr()
        
        cdef c_OCCBase *occ = <c_OCCBase *>self.thisptr
        cdef string cst= string(st)
        
        if occ.fromString(cst) != 0:
            raise OCCError(errorMessage)
        
        return self