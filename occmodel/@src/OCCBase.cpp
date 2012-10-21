// Copyright 2012 by Runar Tenfjord, Tenko as.
// See LICENSE.txt for details on conditions.
#include "OCCModel.h"

int OCCBase::transform(DVec mat, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        // Check if scaling is non-uniform
        double scaleTol = mat[0]*mat[5]*mat[10] - 1.0;
        if (scaleTol > Precision::Confusion()) {
            gp_GTrsf trans;
            int k = 0;
            for (int i = 1; i <= 3; i++) {
                for (int j = 1; j <= 4; j++) {
                    trans.SetValue(i,j,mat[k]);
                    k += 1;
                }
            }
            BRepBuilderAPI_GTransform aTrans(shape, trans, Standard_True);
            aTrans.Build();
            aTrans.Check();
            target->setShape(aTrans.Shape());
        } else {
            gp_Trsf trans;
            trans.SetValues(
                mat[0], mat[1], mat[2], mat[3], 
                mat[4], mat[5], mat[6], mat[7], 
                mat[8], mat[9], mat[10], mat[11], 
                0.00001,0.00001
            );
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
        return 0;
    }
    return 1;
}

int OCCBase::translate(OCCStruct3d delta, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        trans.SetTranslation(gp_Pnt(0,0,0), gp_Pnt(delta.x,delta.y,delta.z));
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
        return 0;
    }
    return 1;
}

int OCCBase::rotate(double angle, OCCStruct3d p1, OCCStruct3d p2, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        gp_Vec dir(gp_Pnt(p1.x, p1.y, p1.z), gp_Pnt(p2.x, p2.y, p2.z));
        gp_Ax1 axis(gp_Pnt(p1.x, p1.y, p1.z), dir);
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
        return 0;
    }
    return 1;
}

int OCCBase::scale(OCCStruct3d pnt, double scale, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Trsf trans;
        trans.SetScale(gp_Pnt(pnt.x,pnt.y,pnt.z), scale);
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
        return 0;
    }
    return 1;
}

int OCCBase::mirror(OCCStruct3d pnt, OCCStruct3d nor, OCCBase *target)
{
    try {
        TopoDS_Shape shape = this->getShape();
        
        if (shape.IsNull())
            StdFail_NotDone::Raise("Null shape");
        
        gp_Ax2 ax2(gp_Pnt(pnt.x,pnt.y,pnt.z), gp_Dir(nor.x,nor.y,nor.z));
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
        return 0;
    }
    return 1;
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

int OCCBase::findPlane(OCCStruct3d *origin, OCCStruct3d *normal, double tolerance = 1e-6)
{
    try {
        const TopoDS_Shape& shape = this->getShape();
        BRepBuilderAPI_FindPlane FP(shape, tolerance);
        if(!FP.Found())
            StdFail_NotDone::Raise("Plane not found");
        const Handle_Geom_Plane plane = FP.Plane();
        const gp_Ax1 axis = plane->Axis();
        
        const gp_Pnt loc = axis.Location();
        origin->x = loc.X();
        origin->y = loc.Y();
        origin->z = loc.Z();
        
        const gp_Dir dir = axis.Direction();
        normal->x = dir.X();
        normal->y = dir.Y();
        normal->z = dir.Z();
        
    } catch(Standard_Failure &err) {
        Handle_Standard_Failure e = Standard_Failure::Caught();
        const Standard_CString msg = e->GetMessageString();
        if (msg != NULL && strlen(msg) > 1) {
            setErrorMessage(msg);
        } else {
            setErrorMessage("Failed to find plane");
        }
        return 0;
    }
    return 1;   
}

TopAbs_ShapeEnum OCCBase::shapeType() {
        return this->getShape().ShapeType();
}

int OCCBase::hashCode() {
    return this->getShape().HashCode(std::numeric_limits<int>::max());
}

bool OCCBase::isEqual(OCCBase *other) {
    if (this->getShape().IsEqual(other->getShape()))
        return true;
    return false;
}

bool OCCBase::isNull() {
    return this->getShape().IsNull() ? true : false;
}

bool OCCBase::isValid() {
    if (this->getShape().IsNull())
        return false;
    BRepCheck_Analyzer aChecker(this->getShape());
    return aChecker.IsValid() ? true : false;
}

bool OCCBase::fixShape() {
    if (this->getShape().IsNull())
        return false;
    
    BRepCheck_Analyzer aChecker(this->getShape());
    if (!aChecker.IsValid()) {
        ShapeFix_ShapeTolerance aSFT;
        aSFT.LimitTolerance(this->getShape(),Precision::Confusion(),Precision::Confusion());
        
        Handle(ShapeFix_Shape) aSfs = new ShapeFix_Shape(this->getShape());
        aSfs->SetPrecision(Precision::Confusion());
        aSfs->Perform();
        
        const TopoDS_Shape aShape = aSfs->Shape();
        aChecker.Init(aShape, Standard_False);
        
        if (aChecker.IsValid() && this->canSetShape(aShape)) {
            this->setShape(aShape);
        }
    }
    return aChecker.IsValid();
}

int OCCBase::toString(std::string *output) {
    std::stringstream str;
    OCCTools::writeBREP(str, this->getShape());
    output->assign(str.str());
    return 0;
}

int OCCBase::fromString(std::string input) {
    std::stringstream str(input);
    TopoDS_Shape shape = TopoDS_Shape();
    
    int ret = OCCTools::readBREP(str, shape);
    if (ret) {
        if (this->canSetShape(shape))
            this->setShape(shape);
    }
    return ret;
}