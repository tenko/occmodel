
.. contents:: Table of Contents


functions
*********

cross(Vector a, Vector b) -> Vector

   Cross product

distance(Point u, Point v) -> double

   Compute distance between 2 points.

dot(Vector a, Vector b) -> double

   Dot product

demo()

   Simple demos

isParallell(Vector v1, Vector v2) -> int

   Return 1 if parallell, -1 if anti-parallell and 0 if not parallell.

isPerpendicular(Vector v1, Vector v2) -> int

   Return 1 if perpendicular and 0 if not perpendicular.

perpendicular(Vector v) -> Vector

   Create a vector perpendicular to v

viewer(objs, colors=None)

   View object or sequence of objects. Edges, faces and solids are
   supported.


Box
***

class Box

   Box(near=(-0.5, 0.5, -0.5), far=(0.5, -0.5, 0.5))

   Class representing a bounding box

   static __new__(S, ...) -> a new object with type S, a subtype of T

   addPoint(self, pnt)

      Adjust bounds to include point.

   addPoints(self, pnts)

      Adjust bounds to include point.

   isPointIn(self, pnt, int strictlyIn=False) -> int

      Check if point is inside box.

   isValid(self) -> int

      Check validity

   static union(cls, Box a, Box b)

      Return a new bounding box which is a union of the arguments.

   __eq__

      x.__eq__(y) <==> x==y

   __ge__

      x.__ge__(y) <==> x>=y

   __gt__

      x.__gt__(y) <==> x>y

   __init__

      x.__init__(...) initializes x; see help(type(x)) for signature

   __le__

      x.__le__(y) <==> x<=y

   __lt__

      x.__lt__(y) <==> x<y

   __ne__

      x.__ne__(y) <==> x!=y

   __repr__

      Return string representation of a box.

   __str__

      Return string representation of a box.

   center

      Calculate center of box

   diagonal

      Return diagonal as a vector

   far

      far: Point

   near

      near: Point

   radius

      Return radius of the sphere enclosing the box

   volume

      Calculate volume of box


Edge
****

class Edge

   Edge()

   Edge - represent edge geometry (curve).

   boundingBox(self) -> Box

      Return edge bounding box

   copy(self) -> Edge

      Create copy of edge

   createArc(self, Vertex start, Vertex end, center)

      Create arc from given start, end and center points

   createArc3P(self, Vertex start, Vertex end, pnt)

      Create arc by fitting through given points

   createBezier(self, Vertex start=None, Vertex end=None, points=None)

      Create bezier curve from start,end and given controll points.

   createCircle(self, center, normal, double radius)

      Create circle from center, normal direction and radius.

   createEllipse(self, center, normal, double rMajor, double rMinor)

      Create ellipse from center, normal direction and given major and
      minor axis.

   createLine(self, Vertex start, Vertex end)

      Create straight line from given start and end points

   createNURBS(self, Vertex start=None, Vertex end=None, points=None, knots=None, weights=None, mults=None)

      Create NURBS curve.

      start - start point end - end point points - sequence of
      controll points knots - sequence of kont values weights -
      sequence of controll point weights mults - sequence of knot
      multiplicity

   createSpline(self, Vertex start=None, Vertex end=None, points=None, tolerance=1e-06)

      Create interpolating spline from start, end and given points.

   length(self) -> double

      Return edge length

   mirror(self, Plane plane)

      Mirror edge inplace

      plane - mirror plane

   rotate(self, p1, p2, angle)

      Rotate edge in place.

      p1 - axis start point p2 - axis end point angle - rotation angle
      in radians

   scale(self, pnt, double scale)

      Scale edge in place.

      pnt - reference point scale - scale factor

   tesselate(self, double factor=0.1, double angle=0.1)

      Tesselate edge to a tuple of points according to given max angle
      or distance factor

   translate(self, delta)

      Translate edge in place.

      delta - (dx,dy,dz)

   end

      end: Vertex

   start

      start: Vertex


GLUTViewer
**********

class GLUTViewer

   GLUTViewer(width, height, title='Viewer (f - zoomFit | esc -
   Quit)')

   OnDisplay(self)

   OnFit(self)

   OnKeyboard(self, key, x, y)

   OnMotion(self, x, y)

   OnMouse(self, button, state, x, y)

   OnReshape(self, width, height)

   Show(self)


Mesh
****

class Mesh

   Mesh()

   Mesh - Represent triangle mesh for viewing purpose

   GLTriangles(self)

      Apply function pointer 'glVertex3d' and 'glNormal3d' to all
      triangles in mesh.

   GLVertices(self)

      Apply function pointer 'glVertex3d' to all vertices in mesh.

   normal(self, size_t index)

      Return normal at given vertex index

   ntriangles(self) -> size_t

      Return number of triangles

   nvertices(self) -> size_t

      Return number of vertices

   triangle(self, size_t index)

      Return triangle indices at given index

   vertex(self, size_t index)

      Return vertex at given index


