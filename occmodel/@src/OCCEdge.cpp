// Gmsh - Copyright (C) 1997-2011 C. Geuzaine, J.-F. Remacle
//
// See the LICENSE.txt file for license information. Please report all
// bugs and problems to <gmsh@geuz.org>.
#include "OCCModel.h"

OCCEdge *OCCEdge::copy()
{
    OCCEdge *ret = new OCCEdge();
    try {
        BRepBuilderAPI_Copy A;
        A.Perform(edge);
        ret->setShape(TopoDS::Edge(A.Shape()));
    } catch(Standard_Failure &err) {
        return NULL;
    }
    return ret;
}

std::vector<DVec> OCCEdge::tesselate(double angular, double curvature)
{
    std::vector<DVec> ret;
    try {
        Standard_Real start, end;
        DVec dtmp;
        
        TopLoc_Location loc = edge.Location();
        gp_Trsf location = loc.Transformation();
        
        Handle(Geom_Curve) curve = BRep_Tool::Curve(this->edge, start, end);
        GeomAdaptor_Curve aCurve(curve);
		
        GCPnts_TangentialDeflection TD(aCurve, start, end, angular, curvature);
        
        for (Standard_Integer i = 1; i <= TD.NbPoints(); i++)
        {
            gp_Pnt pnt = TD.Value(i).Transformed(location);
            dtmp.clear();
            dtmp.push_back(pnt.X());
            dtmp.push_back(pnt.Y());
            dtmp.push_back(pnt.Z());
            ret.push_back(dtmp);
        }
    } catch(Standard_Failure &err) {
        return ret;
    }
    return ret;
}

