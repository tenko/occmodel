# -*- coding: utf-8 -*-

cdef int py_filter_func(void *data, double *near, double *far):
    return (<object>data)((near[0], near[1], near[2]),
                          (far[0], far[1], far[2]))

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
        
        :deepCopy: If true a full copy of the underlying geometry
                   is done. Defaults to False.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid ret = Solid.__new__(Solid, None)
        
        ret.thisptr = occ.copy(deepCopy)
            
        return ret
    
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
        
    cpdef Mesh createMesh(self, double factor = .01, double angle = .25):
        '''
        Create triangle mesh of solid.
        
        factor - deflection from true position
        angle - max angle
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef c_OCCMesh *mesh = occ.createMesh(factor, angle)
        cdef Mesh ret = Mesh.__new__(Mesh, None)
        
        if mesh == NULL:
            raise OCCError('Failed to create mesh')
        
        ret.thisptr = mesh
        return ret
        
    cpdef createSolid(self, faces, double tolerance = 1e-6):
        '''
        Create general solid from sequence of faces
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef vector[c_OCCFace *] cfaces
        cdef int ret
        
        for face in faces:
            cfaces.push_back(<c_OCCFace *>face.thisptr)
        
        ret = occ.createSolid(cfaces, tolerance)
        if ret != 0:
            raise OCCError('Failed to sew faces')
            
        return self
        
    cpdef addSolids(self, solids):
        '''
        Create compund solid from sequence
        of solid objects.
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
        if ret != 0:
            raise OCCError('Failed to add solids')
            
        return self
        
    cpdef createSphere(self, center, double radius):
        '''
        Create sphere from center point and
        radius.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cen
        cdef int ret
        
        cen.push_back(center[0])
        cen.push_back(center[1])
        cen.push_back(center[2])
        
        ret = occ.createSphere(cen, radius)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self

    cpdef createCylinder(self, p1, p2, double radius):
        '''
        Create cylinder
        
        p1 - axis start
        p2 - axis end
        radius - cylinder radius
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createCylinder(cp1, cp2, radius)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self

    cpdef createTorus(self, p1, p2, double radius1, double radius2):
        '''
        Create torus
        
        p1 - axis start
        p2 - axis end
        radius1 - inner radius
        radius2 - outer radius
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createTorus(cp1, cp2, radius1, radius2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef createCone(self, p1, p2, double radius1, double radius2):
        '''
        Create cone
        
        p1 - axis start
        p2 - axis end
        radius1 - radius at start
        radius2 - radius at end
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createCone(cp1, cp2, radius1, radius2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef createBox(self, p1, p2):
        '''
        Create box from points defining diagonal.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.createBox(cp1, cp2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef createPrism(self, obj, normal, bint isInfinite):
        '''
        Create prism from edge/wire/face in direction of normal.
        
        This solid is infinite/semi-infinite and usefull for cutting and
        intersection.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef vector[double] cnormal
        cdef int ret
        
        if isinstance(obj, (Edge,Wire)):
            face = Face().createFace(obj)
        elif isinstance(obj, Face):
            face = obj
        else:
            raise OCCError('Expected edge, wire or face')
            
        cnormal.push_back(normal[0])
        cnormal.push_back(normal[1])
        cnormal.push_back(normal[2])
        
        ret = occ.createPrism(<c_OCCFace *>face.thisptr, cnormal, isInfinite)
        if ret != 0:
            raise OCCError('Failed to create prism solid')
            
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
        cdef vector[double] cg = occ.centreOfMass()
        return cg[0],cg[1],cg[2]
        
    cpdef extrude(self, obj, p1, p2):
        '''
        Create solid by extruding edge, wire or face from
        p1 to p2.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Face face
        cdef vector[double] cp1, cp2
        cdef int ret
        
        if isinstance(obj, (Edge,Wire)):
            face = Face().createFace(obj)
        elif isinstance(obj, Face):
            face = obj
        else:
            raise OCCError('Expected edge, wire or face')
            
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.extrude(<c_OCCFace *>face.thisptr, cp1, cp2)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef revolve(self, Face face, p1, p2, double angle):
        '''
        Create solid by revolving face
        
        p1 - start of axis
        p2 - end of axis
        angle - revolve angle
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cp1, cp2
        cdef int ret
        
        cp1.push_back(p1[0])
        cp1.push_back(p1[1])
        cp1.push_back(p1[2])
        
        cp2.push_back(p2[0])
        cp2.push_back(p2[1])
        cp2.push_back(p2[2])
        
        ret = occ.revolve(<c_OCCFace *>face.thisptr, cp1, cp2, angle)
        if ret != 0:
            raise OCCError('Failed to create solid')
            
        return self
    
    cpdef sweep(self, spine, profiles, int cornerMode = 0):
        '''
        Create solid by sweeping along spine through
        sequence of wires. Optionally the start and
        end can be a vertex.
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
        
        if ret != 0:
            raise OCCError('Failed to perform sweep')
            
        return self
        
    cpdef loft(self, profiles, bint ruled = True, double tolerance = 1e-6):
        '''
        Create solid by lofting through sequence
        of wires or closed edges.
        
        ruled - smooth or rules faces
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
        
        if ret != 0:
            raise OCCError('Failed to loft profiles')
            
        return self
    
    cpdef pipe(self, Face face, path):
        '''
        Create pipe by extruding face allong
        wire or edge.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Wire wire
        cdef int ret
        
        if isinstance(path, Edge):
            wire = Wire().createWire((path,))
        else:
            wire = path
                
        ret = occ.pipe(<c_OCCFace *>face.thisptr, <c_OCCWire *>wire.thisptr)
            
        if ret != 0:
            raise OCCError('Failed to make pipe')
            
        return self
        
    cdef boolean(self, arg, char *op):
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef Solid tool
        cdef int ret
        
        assert op in (b'fuse',b'cut',b'common')
        
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
                    if op == b'fuse':
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
        
        if op == b'fuse':
            ret = occ.fuse(<c_OCCSolid *>tool.thisptr)
        elif op == b'cut':
            ret = occ.cut(<c_OCCSolid *>tool.thisptr)
        elif op == b'common':
            ret = occ.common(<c_OCCSolid *>tool.thisptr)
        else:
            raise OCCError('uknown operation')
        
        if ret != 0:
            raise OCCError('Failed to create boolean %s' % op)
        
        return self
        
    cpdef fuse(self, arg):
        '''
        Create boolean union inplace.
        
        Multiple solids are supported.
        '''
        return self.boolean(arg, 'fuse')
        
    cpdef cut(self, arg):
        '''
        Create boolean difference inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the solid.
        
        Edges and wires allways cut through all, but faces
        are limited by the face itself.
        '''
        return self.boolean(arg, 'cut')
        
    cpdef common(self, arg):
        '''
        Create boolean intersection inplace.
        
        Multiple objects are supported.
        
        Edges, wires and faces are extruded in the normal
        directions to intersect the solid.
        
        Edges and wires allways cut through all, but faces
        are limited by the face itself.
        '''
        return self.boolean(arg, 'common')
    
    cpdef fillet(self, radius, edges = None):
        '''
        Fillet edges inplace.
        
        :radius: sequence of radiuses or single radius.
        :edges: sequence of edges or single edge. Setting the argument to
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
            
        if ret != 0:
            raise OCCError('Failed to create fillet')
        
        return self
        
    cpdef chamfer(self, distances, edges = None):
        '''
        Chamfer edges inplace.
        
        :distances: sequence of distances for each edge or single distance.
        :edges: sequence of edges or single edge. Setting the argument to
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
            
        if ret != 0:
            raise OCCError('Failed to create chamfer')
        
        return self
        
    cpdef shell(self, faces, double offset, double tolerance = 1e-4):
        '''
        Apply shell operation on solid.
        
        :faces: sequence of faces or single face
        :offset: shell offset distance
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[c_OCCFace *] cfaces
        cdef Face face
        cdef int ret
        
        if isinstance(faces, Face):
            faces = (faces,)
            
        for face in faces:
            cfaces.push_back((<c_OCCFace *>face.thisptr))
        
        ret = occ.shell(cfaces, offset, tolerance)
            
        if ret != 0:
            raise OCCError('Shell operation failed')
        
        return self
    
    cpdef section(self, Plane plane):
        '''
        Apply section operation between solid and plane.
        
        plane - section plane
        
        Result returned as a face.
        '''
        cdef Face ret = Face.__new__(Face, None)
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef vector[double] cpnt, cnor
        
        cpnt.push_back(plane.origin.x)
        cpnt.push_back(plane.origin.y)
        cpnt.push_back(plane.origin.z)
        
        cnor.push_back(plane.zaxis.x)
        cnor.push_back(plane.zaxis.y)
        cnor.push_back(plane.zaxis.z)
        
        ret.thisptr = occ.section(cpnt, cnor)
        if ret.thisptr == NULL:
            raise OCCError('Failed to create section')
            
        return ret
        
    cpdef writeSTEP(self, char *filename):
        '''
        Write solid to STEP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeSTEP(filename)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef readSTEP(self, char *filename):
        '''
        Read geometry from STEP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.readSTEP(filename)
        if ret != 0:
            raise OCCError('Failed to read from STEP file')
            
    cpdef writeBREP(self, char *filename):
        '''
        Write solid to BREP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeBREP(filename)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef readBREP(self, char *filename):
        '''
        Read geometry from BREP file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.readBREP(filename)
        if ret != 0:
            raise OCCError('Failed to read from BREP file')
            
    cpdef writeSTL(self, char *filename, bint asciiMode = False):
        '''
        Write solid to STL file.
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        cdef int ret = occ.writeSTL(filename, asciiMode)
        if ret != 0:
            raise OCCError('Failed to write to file')
    
    cpdef heal(self, double tolerance = 0., bint fixdegenerated = True,
                     bint fixsmalledges = True, bint fixspotstripfaces = True, 
                     bint sewfaces = False, bint makesolids = False):
        '''
        Possible heal geometry
        '''
        cdef c_OCCSolid *occ = <c_OCCSolid *>self.thisptr
        occ.heal(tolerance, fixdegenerated, fixsmalledges,
                 fixspotstripfaces, sewfaces, makesolids)

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
        self.thisptr.reset()