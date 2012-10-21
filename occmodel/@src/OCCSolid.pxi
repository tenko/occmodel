# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

# sweep corner modes
SWEEP_TRANSFORMED = 0
SWEEP_RIGHT_CORNER = 1
SWEEP_ROUND_CORNER = 2

cdef class Solid(Base):
    '''
    Geometry represention solid objects or
    compund solid.
    '''
    def __init__(self):
        self.thisptr = new c_OCCSolid()
      
    def __dealloc__(self):
        cdef c_OCCSolid *tmp
        
        if self.thisptr != NULL:
            tmp = <c_OCCSolid *>self.thisptr
            del tmp
    
    def __str__(self):
        return "Solid%s" % repr(self)
    
    def __repr__(self):
        return "()"
    
    def __len__(self):
        return self.numSolids()
    
    def __iter__(self):
        return FaceIterator(self)
        
    cpdef Solid copy(self, bint deepCopy = False):
        '''
        Create copy of solid
        
        :param deepCopy: If true a full copy of the underlying geometry
                         is done. Defaults to False.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid ret = Solid.__new__(Solid, None)
        
        ret.thisptr = occ.copy(deepCopy)
            
        return ret
    
    cpdef Solid copyFrom(self, Solid solid, bint deepCopy = False):
        '''
        Set self from copy of solid
        
        :param solid: Solid to copy
        :param deepCopy: If true a full copy of the underlying geometry
                         is done. Defaults to False.
        '''
        cdef c_OCCSolid *tmp
        
        # remove object
        tmp = <c_OCCSolid *>self.thisptr
        del tmp
        
        # set to copy
        tmp = <c_OCCSolid *>solid.thisptr
        self.thisptr = tmp.copy(deepCopy)
        
        return self
        
    cpdef int numSolids(self):
        '''
        Return number of solids
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.numSolids()
    
    cpdef int numFaces(self):
        '''
        Return number of faces
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.numFaces()
        
    cpdef Mesh createMesh(self, double factor = .01, double angle = .25,
                          bint qualityNormals = False):
        '''
        Create triangle mesh of solid.
        
        :param factor: deflection from true position
        :param angle: max angle
        :param qualityNormals: create normals by evaluating surface parameters
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCMesh *mesh = occ.createMesh(factor, angle, qualityNormals)
        cdef Mesh ret = Mesh.__new__(Mesh, None)
        
        if mesh == NULL:
            raise OCCError(errorMessage)
        
        ret.thisptr = mesh
        ret.setArrays()
        return ret
        
    cpdef createSolid(self, faces, double tolerance = 0.):
        '''
        Create general solid by sewing together faces
        with the given tolerance.
        
        :param faces: Sequence of faces
        :param tolerance: Sewing operation tolerance.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef vector[c_OCCFace *] cfaces
        cdef int ret
        
        for face in faces:
            cfaces.push_back(<c_OCCFace *>face.thisptr)
        
        ret = occ.createSolid(cfaces, tolerance)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef addSolids(self, solids):
        '''
        Create compund solid from sequence
        of solid objects.
        
        This is usefull for accelerating boolean operation
        where multiple objects are used as the tool.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid solid
        cdef vector[c_OCCSolid *] csolids
        cdef int ret
        
        if isinstance(solids, Solid):
            solid = solids
            csolids.push_back(<c_OCCSolid *>solid.thisptr)
        else:
            for solid in solids:
                csolids.push_back(<c_OCCSolid *>solid.thisptr)
        
        ret = occ.addSolids(csolids)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef createSphere(self, center, double radius):
        '''
        Create sphere from center point and
        radius.
        
        :param center: Center point
        :param radius: Sphere radius
        
        example::
            
            s1 = Solid().createSphere((0.,0.,0.),.5)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cen
        cdef int ret
        
        cen.x = center[0]
        cen.y = center[1]
        cen.z = center[2]
        
        ret = occ.createSphere(cen, radius)
        if not ret:
            raise OCCError(errorMessage)
            
        return self

    cpdef createCylinder(self, p1, p2, double radius):
        '''
        Create cylinder
        
        :param p1: Axis start
        :param p2: Axis end
        :param radius: Cylinder radius
        
        example::
            
            s1 = Solid().createCylinder((0.,0.,0.),(0.,0.,1.), .25)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.createCylinder(cp1, cp2, radius)
        if not ret:
            raise OCCError(errorMessage)
            
        return self

    cpdef createTorus(self, p1, p2, double ringRadius, double radius):
        '''
        Create torus
        
        :param p1: axis start
        :param p2: axis end
        :param ringRadius: ring radius
        :param radius: radius tube section
        
        example::
            
            s1 = Solid().createTorus((0.,0.,0.),(0.,0.,.1), .5, .1)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.createTorus(cp1, cp2, ringRadius, radius)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createCone(self, p1, p2, double radius1, double radius2):
        '''
        Create cone
        
        :param p1: axis start
        :param p2: axis end
        :param radius1: radius at start
        :param radius2: radius at end
        
        example::
            
            s1 = Solid().createCone((0.,0.,0.),(0.,0.,1.), .2, .5)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.createCone(cp1, cp2, radius1, radius2)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createBox(self, p1, p2):
        '''
        Create box from points defining diagonal.
        
        example::
            
            s1 = Solid().createBox((-.5,-.5,-.5),(.5,.5,.5))
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.createBox(cp1, cp2)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef createText(self, double height, double depth, text, fontpath = None):
        '''
        Extrude TTF font data to solids
        
        :height: font height
        :depth: extrusion depth
        :text: text content. Only single line of text (UTF-8)
        :fontpath: path to TTF font file
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef char *c_str
        
        bytetext = unicode(text).encode('UTF-8','ignore')
        c_str = bytetext
        
        if fontpath is None:
            ret = occ.createText(height, depth, c_str, NULL)
        else:
            ret = occ.createText(height, depth, c_str, fontpath)
            
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef createPrism(self, obj, normal, bint isInfinite):
        '''
        Create prism from edge/wire/face in direction of normal.
        
        This solid is infinite/semi-infinite and usefull for cutting and
        intersection operations with regular solids.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef c_OCCStruct3d cnormal
        cdef int ret
        
        if isinstance(obj, (Edge,Wire)):
            face = Face().createFace(obj)
        elif isinstance(obj, Face):
            face = obj
        else:
            raise OCCError('Expected edge, wire or face')
            
        cnormal.x = normal[0]
        cnormal.y = normal[1]
        cnormal.z = normal[2]
        
        ret = occ.createPrism(<c_OCCFace *>face.thisptr, cnormal, isInfinite)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cpdef area(self):
        '''
        Return solid area
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.area()
    
    cpdef volume(self):
        '''
        Return solid volume
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        return occ.volume()
    
    cpdef inertia(self):
        '''
        return intertia of solid with respect
        to center of gravity.
        
        Return Ixx, Iyy, Izz, Ixy, Ixz, Iyz
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] res = occ.inertia()
        return res[0],res[1],res[2],res[3],res[4],res[5]
        
    cpdef centreOfMass(self):
        '''
        return center of mass of solid.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cg = occ.centreOfMass()
        return cg.x,cg.y,cg.z
        
    cpdef extrude(self, obj, p1, p2):
        '''
        Create solid by extruding edge, wire or face from
        p1 to p2.
        
        :param p1: start point
        :param p2: end point
        
        example::
            
            e1 = Edge().createLine((-.5,0.,0.),(.5,0.,0.))
            e2 = Edge().createArc3P((.5,0.,0.),(-.5,0.,0.),(0.,.5,0.))
            w1 = Wire().createWire((e1,e2))
            f1 = Face().createFace(w1)
            s1 = Solid().extrude(f1, (0.,0.,0.), (0.,0.,1.))
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        if isinstance(obj, (Edge,Wire)):
            face = Face().createFace(obj)
        elif isinstance(obj, Face):
            face = obj
        else:
            raise OCCError('Expected edge, wire or face')
            
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.extrude(<c_OCCFace *>face.thisptr, cp1, cp2)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef revolve(self, Face face, p1, p2, double angle):
        '''
        Create solid by revolving face
        
        :param p1: start of axis
        :param p2: end of axis
        :param angle: revolve angle in radians
        
        example::
            
            e1 = Edge().createEllipse(center=(0.,0.,0.),normal=(0.,0.,1.), rMajor = .5, rMinor=.2)
            f1 = Face().createFace(e1)
            s1 = Solid().revolve(f1, (1.,0.,0.), (1.,1.,0.), pi/2.)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cp1, cp2
        cdef int ret
        
        cp1.x = p1[0]
        cp1.y = p1[1]
        cp1.z = p1[2]
        
        cp2.x = p2[0]
        cp2.y = p2[1]
        cp2.z = p2[2]
        
        ret = occ.revolve(<c_OCCFace *>face.thisptr, cp1, cp2, angle)
        if not ret:
            raise OCCError(errorMessage)
            
        return self
    
    cpdef sweep(self, spine, profiles, int cornerMode = 0):
        '''
        Create solid by sweeping along spine through
        sequence of wires. Optionally the start and
        end can be a vertex.
        
        :param spine: Edge or wire to define sweep path
        :param profiles: Sequence of closed edges, closed wires or
                         optional start and end vertex.
        
        example::
            
            w1 = Wire().createPolygon((
                (0.,0.,0.),
                (0.,0.,1.),
                (.75,0.,1.),
                (.75,0.,0.)),
                close = False
            )
            e1 = Edge().createCircle(center=(0.,0.,0.),normal=(0.,0.,1.),radius = .2)
            s1 = Solid().sweep(w1, e1)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
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
        Create solid by lofting through sequence
        of wires or closed edges.
        
        :param profiles: sequence of closed edges, closed wires and optional
                         a vertex at the start and end.
        :param ruled: Smooth or ruled result shape
        :param tolerance: Operation tolerance.
        
        example::
            
            e1 = Edge().createCircle(center=(.25,0.,0.),normal=(0.,0.,1.),radius = .25)
            e2 = Edge().createCircle(center=(.25,0.,.5),normal=(0.,0.,1.),radius = .5)
            v1 = Vertex(.25,0.,1.)
            s1 = Solid().loft((e1,e2,v1))
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
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
    
    cpdef pipe(self, Face face, path):
        '''
        Create pipe by extruding face along path.
        The path can be a Edge or Wire. Note that the path
        must be C1 continious.
        
        example::
            
            e1 = Edge().createHelix(.4, 1., .4)
            e2 = Edge().createCircle(center=(.5,0.,0.),normal=(0.,1.,0.),radius = 0.1)
            f1 = Face().createFace(e2)
            s1 = Solid().pipe(f1, e1)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Wire wire
        cdef int ret
        
        if isinstance(path, Edge):
            wire = Wire().createWire((path,))
        else:
            wire = path
                
        ret = occ.pipe(<c_OCCFace *>face.thisptr, <c_OCCWire *>wire.thisptr)
            
        if not ret:
            raise OCCError(errorMessage)
            
        return self
        
    cdef boolean(self, arg, c_BoolOpType op):
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
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
                    if op == BOOL_FUSE:
                        raise OCCError('Solid expected for fuse')
                    
                    if not arg.hasPlane(origin, normal):
                        raise OCCError('Plane not defined for object')
                    
                    isInfinite = True
                    
                    if isinstance(arg, Edge):
                        wire = Wire().createWire(arg)
                    elif isinstance(arg, Wire):
                        wire = arg
                    
                    if not isinstance(arg, Face):
                        face = Face().createFace(wire)
                    else:
                        face = arg
                        isInfinite = False
                    
                    # create semi-infinite or infinite cutting object
                    # in direction of normal
                    solid = Solid().createPrism(face, normal, isInfinite)
                 
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
        
        if op in (BOOL_FUSE, BOOL_CUT, BOOL_COMMON):
            ret = occ.boolean(<c_OCCSolid *>tool.thisptr, op)
        else:
            raise OCCError('uknown operation')
        
        if not ret:
            raise OCCError('Failed to create boolean %s' % op)
        
        return self
        
    cpdef fuse(self, arg):
        '''
        Create boolean union inplace.
        
        Multiple solids are supported.
        '''
        return self.boolean(arg, BOOL_FUSE)
        
    cpdef cut(self, arg):
        '''
        Create boolean difference inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the solid.
        
        Edges and wires allways cut through all, but faces
        are limited by the face itself.
        '''
        return self.boolean(arg, BOOL_CUT)
        
    cpdef common(self, arg):
        '''
        Create boolean intersection inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the solid.
        
        Edges and wires allways cut through all, but faces
        are limited by the face itself.
        '''
        return self.boolean(arg, BOOL_COMMON)
    
    cpdef fillet(self, radius, edges = None):
        '''
        Fillet edges inplace.
        
        :param radius: sequence of radiuses or single radius.
        :param edges: sequence of edges or single edge. Setting the argument to
                      None will select all edges (default)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef vector[double] cradius
        cdef Edge edge
        cdef double r
        cdef int ret
        
        if edges is None:
            edges = tuple(EdgeIterator(self))
            
        elif isinstance(edges, Edge):
            edges = (edges,)
            
        for edge in edges:
            cedges.push_back((<c_OCCEdge *>edge.thisptr))
        
        if isinstance(radius, (float, int)):
            radius = (radius,)
        
        for r in radius:
            cradius.push_back(r)
        
        ret = occ.fillet(cedges, cradius)
            
        if not ret:
            raise OCCError(errorMessage)
        
        return self
        
    cpdef chamfer(self, distances, edges = None):
        '''
        Chamfer edges inplace.
        
        :param distances: sequence of distances for each edge or single distance.
        :param edges: sequence of edges or single edge. Setting the argument to
                      None will select all edges (default)
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[c_OCCEdge *] cedges
        cdef vector[double] cdistances
        cdef Edge edge
        cdef double dist
        cdef int ret
        
        if edges is None:
            edges = tuple(EdgeIterator(self))
            
        elif isinstance(edges, Edge):
            edges = (edges,)
            
        for edge in edges:
            cedges.push_back((<c_OCCEdge *>edge.thisptr))
        
        if isinstance(distances, (float, int)):
            distances = (distances,)
        
        for dist in distances:
            cdistances.push_back(dist)
        
        ret = occ.chamfer(cedges, cdistances)
            
        if not ret:
            raise OCCError(errorMessage)
        
        return self
        
    cpdef shell(self, double offset, faces = None, double tolerance = 1e-4):
        '''
        Apply shell operation on solid.
        
        :param faces: sequence of faces or single face. If no argument is
                      supplied the first face is selected.
        :param offset: shell offset distance
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[c_OCCFace *] cfaces
        cdef Face face
        cdef int ret
        
        if faces is None:
            faces = next(FaceIterator(self))
            
        if isinstance(faces, Face):
            faces = (faces,)
            
        for face in faces:
            cfaces.push_back((<c_OCCFace *>face.thisptr))
        
        ret = occ.shell(cfaces, offset, tolerance)
            
        if not ret:
            raise OCCError(errorMessage)
        
        return self

    cpdef offset(self, Face face, double offset, double tolerance = 1e-6):
        '''
        Create solid by offseting face given distance.
        
        :param face: face object
        :param offset: offset distance
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret
        
        ret = occ.offset(<c_OCCFace *>face.thisptr, offset, tolerance)
        if not ret:
            raise OCCError(errorMessage)
        
        return self
        
    cpdef section(self, Plane plane):
        '''
        Apply section operation between solid and plane.
        
        :param plane: section plane
        
        Result returned as a face.
        '''
        cdef Face ret = Face.__new__(Face, None)
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCStruct3d cpnt, cnor
        
        cpnt.x = plane.origin.x
        cpnt.y = plane.origin.y
        cpnt.z = plane.origin.z
        
        cnor.x = plane.zaxis.x
        cnor.y = plane.zaxis.y
        cnor.z = plane.zaxis.z
        
        ret.thisptr = occ.section(cpnt, cnor)
        if ret.thisptr == NULL:
            raise OCCError(errorMessage)
            
        return ret

cdef class SolidIterator:
    '''
    Iterator of solids
    '''
    cdef c_OCCSolidIterator *thisptr
    
    def __init__(self, Base arg):
        self.thisptr = new c_OCCSolidIterator(<c_OCCBase *>arg.thisptr)
      
    def __dealloc__(self):
        del self.thisptr
            
    def __str__(self):
        return 'SolidIterator%s' % self.__repr__()
    
    def __repr__(self):
        return '()'
    
    def __iter__(self):
        return self
        
    def __next__(self):
        cdef c_OCCSolid *nxt = self.thisptr.next()
        if nxt == NULL:
            raise StopIteration()
        
        cdef Solid ret = Solid.__new__(Solid)
        ret.thisptr = nxt
        return ret
    
    cpdef reset(self):
        '''Restart iteration'''
        self.thisptr.reset()