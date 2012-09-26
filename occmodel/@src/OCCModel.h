// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.

#include "OCCIncludes.h"
#include <vector>
#include <limits>

typedef std::vector<float> FVec;
typedef std::vector<double> DVec;
typedef std::vector<int> IVec;

class OCCSolid;

class OCCMesh {
    public:
        std::vector<DVec> normals;
        std::vector<DVec> vertices;
        std::vector<IVec> triangles;
        OCCMesh() { ; }
};

class OCCBase {
    public:
        int transform(DVec mat, OCCBase *target);
        int translate(DVec delta, OCCBase *target);
        int rotate(DVec p1, DVec p2, double angle, OCCBase *target);
        int scale(DVec pnt, double scale, OCCBase *target);
        int mirror(DVec pnt, DVec nor, OCCBase *target);
        DVec boundingBox(double tolerance);
        int findPlane(double *origin, double *normal, double tolerance);
        int hashCode() {
            return this->getShape().HashCode(std::numeric_limits<int>::max());
        }
        bool isEqual(OCCBase *other) {
            if (this->getShape().IsEqual(other->getShape()))
                return true;
            return false;
        }
        bool isNull() {
            return this->getShape().IsNull() ? true : false;
        }
        bool isValid() {
            if (this->getShape().IsNull())
                return false;
            BRepCheck_Analyzer aChecker(this->getShape());
            return aChecker.IsValid() ? true : false;
        }
        virtual const TopoDS_Shape& getShape() { return TopoDS_Shape(); }
        virtual void setShape(TopoDS_Shape shape) { ; }
};

class OCCVertex : public OCCBase { 
    public:
        TopoDS_Vertex vertex;
        OCCVertex() { ; }
        OCCVertex(double x, double y, double z) {
            gp_Pnt aPnt;
            aPnt = gp_Pnt(x, y, z);
            BRepBuilderAPI_MakeVertex mkVertex(aPnt);
            this->setShape(mkVertex.Vertex());
        }
        double x() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.X();
        }
        double y() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Y();
        }
        double z() const { 
            gp_Pnt pnt = BRep_Tool::Pnt(vertex);
            return pnt.Z();
        }
        const TopoDS_Shape& getShape() { return vertex; }
        const TopoDS_Vertex& getVertex() { return vertex; }
        void setShape(TopoDS_Shape shape) { vertex = TopoDS::Vertex(shape); }
};

