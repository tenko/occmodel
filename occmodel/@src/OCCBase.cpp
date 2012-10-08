// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

int OCCBase::transform(DVec mat, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        trans.SetValues(
            mat[0], mat[1], mat[2], mat[3], 
            mat[4], mat[5], mat[6], mat[7], 
            mat[8], mat[9], mat[10], mat[11], 
            0.00001,0.00001
        );
        // Check if scaling is non-uniform
        double scaleTol = mat[0]*mat[5]*mat[10] - 1.0;
        if (scaleTol > 1e-6) {
            BRepBuilderAPI_GTransform aTrans(shape, trans, Standard_True);
            aTrans.Build();
            aTrans.Check();
            target->setShape(aTrans.Shape());
        } else {
            BRepBuilderAPI_Transform aTrans(shape, trans, Standard_True);
            aTrans.Build();
            aTrans.Check();
            target->setShape(aTrans.Shape());
        }
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to transform object");
        }
        return 1;
    }
    return 0;
}

int OCCBase::translate(DVec delta, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        trans.SetTranslation(gp_Pnt(0,0,0), gp_Pnt(delta[0],delta[1],delta[2]));
        BRepBuilderAPI_Transform aTrans(shape, trans, Standard_True);
        aTrans.Build();
        aTrans.Check();
        target->setShape(aTrans.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to translate object");
        }
        return 1;
    }
    return 0;
}

int OCCBase::rotate( double angle, DVec p1, DVec p2, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        gp_Vec dir(gp_Pnt(p1[0], p1[1], p1[2]), gp_Pnt(p2[0], p2[1], p2[2]));
        gp_Ax1 axis(gp_Pnt(p1[0], p1[1], p1[2]), dir);
        trans.SetRotation(axis, angle);
        BRepBuilderAPI_Transform aTrans(shape, trans, Standard_True);
        aTrans.Build();
        aTrans.Check();
        target->setShape(aTrans.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to rotate object");
        }
        return 1;
    }
    return 0;
}

int OCCBase::scale(DVec pnt, double scale, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        trans.SetScale(gp_Pnt(pnt[0],pnt[1],pnt[2]), scale);
        BRepBuilderAPI_Transform aTrans(shape, trans, Standard_True);
        aTrans.Build();
        aTrans.Check();
        target->setShape(aTrans.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to scale object");
        }
        return 1;
    }
    return 0;
}

int OCCBase::mirror(DVec pnt, DVec nor, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Ax2 ax2(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        gp_Trsf trans;
        trans.SetMirror(ax2);
        BRepBuilderAPI_Transform aTrans(shape, trans, Standard_False);
        target->setShape(aTrans.Shape());
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to mirror object");
        }
        return 1;
    }
    return 0;
}

int OCCBase::findPlane(double *origin, double *normal, double tolerance = 1e-6)
{
    try {
        const TopoDS_Shape& shape = this->getShape();
        BRepBuilderAPI_FindPlane FP(shape, tolerance);
        if(!FP.Found())
            StdFail_NotDone::Raise("Plane not found");
        const Handle_Geom_Plane plane = FP.Plane();
        const gp_Ax1 axis = plane->Axis();
        
        const gp_Pnt loc = axis.Location();
        origin[0] = loc.X();
        origin[1] = loc.Y();
        origin[2] = loc.Z();
        
        const gp_Dir dir = axis.Direction();
        normal[0] = dir.X();
        normal[1] = dir.Y();
        normal[2] = dir.Z();
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to find plane");
        }
        return 1;
    }
    return 0;   
}
DVec OCCBase::boundingBox(double tolerance = 1e-12)
{
    DVec ret;
    try {
        const TopoDS_Shape& shape = this->getShape();
        Bnd_Box aBox;
        BRepBndLib::Add(shape, aBox);
        aBox.SetGap(tolerance);
        Standard_Real aXmin, aYmin, aZmin;
        Standard_Real aXmax, aYmax, aZmax;
        aBox.Get(aXmin, aYmin, aZmin, aXmax, aYmax, aZmax);
        ret.push_back(aXmin);
        ret.push_back(aYmin);
        ret.push_back(aZmin);
        ret.push_back(aXmax);
        ret.push_back(aYmax);
        ret.push_back(aZmax);
    } catch(Standard_Failure &err) {
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
        ret.push_back(0.0);
    }
    return ret;
}