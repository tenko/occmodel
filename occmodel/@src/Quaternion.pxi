# -*- coding: utf-8 -*-
    
cdef class Quaternion:
    '''
    Class representing a quaternion usefull for rotation
    transformations.
    '''
    cdef public double w, x, y, z
    
    def __init__(self, *args):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        self.w = 1.
        self.x = 0.
        self.y = 0.
        self.z = 0.
        self.set(*args)
    
    def __repr__(self):
        """Return string representation of a Quaternion.
        """
        args = (str(self.w), str(self.x), str(self.y), str(self.z))
        return '(%s, %s, %s, %s)' % args
    
    def __str__(self):
        """Return string representation of a Quaternion.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
    
    def __getitem__(self, int key):
        if key == 0:
            return self.w
        elif key == 1:
            return self.x
        elif key == 2:
            return self.y
        elif key == 3:
            return self.z
        raise IndexError('index out of range')
    
    def __len__(self):
        "Length of sequence"
        return 4
        
    property length:
        'Calculate lenght of Quaternion'
        def __get__(self):
            return sqrt(self.w ** 2 + self.x ** 2 + self.y ** 2 + self.z ** 2)
    
    property lengthSquared:
        'Calculate squared lenght of Quaternion'
        def __get__(self):
            return self.w ** 2 + self.x ** 2 + self.y ** 2 + self.z ** 2
    
    property transform:
        'create the coresponding transformation matrix'
        def __get__(self):
            cdef double xx, xy, xz, xw
            cdef double yy, yz, yw
            cdef double zz, zw
            
            xx = self.x ** 2
            xy = self.x * self.y
            xz = self.x * self.z
            xw = self.x * self.w
            yy = self.y ** 2
            yz = self.y * self.z
            yw = self.y * self.w
            zz = self.z ** 2
            zw = self.z * self.w
            
            args = (1. - 2. * (yy + zz),    2. * (xy - zw),         2. * (xz + yw),         0.,
                    2. * (xy + zw),         1. - 2. * (xx + zz),    2. * (yz - xw),         0.,
                    2. * (xz - yw),         2. * (yz + xw),         1. - 2. * (xx + yy),    0.,
                    0.,                     0.,                     0.,                     1.)
            
            tr = Transform.__new__(Transform)
            tr.set(args)            
            
            return tr
    
    def __mul__(self, Quaternion other not None):
        cdef Quaternion ret = Quaternion.__new__(Quaternion)
        
        ret.w = self.w*other.w - self.x*other.x - self.y*other.y - self.z*other.z
        ret.x = self.w*other.x + self.x*other.w + self.y*other.z - self.z*other.y
        ret.y = self.w*other.y + self.y*other.w + self.z*other.x - self.x*other.z
        ret.z = self.w*other.z + self.z*other.w + self.x*other.y - self.y*other.x
        
        return ret
    
    def __imul__(self, Quaternion other not None):
        cdef double w, x, y, z
        
        w = self.w*other.w - self.x*other.x - self.y*other.y - self.z*other.z
        x = self.w*other.x + self.x*other.w + self.y*other.z - self.z*other.y
        y = self.w*other.y + self.y*other.w + self.z*other.x - self.x*other.z
        z = self.w*other.z + self.z*other.w + self.x*other.y - self.y*other.x
        
        self.w = w
        self.x = x
        self.y = y
        self.z = z
        
        return self
        
    cpdef Quaternion unit(self):
        cdef double d
        
        d = self.length
        if fabs(d) > ZERO_TOLERANCE:
            self.w /= d
            self.x /= d
            self.y /= d
            self.z /= d
        return self
    
    cpdef Quaternion conj(self):
        self.x = -self.x
        self.y = -self.y
        self.z = -self.z
        return self
  
    def imap(self, *args):
        """
        Inverse rotation.
        We accept point as multiple argument, sequence like arguments and
        sequence of multiple points.
        """
        cdef double w, x, y, z
        cdef double a, b, c, d
        cdef double Vx, Vy, Vz
        cdef double rx, ry, rz
        cdef int l
        
        assert fabs(self.length - 1.) < 0.00001, 'Quaternion has not unit length'
        
        w = self.w
        x = self.x
        y = self.y
        z = self.z
        
        l = len(args)
        
        if l == 1:
            # sequence like object
            args = args[0]
            if not isinstance(args, float) and not isinstance(args, int):
                if not isinstance(args[0], float) and not isinstance(args[0], int):
                    objects = len(args)
                else:
                    args = (args,)
                    objects = 1
            else:
                args = (args,)
                objects = 1
        else:
            if not isinstance(args[0], float) and not isinstance(args[0], int):
                objects = len(args)
            else:
                objects = 1
            
        ret = [None] * objects
        Vx, Vy, Vz = 0.,0.,0.
        
        for i in range(objects):
            arg = args[i]
            l = len(arg)
            
            if l == 3:
                Vx, Vy, Vz = arg
            elif l == 2:
                Vx, Vy = arg
            elif l == 1:
                Vx = arg[0]
            else:
                raise ValueError("Expected one, two or three numbers.")
            
            a =   x * Vx + y * Vy + z * Vz
            b =   w * Vx - y * Vz + z * Vy
            c =   w * Vy + x * Vz - z * Vx
            d =   w * Vz - x * Vy + y * Vx
  
            rx = a*x + b*w + c*z - d*y
            ry = a*y - b*z + c*w + d*x
            rz = a*z + b*y - c*x + d*w
            
            if l == 3:
                ret[i] = (rx, ry, rz)
            elif l == 2:
                ret[i] = (rx, ry)
            elif l == 1:
                ret[i] = (rx,)
        
        if objects == 1:
            return ret[0]
        else:
            return ret
            
    def map(self, *args):
        """
        Rotation.
        We accept point as multiple argument, sequence like arguments and
        sequence of multiple points.
        """
        cdef double w, x, y, z
        cdef double a, b, c, d
        cdef double Vx, Vy, Vz
        cdef double rx, ry, rz
        cdef int l
        
        assert abs(self.length - 1.) < 0.00001, 'Quaternion has not unit length'
        
        w = self.w
        x = self.x
        y = self.y
        z = self.z
        
        l = len(args)
        
        if l == 1:
            # sequence like object
            args = args[0]
            if not isinstance(args, float) and not isinstance(args, int):
                if not isinstance(args[0], float) and not isinstance(args[0], int):
                    objects = len(args)
                else:
                    args = (args,)
                    objects = 1
            else:
                args = (args,)
                objects = 1
        else:
            if not isinstance(args[0], float) and not isinstance(args[0], int):
                objects = len(args)
            else:
                objects = 1
            
        ret = [None] * objects
        Vx, Vy, Vz = 0.,0.,0.
        
        for i in range(objects):
            arg = args[i]
            l = len(arg)
            
            if l == 3:
                Vx, Vy, Vz = arg
            elif l == 2:
                Vx, Vy = arg
            elif l == 1:
                Vx = arg[0]
            else:
                raise ValueError("Expected one, two or three numbers.")
            
            a = - x * Vx - y * Vy - z * Vz
            b =   w * Vx + y * Vz - z * Vy
            c =   w * Vy - x * Vz + z * Vx
            d =   w * Vz + x * Vy - y * Vx
  
            rx = -a*x + b*w - c*z + d*y
            ry = -a*y + b*z + c*w - d*x
            rz = -a*z - b*y + c*x + d*w
            
            if l == 3:
                ret[i] = (rx, ry, rz)
            elif l == 2:
                ret[i] = (rx, ry)
            elif l == 1:
                ret[i] = (rx,)
        
        if objects == 1:
            return ret[0]
        else:
            return ret
    
    def fromAngleAxis(cls, double angle, Vector axis):
        cdef double s
        
        assert axis is not None
        
        angle = .5 * angle
        
        axis = axis.unit()
        
        ret = cls()
        ret.w = cos(angle)
        
        s = sin(angle)
        ret.x = axis.x * s
        ret.y = axis.y * s
        ret.z = axis.z * s
        
        return ret
    
    fromAngleAxis = classmethod(fromAngleAxis)
    
    def set(self, *args):
        """Set one or more coordinates.
        accept both multiple argument and
        sequence like arguments.
        """
        cdef int l
        
        if len(args) == 1:
            args = args[0]
            if isinstance(args, float) or isinstance(args, int):
                args  = (args,)
        
        l = len(args)
        if l == 4:
            self.w, self.x, self.y, self.z = args
        elif l == 3:
            self.w, self.x, self.y = args
        elif l == 2:
            self.w, self.x = args
        elif l == 1:
            self.w = args[0]
        elif l != 0:
            raise ValueError("Expected one, two or three numbers.")