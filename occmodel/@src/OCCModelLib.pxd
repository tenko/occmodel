cdef extern from *:
    ctypedef char* const_char_ptr "char*"

cdef extern from "<string>" namespace "std":
    cdef cppclass string:
        string() nogil except +
        string(char *) nogil except +
        char* c_str() nogil
        
cdef extern from "<vector>" namespace "std":
    cdef cppclass vector[T]:
       vector()
       void clear()
       void push_back(T&)
       size_t size()
       T& operator[](size_t)

cdef extern from "OCCModel.h":
    char errorMessage[256]
    
    cdef cppclass c_OCCMesh "OCCMesh":
        vector[vector[double]] vertices
        vector[vector[double]] normals
        vector[vector[int]] triangles
        c_OCCMesh()
    
    cdef enum c_BoolOpType "BoolOpType":
        BOOL_FUSE
        BOOL_CUT
        BOOL_COMMON
    
    cdef enum c_TopAbs_ShapeEnum "TopAbs_ShapeEnum":
        TopAbs_COMPOUND
        TopAbs_COMPSOLID
        TopAbs_SOLID
        TopAbs_SHELL
        TopAbs_FACE
        TopAbs_WIRE
        TopAbs_EDGE
        TopAbs_VERTEX
        
    cdef cppclass c_OCCBase "OCCBase":
        c_TopAbs_ShapeEnum shapeType()
        int hashCode()
        bint isEqual(c_OCCBase *other)
        bint isNull()
        bint isValid()
        int transform(vector[double] mat, c_OCCBase *target)
        int translate(vector[double] delta, c_OCCBase *target)
        int rotate(double angle, vector[double] p1, vector[double] p2, c_OCCBase *target)
        int scale(vector[double] pnt, double scale, c_OCCBase *target)
        int mirror(vector[double] pnt, vector[double] nor, c_OCCBase *target)
        vector[double] boundingBox(double tolerance)
        int findPlane(double *origin, double *normal, double tolerance)
        int toString(string *output)
        int fromString(string input)
        
    cdef cppclass c_OCCVertex "OCCVertex":
        c_OCCVertex(double x, double y, double z)
        double X()
        double Y()
        double Z()
    
    cdef cppclass c_OCCVertexIterator "OCCVertexIterator":
        c_OCCVertexIterator(c_OCCBase *arg)
        void reset()
        c_OCCVertex *next()
        
    cdef cppclass c_OCCEdge "OCCEdge":
        c_OCCEdge()
        bint isSeam(c_OCCBase *face)
        bint isDegenerated()
        bint isClosed()
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
        bint isClosed()
        vector[vector[double]] tesselate(double factor, double angle)
        int createWire(vector[c_OCCEdge *] edges)
        int project(c_OCCBase *face)
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
        int createFace(vector[c_OCCWire *] wires)
        int createConstrained(vector[c_OCCEdge *] edges, vector[vector[double]] points)
        double area()
        vector[double] inertia()
        vector[double] centreOfMass()
        int offset(double offset, double tolerance)
        int createPolygonal(vector[vector[double]] points)
        int extrude(c_OCCBase *shape, vector[double] p1, vector[double] p2)
        int revolve(c_OCCBase *shape, vector[double] p1, vector[double] p2, double angle)
        int sweep(c_OCCWire *spine, vector[c_OCCBase *] profiles, int cornerMode)
        int loft(vector[c_OCCBase *] profiles, bint ruled, double tolerance)
        int boolean(c_OCCSolid *tool, c_BoolOpType op)
        c_OCCMesh *createMesh(double factor, double angle, bint qualityNormals)
    
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
        c_OCCMesh *createMesh(double factor, double angle, bint qualityNormals)
        int addSolids(vector[c_OCCSolid *] solids)
        int createSphere(vector[double] center, double radius)
        int createCylinder(vector[double] p1, vector[double] p2, double radius)
        int createTorus(vector[double] p1, vector[double] p2, double ringRadius, double radius)
        int createCone(vector[double] p1, vector[double] p2, double radius1, double radius2)
        int createBox(vector[double] p1, vector[double] p2)
        int createPrism(c_OCCFace *face, vector[double] normal, bint isInfinite)
        int createText(double height, double depth, char *text, char *fontpath)
        int extrude(c_OCCFace *face, vector[double] p1, vector[double] p2)
        int revolve(c_OCCFace *face, vector[double] p1, vector[double] p2, double angle)
        int loft(vector[c_OCCBase *] profiles, bint ruled, double tolerance)
        int sweep(c_OCCWire *spine, vector[c_OCCBase *] profiles, int cornerMode)
        int pipe(c_OCCFace *face, c_OCCWire *wire)
        int boolean(c_OCCSolid *tool, c_BoolOpType op)
        int fillet(vector[c_OCCEdge *] edges, vector[double] radius)
        int chamfer(vector[c_OCCEdge *] edges, vector[double] distances)
        int shell(vector[c_OCCFace *] faces, double offset, double tolerance)
        int offset(c_OCCFace *face, double offset, double tolerance)
        c_OCCFace *section(vector[double] pnt, vector[double] nor)        
    
    cdef cppclass c_OCCSolidIterator "OCCSolidIterator":
        c_OCCSolidIterator(c_OCCBase *arg)
        void reset()
        c_OCCSolid *next()

cdef extern from "OCCModel.h" namespace "OCCTools":
    int writeBREP(char *filename, vector[c_OCCBase *] shapes)
    int writeSTEP(char *filename, vector[c_OCCBase *] shapes)
    int writeSTL(char *filename, vector[c_OCCBase *] shapes)
    int writeVRML(char *filename, vector[c_OCCBase *] shapes)
    int readBREP(char *filename, vector[c_OCCBase *] shapes)
    int readSTEP(char *filename, vector[c_OCCBase *] shapes)