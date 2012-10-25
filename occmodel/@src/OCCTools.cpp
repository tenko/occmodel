// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
#include "OCCModel.h"

void printShapeType(const TopoDS_Shape& shape)
{
    if (!shape.IsNull()) {
        TopAbs_ShapeEnum type = shape.ShapeType();
        switch (type)
        {
        case TopAbs_COMPOUND:
            printf("TopAbs_COMPOUND\n");
            break;
        case TopAbs_COMPSOLID:
            printf("TopAbs_COMPSOLID\n");
            break;
        case TopAbs_SOLID:
            printf("TopAbs_SOLID\n");
            break;
        case TopAbs_SHELL:
            printf("TopAbs_SHELL\n");
            break;
        case TopAbs_FACE:
            printf("TopAbs_FACE\n");
            break;
        case TopAbs_WIRE:
            printf("TopAbs_WIRE\n");
            break;
        case TopAbs_EDGE:
            printf("TopAbs_EDGE\n");
            break;
        case TopAbs_VERTEX:
            printf("TopAbs_VERTEX\n");
            break;
        default:
            printf("Unknown\n");
            break;
        }
    }
    else {
        printf("Empty shape\n");
    }
}

int extractSubShape(const TopoDS_Shape& shape, std::vector<OCCBase *>& shapes)
{
    TopAbs_ShapeEnum type = shape.ShapeType();
    switch (type)
    {
    case TopAbs_COMPOUND:
        return 0;
    case TopAbs_COMPSOLID:
    case TopAbs_SOLID:
    {
        OCCSolid *ret = new OCCSolid();
        ret->setShape(shape);
        if (!ret->fixShape()) {
            delete ret;
            return 0;
        }
        shapes.push_back((OCCBase *)ret);
        break;
    }
    case TopAbs_FACE:
    case TopAbs_SHELL:
    {
        OCCFace *ret = new OCCFace();
        ret->setShape(shape);
        if (!ret->fixShape()) {
            delete ret;
            return 0;
        }
        shapes.push_back((OCCBase *)ret);
        break;
    }
    case TopAbs_WIRE:
    {
        OCCWire *ret = new OCCWire();
        ret->setShape(shape);
        if (!ret->fixShape()) {
            delete ret;
            return 0;
        }
        shapes.push_back((OCCBase *)ret);
        break;
    }
    case TopAbs_EDGE:
    {
        OCCEdge *ret = new OCCEdge();
        ret->setShape(shape);
        if (!ret->fixShape()) {
            delete ret;
            return 0;
        }
        shapes.push_back((OCCBase *)ret);
        break;
    }
    case TopAbs_VERTEX:
    {
        OCCVertex *ret = new OCCVertex();
        ret->setShape(shape);
        if (!ret->fixShape()) {
            delete ret;
            return 0;
        }
        shapes.push_back((OCCBase *)ret);
        break;
    }
    default:
        return 0;
    }
    return 1;
}
    