Plane
*****

class Plane

   Plane(origin=<???>, xaxis=<???>, yaxis=<???>)

   Class representing a mathematical infinite plane.

   ValueAt(self, pnt)

   closestPoint(self, pnt) -> Point

      Return closest point on plane

   distanceTo(self, pnt) -> double

      Signed distance from plane to pnt

   flip(self)

      Flip direction of normal

   static fromFrame(cls, origin, xaxis, yaxis)

   static fromNormal(cls, origin, normal)

   intersectLine(self, start, end)

      Find intersection with line defined by the points start and end

   transform(self, Transform trans)

      Transform plane

   a

      a: 'double'

   b

      b: 'double'

   c

      c: 'double'

   d

      d: 'double'

   origin

      origin: Point

   xaxis

      xaxis: Vector

   yaxis

      yaxis: Vector

   zaxis

      zaxis: Vector


Point
*****

class Point

   Point(>>*<<args)

   Class representing a 3D point in space

   static __new__(S, ...) -> a new object with type S, a subtype of T

   distanceTo(self, Point arg) -> double

      Compute distance between 2 points.

   isZero(self) -> int

      Check if arg is all zeros.

   maximumCoordinate(self) -> double

   maximumCoordinateIndex(self) -> int

   set(self, *args)

      Set one or more coordinates. accept both multiple argument and
      sequence like arguments.

   __abs__

      Return absolute value of point: abs(v)

   __add__

      Point addition The arguments must be of same length

   __div__

      Point division by scalar.

   __eq__

      x.__eq__(y) <==> x==y

   __ge__

      x.__ge__(y) <==> x>=y

   __getitem__

      Override the list __getitem__ function to return a new point
      rather than a list.

   __gt__

      x.__gt__(y) <==> x>y

   __iadd__

      Inline Point addition ( p1 += p2) The arguments must be of same
      length

   __idiv__

      Inline Point division by scalar. (p1 /= 2.)

   __imul__

      Inline Point multiplication (v1 >>*<<= s1) We accept
      multiplication by scalar and a 4x4 transformation matrix.

   __init__

      We accept both multiple argument and sequence like arguments.

   __isub__

      Inline Point subtraction ( p1 -= p2) The arguments must be of
      same length

   __le__

      x.__le__(y) <==> x<=y

   __len__

      Length of sequence

   __lt__

      x.__lt__(y) <==> x<y

   __mul__

      Point multiplication We accept multiplication by a scalar, and a
      4x4 transformation matrix.

   __ne__

      x.__ne__(y) <==> x!=y

   __neg__

      Return negated value of point: -v

   __pos__

      Return positive value of point: +v

   __radd__

      x.__radd__(y) <==> y+x

   __rdiv__

      x.__rdiv__(y) <==> y/x

   __repr__

      Return string representation of a point.

   __rmul__

      x.__rmul__(y) <==> y*x

   __rsub__

      x.__rsub__(y) <==> y-x

   __str__

      Return string representation of a point.

   __sub__

      Point subtraction The arguments must be of same length

   x

      x: 'double'

   y

      y: 'double'

   z

      z: 'double'


Quaternion
**********

class Quaternion

   Quaternion(>>*<<args)

   Class representing a quaternion usefull for rotation
   transformations.

   static __new__(S, ...) -> a new object with type S, a subtype of T

   conj(self) -> Quaternion

   static fromAngleAxis(cls, double angle, Vector axis)

   imap(self, *args)

      Inverse rotation. We accept point as multiple argument, sequence
      like arguments and sequence of multiple points.

   map(self, *args)

      Rotation. We accept point as multiple argument, sequence like
      arguments and sequence of multiple points.

   set(self, *args)

      Set one or more coordinates. accept both multiple argument and
      sequence like arguments.

   unit(self) -> Quaternion

   __getitem__

      x.__getitem__(y) <==> x[y]

   __imul__

      x.__imul__(y) <==> x*=y

   __init__

      We accept both multiple argument and sequence like arguments.

   __len__

      Length of sequence

   __mul__

      x.__mul__(y) <==> x*y

   __repr__

      Return string representation of a Quaternion.

   __rmul__

      x.__rmul__(y) <==> y*x

   __str__

      Return string representation of a Quaternion.

   length

      Calculate lenght of Quaternion

   lengthSquared

      Calculate squared lenght of Quaternion

   transform

      create the coresponding transformation matrix

   w

      w: 'double'

   x

      x: 'double'

   y

      y: 'double'

   z

      z: 'double'


Solid
*****