class OCCVertexIterator {
    public:
        TopExp_Explorer ex;
        OCCVertexIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_VERTEX);
        }
        
        OCCVertex *next() {
            if (ex.More()) {
                OCCVertex *ret = new OCCVertex();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCEdge : public OCCBase {
    public:
        TopoDS_Edge edge;
        OCCEdge() { ; }
        OCCEdge *copy();
        int numVertices();
        std::vector<DVec> tesselate(double factor, double angle);
        int createLine(OCCVertex *start, OCCVertex *end);
        int createArc(OCCVertex *start, OCCVertex *end, DVec center);
        int createArc3P(OCCVertex *start, OCCVertex *end, DVec pnt);
        int createCircle(DVec center, DVec normal, double radius);
        int createEllipse(DVec pnt, DVec nor, double rMajor, double rMinor);
        int createHelix(double pitch, double height, double radius, double angle,
                        bool leftHanded);
        int createBezier(OCCVertex *start, OCCVertex *end, std::vector<DVec> points);
        int createSpline(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                         double tolerance);
        int createNURBS(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                        DVec knots, DVec weights, IVec mult);
        double length();
        const TopoDS_Shape& getShape() { return edge; }
        const TopoDS_Edge& getEdge() { return edge; }
        void setShape(TopoDS_Shape shape) { edge = TopoDS::Edge(shape); }
};

class OCCEdgeIterator {
    public:
        TopExp_Explorer ex;
        OCCEdgeIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_EDGE);
        }
        
        OCCEdge *next() {
            if (ex.More()) {
                OCCEdge *ret = new OCCEdge();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCWire : public OCCBase {
    public:
        TopoDS_Wire wire;
        OCCWire() { ; }
        OCCWire *copy();
        int numVertices();
        int numEdges();
        int createWire(std::vector<OCCEdge *> edges);
        std::vector<DVec> tesselate(double factor, double angle);
        double length();
        const TopoDS_Shape& getShape() { return wire; }
        const TopoDS_Wire& getWire() { return wire; }
        void setShape(TopoDS_Shape shape) { wire = TopoDS::Wire(shape); }
};

class OCCWireIterator {
    public:
        TopExp_Explorer ex;
        OCCWireIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_WIRE);
        }
        
        OCCWire *next() {
            if (ex.More()) {
                OCCWire *ret = new OCCWire();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCFace : public OCCBase {
    public:
        TopoDS_Shape face;
        OCCFace() { ; }
        OCCFace *copy();
        int numWires();
        int numFaces();
        int createFace(OCCWire *wire);
        int createConstrained(std::vector<OCCEdge *> edges, std::vector<DVec> points);
        double area();
        DVec inertia();
        DVec centreOfMass();
        std::vector<DVec> tesselate(double factor, double angle);
        int createPolygonal(std::vector<DVec> points);
        int extrude(OCCEdge *edge, DVec p1, DVec p2);
        int revolve(OCCEdge *edge, DVec p1, DVec p2, double angle);
        int cut(OCCSolid *tool);
        int common(OCCSolid *tool);
        OCCMesh *createMesh(double defle, double angle);
        const TopoDS_Shape& getShape() { return face; }
        const TopoDS_Face& getFace() { return TopoDS::Face(face); }
        const TopoDS_Shell& getShell() { return TopoDS::Shell(face); }
        void setShape(TopoDS_Shape shape) { face = shape; }
};

class OCCFaceIterator {
    public:
        TopExp_Explorer ex;
        OCCFaceIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_FACE);
        }
        
        OCCFace *next() {
            if (ex.More()) {
                OCCFace *ret = new OCCFace();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

class OCCSolid : public OCCBase {
    public:
        TopoDS_Shape solid;
        OCCSolid() { ; }
        OCCSolid *copy();
        int numSolids();
        int numFaces();
        int createSolid(std::vector<OCCFace *> faces, double tolerance);
        double area() ;
        double volume();
        DVec inertia();
        DVec centreOfMass();
        OCCMesh *createMesh(double defle, double angle);
        int addSolids(std::vector<OCCSolid *> solids);
        int createSphere(DVec center, double radius);
        int createCylinder(DVec p1, DVec p2, double radius);
        int createTorus(DVec p1, DVec p2, double radius1, double radius2);
        int createCone(DVec p1, DVec p2, double radius1, double radius2);
        int createBox(DVec p1, DVec p2);
        int createPrism(OCCFace *face, DVec normal, bool isInfinite);
        int extrude(OCCFace *face, DVec p1, DVec p2);
        int revolve(OCCFace *face, DVec p1, DVec p2, double angle);
        int loft(std::vector<OCCBase *> profiles, bool ruled, double tolerance);
        int pipe(OCCFace *face, OCCWire *wire);
        int sweep(OCCWire *spine, std::vector<OCCBase *> profiles, int cornerMode);
        int fuse(OCCSolid *tool);
        int cut(OCCSolid *tool);
        int common(OCCSolid *tool);
        int fillet(std::vector<OCCEdge *> edges, std::vector<double> radius);
        int chamfer(std::vector<OCCEdge *> edges, std::vector<double> distances);
        int shell(std::vector<OCCFace *> faces, double offset, double tolerance);
        OCCFace *section(DVec pnt, DVec nor);
        int writeBREP(const char *);  
        int readBREP(const char *);  
        int writeSTEP(const char *);
        int readSTEP(const char *fn);
        int writeSTL(const char *, bool asciiMode);
        void heal(double tolerance, bool fixdegenerated,
                  bool fixsmalledges, bool fixspotstripfaces, 
                  bool sewfaces, bool makesolids);
        const TopoDS_Shape& getShape() { return solid; }
        const TopoDS_Shape& getSolid() { return solid; }
        void setShape(TopoDS_Shape shape);
};

class OCCSolidIterator {
    public:
        TopExp_Explorer ex;
        OCCSolidIterator(OCCBase *arg) {
            ex.Init(arg->getShape(), TopAbs_SOLID);
        }
        
        OCCSolid *next() {
            if (ex.More()) {
                OCCSolid *ret = new OCCSolid();
                ret->setShape(ex.Current());
                ex.Next();
                return ret;
            } else {
                return NULL;
            }
        }
};

void printShapeType(const TopoDS_Shape& shape);
int extractFaceMesh(const TopoDS_Face& face, OCCMesh *mesh);
void connectEdges (std::vector<TopoDS_Edge>& edges, std::vector<TopoDS_Wire>& wires);