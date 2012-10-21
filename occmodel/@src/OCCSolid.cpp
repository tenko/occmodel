// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
#include "OCCModel.h"

#define STB_TRUETYPE_IMPLEMENTATION
#define STBTT_malloc(x,u)    malloc(x)
#define STBTT_free(x,u)      free(x)
#include "stb_truetype.h"
#include "droidsans_ttf.h"

int OCCSolid::createSolid(std::vector<OCCFace *> faces, double tolerance)
{
    // algorithm from salomegeometry : GEOMImpl_ShapeDriver.cpp
    try {
        BRep_Builder B;
        TopoDS_Shape aShape, sh;
        
        tolerance = std::max(Precision::Confusion()*10.0, tolerance);
        
        BRepOffsetAPI_Sewing SW(tolerance);
        unsigned i = 0;
        for (; i<faces.size(); i++) {
            SW.Add(faces[i]->face);
        }
        SW.Perform();
        
        sh = SW.SewedShape();
        if( sh.ShapeType() == TopAbs_FACE && i == 1 ) {
            // case for creation of shell from one face - PAL12722 (skl 26.06.2006)
            TopoDS_Shell ss;
            B.MakeShell(ss);
            B.Add(ss,sh);
            aShape = ss;
        } else {
            TopExp_Explorer exp (sh, TopAbs_SHELL);
            Standard_Integer ish = 0;
            for (; exp.More(); exp.Next()) {
                aShape = exp.Current();
                ish++;
            }
        
            if (ish != 1)
                aShape = SW.SewedShape();
        }
        
        TopoDS_Solid sol;
        B.MakeSolid(sol);
        B.Add(sol, aShape);
        
        BRepClass3d_SolidClassifier SC (sol);
        SC.PerformInfinitePoint(Precision::Confusion());
        if (SC.State() == TopAbs_IN) {
            B.MakeSolid(sol);
            B.Add(sol, aShape.Reversed());
        }

        this->setShape(sol);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("solid not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create solid");
        }
        return 0;
    }
    return 1;
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
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to copy object");
        }
        return NULL;
    }
    return ret;
}

int OCCSolid::numSolids()
{
    const TopoDS_Shape& shp = this->getShape();
    if (shp.ShapeType() == TopAbs_SOLID) {
        return 1;
    } else {
        // CompSolid or Compound
        TopTools_IndexedMapOfShape compsolids;
        TopExp::MapShapes(shp, TopAbs_COMPSOLID, compsolids);
        
        TopTools_IndexedMapOfShape solids;
        TopExp::MapShapes(shp, TopAbs_SOLID, solids);
        
        return solids.Extent() + compsolids.Extent();
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
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to mesh object");
        }
        return NULL;
    }
    return mesh;
}

