// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

int OCCSolid::createSolid(std::vector<OCCFace *> faces, double tolerance)
{
    try {
        BRepOffsetAPI_Sewing SW(tolerance);
        for (unsigned i=0; i<faces.size(); i++) {
            SW.Add(faces[i]->face);
        }
        SW.Perform();
        
        if (SW.SewedShape().IsNull())
          return 1;
        
        this->setShape(SW.SewedShape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}


OCCSolid *OCCSolid::copy(bool deepCopy = false)
{
    OCCSolid *ret = new OCCSolid();
    try {
        if (deepCopy) {
            BRepBuilderAPI_Copy A;
            A.Perform(this->getSolid());
            ret->setShape(A.Shape());
        } else {
            ret->setShape(this->getShape());
        }
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

int OCCSolid::numSolids()
{
    TopTools_IndexedMapOfShape anIndices;
    const TopoDS_Shape& shp = this->getShape();
    if (shp.ShapeType() == TopAbs_SOLID) {
        return 1;
    } else {
        // CompSolid or Compound
        TopExp::MapShapes(shp, TopAbs_SOLID, anIndices);
        return anIndices.Extent();
    }
}

int OCCSolid::numFaces()
{
    TopTools_IndexedMapOfShape anIndices;
    TopExp::MapShapes(this->getShape(), TopAbs_FACE, anIndices);
    return anIndices.Extent();
}

OCCMesh *OCCSolid::createMesh(double factor, double angle, bool qualityNormals = true)
{
    OCCMesh *mesh = new OCCMesh();
    const TopoDS_Shape& shape = this->getShape();
    
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(shape, aBox);
        
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        
        Standard_Real maxd = fabs(aXmax - aXmin);
        maxd = std::max(maxd, fabs(aYmax - aYmin));
        maxd = std::max(maxd, fabs(aZmax - aZmin));
        
        BRepMesh_FastDiscret MSH(factor*maxd, angle, aBox, Standard_True, Standard_True, 
                                 Standard_True, Standard_True);
        
        MSH.Perform(shape);
        
        if (shape.ShapeType() == TopAbs_COMPSOLID || shape.ShapeType() == TopAbs_COMPOUND) {
            TopExp_Explorer exSolid, exFace;
            for (exSolid.Init(shape, TopAbs_SOLID); exSolid.More(); exSolid.Next()) {
                const TopoDS_Solid& solid = static_cast<const TopoDS_Solid &>(exSolid.Current());
                for (exFace.Init(solid, TopAbs_FACE); exFace.More(); exFace.Next()) {
                    const TopoDS_Face& face = static_cast<const TopoDS_Face &>(exFace.Current());
                    if (face.IsNull()) continue;
                    mesh->extractFaceMesh(face, qualityNormals);
                }
            }
        }  else {
            TopExp_Explorer exFace;
            for (exFace.Init(shape, TopAbs_FACE); exFace.More(); exFace.Next()) {
                const TopoDS_Face& face = static_cast<const TopoDS_Face &>(exFace.Current());
                if (face.IsNull()) continue;
                mesh->extractFaceMesh(face, qualityNormals);
            }
        }
    } catch(Standard_Failure &err) {
        //Handle_Standard_Failure e = Standard_Failure::Caught();
        //printf("ERROR: %s\n", e->GetMessageString());
        return NULL;
    }
    return mesh;
}

int OCCSolid::addSolids(std::vector<OCCSolid *> solids)
{
    try {
        BRep_Builder B;
        TopoDS_Compound C;
        B.MakeCompound(C);
        for (unsigned i = 0; i < solids.size(); i++) {
            B.Add(C, solids[i]->getShape());
        }
        this->setShape(C);
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createSphere(DVec center, double radius)
{
    try {
        gp_Pnt aP(center[0], center[1], center[2]);
        this->setShape(BRepPrimAPI_MakeSphere(aP, radius).Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createCylinder(DVec p1, DVec p2, double radius)
{
    try {
        const double dx = p2[0] - p1[0];
        const double dy = p2[1] - p1[1];
        const double dz = p2[2] - p1[2];
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        gp_Pnt aP(p1[0], p1[1], p1[2]);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        BRepPrimAPI_MakeCylinder MC(anAxes, radius, H);
        MC.Build();
        if (!MC.IsDone()) {
            return 1;
        }
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createTorus(DVec p1, DVec p2, double radius1, double radius2) {
    try {
        const double dx = p2[0] - p1[0];
        const double dy = p2[1] - p1[1];
        const double dz = p2[2] - p1[2];
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        gp_Pnt aP(p1[0], p1[1], p1[2]);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        BRepPrimAPI_MakeTorus MC(anAxes, radius1, radius2);
        MC.Build();
        if (!MC.IsDone()) {
            return 1;
        }
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createCone(DVec p1, DVec p2, double radius1, double radius2) {
    try {
        const double dx = p2[0] - p1[0];
        const double dy = p2[1] - p1[1];
        const double dz = p2[2] - p1[2];
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        gp_Pnt aP(p1[0], p1[1], p1[2]);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        BRepPrimAPI_MakeCone MC(anAxes, radius1, radius2, H);
        MC.Build();
        if (!MC.IsDone()) {
            return 1;
        }
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createBox(DVec p1, DVec p2) {
    try {
        gp_Pnt aP1(p1[0], p1[1], p1[2]);
        gp_Pnt aP2(p2[0], p2[1], p2[2]);
        BRepPrimAPI_MakeBox MB(aP1, aP2);
        MB.Build();
        if (!MB.IsDone()) {
            return 1;
        }
        this->setShape(MB.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::createPrism(OCCFace *face, DVec normal, bool isInfinite) {
    try {
        gp_Dir direction(normal[0], normal[1], normal[2]);
        
        Standard_Boolean inf = Standard_True;
        if (!isInfinite) inf = Standard_False;
        
        BRepPrimAPI_MakePrism MP(face->getShape(), direction, inf);
        if (!MP.IsDone()) {
            return 1;
        }
        this->setShape(MP.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

double OCCSolid::area() {
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(this->getSolid(), prop);
    return prop.Mass();
}

double OCCSolid::volume() {
    GProp_GProps prop;
    BRepGProp::VolumeProperties(this->getSolid(), prop);
    return prop.Mass();
}

DVec OCCSolid::inertia() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::VolumeProperties(this->getSolid(), prop);
    gp_Mat mat = prop.MatrixOfInertia();
    ret.push_back(mat(1,1)); // Ixx
    ret.push_back(mat(2,2)); // Iyy
    ret.push_back(mat(3,3)); // Izz
    ret.push_back(mat(1,2)); // Ixy
    ret.push_back(mat(1,3)); // Ixz
    ret.push_back(mat(2,3)); // Iyz
    return ret;
}

DVec OCCSolid::centreOfMass() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::VolumeProperties(this->getSolid(), prop);
    gp_Pnt cg = prop.CentreOfMass();
    ret.push_back(cg.X());
    ret.push_back(cg.Y());
    ret.push_back(cg.Z());
    return ret;
}

int OCCSolid::extrude(OCCFace *face, DVec p1, DVec p2)
{
    try {
        gp_Vec direction(gp_Pnt(p1[0], p1[1], p1[2]),
                         gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);

        BRepPrimAPI_MakePrism MP(face->getShape(), direction,
                                 Standard_False);
        if (!MP.IsDone()) {
            return 1;
        }
        this->setShape(MP.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::revolve(OCCFace *face, DVec p1, DVec p2, double angle)
{
    try {
        gp_Dir direction(p2[0] - p1[0], p2[1] - p1[1], p2[2] - p1[2]);
        gp_Ax1 axisOfRevolution(gp_Pnt(p1[0], p1[1], p1[2]), direction);
        BRepPrimAPI_MakeRevol MR(face->getShape(), axisOfRevolution, angle, Standard_False);
        if (!MR.IsDone()) {
            return 1;
        }
        this->setShape(MR.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::pipe(OCCFace *face, OCCWire *wire)
{
    try {
        BRepOffsetAPI_MakePipe MP(wire->wire, face->getShape());
        if (!MP.IsDone()) {
            return 1;
        }
        this->setShape(MP.Shape());
    } catch(Standard_Failure &err) {
        //Handle_Standard_Failure e = Standard_Failure::Caught();
        //printf("ERROR: %s\n", e->GetMessageString());
        return 1;
    }
    return 0;
}

int OCCSolid::sweep(OCCWire *spine, std::vector<OCCBase *> profiles, int cornerMode = 0)
{
    try {
        BRepOffsetAPI_MakePipeShell PS(spine->wire);
        // set corner mode
        switch (cornerMode) {
            case 1: PS.SetTransitionMode(BRepBuilderAPI_RightCorner);
                break;
            case 2: PS.SetTransitionMode(BRepBuilderAPI_RoundCorner);
                break;
            default: PS.SetTransitionMode(BRepBuilderAPI_Transformed);
                break;
        }
        // add profiles
        for (unsigned i=0; i<profiles.size(); i++) {
            PS.Add(profiles[i]->getShape());
        }
        if (!PS.IsReady()) {
            return 1;
        }
        PS.Build();
        if (!PS.MakeSolid()) {
            return 1;
        }
        this->setShape(PS.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::loft(std::vector<OCCBase *> profiles, bool ruled, double tolerance)
{
    try {
        Standard_Boolean isSolid = Standard_True;
        Standard_Boolean isRuled = Standard_True;
        
        if (!ruled) isRuled = Standard_False;
        
        BRepOffsetAPI_ThruSections TS(isSolid, isRuled, tolerance);
        
        for (unsigned i=0; i<profiles.size(); i++) {
            if (profiles[i]->getShape().ShapeType() == TopAbs_WIRE) {
                TS.AddWire(TopoDS::Wire(profiles[i]->getShape()));
            } else {
                TS.AddVertex(TopoDS::Vertex(profiles[i]->getShape()));
            }
        }
        //TS.CheckCompatibility(Standard_False);  
        TS.Build();
        if (!TS.IsDone()) {
            return 1;
        }
        this->setShape(TS.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::fuse(OCCSolid *tool) {
    try {
        BRepAlgoAPI_Fuse BO (tool->getShape(), getShape());
        if (!BO.IsDone()) {
          return 1;
        }
        this->setShape(BO.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::cut(OCCSolid *tool) {
    try {
        BRepAlgoAPI_Cut BO (getShape(), tool->getShape());
        if (!BO.IsDone()) {
          return 1;
        }
        this->setShape(BO.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::common(OCCSolid *tool) {
    try {
        BRepAlgoAPI_Common BO (tool->getShape(), getShape());
        if (!BO.IsDone()) {
          return 1;
        }
        this->setShape(BO.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCSolid::chamfer(std::vector<OCCEdge *> edges, std::vector<double> distances) {
    int edges_size = edges.size();
    int distances_size = distances.size();
    BRepFilletAPI_MakeChamfer CF(solid);
    
    TopTools_IndexedDataMapOfShapeListOfShape mapEdgeFace;
    TopExp::MapShapesAndAncestors(solid, TopAbs_EDGE, TopAbs_FACE, mapEdgeFace);
    
    for (unsigned i=0; i<edges.size(); i++) {
            OCCEdge *edge = edges[i];
            
            // skip degenerated edge
            if (BRep_Tool::Degenerated(edge->getEdge()))
                continue;
        
            const TopoDS_Face& face = TopoDS::Face(mapEdgeFace.FindFromKey(edge->getEdge()).First());
            
            // skip edge if it is a seam
            if (BRep_Tool::IsClosed(edge->getEdge(), face))
                continue;
            
            
            if (distances_size == 1) {
                // single distance
                CF.Add(distances[0], edge->getEdge(), face);
                
            } else if (distances_size == edges_size) {
                // distance given for each edge
                CF.Add(distances[i], edge->getEdge(), face);
                
            } else {
                return 1;
            }
    }
    
    CF.Build();
    
    if (!CF.IsDone()) return 1;
    
    const TopoDS_Shape& tmp = CF.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
}

int OCCSolid::fillet(std::vector<OCCEdge *> edges, std::vector<double> radius) {
    int edges_size = edges.size();
    int radius_size = radius.size();
    BRepFilletAPI_MakeFillet fill(solid);
    
    TopTools_IndexedDataMapOfShapeListOfShape mapEdgeFace;
    TopExp::MapShapesAndAncestors(solid, TopAbs_EDGE, TopAbs_FACE, mapEdgeFace);
    
    for (unsigned i=0; i<edges.size(); i++) {
            OCCEdge *edge = edges[i];
        
            // skip degenerated edge
            if (BRep_Tool::Degenerated(edge->getEdge()))
                continue;
            
            
            const TopoDS_Face& face = TopoDS::Face(mapEdgeFace.FindFromKey(edge->getEdge()).First());
            
            // skip edge if it is a seam
            if (BRep_Tool::IsClosed(edge->getEdge(), face))
                continue;
            
            if (radius_size == 1) {
                // single radius
                fill.Add(radius[0], edge->getEdge());
            } else if (radius_size == edges_size) {
                // radius given for each edge
                fill.Add(radius[i], edge->getEdge());
            } else if (radius_size == 2*edges_size) {
                // variable radius
                fill.Add(radius[2*i+0], radius[2*i+1], edge->getEdge());
            } else {
                return 1;
            }
    }
    
    fill.Build();
    
    if (!fill.IsDone()) return 1;
    
    const TopoDS_Shape& tmp = fill.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
    
}

int OCCSolid::shell(std::vector<OCCFace *> faces, double offset, double tolerance) {
    TopTools_ListOfShape facelist;
    for (unsigned i=0; i<faces.size(); i++) {
        OCCFace *face = faces[i];
        facelist.Append(face->getShape());
    }
    
    BRepOffsetAPI_MakeThickSolid TS(solid, facelist, offset, tolerance);
    TS.Build();
    
    if (!TS.IsDone()) return 1;
    
    const TopoDS_Shape& tmp = TS.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
}

int OCCSolid::offset(OCCFace *face, double offset, double tolerance = 1e-6) {
    try {
        BRepOffset_MakeOffset MO(face->getShape(), offset, tolerance, BRepOffset_Skin,
                                 Standard_False, Standard_False, GeomAbs_Arc, Standard_True);
        
        if (!MO.IsDone())
            return 1;
        
        this->setShape(MO.Shape());
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

// FIXME!: Return vector of faces
// See FreeCad/CrossSection.cpp
//
OCCFace *OCCSolid::section(DVec pnt, DVec nor)
{
    Handle(TopTools_HSequenceOfShape) wires = new TopTools_HSequenceOfShape;
    Handle(TopTools_HSequenceOfShape) edges = new TopTools_HSequenceOfShape;
    TopExp_Explorer ex;
    OCCFace *ret = new OCCFace();
    try {
        gp_Pln pln(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        
        BRepAlgoAPI_Section mkSection(getShape(), pln);
        if (!mkSection.IsDone()) return NULL;
    
        for (ex.Init(mkSection.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges->Append(TopoDS::Edge(ex.Current()));
            }
        }
        
        ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,Precision::Confusion(),Standard_True,wires);
        if (wires->Length() != 1)
            return NULL;
        
        const TopoDS_Wire& wire = TopoDS::Wire(wires->Value(1));
        
        BRepBuilderAPI_MakeFace MFInit(pln, wire, Standard_True);
        MFInit.Build();
        if (!MFInit.IsDone()) return NULL;
        
        ShapeFix_Wire fixer(wire, MFInit.Face(), 1.0e-6);
        fixer.FixEdgeCurves();
        fixer.Perform();
        
        BRepBuilderAPI_MakeFace MFRes(pln, fixer.Wire(), Standard_True);
        MFRes.Build();
        if (!MFRes.IsDone()) return NULL;
        
        ret->setShape(MFRes.Face());
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

void OCCSolid::setShape(TopoDS_Shape shape)
{
    TopAbs_ShapeEnum type = shape.ShapeType();
    if (type == TopAbs_SOLID || type == TopAbs_COMPSOLID) {
        solid = shape;
    } else {
        int solids = 0;
        TopExp_Explorer ex;
        
        for (ex.Init(shape, TopAbs_SOLID); ex.More(); ex.Next()) {
            solids++;
        }
        
        for (ex.Init(shape, TopAbs_COMPSOLID); ex.More(); ex.Next()) {
            solids++;
        }
        
        if (solids == 1) {
            // exract single solids or compsolid
            for (ex.Init(shape, TopAbs_SOLID); ex.More(); ex.Next()) {
                solid = ex.Current();
            }
            for (ex.Init(shape, TopAbs_COMPSOLID); ex.More(); ex.Next()) {
                solid = ex.Current();
            }
        } else {
            // create compound of several solids
            BRep_Builder B;
            TopoDS_Compound C;
            B.MakeCompound(C);
            
            for (ex.Init(shape, TopAbs_SOLID); ex.More(); ex.Next()) {
                B.Add(C, ex.Current());
            }
            
            for (ex.Init(shape, TopAbs_COMPSOLID); ex.More(); ex.Next()) {
                B.Add(C, ex.Current());
            }
            solid = C;
        }
    }
}