int OCCEdge::createLine(OCCVertex *start, OCCVertex *end) {
    try {
        gp_Pnt aP1(start->x(), start->y(), start->z());
        gp_Pnt aP2(end->x(), end->y(), end->z());
        GC_MakeLine line(aP1, aP2);
        this->setShape(BRepBuilderAPI_MakeEdge(line, start->vertex, end->vertex));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createArc(OCCVertex *start, OCCVertex *end, DVec center) {
    try {
        gp_Pnt aP1(start->x(), start->y(), start->z());
        gp_Pnt aP2(center[0], center[1], center[2]);
        gp_Pnt aP3(end->x(), end->y(), end->z());
        
        Standard_Real Radius = aP1.Distance(aP2);
        gce_MakeCirc MC(aP2,gce_MakePln(aP1, aP2, aP3).Value(), Radius);
        const gp_Circ& Circ = MC.Value();
        
        Standard_Real Alpha1 = ElCLib::Parameter(Circ, aP1);
        Standard_Real Alpha2 = ElCLib::Parameter(Circ, aP3);
        Handle(Geom_Circle) C = new Geom_Circle(Circ);
        Handle(Geom_TrimmedCurve) arc = new Geom_TrimmedCurve(C, Alpha1, Alpha2, false);
        
        this->setShape(BRepBuilderAPI_MakeEdge(arc, start->vertex, end->vertex));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createArc3P(OCCVertex *start, OCCVertex *end, DVec aPoint) {
    try {
        gp_Pnt aP1(start->x(), start->y(), start->z());
        gp_Pnt aP2(aPoint[0], aPoint[1], aPoint[2]);
        gp_Pnt aP3(end->x(), end->y(), end->z());
        GC_MakeArcOfCircle arc(aP1, aP2, aP3);
        this->setShape(BRepBuilderAPI_MakeEdge(arc, start->vertex, end->vertex));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createCircle(DVec center, DVec normal, double radius)
{
    try {
        gp_Pnt aP1(center[0], center[1], center[2]);
        gp_Dir aD1(normal[0], normal[1], normal[2]);
        gce_MakeCirc circle(aP1, aD1, radius);
        if (!circle.IsDone()) {
            return 1;
        }
        this->setShape(BRepBuilderAPI_MakeEdge(circle));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createEllipse(DVec pnt, DVec nor, double rMajor, double rMinor)
{
    try {
        gp_Ax2 ax2(gp_Pnt(pnt[0],pnt[1],pnt[2]), gp_Dir(nor[0],nor[1],nor[2]));
        gce_MakeElips ellipse(ax2, rMajor, rMinor);
        
        if (!ellipse.IsDone()) {
            return 1;
        }
        this->setShape(BRepBuilderAPI_MakeEdge(ellipse));
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createHelix(OCCVertex *start, OCCVertex *end, double pitch, double height, double radius, double angle, bool leftHanded)
{
    try {
        gp_Ax2 cylAx2(gp_Pnt(0.0,0.0,0.0) , gp::DZ());
        Handle_Geom_Surface surf;
        if (angle <= 0.0) {
            surf = new Geom_CylindricalSurface(cylAx2, radius);
        } else {
            surf = new Geom_ConicalSurface(gp_Ax3(cylAx2), angle, radius);
        }
        
        gp_Pnt2d aPnt(0, 0);
        gp_Dir2d aDir(2. * M_PI, pitch);
        if (leftHanded) {
            aPnt.SetCoord(2. * M_PI, 0.0);
            aDir.SetCoord(-2. * M_PI, pitch);
        }
        gp_Ax2d aAx2d(aPnt, aDir);

        Handle(Geom2d_Line) line = new Geom2d_Line(aAx2d);
        gp_Pnt2d pnt_beg = line->Value(0);
        gp_Pnt2d pnt_end = line->Value(sqrt(4.0*M_PI*M_PI+pitch*pitch)*(height/pitch));
        Handle(Geom2d_TrimmedCurve) segm = GCE2d_MakeSegment(pnt_beg , pnt_end);

        this->setShape(BRepBuilderAPI_MakeEdge(segm , surf));
        BRepLib::BuildCurves3d(edge);
        
        if (start != NULL && end != NULL) {
            // find start and end vertices
            start->setShape(TopExp::FirstVertex(edge));
            end->setShape(TopExp::LastVertex(edge));
        }
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createBezier(OCCVertex *start, OCCVertex *end, std::vector<DVec> points)
{
    try {
        int nbControlPoints = points.size();
        int vertices = 0;
        if (start != NULL && end != NULL) {
            vertices = 2;
        }
        
        TColgp_Array1OfPnt ctrlPoints(1, nbControlPoints + vertices);
        
        int index = 1;
        if (vertices) {
            ctrlPoints.SetValue(index++, gp_Pnt(start->x(), start->y(), start->z()));
        }
        
        for (int i = 0; i < nbControlPoints; i++) {
            gp_Pnt aP(points[i][0],points[i][1],points[i][2]);
            ctrlPoints.SetValue(index++, aP);
        }
        
        if (vertices) {
            ctrlPoints.SetValue(index++, gp_Pnt(end->x(), end->y(), end->z())); 
        } else {
            // repeat first point
            ctrlPoints.SetValue(index++, ctrlPoints(1));
        }
        
        Handle(Geom_BezierCurve) bezier = new Geom_BezierCurve(ctrlPoints);
        
        if (vertices) {
            this->setShape(BRepBuilderAPI_MakeEdge(bezier, start->vertex, end->vertex));
        } else {
            this->setShape(BRepBuilderAPI_MakeEdge(bezier));
        }
        
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createSpline(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                           double tolerance)
{
    try {
        Standard_Boolean periodic = false;
        Standard_Real tol = tolerance;
        
        int vertices = 0;
        if (start != NULL && end != NULL) {
            vertices = 2;
            periodic = true;
        }
        
        int nbControlPoints = points.size();
        Handle(TColgp_HArray1OfPnt) ctrlPoints;
        ctrlPoints = new TColgp_HArray1OfPnt(1, nbControlPoints + vertices);
        
        int index = 1;
        
        if (vertices) {
            ctrlPoints->SetValue(index++, gp_Pnt(start->x(), start->y(), start->z()));  
        }
        
        for (int i = 0; i < nbControlPoints; i++) {
            gp_Pnt aP(points[i][0],points[i][1],points[i][2]);
            ctrlPoints->SetValue(index++, aP);
        }
        
        if (vertices) {
            ctrlPoints->SetValue(index++, gp_Pnt(end->x(), end->y(), end->z()));
        }
        
        GeomAPI_Interpolate INT(ctrlPoints, periodic, tol);
        INT.Perform();
        
        if (!INT.IsDone()) {
            return 1;
        }
        
        Handle(Geom_BSplineCurve) curve = INT.Curve();
        if (vertices) {
            this->setShape(BRepBuilderAPI_MakeEdge(curve, start->vertex, end->vertex));
        } else {
            this->setShape(BRepBuilderAPI_MakeEdge(curve));
        }
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

int OCCEdge::createNURBS(OCCVertex *start, OCCVertex *end, std::vector<DVec> points,
                          DVec knots, DVec weights, IVec mult)
{
    try {
        Standard_Boolean periodic = false;
        
        int vertices = 0;
        if (start != NULL && end != NULL) {
            vertices = 2;
            periodic = true;
        }
        
        int nbControlPoints = points.size() + vertices;
        TColgp_Array1OfPnt  ctrlPoints(1, nbControlPoints);
        
        TColStd_Array1OfReal _knots(1, knots.size());
        TColStd_Array1OfReal _weights(1, weights.size());
        TColStd_Array1OfInteger  _mult(1, mult.size());
        
        for (unsigned i = 0; i < knots.size(); i++) {
            _knots.SetValue(i+1, knots[i]);
        }
        
        for (unsigned i = 0; i < weights.size(); i++) {
            _weights.SetValue(i+1, weights[i]);
        }
        
        int totKnots = 0;
        for (unsigned i = 0; i < mult.size(); i++) {
            _mult.SetValue(i+1, mult[i]);   
            totKnots += mult[i];
        }

        const int degree = totKnots - nbControlPoints - 1;

        int index = 1;
        
        if (!periodic) {
            ctrlPoints.SetValue(index++, gp_Pnt(start->x(), start->y(), start->z()));
        }
        
        for (unsigned i = 0; i < points.size(); i++) {
            gp_Pnt aP(points[i][0],points[i][1],points[i][2]);
            ctrlPoints.SetValue(index++, aP);
        }
        
        if (!periodic) {
            ctrlPoints.SetValue(index++, gp_Pnt(end->x(), end->y(), end->z()));
        }
        
        Handle(Geom_BSplineCurve) NURBS = new Geom_BSplineCurve
        (ctrlPoints, _weights, _knots, _mult, degree, periodic);
        
        if (!periodic) {
            this->setShape(BRepBuilderAPI_MakeEdge(NURBS, start->vertex, end->vertex));
        } else {
            this->setShape(BRepBuilderAPI_MakeEdge(NURBS));
        }
    } catch(Standard_Failure &err) {
        return 1;
    }
    return 0;
}

double OCCEdge::length() {
    GProp_GProps prop;
    BRepGProp::LinearProperties(edge, prop);
    return prop.Mass();
}