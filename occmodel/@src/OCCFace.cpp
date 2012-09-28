// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

OCCFace *OCCFace::copy(bool deepCopy = false)
{
    OCCFace *ret = new OCCFace();
    try {
        if (deepCopy) {
            BRepBuilderAPI_Copy A;
            A.Perform(this->getFace());
            ret->setShape(A.Shape());
        } else {
            ret->setShape(this->getShape());
        }
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

int OCCFace::numFaces()
{
    TopTools_IndexedMapOfShape anIndices;
    const TopoDS_Shape& shp = this->getShape();
    if (shp.ShapeType() == TopAbs_FACE) {
        return 1;
    } else {
        // Shell
        TopExp::MapShapes(shp, TopAbs_FACE, anIndices);
        return anIndices.Extent();
    }
}

int OCCFace::numWires()
{
    TopTools_IndexedMapOfShape anIndices;
    TopExp::MapShapes(this->getShape(), TopAbs_WIRE, anIndices);
    return anIndices.Extent();
}

int OCCFace::createFace(OCCWire *wire) {
    try {
        this->setShape(BRepBuilderAPI_MakeFace(wire->wire));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::createConstrained(std::vector<OCCEdge *> edges, std::vector<DVec> points) {
    try {
        BRepOffsetAPI_MakeFilling aGenerator;
        for (unsigned i = 0; i < edges.size(); i++) {
            OCCEdge *edge = edges[i];
            aGenerator.Add(edge->edge, GeomAbs_C0);
        }
        for (unsigned i = 0; i < points.size(); i++) {
            gp_Pnt aPnt(points[i][0], points[i][1], points[i][2]);
            aGenerator.Add(aPnt);
        }
        aGenerator.Build();
        this->setShape(aGenerator.Shape());
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

double OCCFace::area() {
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(this->getShape(), prop);
    return prop.Mass();
}

DVec OCCFace::inertia() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(this->getShape(), prop);
    gp_Mat mat = prop.MatrixOfInertia();
    ret.push_back(mat(1,1)); // Ixx
    ret.push_back(mat(2,2)); // Iyy
    ret.push_back(mat(3,3)); // Izz
    ret.push_back(mat(1,2)); // Ixy
    ret.push_back(mat(1,3)); // Ixz
    ret.push_back(mat(2,3)); // Iyz
    return ret;
}

DVec OCCFace::centreOfMass() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(this->getShape(), prop);
    gp_Pnt cg = prop.CentreOfMass();
    ret.push_back(cg.X());
    ret.push_back(cg.Y());
    ret.push_back(cg.Z());
    return ret;
}

int OCCFace::offset(double offset, double tolerance = 1e-6) {
    BRepOffset_MakeOffset MO(this->getShape(), offset, tolerance, BRepOffset_Skin,
                             Standard_False, Standard_False, GeomAbs_Arc, Standard_False);
    
    if (!MO.IsDone())
        return 1;
    
    this->setShape(MO.Shape());
    return 0;
}

int OCCFace::createPolygonal(std::vector<DVec> points)
{
    try {
        BRepBuilderAPI_MakePolygon MP;
        for (unsigned i=0; i<points.size(); i++) {
            MP.Add(gp_Pnt(points[i][0], points[i][1], points[i][2]));
        }
        MP.Close();
        if (!MP.IsDone())
            return 1;
        BRepBuilderAPI_MakeFace MF(MP.Wire(), false);
        this->setShape(MF.Face());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::extrude(OCCEdge *edge, DVec p1, DVec p2) {
    try {
        gp_Vec direction(gp_Pnt(p1[0], p1[1], p1[2]),
                         gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);

        BRepPrimAPI_MakePrism MP(edge->getShape(), direction,
                                 Standard_False);
        this->setShape(TopoDS::Face(MP.Shape()));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::revolve(OCCEdge *edge, DVec p1, DVec p2, double angle)
{
    try {
        gp_Dir direction(p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]);
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);
        BRepPrimAPI_MakeRevol MR(edge->getShape(), axisOfRevolution, angle, Standard_False);
        this->setShape(TopoDS::Face(MR.Shape()));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCFace::cut(OCCSolid *tool) {
    BRepAlgoAPI_Cut BO (getShape(), tool->getShape());
    if (!BO.IsDone()) {
      return 1;
    }
    
    const TopoDS_Shape& res = BO.Shape();
    
    // extract single face or shell
    int idx = 0;
    TopExp_Explorer exBO;
    for (exBO.Init(res, TopAbs_SHELL); exBO.More(); exBO.Next()) {
        if (idx > 0) return 1;
        const TopoDS_Shape& cur = exBO.Current();
        this->setShape(cur);
        idx++;
    }
    
    if (idx == 0) {
        idx = 0;
        for (exBO.Init(res, TopAbs_FACE); exBO.More(); exBO.Next()) {
            if (idx > 0) return 1;
            const TopoDS_Shape& cur = exBO.Current();
            this->setShape(cur);
            idx++;
        }
    }
    
    if (idx == 0) return 1;
    
    return 0;
}

int OCCFace::common(OCCSolid *tool) {
    BRepAlgoAPI_Common BO (getShape(), tool->getShape());
    if (!BO.IsDone()) {
      return 1;
    }
    const TopoDS_Shape& res = BO.Shape();
    
    // extract single face or shell
    int idx = 0;
    TopExp_Explorer exBO;
    for (exBO.Init(res, TopAbs_SHELL); exBO.More(); exBO.Next()) {
        if (idx > 0) return 1;
        const TopoDS_Shape& cur = exBO.Current();
        this->setShape(cur);
        idx++;
    }
    
    if (idx == 0) {
        idx = 0;
        for (exBO.Init(res, TopAbs_FACE); exBO.More(); exBO.Next()) {
            if (idx > 0) return 1;
            const TopoDS_Shape& cur = exBO.Current();
            this->setShape(cur);
            idx++;
        }
    }
    
    if (idx == 0) return 1;
    
    return 0;
}

OCCMesh *OCCFace::createMesh(double factor, double angle, bool qualityNormals = true)
{
    OCCMesh *mesh = new OCCMesh();
    
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(this->getShape(), aBox);
        
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        
        Standard_Real maxd = fabs(aXmax - aXmin);
        maxd = std::max(maxd, fabs(aYmax - aYmin));
        maxd = std::max(maxd, fabs(aZmax - aZmin));
        
        BRepMesh_FastDiscret MSH(factor*maxd, angle, aBox, Standard_False, Standard_False, 
                                 Standard_True, Standard_True);
        
        MSH.Perform(this->getShape());
        
        BRepMesh::Mesh(this->getShape(),factor*maxd);
        
        if (this->getShape().ShapeType() != TopAbs_FACE) {
            TopExp_Explorer exFace;
            for (exFace.Init(this->getShape(), TopAbs_FACE); exFace.More(); exFace.Next()) {
                const TopoDS_Face& faceref = TopoDS::Face(exFace.Current());
                extractFaceMesh(faceref, mesh, qualityNormals);
            }
        } else {
            extractFaceMesh(this->getFace(), mesh, qualityNormals);
        }
    } catch(Standard_Failure &err) {
        //Handle_Standard_Failure e = Standard_Failure::Caught();
        //printf("ERROR: %s\n", e->GetMessageString());
        return NULL;
    }
    return mesh;
}