int extractShape(const TopoDS_Shape& shape, std::vector<OCCBase *>& shapes)
{
    TopAbs_ShapeEnum type = shape.ShapeType();
    
    if (type != TopAbs_COMPOUND) {
        extractSubShape(shape, shapes);
        return 0;
    }
    
    TopExp_Explorer ex;
    int ret = 0;
    
    // extract compund
    for (ex.Init(shape, TopAbs_COMPOUND); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    
    // extract solids
    for (ex.Init(shape, TopAbs_COMPSOLID); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    for (ex.Init(shape, TopAbs_SOLID); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    
    // extract free faces
    for (ex.Init(shape, TopAbs_SHELL, TopAbs_SOLID); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    for (ex.Init(shape, TopAbs_FACE, TopAbs_SOLID); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    
    // extract free wires
    for (ex.Init(shape, TopAbs_WIRE, TopAbs_FACE); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    
    // extract free edges
    for (ex.Init(shape, TopAbs_EDGE, TopAbs_WIRE); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
        
    // extract free vertices
    for (ex.Init(shape, TopAbs_VERTEX, TopAbs_EDGE); ex.More(); ex.Next())
        ret += extractSubShape(ex.Current(), shapes);
    
    return ret;
}

int OCCTools::writeBREP(const char *filename, std::vector<OCCBase *> shapes)
{
    try {
        BRep_Builder B;
        TopoDS_Compound C;
        B.MakeCompound(C);
        for (unsigned i = 0; i < shapes.size(); i++) {
            B.Add(C, shapes[i]->getShape());
        }
        BRepTools::Write(C, filename);
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to write BREP file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::writeBREP(std::ostream& str, const TopoDS_Shape& shape)
{
    BRepTools::Write(shape, str);
    return 1;
}

int OCCTools::writeSTEP(const char *filename, std::vector<OCCBase *> shapes)
{
    try {
        STEPControl_Writer writer;
        IFSelect_ReturnStatus status;
        
        Interface_Static::SetCVal("xstep.cascade.unit","M");
        Interface_Static::SetIVal("read.step.nonmanifold", 1);
        
        for (unsigned i = 0; i < shapes.size(); i++) {
            status = writer.Transfer(shapes[i]->getShape(), STEPControl_AsIs);
            if (status != IFSelect_RetDone) {
                StdFail_NotDone::Raise("Failed to write STEP file");
            }
        }
        status = writer.Write(filename);
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to write STEP file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::writeSTL(const char *filename, std::vector<OCCBase *> shapes)
{
    try {
        BRep_Builder B;
        TopoDS_Compound shape;
        B.MakeCompound(shape);
        
        for (unsigned i = 0; i < shapes.size(); i++) {
            B.Add(shape, shapes[i]->getShape());
        }
        StlAPI_Writer writer;
        writer.Write(shape, filename);
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to write STL file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::writeVRML(const char *filename, std::vector<OCCBase *> shapes)
{
    try {
        BRep_Builder B;
        TopoDS_Compound shape;
        B.MakeCompound(shape);
        
        for (unsigned i = 0; i < shapes.size(); i++) {
            B.Add(shape, shapes[i]->getShape());
        }
        VrmlAPI_Writer writer;
        writer.Write(shape, filename);
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to write VRML file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::readBREP(const char *filename, std::vector<OCCBase *>& shapes)
{
    try {
        // read brep-file
        TopoDS_Shape shape;
        BRep_Builder aBuilder;
        if (!BRepTools::Read(shape, filename, aBuilder)) {
            StdFail_NotDone::Raise("Failed to read BFREP file");
        }
        extractShape(shape, shapes);
    } catch (Standard_Failure) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to read BREP file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::readBREP(std::istream& str, TopoDS_Shape& shape)
{
    try {
        // read brep-file
        BRep_Builder aBuilder;
        BRepTools::Read(shape, str, aBuilder);
    } catch (Standard_Failure) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to read BREP file");
        }
        return 0;
    }
    return 1;
}

int OCCTools::readSTEP(const char *filename, std::vector<OCCBase *>& shapes)
{
    try {
        STEPControl_Reader aReader;
        
        Interface_Static::SetCVal("xstep.cascade.unit","M");
        Interface_Static::SetIVal("read.step.nonmanifold", 1);
        
        if (aReader.ReadFile(filename) != IFSelect_RetDone) {
            StdFail_NotDone::Raise("Failed to read STEP file");
        }
        
        // Root transfers
        int nbr = aReader.NbRootsForTransfer();
        for (int n = 1; n<= nbr; n++) {
            aReader.TransferRoot(n);
        }
        
        // Collecting resulting entities
        int nbs = aReader.NbShapes();
        if (nbs == 0) return 1;
        
        for (int i=1; i<=nbs; i++) {
            const TopoDS_Shape& aShape = aReader.Shape(i);
            extractShape(aShape, shapes);
        }
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        //printf("ERROR: %s\n", e->GetMessageString());
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to read STEP file");
        }
        return 0;
    }
    return 1;
}