class Solid

   Solid()

   Geometry represention solid objects or compund solid.

   addSolids(self, solids)

      Create compund solid from sequence of solid objects.

   area(self)

      Return solid area

   booleanDifference(self, Solid tool)

      Create boolean difference inplace.

   booleanIntersection(self, Solid tool)

      Create boolean intersection inplace.

   booleanUnion(self, Solid tool)

      Create boolean union inplace.

   boundingBox(self) -> Box

      Return solid bounding box

   centreOfMass(self)

      return center of mass of solid.

   chamfer(self, double distance, edgefilter=None)

      Chamfer edges inplace.

      Distance :
         chamfer distance

      Edgefilter :
         optional function taking argument of edge near, far and
         return edge selection status (boolean)

   copy(self) -> Solid

      Create copy of solid

   createBox(self, p1, p2)

      Crate box from points defining diagonal.

   createCone(self, p1, p2, double radius1, double radius2)

      Crate cone

      p1 - axis start p2 - axis end radius1 - radius at start radius2
      - radius at end

   createCylinder(self, p1, p2, double radius)

      Create cylinder

      p1 - axis start p2 - axis end radius - cylinder radius

   createMesh(self, double factor=0.01, double angle=0.25) -> Mesh

      Create triangle mesh of solid.

      factor - deflection from true position angle - max angle

   createSolid(self, faces, double tolerance=1e-06)

      Create general solid from sequence of faces

   createSphere(self, center, double radius)

      Create sphere from center point and radius.

   createTorus(self, p1, p2, double radius1, double radius2)

      Create torus

      p1 - axis start p2 - axis end radius1 - inner radius radius2 -
      outer radius

   extrude(self, Face face, p1, p2)

      Create solid by extruding face from p1 to p2.

   fillet(self, double radius, edgefilter=None)

      Fillet edges inplace.

      Radius :
         fillet radius

      Edgefilter :
         optional function taking argument of edge near, far and
         return edge selection status (boolean)

   heal(self, double tolerance=0.0, int fixdegenerated=True, int fixsmalledges=True, int fixspotstripfaces=True, int sewfaces=False, int makesolids=False)

      Possible heal geometry

   inertia(self)

      return intertia of solid with respect to center of gravity.

      Return Ixx, Iyy, Izz, Ixy, Ixz, Iyz

   loft(self, wires, int ruled=True)

      Crate solid by lofting through sequence of wires.

      ruled - smooth or rules faces

   mirror(self, Plane plane)

      Mirror solid inplace

      plane - mirror plane

   pipe(self, Face face, edges)

      Create pipe by extruding face allong sequence of edges.

   readBREP(self, char *filename)

      Read geometry from BREP file.

   readSTEP(self, char *filename)

      Read geometry from STEP file.

   revolve(self, Face face, p1, p2, double angle)

      Create solid by revolving face

      p1 - start of axis p2 - end of axis angle - revolve angle

   rotate(self, p1, p2, angle)

      Rotate solid in place.

      p1 - axis start point p2 - axis end point angle - rotation angle
      in radians

   scale(self, pnt, double scale)

      Scale solid in place.

      pnt - reference point scale - scale factor

   section(self, Plane plane)

      Apply section operation between solid and plane.

      plane - section plane

      Result returned as a face.

   shell(self, double offset, facefilter=None)

      Apply shell operation no solid.

      Offset :
         shell offset distance

      Facefilter :
         function taking argument of face near, far and return face
         selection status (boolean)

   translate(self, delta)

      Translate solid in place.

      delta - (dx,dy,dz)

   volume(self)

      Return solid volume

   writeBREP(self, char *filename)

      Write solid to BREP file.

   writeSTEP(self, char *filename)

      Write solid to STEP file.

   writeSTL(self, char *filename, int asciiMode=False)

      Write solid to STL file.


Transform
*********

