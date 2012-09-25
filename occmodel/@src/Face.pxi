# -*- coding: utf-8 -*-

cdef class Face(Base):
    '''
    Face - Reprecent face geometry
    
    The face geometry could be represented by several
    underlying faces (a OpenCASCADE shell) or a single
    face.
    '''
    def __init__(self):
        self.thisptr = new c_OCCFace()
      
    def __dealloc__(self):
        cdef c_OCCFace *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCFace *>self.thisptr
            del tmp
        
    def __str__(self):
        return "Face%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    def __len__(self):
        return self.numFaces()

    def __iter__(self):
        return WireIterator(self)
        
    cpdef Face copy(self):
        '''
        Create copy of face
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Face ret = Face.__new__(Face, None)
        ret.thisptr = occ.copy()
        return ret
    
    cpdef int numWires(self):
        '''
        Return number of wires
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        return occ.numWires()
    
    cpdef int numFaces(self):
        '''
        Return number of faces
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        return occ.numFaces()
        
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
    
    cdef boolean(self, arg, char *op):
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Solid tool
        cdef int ret
        
        assert op in (b'cut',b'common')
        
        if not isinstance(arg, Solid):
            if not isinstance(arg, (tuple,list,set)):
                args = arg,
            else:
                args = arg
            
            solids = []
            origin = Point()
            normal = Vector()
            
            for arg in args:
                if isinstance(arg, (Edge,Wire,Face)):
                    if not arg.hasPlane(origin, normal):
                        raise OCCError('Plane not defined for object')
                    
                    if isinstance(arg, Edge):
                        wire = Wire().createWire(arg)
                    elif isinstance(arg, Wire):
                        wire = arg
                    
                    if not isinstance(arg, Face):
                        face = Face().createFace(wire)
                    else:
                        face = arg
                    
                    # create infinite cutting object
                    # in direction of normal
                    solid = Solid().createPrism(face, normal, True)
                 
                    solids.append(solid)
                 
                elif isinstance(arg, Solid):
                    solids.append(arg)
                
                else:
                    raise OCCError('unknown object type %s' % arg)
                
            if not solids:
                raise OCCError('No objects created')
            
            # create compound of solid objects
            tool = Solid().addSolids(solids)
        else:
            tool = arg
        
        if op == b'cut':
            ret = occ.cut(<c_OCCSolid *>tool.thisptr)
        else:
            ret = occ.common(<c_OCCSolid *>tool.thisptr)
        
        if ret != 0:
            raise OCCError('Failed to create boolean %s' % op)
        
        return self
        
    cpdef cut(self, arg):
        '''
        Create boolean difference inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the face.
        '''
        return self.boolean(arg, 'cut')
        
    cpdef common(self, arg):
        '''
        Create boolean intersection inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the face.
        '''
        return self.boolean(arg, 'common')

cdef class FaceIterator:
    '''
    Iterator of faces
    '''
    cdef c_OCCFaceIterator *thisptr
    
    def __init__(self, Base arg):
        self.thisptr = new c_OCCFaceIterator(<c_OCCBase *>arg.thisptr)
      
    def __dealloc__(self):
        del self.thisptr
            
    def __str__(self):
        return 'FaceIterator%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __iter__(self):
        return self
        
    def __next__(self):
        cdef c_OCCFace *nxt = self.thisptr.next()
        if nxt == NULL:
            raise StopIteration()
        
        cdef Face ret = Face.__new__(Face)
        ret.thisptr = nxt
        return ret