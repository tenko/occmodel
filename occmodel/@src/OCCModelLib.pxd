cdef extern from *:
    ctypedef char* const_char_ptr "char*"

cdef extern from "<vector>" namespace "std":
    cdef cppclass vector[T]:
       vector()
       void clear()
       void push_back(T&)
       size_t size()
       T& operator[](size_t)

cdef extern from "OCCModel.h":
    cdef cppclass c_OCCMesh "OCCMesh":
        vector[vector[double]] vertices
        vector[vector[double]] normals
        vector[vector[int]] triangles
        c_OCCMesh()
    
    cdef cppclass c_OCCBase "OCCBase":
        int hashCode()
        bint isEqual(c_OCCBase *other)
        bint isNull()
        bint isValid()
        int transform(vector[double] mat, c_OCCBase *target)
        int translate(vector[double] delta, c_OCCBase *target)
        int rotate(vector[double] p1, vector[double] p2, double angle, c_OCCBase *target)
        int scale(vector[double] pnt, double scale, c_OCCBase *target)
        int mirror(vector[double] pnt, vector[double] nor, c_OCCBase *target)
        vector[double] boundingBox(double tolerance)
        int findPlane(double *origin, double *normal, double tolerance)
        
    cdef cppclass c_OCCVertex "OCCVertex":
        c_OCCVertex(double x, double y, double z)
        double x()
        double y()
        double z()
    
    cdef cppclass c_OCCVertexIterator "OCCVertexIterator":
        c_OCCVertexIterator(c_OCCBase *arg)
        void reset()
        c_OCCVertex *next()
        
    cdef cppclass c_OCCEdge "OCCEdge":
        c_OCCEdge()
        c_OCCEdge *copy(bint deepCopy)
        int numVertices()
        vector[vector[double]] tesselate(double factor, double angle)
        int createLine(c_OCCVertex *v1, c_OCCVertex *v2)
        int createArc(c_OCCVertex *start, c_OCCVertex *end, vector[double] center)
        int createArc3P(c_OCCVertex *start, c_OCCVertex *end, vector[double] pnt)
        int createCircle(vector[double] center, vector[double] normal, double radius)
        int createEllipse(vector[double] pnt, vector[double] nor, double rMajor, double rMinor)
        int createHelix(double pitch, double height, double radius, double angle, bint leftHanded)
        int createBezier(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points)
        int createSpline(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points, double tolerance)
        int createNURBS(c_OCCVertex *start, c_OCCVertex *end, vector[vector[double]] points,
                        vector[double] knots, vector[double] weights, vector[int] mult)
        double length()
    
    cdef cppclass c_OCCEdgeIterator "OCCEdgeIterator":
        c_OCCEdgeIterator(c_OCCBase *arg)
        void reset()
        c_OCCEdge *next()
        
    cdef cppclass c_OCCWire "OCCWire":
        c_OCCWire()
        c_OCCWire *copy(bint deepCopy)
        int numVertices()
        int numEdges()
        vector[vector[double]] tesselate(double factor, double angle)
        int createWire(vector[c_OCCEdge *] edges)
        int offset(double distance, int joinType)
        int fillet(vector[c_OCCVertex *] vertices, vector[double] radius)
        int chamfer(vector[c_OCCVertex *] vertices, vector[double] distances)
        double length()
    
    cdef cppclass c_OCCWireIterator "OCCWireIterator":
        c_OCCWireIterator(c_OCCBase *arg)
        void reset()
        c_OCCWire *next()
        
    cdef cppclass c_OCCFace "OCCFace":
        c_OCCFace()
        c_OCCFace *copy(bint deepCopy)
        int numWires()
        int numFaces()
        int createFace(c_OCCWire *wire)
        int createConstrained(vector[c_OCCEdge *] edges, vector[vector[double]] points)
        double area()
        vector[double] inertia()
        vector[double] centreOfMass()
        int offset(double offset, double tolerance)
        int createPolygonal(vector[vector[double]] points)
        int extrude(c_OCCEdge *edge, vector[double] p1, vector[double] p2)
        int revolve(c_OCCEdge *edge, vector[double] p1, vector[double] p2, double angle)
        int cut(c_OCCSolid *tool)
        int common(c_OCCSolid *tool)
        c_OCCMesh *createMesh(double factor, double angle)
    
    cdef cppclass c_OCCFaceIterator "OCCFaceIterator":
        c_OCCFaceIterator(c_OCCBase *arg)
        void reset()
        c_OCCFace *next()
        
    cdef cppclass c_OCCSolid "OCCSolid":
        c_OCCSolid()
        c_OCCSolid *copy(bint deepCopy)
        int numSolids()
        int numFaces()
        int createSolid(vector[c_OCCFace *] faces, double tolerance)
        double area()
        double volume()
        vector[double] inertia()
        vector[double] centreOfMass()
        c_OCCMesh *createMesh(double factor, double angle)
        int addSolids(vector[c_OCCSolid *] solids)
        int createSphere(vector[double] center, double radius)
        int createCylinder(vector[double] p1, vector[double] p2, double radius)
        int createTorus(vector[double] p1, vector[double] p2, double radius1, double radius2)
        int createCone(vector[double] p1, vector[double] p2, double radius1, double radius2)
        int createBox(vector[double] p1, vector[double] p2)
        int createPrism(c_OCCFace *face, vector[double] normal, bint isInfinite)
        int extrude(c_OCCFace *face, vector[double] p1, vector[double] p2)
        int revolve(c_OCCFace *face, vector[double] p1, vector[double] p2, double angle)
        int loft(vector[c_OCCBase *] profiles, bint ruled, double tolerance)
        int sweep(c_OCCWire *spine, vector[c_OCCBase *] profiles, int cornerMode)
        int pipe(c_OCCFace *face, c_OCCWire *wire)
        int fuse(c_OCCSolid *tool)
        int cut(c_OCCSolid *tool)
        int common(c_OCCSolid *tool)
        int fillet(vector[c_OCCEdge *] edges, vector[double] radius)
        int chamfer(vector[c_OCCEdge *] edges, vector[double] distances)
        int shell(vector[c_OCCFace *] faces, double offset, double tolerance)
        int offset(c_OCCFace *face, double offset, double tolerance)
        c_OCCFace *section(vector[double] pnt, vector[double] nor)
        int writeBREP(char *filename)
        int readBREP(char *filename)
        int writeSTEP(char *filename)
        int readSTEP(char *filename)
        int writeSTL(char *filename, bint asciiMode)
        void heal(double tolerance, bint fixdegenerated,
                  bint fixsmalledges, bint fixspotstripfaces, 
                  bint sewfaces, bint makesolids)        
    
    cdef cppclass c_OCCSolidIterator "OCCSolidIterator":
        c_OCCSolidIterator(c_OCCBase *arg)
        void reset()
        c_OCCSolid *next()