int OCCSolid::addSolids(std::vector<OCCSolid *> solids)
{
    try {
        bool isCompound = false;
        const TopoDS_Shape& shape = this->getShape();
        if (!shape.IsNull()) {
            if (shape.ShapeType() == TopAbs_COMPOUND)
                isCompound = true;
        }
        
        BRep_Builder B;
        TopoDS_Compound C;
        B.MakeCompound(C);
        
        // include self
        if (isCompound) {
            TopExp_Explorer ex;
            for (ex.Init(shape, TopAbs_COMPSOLID); ex.More(); ex.Next())
                B.Add(C, ex.Current());
            for (ex.Init(shape, TopAbs_SOLID); ex.More(); ex.Next())
                B.Add(C, ex.Current());
        } else {
            if (!shape.IsNull())
                B.Add(C, shape);
        }
        for (unsigned i = 0; i < solids.size(); i++) {
            B.Add(C, solids[i]->getShape());
        }
        this->setShape(C);
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to add solid");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createSphere(OCCStruct3d center, double radius)
{
    try {
        gp_Pnt aP(center.x, center.y, center.z);
        
        if (radius <= Precision::Confusion()) {
            StdFail_NotDone::Raise("radius to small");
        }
        
        this->setShape(BRepPrimAPI_MakeSphere(aP, radius).Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create sphere");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createCylinder(OCCStruct3d p1, OCCStruct3d p2, double radius)
{
    try {
        const double dx = p2.x - p1.x;
        const double dy = p2.y - p1.y;
        const double dz = p2.z - p1.z;
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        
        if (radius <= Precision::Confusion()) {
            StdFail_NotDone::Raise("radius to small");
        }
        
        gp_Pnt aP(p1.x, p1.y, p1.z);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        BRepPrimAPI_MakeCylinder MC(anAxes, radius, H);
        MC.Build();
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create cylinder");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createTorus(OCCStruct3d p1, OCCStruct3d p2, double ringRadius, double radius) {
    try {
        const double dx = p2.x - p1.x;
        const double dy = p2.y - p1.y;
        const double dz = p2.z - p1.z;
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        gp_Pnt aP(p1.x, p1.y, p1.z);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        
        if (radius <= Precision::Confusion()) {
            StdFail_NotDone::Raise("radius to small");
        }
        
        if (ringRadius <= Precision::Confusion()) {
            StdFail_NotDone::Raise("ringRadius to small");
        }
        
        BRepPrimAPI_MakeTorus MC(anAxes, ringRadius, radius);
        MC.Build();
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create torus");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createCone(OCCStruct3d p1, OCCStruct3d p2, double radius1, double radius2) {
    try {
        const double dx = p2.x - p1.x;
        const double dy = p2.y - p1.y;
        const double dz = p2.z - p1.z;
        const double H = sqrt(dx*dx + dy*dy + dz*dz);
        gp_Pnt aP(p1.x, p1.y, p1.z);
        gp_Vec aV(dx / H, dy / H, dz / H);
        gp_Ax2 anAxes(aP, aV);
        BRepPrimAPI_MakeCone MC(anAxes, radius1, radius2, H);
        MC.Build();
        this->setShape(MC.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create cone");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createBox(OCCStruct3d p1, OCCStruct3d p2) {
    try {
        gp_Pnt aP1(p1.x, p1.y, p1.z);
        gp_Pnt aP2(p2.x, p2.y, p2.z);
        BRepPrimAPI_MakeBox MB(aP1, aP2);
        MB.Build();
        this->setShape(MB.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create box");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createText(double height, double depth, const char *text, const char *fontpath = NULL)
{
    Handle(TopTools_HSequenceOfShape) wires = new TopTools_HSequenceOfShape;
    Handle(TopTools_HSequenceOfShape) edges = new TopTools_HSequenceOfShape;
    
    FILE* fp = 0;
    stbtt_fontinfo font;
    float scale, x0, y0, x, y, newx, newy, cx, cy;
    unsigned char* data = 0;
    unsigned int codepoint, lastcp;
	unsigned int state = 0;
    int datasize, i, g, advance, ascent;
    
    try {
        BRep_Builder Builder;
        TopoDS_Compound Compound;
        Builder.MakeCompound(Compound);
        
        if (!fontpath)
        {
            // default font
            data = &droidsans_ttf[0];
        } else {
            // Read in the font data.
            fp = fopen(fontpath, "rb");
            if (!fp) {
                StdFail_NotDone::Raise("failed to open font");
            }
            fseek(fp,0,SEEK_END);
            datasize = (int)ftell(fp);
            fseek(fp,0,SEEK_SET);
            
            data = (unsigned char*)malloc(datasize);
            if (data == NULL) {
                StdFail_NotDone::Raise("failed allocate font data");
            }
            
            fread(data, 1, datasize, fp);
            fclose(fp);
            fp = 0;
        }
        // Init stb_truetype
        if (!stbtt_InitFont(&font, data, 0)) {
            StdFail_NotDone::Raise("failed parse font data");
        }
        
        // Find scale factor
        scale = (double)stbtt_ScaleForPixelHeight(&font, (float)height);
        
        // Find basline
        stbtt_GetFontVMetrics(&font, &ascent,0,0);
        y0 = (ascent*scale);
        
        // Loop chars
        lastcp = 255; // Mark with invalid value
        x0 = x = y = 0.f;
        for (; *text; ++text)
        {
            stbtt_vertex *vertices = 0;
            // decode UTF-8 codepoint, ignore invalid
            if (decutf8(&state, &codepoint, *(unsigned char*)text)) continue;
            
            // kerning
            if (lastcp != 255) {
                x0 += scale*stbtt_GetCodepointKernAdvance(&font, lastcp, codepoint);
            }
            
            // get shape metric
            g = stbtt_FindGlyphIndex(&font, codepoint);
            stbtt_GetGlyphHMetrics(&font, g, &advance, 0);
            
            // get shape vertices
            int num_verts = stbtt_GetGlyphShape(&font, g, &vertices);
            //printf("num_verts = %d\n\n", num_verts);
            
            wires->Clear();
            edges->Clear();
            
            for (i=0; i < num_verts; ++i) {
                switch (vertices[i].type) {
                    case STBTT_vmove:
                    {
                        // start the next contour
                        if (edges->Length() > 0) {
                            Handle(TopTools_HSequenceOfShape) res = new TopTools_HSequenceOfShape;
                            
                            ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,1e-3,Standard_False,res);
                            if (res->Length() != 1)
                                StdFail_NotDone::Raise("Multiple wires created");
                            
                            wires->Append(res->Value(1));
                            edges->Clear();
                        }
                        x = x0 + vertices[i].x*scale;
                        y = y0 + vertices[i].y*scale;
                        //printf("%d STBTT_vmove x: %f, y: %f\n", i, x, y);
                        break;
                    }
                    case STBTT_vline:
                    {
                        newx = x0 + vertices[i].x*scale;
                        newy = y0 + vertices[i].y*scale;
                        //printf("%d STBTT_vline (x1: %f, y1: %f), (x2: %f, y2: %f)\n", i, x, y, newx, newy);
                        
                        gp_Pnt aP1(x, y, 0.);
                        BRepBuilderAPI_MakeVertex aV1(aP1);
                        
                        gp_Pnt aP2(newx, newy, 0.);
                        BRepBuilderAPI_MakeVertex aV2(aP2);
                        
                        GC_MakeLine line(aP1, aP2);
                        BRepBuilderAPI_MakeEdge ME(line, aV1.Vertex(), aV2.Vertex());
                        
                        edges->Append(ME.Edge());
                        
                        x = newx;
                        y = newy;
                        break;
                    }
                    case STBTT_vcurve:
                    {                        
                        TColgp_Array1OfPnt ctrlPoints(1, 3);
                        ctrlPoints.SetValue(1, gp_Pnt(x, y, 0.));
                        
                        cx = x0 + vertices[i].cx*scale;
                        cy = y0 + vertices[i].cy*scale;
                        ctrlPoints.SetValue(2, gp_Pnt(cx, cy, 0.));
                        
                        newx = x0 + vertices[i].x*scale;
                        newy = y0 + vertices[i].y*scale;
                        ctrlPoints.SetValue(3, gp_Pnt(newx, newy, 0.));
                        
                        //printf("%d STBTT_vcurve (x1: %f, y1: %f), (cx: %f, cy: %f), (x2: %f, y2: %f)\n", i, x, y, cx, cy, newx, newy);
                        
                        Handle(Geom_BezierCurve) bezier = new Geom_BezierCurve(ctrlPoints);
                        
                        gp_Pnt aP1(x, y, 0.);
                        BRepBuilderAPI_MakeVertex aV1(aP1);
                        
                        gp_Pnt aP2(newx, newy, 0.);
                        BRepBuilderAPI_MakeVertex aV2(aP2);
                        
                        BRepBuilderAPI_MakeEdge ME(bezier, aV1, aV2);
                        
                        GProp_GProps prop;
                        BRepGProp::LinearProperties(ME.Edge(), prop);
                        if (prop.Mass() <= Precision::Confusion()) {
                            StdFail_NotDone::Raise("bezier not valid");
                        }
        
                        edges->Append(ME.Edge());
                        
                        x = newx;
                        y = newy;
                        break;
                    }
                }
            }
            
            if (vertices) free(vertices);
            
            // add last contour
            if (edges->Length() > 0) {
                Handle(TopTools_HSequenceOfShape) res = new TopTools_HSequenceOfShape;
                
                ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,1e-3,Standard_False,res);
                if (res->Length() != 1)
                    StdFail_NotDone::Raise("Multiple wires created");
                
                wires->Append(res->Value(1));
                edges->Clear();
            }
            
            if (wires->Length() == 0) {
                StdFail_NotDone::Raise("failed to create edges");
            }
            
            // build face
            gp_Pln pln(gp_Pnt(0.,0.,0.), gp_Dir(0.,0.,1.));
            const TopoDS_Wire& wire = TopoDS::Wire(wires->Value(1));
            BRepBuilderAPI_MakeFace MF(pln, wire, Standard_True);
            
            // add possible additional wires
            for (unsigned i=2; i< wires->Length() + 1; i++) {
                TopoDS_Wire hole = TopoDS::Wire(wires->Value(i));
                if (hole.Orientation() == wire.Orientation()) {
                    MF.Add(TopoDS::Wire(hole.Reversed()));
                } else {
                    MF.Add(hole);
                }
            }
            
            MF.Build();
            if (!MF.IsDone())
                StdFail_NotDone::Raise("Could not create face");
            
            // extrude face to solid
            const TopoDS_Face& face = MF.Face();
            gp_Vec direction(gp_Pnt(0., 0., 0.), gp_Pnt(0., 0., depth));
            BRepPrimAPI_MakePrism MP(face, direction, Standard_False);
            Builder.Add(Compound, MP.Shape());
            
            // advance to next glyph
            x0 += (advance*scale);
            
            lastcp = codepoint;
        }
        
        // free data
        if (fontpath && data) free(data);
        
        this->setShape(Compound);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        if (fontpath && data) free(data);
        if (fp) fclose(fp);
        
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create solids from font data");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::createPrism(OCCFace *face, OCCStruct3d normal, bool isInfinite) {
    try {
        gp_Dir direction(normal.x, normal.y, normal.z);
        
        Standard_Boolean inf = Standard_True;
        if (!isInfinite) inf = Standard_False;
        
        BRepPrimAPI_MakePrism MP(face->getShape(), direction, inf);
        this->setShape(MP.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create prism");
        }
        return 0;
    }
    return 1;
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

OCCStruct3d OCCSolid::centreOfMass() {
    OCCStruct3d ret;
    GProp_GProps prop;
    BRepGProp::VolumeProperties(this->getSolid(), prop);
    gp_Pnt cg = prop.CentreOfMass();
    ret.x = cg.X();
    ret.y = cg.Y();
    ret.z = cg.Z();
    return ret;
}

int OCCSolid::extrude(OCCFace *face, OCCStruct3d p1, OCCStruct3d p2)
{
    try {
        gp_Vec direction(gp_Pnt(p1.x, p1.y, p1.z),
                         gp_Pnt(p2.x, p2.y, p2.z));
        gp_Ax1 axisOfRevolution(gp_Pnt(p1.x, p1.y, p1.z), direction);

        BRepPrimAPI_MakePrism MP(face->getShape(), direction,
                                 Standard_False);
        
        this->setShape(MP.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to extrude");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::revolve(OCCFace *face, OCCStruct3d p1, OCCStruct3d p2, double angle)
{
    try {
        gp_Dir direction(p2.x - p1.x, p2.y - p1.y, p2.z - p1.z);
        gp_Ax1 axisOfRevolution(gp_Pnt(p1.x, p1.y, p1.z), direction);
        BRepPrimAPI_MakeRevol MR(face->getShape(), axisOfRevolution, angle, Standard_False);
        this->setShape(MR.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to revolve");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::pipe(OCCFace *face, OCCWire *wire)
{
    try {
        BRepOffsetAPI_MakePipe MP(wire->wire, face->getShape());
        this->setShape(MP.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create pipe");
        }
        return 0;
    }
    return 1;
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
            StdFail_NotDone::Raise("Failed to create sweep");
        }
        PS.Build();
        if (!PS.MakeSolid()) {
            StdFail_NotDone::Raise("Failed to create a solid object from sweep");
        }
        this->setShape(PS.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create sweep");
        }
        return 0;
    }
    return 1;
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
        this->setShape(TS.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to loft");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::boolean(OCCSolid *tool, BoolOpType op) {
    try {
        TopoDS_Shape shape;
        switch (op) {
            case BOOL_FUSE:
            {
                BRepAlgoAPI_Fuse FU (tool->getShape(), this->getShape());
                if (!FU.IsDone())
                    Standard_ConstructionError::Raise("operation failed");
                shape = FU.Shape();
                break;
            }
            case BOOL_CUT:
            {
                BRepAlgoAPI_Cut CU (this->getShape(), tool->getShape());
                if (!CU.IsDone())
                    Standard_ConstructionError::Raise("operation failed");
                shape = CU.Shape();
                break;
            }
            case BOOL_COMMON:
            {
                BRepAlgoAPI_Common CO (tool->getShape(), this->getShape());
                if (!CO.IsDone())
                    Standard_ConstructionError::Raise("operation failed");
                shape = CO.Shape();
                break;
            }
            default:
                Standard_ConstructionError::Raise("unknown operation");
                break;
        }
        
        // check for empty compund shape
        TopoDS_Iterator It (shape, Standard_True, Standard_True);
        int found = 0;
        for (; It.More(); It.Next())
            found++;
        if (found == 0) {
            Standard_ConstructionError::Raise("result object is empty compound");
        }
        
        this->setShape(shape);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed in boolean operation");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::chamfer(std::vector<OCCEdge *> edges, std::vector<double> distances) {
    int edges_size = edges.size();
    int distances_size = distances.size();
    
    try {
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
                    StdFail_NotDone::Raise("size of distances argument not correct");;
                }
        }
        
        CF.Build();
        
        if (!CF.IsDone())
            StdFail_NotDone::Raise("Failed to chamfer solid");
        
        const TopoDS_Shape& tmp = CF.Shape();
        
        if (tmp.IsNull())
            StdFail_NotDone::Raise("Chamfer operaton return Null shape");
        
        this->setShape(tmp);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to chamfer solid");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::fillet(std::vector<OCCEdge *> edges, std::vector<double> radius) {
    int edges_size = edges.size();
    int radius_size = radius.size();
    
    try {
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
                    StdFail_NotDone::Raise("radius argument size not valid");;
                }
        }
        
        fill.Build();
        
        if (!fill.IsDone())
            StdFail_NotDone::Raise("Filler operation failed");
        
        const TopoDS_Shape& tmp = fill.Shape();
        
        if (tmp.IsNull())
            StdFail_NotDone::Raise("Fillet operation resulted in Null shape");
        
        this->setShape(tmp);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to fillet solid");
        }
        return 0;
    }
    return 1;
    
}

int OCCSolid::shell(std::vector<OCCFace *> faces, double offset, double tolerance) {
    try {
        TopTools_ListOfShape facelist;
        for (unsigned i=0; i<faces.size(); i++) {
            OCCFace *face = faces[i];
            facelist.Append(face->getShape());
        }
        
        BRepOffsetAPI_MakeThickSolid TS(solid, facelist, offset, tolerance);
        TS.Build();
        
        if (!TS.IsDone())
            StdFail_NotDone::Raise("Shell operation failed");
        
        const TopoDS_Shape& tmp = TS.Shape();
        
        if (tmp.IsNull())
            StdFail_NotDone::Raise("Shell operation resulted in Null shape");
        
        this->setShape(tmp);
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
    
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to shell solid");
        }
        return 0;
    }
    return 1;
}

int OCCSolid::offset(OCCFace *face, double offset, double tolerance = 1e-6) {
    try {
        BRepOffset_MakeOffset MO(face->getShape(), offset, tolerance, BRepOffset_Skin,
                                 Standard_False, Standard_False, GeomAbs_Arc, Standard_True);
        
        this->setShape(MO.Shape());
        
        // possible fix shape
        if (!this->fixShape())
            StdFail_NotDone::Raise("Shapes not valid");
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to offset face");
        }
        return 0;
    }
    return 1;
}

// FIXME!: Return vector of faces
// See FreeCad/CrossSection.cpp
//
OCCFace *OCCSolid::section(OCCStruct3d pnt, OCCStruct3d nor)
{
    Handle(TopTools_HSequenceOfShape) wires = new TopTools_HSequenceOfShape;
    Handle(TopTools_HSequenceOfShape) edges = new TopTools_HSequenceOfShape;
    TopExp_Explorer ex;
    OCCFace *ret = new OCCFace();
    try {
        gp_Pln pln(gp_Pnt(pnt.x,pnt.y,pnt.z), gp_Dir(nor.x,nor.y,nor.z));
        
        BRepAlgoAPI_Section mkSection(getShape(), pln);
        if (!mkSection.IsDone())
            StdFail_NotDone::Raise("Section operation failed");
    
        for (ex.Init(mkSection.Shape(), TopAbs_EDGE); ex.More(); ex.Next()) {
            if (!ex.Current().IsNull()) {
                edges->Append(TopoDS::Edge(ex.Current()));
            }
        }
        
        ShapeAnalysis_FreeBounds::ConnectEdgesToWires(edges,Precision::Confusion(),Standard_True,wires);
        if (wires->Length() != 1)
            StdFail_NotDone::Raise("No edges created");
        
        const TopoDS_Wire& wire = TopoDS::Wire(wires->Value(1));
        
        BRepBuilderAPI_MakeFace MFInit(pln, wire, Standard_True);
        MFInit.Build();
        if (!MFInit.IsDone())
            StdFail_NotDone::Raise("Could not create face");
        
        ShapeFix_Wire fixer(wire, MFInit.Face(), 1.0e-6);
        fixer.FixEdgeCurves();
        fixer.Perform();
        
        BRepBuilderAPI_MakeFace MFRes(pln, fixer.Wire(), Standard_True);
        MFRes.Build();
        
        ret->setShape(MFRes.Face());
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to create section");
        }
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
