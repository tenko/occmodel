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


OCCSolid *OCCSolid::copy()
{
    OCCSolid *ret = new OCCSolid();
    try {
        BRepBuilderAPI_Copy A;
        A.Perform(solid);
        ret->setShape(A.Shape());
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

OCCMesh *OCCSolid::createMesh(double factor, double angle)
{
    OCCMesh *mesh = new OCCMesh();
    
    try {
        Bnd_Box aBox;
        BRepBndLib::Add(solid, aBox);
        
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        
        Standard_Real maxd = fabs(aXmax - aXmin);
        maxd = std::max(maxd, fabs(aYmax - aYmin));
        maxd = std::max(maxd, fabs(aZmax - aZmin));
        
        BRepMesh_FastDiscret MSH(factor*maxd, angle, aBox, Standard_True, Standard_True, 
                                 Standard_True, Standard_True);
        
        MSH.Perform(solid);
        
        // TODO : Handle comp solid!!
        TopExp_Explorer exFace;
        for (exFace.Init(solid, TopAbs_FACE); exFace.More(); exFace.Next()) {
            TopoDS_Face face = TopoDS::Face(exFace.Current());
            if (extractFaceMesh(face, mesh) == 1)
                return NULL;
        }
    } catch(Standard_Failure &err) {
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

double OCCSolid::area() {
    GProp_GProps prop;
    BRepGProp::SurfaceProperties(solid, prop);
    return prop.Mass();
}

double OCCSolid::volume() {
    GProp_GProps prop;
    BRepGProp::VolumeProperties(solid, prop);
    return prop.Mass();
}

DVec OCCSolid::inertia() {
    DVec ret;
    GProp_GProps prop;
    BRepGProp::VolumeProperties(solid, prop);
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
    BRepGProp::VolumeProperties(solid, prop);
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
        BRepOffsetAPI_MakePipe MP(wire->wire, face->face);
        if (!MP.IsDone()) {
            return 1;
        }
        this->setShape(TopoDS::Solid(MP.Shape()));
    } catch(Standard_Failure &err) {
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
        this->setShape(TopoDS::Solid(PS.Shape()));
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

int OCCSolid::booleanUnion(OCCSolid *tool) {
    BRepAlgoAPI_Fuse BO (tool->getShape(), getShape());
    if (!BO.IsDone()) {
      return 1;
    }
    this->setShape(BO.Shape());
    return 0;
}

int OCCSolid::booleanDifference(OCCSolid *tool) {
    BRepAlgoAPI_Cut BO (getShape(), tool->getShape());
    if (!BO.IsDone()) {
      return 1;
    }
    this->setShape(BO.Shape());
    return 0;
}

int OCCSolid::booleanIntersection(OCCSolid *tool) {
    BRepAlgoAPI_Common BO (tool->getShape(), getShape());
    if (!BO.IsDone()) {
      return 1;
    }
    this->setShape(BO.Shape());
    return 0;
}

    
int OCCSolid::chamfer(double distance, filter_func userfunc, void *userdata) {
    TopExp_Explorer exp;
    BRepFilletAPI_MakeChamfer CF(solid);
    double near[3], far[3];
    
    TopTools_IndexedDataMapOfShapeListOfShape mapEdgeFace;
    TopExp::MapShapesAndAncestors(solid, TopAbs_EDGE, TopAbs_FACE, mapEdgeFace);
    
    for(exp.Init(solid, TopAbs_EDGE); exp.More(); exp.Next()) {
        TopoDS_Edge edge = TopoDS::Edge(exp.Current());
        
        Bnd_Box aBox;
        BRepBndLib::Add(edge, aBox);
        aBox.Get(near[0], near[1], near[2], far[0], far[1], far[2]);
        
        if (userfunc(userdata, near, far) == 0) {
            continue;
        }
        const TopoDS_Face& face = TopoDS::Face(mapEdgeFace.FindFromKey(edge).First());
        CF.Add(distance, edge, face);
    }
    
    CF.Build();
    
    if (!CF.IsDone()) return 1;
    
    TopoDS_Shape tmp = CF.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
}

int OCCSolid::fillet(double radius, filter_func userfunc, void *userdata) {
    TopExp_Explorer exp;
    BRepFilletAPI_MakeFillet fill(solid);
    double near[3], far[3];
    
    for(exp.Init(solid, TopAbs_EDGE); exp.More(); exp.Next()) {
        TopoDS_Edge edge = TopoDS::Edge(exp.Current());
        
        Bnd_Box aBox;
        BRepBndLib::Add(edge, aBox);
        aBox.Get(near[0], near[1], near[2], far[0], far[1], far[2]);
        
        if (userfunc(userdata, near, far) == 0) {
            continue;
        }
        
        fill.Add(edge);
    }
    for (int i = 1; i <= fill.NbContours(); i++) {
        fill.SetRadius(radius, i, 1);
    }
    fill.Build();
    
    if (!fill.IsDone()) return 1;
    
    TopoDS_Shape tmp = fill.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
}

int OCCSolid::shell(double offset, filter_func userfunc, void *userdata) {
    double near[3], far[3];
    TopExp_Explorer exp;
    TopTools_ListOfShape faces;
    
    for(exp.Init(solid, TopAbs_FACE); exp.More(); exp.Next()) {
        TopoDS_Face face = TopoDS::Face(exp.Current());
        
        Bnd_Box aBox;
        BRepBndLib::Add(face, aBox);
        aBox.Get(near[0], near[1], near[2], far[0], far[1], far[2]);
        
        if (userfunc(userdata, near, far) == 0) {
            continue;
        }
        
        faces.Append(face);
    }
    
    BRepOffsetAPI_MakeThickSolid TS(solid, faces, offset, 1e-4);
    TS.Build();
    
    if (!TS.IsDone()) return 1;
    
    TopoDS_Shape tmp = TS.Shape();
    
    if (tmp.IsNull()) return 1;
    
    // Check shape validity
    BRepCheck_Analyzer ana (tmp, false);
    if (!ana.IsValid()) {
        return 1;
    }
  
    this->setShape(tmp);
    return 0;
}

// FIXME!: Return vector of faces
// See FreeCad/CrossSection.cpp
//
OCCFace *OCCSolid::section(DVec pnt, DVec nor)
{
    std::vector<TopoDS_Wire> wires;
    std::vector<TopoDS_Edge> edges;
    TopExp_Explorer ex;
    OCCFace *ret = new OCCFace();
    try {
        gp_Pln pln(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        
        BRepAlgoAPI_Section mkSection(getShape(), pln);
        if (!mkSection.IsDone()) return NULL;
    
        for (ex.Init(mkSection.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges.push_back(TopoDS::Edge(ex.Current()));
            }
        }
        connectEdges(edges, wires);
        if (wires.empty()) return NULL;
        
        BRepBuilderAPI_MakeFace MFInit(pln, wires[0], Standard_True);
        MFInit.Build();
        if (!MFInit.IsDone()) return NULL;
        
        ShapeFix_Wire fixer(wires[0], MFInit.Face(), 1.0e-6);
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

int OCCSolid::writeBREP(const char *fn)
{
  std::ofstream myFile;
  myFile.open(fn);
  try {
    BRepTools::Write(solid, myFile);
  }
  catch(Standard_Failure &err){
    return 1;
  }
  myFile.close();
  return 0;
}

int OCCSolid::readBREP(const char *fn)
{
  BRep_Builder aBuilder;
  try {
    BRepTools::Read(solid, (char*)fn, aBuilder);
  } catch(Standard_Failure &err) {
    return 1;
  }
  BRepTools::Clean(solid);
  return 0;
}

int OCCSolid::writeSTEP(const char *fn)
{
  STEPControl_Writer writer;
  IFSelect_ReturnStatus status = writer.Transfer(getShape(), STEPControl_ManifoldSolidBrep);
  if (status == IFSelect_RetDone) 
    status = writer.Write((char*)fn);
  if (status == IFSelect_RetDone) 
    return 0;
  return 1;
}

int OCCSolid::readSTEP(const char *fn)
{
  STEPControl_Reader reader;
  try {
    reader.ReadFile((char*)fn);
    reader.NbRootsForTransfer();
    reader.TransferRoots(); 
  } catch(Standard_Failure &err) {
    return 1;
  }
  solid = reader.OneShape(); 
  BRepTools::Clean(solid);
  return 0;
}

int OCCSolid::writeSTL(const char *fn, bool asciiMode)
{
  Standard_CString filename = fn;
  StlAPI_Writer writer;
  
  Standard_Boolean& flag = writer.ASCIIMode();
  if (asciiMode) {
      flag = Standard_True;
  } else {
      flag = Standard_False;
  }
  
  try {
    writer.Write(getShape(), filename);
  } catch(Standard_Failure &err) {
    return 1;
  }
  return 0;
}

void OCCSolid::heal(double tolerance, bool fixdegenerated,
                    bool fixsmalledges, bool fixspotstripfaces, 
                    bool sewfaces, bool makesolids)
{
    if(!fixdegenerated && !fixsmalledges && !fixspotstripfaces &&
       !sewfaces && !makesolids) return;
    
    TopExp_Explorer exp0, exp1;
    
    if (fixdegenerated) {
        {
            Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
            rebuild->Apply(solid);
            for (exp1.Init (solid, TopAbs_EDGE); exp1.More(); exp1.Next()){
                TopoDS_Edge edge = TopoDS::Edge(exp1.Current());
                if(BRep_Tool::Degenerated(edge))
                  rebuild->Remove(edge, false);
            }
            solid = rebuild->Apply(solid);
        }

        {
            Handle(ShapeFix_Face) sff;
            Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
            rebuild->Apply(solid);

            for (exp0.Init (solid, TopAbs_FACE); exp0.More(); exp0.Next()){
                TopoDS_Face face = TopoDS::Face(exp0.Current());

                sff = new ShapeFix_Face (face);
                sff->FixAddNaturalBoundMode() = Standard_True;
                sff->FixSmallAreaWireMode() = Standard_True;
                sff->Perform();

                if(sff->Status(ShapeExtend_DONE1) ||
                   sff->Status(ShapeExtend_DONE2) ||
                   sff->Status(ShapeExtend_DONE3) ||
                   sff->Status(ShapeExtend_DONE4) ||
                   sff->Status(ShapeExtend_DONE5))
                  {
                    if(sff->Status(ShapeExtend_DONE1))
                      printf("  (some wires are fixed)");
                    else if(sff->Status(ShapeExtend_DONE2))
                      printf("  (orientation of wires fixed)");
                    else if(sff->Status(ShapeExtend_DONE3))
                      printf("  (missing seam added)");
                    else if(sff->Status(ShapeExtend_DONE4))
                      printf("  (small area wire removed)");
                    else if(sff->Status(ShapeExtend_DONE5))
                      printf("  (natural bounds added)");
                    
                    TopoDS_Face newface = sff->Face();
                    rebuild->Replace(face, newface, Standard_False);
                  }
            }
            solid = rebuild->Apply(solid);
        }
        
        {
            Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
            rebuild->Apply(solid);
            for (exp1.Init (solid, TopAbs_EDGE); exp1.More(); exp1.Next()){
                TopoDS_Edge edge = TopoDS::Edge(exp1.Current());
                if (BRep_Tool::Degenerated(edge))
                  rebuild->Remove(edge, false);
            }
            solid = rebuild->Apply(solid);
        }
    }
    
    if (fixsmalledges) {
        Handle(ShapeFix_Wire) sfw;
        Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
        rebuild->Apply(solid);
        
        for (exp0.Init (solid, TopAbs_FACE); exp0.More(); exp0.Next()){
            TopoDS_Face face = TopoDS::Face(exp0.Current());
          
            for (exp1.Init (face, TopAbs_WIRE); exp1.More(); exp1.Next()){
                TopoDS_Wire oldwire = TopoDS::Wire(exp1.Current());
                sfw = new ShapeFix_Wire (oldwire, face ,tolerance);
                sfw->ModifyTopologyMode() = Standard_True;
                
                sfw->ClosedWireMode() = Standard_True;
                
                bool replace = false;
                replace = sfw->FixReorder() || replace;
                replace = sfw->FixConnected() || replace;
                
                if (sfw->FixSmall(Standard_False, tolerance) && 
                    ! (sfw->StatusSmall(ShapeExtend_FAIL1) ||
                       sfw->StatusSmall(ShapeExtend_FAIL2) ||
                       sfw->StatusSmall(ShapeExtend_FAIL3))){
                    replace = true;
                }
                replace = sfw->FixEdgeCurves() || replace;
                replace = sfw->FixDegenerated() || replace;
                replace = sfw->FixSelfIntersection() || replace;
                replace = sfw->FixLacking(Standard_True) || replace;
                if(replace){
                    TopoDS_Wire newwire = sfw->Wire();
                    rebuild->Replace(oldwire, newwire, Standard_False);
                }
            }
        }
        
        solid = rebuild->Apply(solid);
        
        {
            Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
            rebuild->Apply(solid);
            for (exp1.Init (solid, TopAbs_EDGE); exp1.More(); exp1.Next()){
                TopoDS_Edge edge = TopoDS::Edge(exp1.Current());
                if(BRep_Tool::Degenerated(edge) )
                    rebuild->Remove(edge, false);
            }
            solid = rebuild->Apply(solid);
        }
        
        Handle(ShapeFix_Wireframe) sfwf = new ShapeFix_Wireframe;
        sfwf->SetPrecision(tolerance);
        sfwf->Load (solid);
        sfwf->ModeDropSmallEdges() = Standard_True;
        
        if (sfwf->FixWireGaps()){
            printf("- fixing wire gaps");
            if (sfwf->StatusWireGaps(ShapeExtend_OK)) 
                printf("  no gaps found");
            if (sfwf->StatusWireGaps(ShapeExtend_DONE1))
                printf("  some 2D gaps fixed");
            if (sfwf->StatusWireGaps(ShapeExtend_DONE2)) 
                printf("  some 3D gaps fixed");
            if (sfwf->StatusWireGaps(ShapeExtend_FAIL1)) 
                printf("  failed to fix some 2D gaps");
            if (sfwf->StatusWireGaps(ShapeExtend_FAIL2))
                printf("  failed to fix some 3D gaps");
        }
        
        sfwf->SetPrecision(tolerance);
        
        if (sfwf->FixSmallEdges()){
            printf("- fixing wire frames");
            if (sfwf->StatusSmallEdges(ShapeExtend_OK)) 
                printf("  no small edges found");
            if (sfwf->StatusSmallEdges(ShapeExtend_DONE1))
                printf("  some small edges fixed");
            if (sfwf->StatusSmallEdges(ShapeExtend_FAIL1)) 
                printf("  failed to fix some small edges");
        }
        solid = sfwf->Shape();
    }
    
    if (fixspotstripfaces){
        Handle(ShapeFix_FixSmallFace) sffsm = new ShapeFix_FixSmallFace();
        sffsm -> Init (solid);
        sffsm -> SetPrecision (tolerance);
        sffsm -> Perform();
        solid = sffsm -> FixShape();
    }

    if (sewfaces){
        BRepOffsetAPI_Sewing sewedObj(tolerance);
        
        for (exp0.Init (solid, TopAbs_FACE); exp0.More(); exp0.Next()){
            TopoDS_Face face = TopoDS::Face (exp0.Current());
            sewedObj.Add (face);
        }
        
        sewedObj.Perform();
        
        if (!sewedObj.SewedShape().IsNull())
          solid = sewedObj.SewedShape();
    }
  
    {
        Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
        rebuild->Apply(solid);
        for (exp1.Init (solid, TopAbs_EDGE); exp1.More(); exp1.Next()){
            TopoDS_Edge edge = TopoDS::Edge(exp1.Current());
            if ( BRep_Tool::Degenerated(edge) )
                rebuild->Remove(edge, false);
        }
        solid = rebuild->Apply(solid);
    }
  
    if (makesolids){
        BRepBuilderAPI_MakeSolid ms;
        int count = 0;
        for (exp0.Init(solid, TopAbs_SHELL); exp0.More(); exp0.Next()){
            count++;
            ms.Add (TopoDS::Shell(exp0.Current()));
        }
        
        if (count){
            BRepCheck_Analyzer ba(ms);
            if (ba.IsValid ()) {
                Handle(ShapeFix_Shape) sfs = new ShapeFix_Shape;
                sfs->Init (ms);
                sfs->SetPrecision(tolerance);
                sfs->SetMaxTolerance(tolerance);
                sfs->Perform();
                solid = sfs->Shape();

                for (exp0.Init(solid, TopAbs_SOLID); exp0.More(); exp0.Next()){
                    TopoDS_Solid cur = TopoDS::Solid(exp0.Current());
                    TopoDS_Solid newsolid = cur;
                    BRepLib::OrientClosedSolid (newsolid);
                    Handle_ShapeBuild_ReShape rebuild = new ShapeBuild_ReShape;
                    rebuild->Replace(cur, newsolid, Standard_False);
                    TopoDS_Shape newshape = rebuild->Apply(solid, TopAbs_COMPSOLID);//, 1);
                    solid = newshape;
                }
            }
        }
    }
}
