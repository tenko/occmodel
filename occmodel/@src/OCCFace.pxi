# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
cdef class Face(Base):
    '''
    Face - Reprecent face geometry
    
    The face geometry could be represented by several
    underlying faces (a OpenCASCADE shell) or a single
    face.
    '''
    def __init__(self, arg = None):
        '''
        Create empty Face or a planar Face from
        given closed Edge or Wire.
        '''
        self.thisptr = new c_OCCFace()
        if not arg is None:
            self.createFace(arg)
      
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
        
    cpdef Face copy(self, bint deepCopy = False):
        '''
        Create copy of face
        
        :param deepCopy: If true a full copy of the underlying geometry
                         is done. Defaults to False.
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Face ret = Face.__new__(Face, None)
        
        ret.thisptr = occ.copy(deepCopy)
            
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
        
    cpdef Mesh createMesh(self, double factor = .01, double angle = .25,
                          bint qualityNormals = False):
        '''
        Create triangle mesh of face.
        
        :param factor: deflection from true position
        :param angle: max angle
        :param qualityNormals: create normals by evaluating surface parameters
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef c_OCCMesh *mesh = occ.createMesh(factor, angle, qualityNormals)
        cdef Mesh ret = Mesh.__new__(Mesh, None)
        
        if mesh == NULL:
            raise OCCError(errorMessage)
        
        ret.thisptr = mesh
        ret.setArrays()
        return ret
    
    cpdef createFace(self, arg):
        '''
        Create planar face from one or more wires or
        closed edges.
        
        The first argument must be the outer contour.
        Additional arguments define holes in the face.
        
        example::
            
            w1 = Wire().createRectangle(width = 1., height = 1., radius = 0.)
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .25)
            f1 = Face().createFace((w1, e1))
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCWire *] cwires
        cdef Wire wire
        
        if isinstance(arg, (Edge,Wire)):
            arg = (arg,)
        
        ref = []
        for obj in arg:
            if isinstance(obj, Edge):
                wire = Wire().createWire(obj)
                # keep reference to avoid to be bitten by
                # the garbage collector.
                ref.append(wire)
            else:
                wire = obj
                
            if not wire.hasPlane():
                raise OCCError('Plane not defined for object')
                        
            cwires.push_back(<c_OCCWire *>wire.thisptr)
            
        if not occ.createFace(cwires):
            raise OCCError(errorMessage)
        
        return self
        
    cpdef createConstrained(self, edges, points = None):
        '''
        Create general face constrained by edges
        and optional points.
        
        :param edges: sequence of face edges
        :param points: optional sequence of point constraints
        
        example::
            
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .5)
            f1 = Face().createConstrained(e1, ((0.,.0,.25),))
        '''
        cdef Edge edge
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef vector[c_OCCStruct3d] cpoints
        cdef c_OCCStruct3d tmp
        cdef int ret
        
        if isinstance(edges, Edge):
            edge = edges
            cedges.push_back(<c_OCCEdge *>edge.thisptr)
        else:
            for edge in edges:
                cedges.push_back(<c_OCCEdge *>edge.thisptr)
        
        if points:
            for point in points:
                tmp.x = point[0]
                tmp.y = point[1]
                tmp.z = point[2]
                cpoints.push_back(tmp)
            
        ret = occ.createConstrained(cedges, cpoints)
        if not ret:
            raise OCCError(errorMessage)
            
        if not self.isValid() or self.isNull():
            raise OCCError('Failed to create face')
            
        return self
      
    cpdef createPolygonal(self, points):
        '''
        Create polygonal face from given
        points. The points must lie in a
        common plane.
        
        example::
            
            pnts = ((-.5,-.5,0.), (0.,.5,0.), (1.,.5,0.), (.5,-.5,0.))
            f1 = Face().createPolygonal(pnts)
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCStruct3d] cpoints
        cdef c_OCCStruct3d tmp
        
        for point in points:
            tmp.x = point[0]
            tmp.y = point[1]
            tmp.z = point[2]
            cpoints.push_back(tmp)
        
        if not occ.createPolygonal(cpoints):
            raise OCCError(errorMessage)
            
        if not self.isValid() or self.isNull():
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
        cdef c_OCCStruct3d cg = occ.centreOfMass()
        return cg.x,cg.y,cg.z
        
    
    cpdef offset(self, double offset, double tolerance = 1e-6):
        '''
        Offseting face given distance.
        
        :param offset: offset distance
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef int ret
        
        ret = occ.offset(offset, tolerance)
        if not ret:
            raise OCCError(errorMessage)
        
        return self
        
    cpdef extrude(self, Base shape, p1, p2):
        '''
        Create extrusion face.
        
        :param shape: Wire or edge
        :param p1: start point
        :param p2: end point.
        
        example::
            
            e1 = Edge().createArc(start = (-.5,-.25,0.), end = (.5,.75,0.), center = (.5,-.25,0.))
            f1 = Face().extrude(e1, (0.,0.,0.), (0.,0.,1.))
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.extrude(<c_OCCBase *>shape.thisptr, cp1, cp2)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef revolve(self, Base shape, p1, p2, double angle):
        '''
        Create by revolving shape.
        
        :param shape: Edge or wire.
        :param p1: Start point of axis
        :param p2: End point of axis
        :param angle: Angle in radians
        
        example::
            
            pnts = ((0.,0.,0.), (0.,1.,0.), (1.,.5,0.), (1.,0.,0.))
            e1 = Edge().createBezier(points = pnts)
            f1 = Face().revolve(e1, (0.,-1.,0.), (1.,-1.,0.), pi/2.)
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.revolve(<c_OCCBase *>shape.thisptr, cp1, cp2, angle)
        if not ret:
            raise OCCError(errorMessage)
            
        return self

    cpdef sweep(self, spine, profiles, int cornerMode = 0):
        '''
        Create face by sweeping along spine through
        sequence of shapes. Optionally the start and
        end can be a vertex.
        
        :param spine: Edge or wire to define sweep path
        :param profiles: Sequence of edges, wires or optional
                         start and end vertex.
        
        example::
            
            e1 = Edge().createArc((0.,0.,0.), (1.,0.,1.), (1.,0.,0.))
            e2 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .25)
            f1 = Face().sweep(e1, e2)
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCBase *] cprofiles
        cdef Wire cspine
        cdef Base cobj
        cdef int ret
        
        if isinstance(spine, Edge):
            cspine = Wire().createWire((spine,))
        else:
            cspine = spine
        
        if not isinstance(profiles, (tuple, list)):
            profiles = (profiles,)
        
        ref = []        
        for obj in profiles:
            if isinstance(obj, Edge):
                obj = Wire().createWire((obj,))
                # keep reference to temporary object
                ref.append(obj)
            elif not isinstance(obj, (Wire, Vertex)):
                raise OCCError('Expected wire, edge or vertex')
            cobj = obj
            cprofiles.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = occ.sweep(<c_OCCWire *>cspine.thisptr, cprofiles, cornerMode)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef loft(self, profiles, bint ruled = True, double tolerance = 1e-6):
        '''
        Create face by lofting through profiles.
        
        :param profiles: sequence of edges, wires and optional a vertex
                         at the start and end.
        :param ruled: Smooth or ruled result shape
        :param tolerance: Operation tolerance.
        
        example::
            
            e1 = Edge().createArc((0.,0.,0.),(1.,0.,1.),(1.,0.,0.))
            e2 = Edge().createArc((0.,1.,0.),(2.,1.,2.),(2.,1.,0.))
            f1 = Face().loft((e1,e2))
        '''
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef vector[c_OCCBase *] cprofiles
        cdef Base cobj
        cdef int ret
        
        ref = []
        for obj in profiles:
            if isinstance(obj, Edge):
                obj = Wire().createWire((obj,))
                # keep reference to temporary object
                ref.append(obj)
            elif not isinstance(obj, (Wire, Vertex)):
                raise OCCError('Expected wire, edge or vertex')
            cobj = obj
            cprofiles.push_back((<c_OCCBase *>cobj.thisptr))
        
        ret = occ.loft(cprofiles, ruled, tolerance)
        
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cdef boolean(self, arg, c_BoolOpType op):
        cdef c_OCCFace *occ = <c_OCCFace *>self.thisptr
        cdef Solid tool
        cdef int ret
        
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
        
        if op in (BOOL_CUT, BOOL_COMMON):
            ret = occ.boolean(<c_OCCSolid *>tool.thisptr, op)
        else:
            raise OCCError('uknown operation')
        
        if not ret:
            raise OCCError('Failed to create boolean %s' % op)
        
        return self
        
    cpdef cut(self, arg):
        '''
        Create boolean difference inplace.
        The face must be planar and the operation
        must result in a single face.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the face.
        '''
        return self.boolean(arg, BOOL_CUT)
        
    cpdef common(self, arg):
        '''
        Create boolean intersection inplace.
        The face must be planar and the operation
        must result in a single face.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the face.
        '''
        return self.boolean(arg, BOOL_COMMON)

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

    cpdef reset(self):
        '''Restart iteration'''
        self.thisptr.reset()