class Transform

   Transform(>>*<<args)

   Matrix of 4x4 size. Typical 3D transformation matrix.

   static __new__(S, ...) -> a new object with type S, a subtype of T

   det(self) -> double

      Determinand of matrix

   identity(self) -> Transform

      set identity matrix

   invert(self) -> Transform

      Inverse of matrix

   map(self, *args)

      We accept point as multiple argument, sequence like arguments
      and sequence of multiple points.

   rotateAxisCenter(self, double angle, _axis, _center=(0.0, 0.0, 0.0)) -> Transform

      Construct 4x4 rotation matrix.

   rotateX(self, double x) -> Transform

      We accept both multiple argument and sequence like arguments.

   rotateY(self, double y) -> Transform

      We accept both multiple argument and sequence like arguments.

   rotateZ(self, double z) -> Transform

      We accept both multiple argument and sequence like arguments.

   scale(self, *args)

      We accept both multiple argument and sequence like arguments.

   set(self, *args)

      We accept 16 arguments setting all values. Sequence of sequence
      of size 3x3 setting all values.

         m11 m12 m13 m14

      Matrix =   m21 m22 m23 m24
         m31 m32 m33 m34 m41 m42 m43 m44

   translate(self, *args)

      We accept both multiple argument and sequence like arguments.

   transpose(self) -> Transform

      Transpose of matrix

   zero(self) -> Transform

      set all values to zero

   __abs__

      Return absolute value of matrix: abs(m)

   __add__

      Matrix addition They must be of same shape.

   __div__

      Matrix division We accept only division by a scalar.

   __getitem__

      Return rows as a tuple object

   __iadd__

      Inline Matrix addition ( m1 += m2) They must be of same shape.

   __idiv__

      Inline Matrix division (v1 >>*<<= v2) We accept only division by
      a scalar.

   __imul__

      Matrix multiplication We accept both multiplication by a scalar
      and a other matrix. This is the matrix multiplication known from
      linear algebra.

   __init__

      We accept 16 arguments setting all values. Sequence of sequence
      of size 3x3 setting all values.

         m11 m12 m13 m14

      Matrix =      m21 m22 m23 m24
         m31 m32 m33 m34 m41 m42 m43 m44

   __isub__

      Inline Matrix subtraction ( m1 -= m2) They must be of same
      shape.

   __len__

      We have 4 rows

   __mul__

      Matrix multiplication We accept both multiplication by a scalar
      and a other matrix. This is the matrix multiplication known from
      linear algebra. See the Matrix.dot function for this.

   __neg__

      Return negated value of matrix: -v

   __pos__

      Return positive value of matrix: +v

   __radd__

      x.__radd__(y) <==> y+x

   __rdiv__

      x.__rdiv__(y) <==> y/x

   __repr__

      Return string representation of a matrix.

   __rmul__

      x.__rmul__(y) <==> y*x

   __rsub__

      x.__rsub__(y) <==> y-x

   __str__

      Return string representation of a matrix.

   __sub__

      Matrix subtraction They must be of same shape.


Vector
******

class Vector

   distanceTo(self, Point arg) -> double

      Compute distance between 2 points.

   isZero(self) -> int

      Check if arg is all zeros.

   maximumCoordinate(self) -> double

   maximumCoordinateIndex(self) -> int

   set(self, *args)

      Set one or more coordinates. accept both multiple argument and
      sequence like arguments.

   unit(self) -> Vector

      Normalize the vector (arg.lenght = 1.)

   length

      Calculate lenght of vector

   lengthSquared

      Calculate squared lenght of vector

   x

      x: 'double'

   y

      y: 'double'

   z

      z: 'double'


Vertex
******

class Vertex

   Vertex(double x, double y, double z)

   Vertex

   x(self) -> double

   y(self) -> double

   z(self) -> double


Viewer
******

class Viewer

   Viewer()

   General viewer class

   Clear(self)

   OnDraw(self)

   OnSetup(self)

   addObject(self, obj, bbox, color='grey')

   dls

      dls: object

   objects

      objects: set


Viewport
********

class Viewport

   Viewport(projection=PARALLEL)

   cameraToClip(self)

   cameraToWorld(self)

   clipToCamera(self)

   extents(self, angle)

   getDollyCameraVector(self, x0, y0, x1, y1, distance_to_camera)

   loadModelViewMatrix(self)

   loadProjectionMatrix(self)

   resizeGL(self, width, height)

   rotateCamera(self, angle, axis, center)

   setCameraAngle(self, angle)

   setFrustumAspect(self, frustum_aspect)

   setFrustumNearFar(self, n, f)

   setViewportSize(self, width, height)

   updateCameraFrame(self)

   worldToCamera(self)

   zoomFactor(self, magnification_factor, fixed_screen_point=None)

   zoomToFit(self)

   bbox

      bbox: Box

   camDir

      camDir: Vector

   camLoc

      camLoc: Point

   camUp

      camUp: Vector

   camX

      camX: Vector

   camY

      camY: Vector

   camZ

      camZ: Vector

   fvBottom

      fvBottom: 'double'

   fvFar

      fvFar: 'double'

   fvLeft

      fvLeft: 'double'

   fvNear

      fvNear: 'double'

   fvRight

      fvRight: 'double'

   fvTop

      fvTop: 'double'

   projection

      projection: 'int'

   scrBottom

      scrBottom: 'int'

   scrFar

      scrFar: 'double'

   scrLeft

      scrLeft: 'int'

   scrNear

      scrNear: 'double'

   scrRight

      scrRight: 'int'

   scrTop

      scrTop: 'int'

   target

      target: Point
