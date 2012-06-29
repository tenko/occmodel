
occmodel
********

occmodel.viewer()

   View object or sequence of objects. Edges, faces and solids are
   supported

occmodel.demo()

   Simple demos


Box
***

class class occmodel.Box

   addPoint()

      Adjust bounds to include point.

   addPoints()

      Adjust bounds to include point.

   center

      Calculate center of box

   diagonal

      Return diagonal as a vector

   isPointIn()

      Check if point is inside box.

   isValid()

      Check validity

   radius

      Return radius of the sphere enclosing the box

   static union()

      Return a new bounding box which is a union of the arguments.

   volume

      Calculate volume of box


Edge
****

class class occmodel.Edge

   Edge - represent edge geometry (curve).

   boundingBox()

      Return edge bounding box

   copy()

      Create copy of edge

   createArc()

      Create arc from given start, end and center points

   createArc3P()

      Create arc by fitting through given points

   createBezier()

      Create bezier curve from start,end and given controll points.

   createCircle()

      Create circle from center, normal direction and radius.

   createEllipse()

      Create ellipse from center, normal direction and given major and
      minor axis.

   createLine()

      Create straight line from given start and end points

   createNURBS()

      Create NURBS curve.

      start - start point end - end point points - sequence of
      controll points knots - sequence of kont values weights -
      sequence of controll point weights mults - sequence of knot
      multiplicity

   createSpline()

      Create interpolating spline from start, end and given points.

   length()

      Return edge length

   mirror()

      Mirror edge inplace

      plane - mirror plane

   rotate()

      Rotate edge in place.

      p1 - axis start point p2 - axis end point angle - rotation angle
      in radians

   scale()

      Scale edge in place.

      pnt - reference point scale - scale factor

   tesselate()

      Tesselate edge to a tuple of points according to given max angle
      or distance factor

   translate()

      Translate edge in place.

      delta - (dx,dy,dz)


GLUTViewer
**********

class class occmodel.GLUTViewer


Plane
*****

class class occmodel.Plane

   closestPoint()

      Return closest point on plane

   distanceTo()

      Signed distance from plane to pnt

   flip()

      Flip direction of normal

   intersectLine()

      Find intersection with line defined by the points start and end

   transform()

      Transform plane


Point
*****

class class occmodel.Point

   distanceTo()

      Compute distance between 2 points.

   isZero()

      Check if arg is all zeros.

   set()

      Set one or more coordinates. accept both multiple argument and
      sequence like arguments.


Quaternion
**********

class class occmodel.Quaternion

   imap()

      Inverse rotation. We accept point as multiple argument, sequence
      like arguments and sequence of multiple points.

   length

      Calculate lenght of Quaternion

   lengthSquared

      Calculate squared lenght of Quaternion

   map()

      Rotation. We accept point as multiple argument, sequence like
      arguments and sequence of multiple points.

   set()

      Set one or more coordinates. accept both multiple argument and
      sequence like arguments.

   transform

      create the coresponding transformation matrix


Solid
*****

class class occmodel.Solid

   Geometry represention solid objects or compund solid.

   addSolids()

      Create compund solid from sequence of solid objects.

   area()

      Return solid area

   booleanDifference()

      Create boolean difference inplace.

   booleanIntersection()

      Create boolean intersection inplace.

   booleanUnion()

      Create boolean union inplace.

   boundingBox()

      Return solid bounding box

   centreOfMass()

      return center of mass of solid.

   chamfer()

      Chamfer edges inplace.

      Distance :
         chamfer distance

      Edgefilter :
         optional function taking argument of edge near, far and
         return edge selection status (boolean)

   copy()

      Create copy of solid

   createBox()

      Crate box from points defining diagonal.

   createCone()

      Crate cone

      p1 - axis start p2 - axis end radius1 - radius at start radius2
      - radius at end

   createCylinder()

      Create cylinder

      p1 - axis start p2 - axis end radius - cylinder radius

   createMesh()

      Create triangle mesh of solid.

      factor - deflection from true position angle - max angle

   createSolid()

      Create general solid from sequence of faces

   createSphere()

      Create sphere from center point and radius.

   createTorus()

      Create torus

      p1 - axis start p2 - axis end radius1 - inner radius radius2 -
      outer radius

   extrude()

      Create solid by extruding face from p1 to p2.

   fillet()

      Fillet edges inplace.

      Radius :
         fillet radius

      Edgefilter :
         optional function taking argument of edge near, far and
         return edge selection status (boolean)

   heal()

      Possible heal geometry

   inertia()

      return intertia of solid with respect to center of gravity.

      Return Ixx, Iyy, Izz, Ixy, Ixz, Iyz

   loft()

      Crate solid by lofting through sequence of wires.

      ruled - smooth or rules faces

   mirror()

      Mirror solid inplace

      plane - mirror plane

   pipe()

      Create pipe by extruding face allong sequence of edges.

   readBREP()

      Read geometry from BREP file.

   readSTEP()

      Read geometry from STEP file.

   revolve()

      Create solid by revolving face

      p1 - start of axis p2 - end of axis angle - revolve angle

   rotate()

      Rotate solid in place.

      p1 - axis start point p2 - axis end point angle - rotation angle
      in radians

   scale()

      Scale solid in place.

      pnt - reference point scale - scale factor

   section()

      Apply section operation between solid and plane.

      plane - section plane

      Result returned as a face.

   shell()

      Apply shell operation no solid.

      Offset :
         shell offset distance

      Facefilter :
         function taking argument of face near, far and return face
         selection status (boolean)

   translate()

      Translate solid in place.

      delta - (dx,dy,dz)

   volume()

      Return solid volume

   writeBREP()

      Write solid to BREP file.

   writeSTEP()

      Write solid to STEP file.

   writeSTL()

      Write solid to STL file.


Transform
*********

class class occmodel.Transform

   Matrix of 4x4 size. Typical 3D transformation matrix.

   det()

      Determinand of matrix

   identity()

      set identity matrix

   invert()

      Inverse of matrix

   map()

      We accept point as multiple argument, sequence like arguments
      and sequence of multiple points.

   rotateAxisCenter()

      Construct 4x4 rotation matrix.

   rotateX()

      We accept both multiple argument and sequence like arguments.

   rotateY()

      We accept both multiple argument and sequence like arguments.

   rotateZ()

      We accept both multiple argument and sequence like arguments.

   scale()

      We accept both multiple argument and sequence like arguments.

   set()

      We accept 16 arguments setting all values. Sequence of sequence
      of size 3x3 setting all values.

         m11 m12 m13 m14

      Matrix =   m21 m22 m23 m24
         m31 m32 m33 m34 m41 m42 m43 m44

   translate()

      We accept both multiple argument and sequence like arguments.

   transpose()

      Transpose of matrix

   zero()

      set all values to zero


Vector
******

class class occmodel.Vector

   length

      Calculate lenght of vector

   lengthSquared

      Calculate squared lenght of vector

   unit()

      Normalize the vector (arg.lenght = 1.)


Vertex
******

class class occmodel.Vertex

   Vertex


Viewer
******

class class occmodel.Viewer

   General viewer class


Viewport
********

class class occmodel.Viewport
