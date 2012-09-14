# -*- coding: utf-8 -*-

cdef class Face:
    '''
    Face - Reprecent face geometry (surface)
    '''
    cdef void *thisptr
    
    def __init__(self):
        self.thisptr = new c_OCCFace()
      
    def __dealloc__(self):
        cdef c_OCCFace *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCFace *>self.thisptr
            del tmp
    
    cdef void *getNativePtr(self):
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        return occ.getNativePtr()
        
    def __str__(self):
        return "Face%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    cpdef Face copy(self):
        '''
        Create copy of face
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Face ret = Face.__new__(Face, None)
        ret.thisptr = occ.copy()
        return ret
        
    cpdef Mesh createMesh(self, double factor = .01, double angle = .25):
        '''
        Create triangle mesh of face.
        
        factor - deflection from true position
        angle - max angle
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef c_OCCMesh *mesh = occ.createMesh(factor, angle)
        cdef Mesh ret = Mesh.__new__(Mesh, None)
        
        if mesh == NULL:
            raise OCCError('Failed to create mesh')
        
        ret.thisptr = mesh
        return ret
    
    cpdef createFace(self, arg):
        '''
        Create from wire or single closed edge.
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Wire wire
        
        if isinstance(arg, Edge):
            wire = Wire().createWire((arg,))
        else:
            wire = arg
            
        occ.createFace(<c_OCCWire *>wire.thisptr)
        
        return self
        
    cpdef createConstrained(self, edges, points = None):
        '''
        Create general face constrained by edges
        and optional points.
        
        edges - sequence of face edges
        points - optional sequence of point constraints
        '''
        cdef Edge edge
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef vector[vector[double]] cpoints
        cdef vector[double] tmp
        cdef int ret
        
        if isinstance(edges, Edge):
            edge = edges
            cedges.push_back(<c_OCCEdge *>edge.thisptr)
        else:
            for edge in edges:
                cedges.push_back(<c_OCCEdge *>edge.thisptr)
        
        if points:
            for point in points:
                tmp.clear()
                tmp.push_back(point[0])
                tmp.push_back(point[1])
                tmp.push_back(point[2])
                cpoints.push_back(tmp)
            
        ret = occ.createConstrained(cedges, cpoints)
        if ret != 0:
            raise OCCError('Failed to create face')
            
        return self
    
    cpdef Box boundingBox(self):
        '''
        Return face bounding box
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] bbox = occ.boundingBox()
        cdef Box ret = Box.__new__(Box, None)
        ret.near = Point(bbox[0], bbox[1], bbox[2])
        ret.far = Point(bbox[3], bbox[4], bbox[5])
        return ret
    
    cpdef translate(self, delta):
        '''
        Translate face in place.
        
        delta - (dx,dy,dz)
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cdelta
        cdef int ret
        
        cdelta.push_back(delta[0])
        cdelta.push_back(delta[1])
        cdelta.push_back(delta[2])
        
        ret = occ.translate(cdelta)
        if ret != 0:
            raise OCCError('Failed to translate face')
            
        return self
    
    cpdef rotate(self, p1, p2, angle):
        '''
        Rotate face in place.
        
        p1 - axis start point
        p2 - axis end point
        angle - rotation angle in radians
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.rotate(cp1, cp2, angle)
        if ret != 0:
            raise OCCError('Failed to rotate face')
            
        return self

    cpdef scale(self, pnt, double scale):
        '''
        Scale face in place.
        
        pnt - reference point
        scale - scale factor
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cpnt
        cdef int ret
        
        cpnt.push_back(pnt[0])
        cpnt.push_back(pnt[1])
        cpnt.push_back(pnt[2])
        
        ret = occ.scale(cpnt, scale)
        if ret != 0:
            raise OCCError('Failed to scale face')
            
        return self
    
    cpdef mirror(self, Plane plane):
        '''
        Mirror face inplace
        
        plane - mirror plane
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cpnt, cnor
        cdef int ret
        
        cpnt.push_back(plane.origin.x)
        cpnt.push_back(plane.origin.y)
        cpnt.push_back(plane.origin.z)
        
        cnor.push_back(plane.zaxis.x)
        cnor.push_back(plane.zaxis.y)
        cnor.push_back(plane.zaxis.z)
        
        ret = occ.mirror(cpnt, cnor)
        if ret != 0:
            raise OCCError('Failed to mirror face')
            
        return self
        
    cpdef createPolygonal(self, points):
        '''
        Create polygonal face from given
        points.
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[vector[double]] cpoints
        cdef vector[double] tmp
        cdef int ret
        
        for point in points:
            tmp.clear()
            tmp.push_back(point[0])
            tmp.push_back(point[1])
            tmp.push_back(point[2])
            cpoints.push_back(tmp)
        
        ret = occ.createPolygonal(cpoints)
        
        if ret != 0:
            raise OCCError('Failed to create face')
            
        return self
        
    cpdef area(self):
        '''
        Return face area
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        return occ.area()
    
    cpdef inertia(self):
        '''
        return intertia of face with respect
        to center of gravity.
        
        Return Ixx, Iyy, Izz, Ixy, Ixz, Iyz
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] res = occ.inertia()
        return res[0],res[1],res[2],res[3],res[4],res[5]
        
    cpdef centreOfMass(self):
        '''
        Return center of face
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cg = occ.centreOfMass()
        return cg[0],cg[1],cg[2]
        
        
    cpdef extrude(self, Edge edge, p1, p2):
        '''
        Create extrusion face from edge and
        given points p1 and p2.
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.extrude(<c_OCCEdge *>edge.thisptr, cp1, cp2)
        if ret != 0:
            raise OCCError('Failed to create face')
            
        return self
    
    cpdef revolve(self, Edge edge, p1, p2, double angle):
        '''
        Create revolve face from edge and given
        points p1,p2 and angle.
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.revolve(<c_OCCEdge *>edge.thisptr, cp1, cp2, angle)
        if ret != 0:
            raise OCCError('Failed to create face')
            
        return self