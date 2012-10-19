# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#

cdef class Row:
    """
    Pointer to access row of matrix
    """
    cdef double *m
    cdef object parent
    
    # buffer interface
    cdef Py_ssize_t __shape[1]
    cdef Py_ssize_t __strides[1]
    cdef __cythonbufferdefaults__ = {"ndim": 1, "mode": "c"}
    
    def __init__(self, parent):
        """We must keep reference to parent Matrix to
           avoid memory to be reclaimed by system.
        """
        self.parent = parent
                      
    cdef set(self, double *m):
        self.m = m
    
    def __repr__(self):
        """Return string representation of a matrix.
        """
        return '(%f, %f, %f, %f)' % (self.m[0], self.m[1], self.m[2], self.m[3])
    
    def __str__(self):
        """Return string representation of a matrix.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
                 
    def __getitem__(self, int key):
        """Return item at index key
        """
        if key == 0:
            return self.m[0]
        elif key == 1:
            return self.m[1]
        elif key == 2:
            return self.m[2]
        elif key == 3:
            return self.m[3]
        raise IndexError('index out of range')
    
    def __setitem__(self, int key, double val):
        """Return item at index key
        """
        if key == 0:
            self.m[0] = val
        elif key == 1:
            self.m[1] = val
        elif key == 2:
            self.m[2] = val
        elif key == 3:
            self.m[3] = val
        else:
            raise IndexError('index out of range')
    
    def __len__(self):
        """We have 4 rows/cols"""
        return 4
    
    def __getbuffer__(self, Py_buffer* buffer, int flags):
        self.__shape[0] = 4
        self.__strides[0] = sizeof(double)
        
        buffer.buf = <void *>self.m
        buffer.obj = self
        buffer.len =  4*sizeof(double)
        buffer.readonly = 0
        buffer.format = <char*>"d"
        buffer.ndim = 1
        buffer.shape = <Py_ssize_t *>&self.__shape[0]
        buffer.strides = <Py_ssize_t *>&self.__strides[0]
        buffer.suboffsets = NULL
        buffer.itemsize = sizeof(double)
        buffer.internal = NULL
        
    def __releasebuffer__(self, Py_buffer* buffer):
        pass
    
cdef class Transform:
    """
    Matrix of 4x4 size. Typical 3D
    transformation matrix.
    """
    cdef double m[4][4]
    
    # buffer interface
    cdef Py_ssize_t __shape[2]
    cdef Py_ssize_t __strides[2]
    cdef __cythonbufferdefaults__ = {"ndim": 2, "mode": "c"}
    
    def __init__(self, *args):
        """
        We accept 16 arguments setting all values.
        Sequence of sequence of size 3x3 setting all values.
           
                      m11 m12 m13 m14
        Matrix =      m21 m22 m23 m24
                      m31 m32 m33 m34
                      m41 m42 m43 m44
        """
        self.set(args)
    
    def __repr__(self):
        """Return string representation of a matrix.
        """
        return '((%s, %s, %s, %s),\n(%s, %s, %s, %s),\n(%s, %s, %s, %s),\n(%s, %s, %s, %s))\n' % \
                (str(self.m[0][0]), str(self.m[0][1]), str(self.m[0][2]), str(self.m[0][3]),
                 str(self.m[1][0]), str(self.m[1][1]), str(self.m[1][2]), str(self.m[1][3]),
                 str(self.m[2][0]), str(self.m[2][1]), str(self.m[2][2]), str(self.m[2][3]),
                 str(self.m[3][0]), str(self.m[3][1]), str(self.m[3][2]), str(self.m[3][3]))
    
    def __str__(self):
        """Return string representation of a matrix.
        """
        return '%s%s' % (self.__class__.__name__, repr(self))
    
    def __getitem__(self, arg):
        """Return rows as a tuple object
        """
        cdef int key, row, col
        cdef Row ret
        
        try:
            key = arg
        except TypeError:
            try:
                row, col = arg
            except TypeError:
                raise TypeError('row or tuple (row, col) supplied')
            else:
                if row > 3 or col > 3:
                    raise IndexError('index out of range')
                else:
                    return self.m[row][col]
        else:
            ret = Row(self)
            if key == 0:
                ret.set(<double *>self.m[0])
            elif key == 1:
                ret.set(<double *>self.m[1])
            elif key == 2:
                ret.set(<double *>self.m[2])
            elif key == 3:
                ret.set(<double *>self.m[3])
            else:
                raise IndexError('index out of range')
            return ret
        
    def __len__(self):
        """We have 4 rows"""
        return 4
    
    def __getbuffer__(self, Py_buffer* buffer, int flags):
        self.__shape[0] = 4
        self.__shape[1] = 4
        self.__strides[0] = 4*sizeof(double)
        self.__strides[1] = sizeof(double)
        
        buffer.buf = self.m
        buffer.obj = self
        buffer.len = 16*sizeof(double)
        buffer.readonly = 0
        buffer.format = <char*>"d"
        buffer.ndim = 2
        buffer.shape = <Py_ssize_t *>&self.__shape[0]
        buffer.strides = <Py_ssize_t *>&self.__strides[0]
        buffer.suboffsets = NULL
        buffer.itemsize = sizeof(double)
        buffer.internal = NULL
        
    def __abs__(self):
        """Return absolute value of matrix: abs(m)
        """
        cdef Transform ret = Transform.__new__(Transform)
        
        ret.m[0][0] = fabs(self.m[0][0])
        ret.m[0][1] = fabs(self.m[0][1])
        ret.m[0][2] = fabs(self.m[0][2])
        ret.m[0][3] = fabs(self.m[0][3])
        
        ret.m[1][0] = fabs(self.m[1][0])
        ret.m[1][1] = fabs(self.m[1][1])
        ret.m[1][2] = fabs(self.m[1][2])
        ret.m[1][3] = fabs(self.m[1][3])
        
        ret.m[2][0] = fabs(self.m[2][0])
        ret.m[2][1] = fabs(self.m[2][1])
        ret.m[2][2] = fabs(self.m[2][2])
        ret.m[2][3] = fabs(self.m[2][3])
        
        ret.m[3][0] = fabs(self.m[3][0])
        ret.m[3][1] = fabs(self.m[3][1])
        ret.m[3][2] = fabs(self.m[3][2])
        ret.m[3][3] = fabs(self.m[3][3])
        return ret
    
    def __neg__(self):
        """Return negated value of matrix: -v
        """
        cdef Transform ret = Transform.__new__(Transform)
        
        ret.m[0][0] = -self.m[0][0]
        ret.m[0][1] = -self.m[0][1]
        ret.m[0][2] = -self.m[0][2]
        ret.m[0][3] = -self.m[0][3]
        
        ret.m[1][0] = -self.m[1][0]
        ret.m[1][1] = -self.m[1][1]
        ret.m[1][2] = -self.m[1][2]
        ret.m[1][3] = -self.m[1][3]
        
        ret.m[2][0] = -self.m[2][0]
        ret.m[2][1] = -self.m[2][1]
        ret.m[2][2] = -self.m[2][2]
        ret.m[2][3] = -self.m[2][3]
        
        ret.m[3][0] = -self.m[3][0]
        ret.m[3][1] = -self.m[3][1]
        ret.m[3][2] = -self.m[3][2]
        ret.m[3][3] = -self.m[3][3]
        return ret
    
    def __pos__(self):
        """Return positive value of matrix: +v
        """
        cdef Transform ret = Transform.__new__(Transform)
        
        ret.m[0][0] = self.m[0][0]
        ret.m[0][1] = self.m[0][1]
        ret.m[0][2] = self.m[0][2]
        ret.m[0][3] = self.m[0][3]
        
        ret.m[1][0] = self.m[1][0]
        ret.m[1][1] = self.m[1][1]
        ret.m[1][2] = self.m[1][2]
        ret.m[1][3] = self.m[1][3]
        
        ret.m[2][0] = self.m[2][0]
        ret.m[2][1] = self.m[2][1]
        ret.m[2][2] = self.m[2][2]
        ret.m[2][3] = self.m[2][3]
        
        ret.m[3][0] = self.m[3][0]
        ret.m[3][1] = self.m[3][1]
        ret.m[3][2] = self.m[3][2]
        ret.m[3][3] = self.m[3][3]
        return ret
    
    def __add__(Transform self not None, Transform rhs not None):
        """Matrix addition
        They must be of same shape.
        """
        cdef Transform ret = Transform.__new__(Transform)
        
        ret.m[0][0] += rhs[0][0]
        ret.m[0][1] += rhs[0][1]
        ret.m[0][2] += rhs[0][2]
        ret.m[0][3] += rhs[0][3]
        
        ret.m[1][0] += rhs[1][0]
        ret.m[1][1] += rhs[1][1]
        ret.m[1][2] += rhs[1][2]
        ret.m[1][3] += rhs[1][3]
        
        ret.m[2][0] += rhs[2][0]
        ret.m[2][1] += rhs[2][1]
        ret.m[2][2] += rhs[2][2]
        ret.m[2][3] += rhs[2][3]
        
        ret.m[3][0] += rhs[3][0]
        ret.m[3][1] += rhs[3][1]
        ret.m[3][2] += rhs[3][2]
        ret.m[3][3] += rhs[3][3]
        return ret
    
    def __iadd__(self, Transform rhs not None):
        """Inline Matrix addition ( m1 += m2)
        They must be of same shape.
        """
        self.m[0][0] += rhs[0][0]
        self.m[0][1] += rhs[0][1]
        self.m[0][2] += rhs[0][2]
        self.m[0][3] += rhs[0][3]
        
        self.m[1][0] += rhs[1][0]
        self.m[1][1] += rhs[1][1]
        self.m[1][2] += rhs[1][2]
        self.m[1][3] += rhs[1][3]
        
        self.m[2][0] += rhs[2][0]
        self.m[2][1] += rhs[2][1]
        self.m[2][2] += rhs[2][2]
        self.m[2][3] += rhs[2][3]
        
        self.m[3][0] += rhs[3][0]
        self.m[3][1] += rhs[3][1]
        self.m[3][2] += rhs[3][2]
        self.m[3][3] += rhs[3][3]
        return self
    
    def __sub__(Transform self not None, Transform rhs not None):
        """Matrix subtraction
        They must be of same shape.
        """
        cdef Transform ret = Transform.__new__(Transform)
        
        ret.m[0][0] -= rhs[0][0]
        ret.m[0][1] -= rhs[0][1]
        ret.m[0][2] -= rhs[0][2]
        ret.m[0][3] -= rhs[0][3]
        
        ret.m[1][0] -= rhs[1][0]
        ret.m[1][1] -= rhs[1][1]
        ret.m[1][2] -= rhs[1][2]
        ret.m[1][3] -= rhs[1][3]
        
        ret.m[2][0] -= rhs[2][0]
        ret.m[2][1] -= rhs[2][1]
        ret.m[2][2] -= rhs[2][2]
        ret.m[2][3] -= rhs[2][3]
        
        ret.m[3][0] -= rhs[3][0]
        ret.m[3][1] -= rhs[3][1]
        ret.m[3][2] -= rhs[3][2]
        ret.m[3][3] -= rhs[3][3]
        return ret
 
    def __isub__(self, Transform rhs not None):
        """Inline Matrix subtraction ( m1 -= m2)
        They must be of same shape.
        """
        self.m[0][0] -= rhs[0][0]
        self.m[0][1] -= rhs[0][1]
        self.m[0][2] -= rhs[0][2]
        self.m[0][3] -= rhs[0][3]
        
        self.m[1][0] -= rhs[1][0]
        self.m[1][1] -= rhs[1][1]
        self.m[1][2] -= rhs[1][2]
        self.m[1][3] -= rhs[1][3]
        
        self.m[2][0] -= rhs[2][0]
        self.m[2][1] -= rhs[2][1]
        self.m[2][2] -= rhs[2][2]
        self.m[2][3] -= rhs[2][3]
        
        self.m[3][0] -= rhs[3][0]
        self.m[3][1] -= rhs[3][1]
        self.m[3][2] -= rhs[3][2]
        self.m[3][3] -= rhs[3][3]
        return self
    
    def __mul__(a, b):
        """Matrix multiplication
        We accept both multiplication by a scalar and
        a other matrix. This is the matrix
        multiplication known from linear algebra. See the
        Matrix.dot function for this.
        """
        cdef Transform aa, bb, res
        cdef double s
        cdef int ta, tb
        
        ta = isinstance(a, Transform)
        tb = isinstance(b, Transform)
        
        if not ta  and tb:
            try:
                s = a
            except TypeError:
                raise TypeError("unsupported operand type for *")
            
            res = Transform.__new__(Transform)
            bb = b
            res.m[0][0] = s * bb.m[0][0]
            res.m[0][1] = s * bb.m[0][1]
            res.m[0][2] = s * bb.m[0][2]
            res.m[0][3] = s * bb.m[0][3]
        
            res.m[1][0] = s * bb.m[1][0]
            res.m[1][1] = s * bb.m[1][1]
            res.m[1][2] = s * bb.m[1][2]
            res.m[1][3] = s * bb.m[1][3]
            
            res.m[2][0] = s * bb.m[2][0]
            res.m[2][1] = s * bb.m[2][1]
            res.m[2][2] = s * bb.m[2][2]
            res.m[2][3] = s * bb.m[2][3]
            
            res.m[3][0] = s * bb.m[3][0]
            res.m[3][1] = s * bb.m[3][1]
            res.m[3][2] = s * bb.m[3][2]
            res.m[3][3] = s * bb.m[3][3]
            return res
        elif not tb and ta:
            try:
                s = b
            except TypeError:
                raise TypeError("unsupported operand type for *")
            
            res = Transform.__new__(Transform)
            aa = a
            res.m[0][0] = s * aa.m[0][0]
            res.m[0][1] = s * aa.m[0][1]
            res.m[0][2] = s * aa.m[0][2]
            res.m[0][3] = s * aa.m[0][3]
        
            res.m[1][0] = s * aa.m[1][0]
            res.m[1][1] = s * aa.m[1][1]
            res.m[1][2] = s * aa.m[1][2]
            res.m[1][3] = s * aa.m[1][3]
            
            res.m[2][0] = s * aa.m[2][0]
            res.m[2][1] = s * aa.m[2][1]
            res.m[2][2] = s * aa.m[2][2]
            res.m[2][3] = s * aa.m[2][3]
            
            res.m[3][0] = s * aa.m[3][0]
            res.m[3][1] = s * aa.m[3][1]
            res.m[3][2] = s * aa.m[3][2]
            res.m[3][3] = s * aa.m[3][3]
            return res
        elif ta and tb:
            res = Transform.__new__(Transform)
            aa = a
            bb = b
            res.m[0][0] = aa.m[0][0]*bb.m[0][0] + aa.m[0][1]*bb.m[1][0] + aa.m[0][2]*bb.m[2][0] + aa.m[0][3]*bb.m[3][0]
            res.m[0][1] = aa.m[0][0]*bb.m[0][1] + aa.m[0][1]*bb.m[1][1] + aa.m[0][2]*bb.m[2][1] + aa.m[0][3]*bb.m[3][1]
            res.m[0][2] = aa.m[0][0]*bb.m[0][2] + aa.m[0][1]*bb.m[1][2] + aa.m[0][2]*bb.m[2][2] + aa.m[0][3]*bb.m[3][2]
            res.m[0][3] = aa.m[0][0]*bb.m[0][3] + aa.m[0][1]*bb.m[1][3] + aa.m[0][2]*bb.m[2][3] + aa.m[0][3]*bb.m[3][3]
            
            res.m[1][0] = aa.m[1][0]*bb.m[0][0] + aa.m[1][1]*bb.m[1][0] + aa.m[1][2]*bb.m[2][0] + aa.m[1][3]*bb.m[3][0]
            res.m[1][1] = aa.m[1][0]*bb.m[0][1] + aa.m[1][1]*bb.m[1][1] + aa.m[1][2]*bb.m[2][1] + aa.m[1][3]*bb.m[3][1]
            res.m[1][2] = aa.m[1][0]*bb.m[0][2] + aa.m[1][1]*bb.m[1][2] + aa.m[1][2]*bb.m[2][2] + aa.m[1][3]*bb.m[3][2]
            res.m[1][3] = aa.m[1][0]*bb.m[0][3] + aa.m[1][1]*bb.m[1][3] + aa.m[1][2]*bb.m[2][3] + aa.m[1][3]*bb.m[3][3]
            
            res.m[2][0] = aa.m[2][0]*bb.m[0][0] + aa.m[2][1]*bb.m[1][0] + aa.m[2][2]*bb.m[2][0] + aa.m[2][3]*bb.m[3][0]
            res.m[2][1] = aa.m[2][0]*bb.m[0][1] + aa.m[2][1]*bb.m[1][1] + aa.m[2][2]*bb.m[2][1] + aa.m[2][3]*bb.m[3][1]
            res.m[2][2] = aa.m[2][0]*bb.m[0][2] + aa.m[2][1]*bb.m[1][2] + aa.m[2][2]*bb.m[2][2] + aa.m[2][3]*bb.m[3][2]
            res.m[2][3] = aa.m[2][0]*bb.m[0][3] + aa.m[2][1]*bb.m[1][3] + aa.m[2][2]*bb.m[2][3] + aa.m[2][3]*bb.m[3][3]
            
            res.m[3][0] = aa.m[3][0]*bb.m[0][0] + aa.m[3][1]*bb.m[1][0] + aa.m[3][2]*bb.m[2][0] + aa.m[3][3]*bb.m[3][0]
            res.m[3][1] = aa.m[3][0]*bb.m[0][1] + aa.m[3][1]*bb.m[1][1] + aa.m[3][2]*bb.m[2][1] + aa.m[3][3]*bb.m[3][1]
            res.m[3][2] = aa.m[3][0]*bb.m[0][2] + aa.m[3][1]*bb.m[1][2] + aa.m[3][2]*bb.m[2][2] + aa.m[3][3]*bb.m[3][2]
            res.m[3][3] = aa.m[3][0]*bb.m[0][3] + aa.m[3][1]*bb.m[1][3] + aa.m[3][2]*bb.m[2][3] + aa.m[3][3]*bb.m[3][3]
            return res
        else:
            raise TypeError("unsupported operand type for *")
    
    def __imul__(self, rhs):
        """Matrix multiplication
        We accept both multiplication by a scalar and
        a other matrix. This is the matrix
        multiplication known from linear algebra.
        """
        cdef Transform a
        cdef double s
        cdef int trhs
         
        cdef double m00, m01, m02, m03
        cdef double m10, m11, m12, m13
        cdef double m20, m21, m22, m23
        cdef double m30, m31, m32, m33
        
        trhs = isinstance(rhs, Transform)
        
        if not trhs:
            try:
                s = rhs
            except TypeError:
                raise TypeError("unsupported operand type for *")
            
            self.m[0][0] *= s
            self.m[0][1] *= s
            self.m[0][2] *= s
            self.m[0][3] *= s
        
            self.m[1][0] *= s
            self.m[1][1] *= s
            self.m[1][2] *= s
            self.m[1][3] *= s
            
            self.m[2][0] *= s
            self.m[2][1] *= s
            self.m[2][2] *= s
            self.m[2][3] *= s
            
            self.m[3][0] *= s
            self.m[3][1] *= s
            self.m[3][2] *= s
            self.m[3][3] *= s
        elif trhs:
            a = rhs
            m00 = self.m[0][0]*a.m[0][0] + self.m[0][1]*a.m[1][0] + self.m[0][2]*a.m[2][0] + self.m[0][3]*a.m[3][0]
            m01 = self.m[0][0]*a.m[0][1] + self.m[0][1]*a.m[1][1] + self.m[0][2]*a.m[2][1] + self.m[0][3]*a.m[3][1]
            m02 = self.m[0][0]*a.m[0][2] + self.m[0][1]*a.m[1][2] + self.m[0][2]*a.m[2][2] + self.m[0][3]*a.m[3][2]
            m03 = self.m[0][0]*a.m[0][3] + self.m[0][1]*a.m[1][3] + self.m[0][2]*a.m[2][3] + self.m[0][3]*a.m[3][3]
            
            m10 = self.m[1][0]*a.m[0][0] + self.m[1][1]*a.m[1][0] + self.m[1][2]*a.m[2][0] + self.m[1][3]*a.m[3][0]
            m11 = self.m[1][0]*a.m[0][1] + self.m[1][1]*a.m[1][1] + self.m[1][2]*a.m[2][1] + self.m[1][3]*a.m[3][1]
            m12 = self.m[1][0]*a.m[0][2] + self.m[1][1]*a.m[1][2] + self.m[1][2]*a.m[2][2] + self.m[1][3]*a.m[3][2]
            m13 = self.m[1][0]*a.m[0][3] + self.m[1][1]*a.m[1][3] + self.m[1][2]*a.m[2][3] + self.m[1][3]*a.m[3][3]
            
            m20 = self.m[2][0]*a.m[0][0] + self.m[2][1]*a.m[1][0] + self.m[2][2]*a.m[2][0] + self.m[2][3]*a.m[3][0]
            m21 = self.m[2][0]*a.m[0][1] + self.m[2][1]*a.m[1][1] + self.m[2][2]*a.m[2][1] + self.m[2][3]*a.m[3][1]
            m22 = self.m[2][0]*a.m[0][2] + self.m[2][1]*a.m[1][2] + self.m[2][2]*a.m[2][2] + self.m[2][3]*a.m[3][2]
            m23 = self.m[2][0]*a.m[0][3] + self.m[2][1]*a.m[1][3] + self.m[2][2]*a.m[2][3] + self.m[2][3]*a.m[3][3]
            
            m30 = self.m[3][0]*a.m[0][0] + self.m[3][1]*a.m[1][0] + self.m[3][2]*a.m[2][0] + self.m[3][3]*a.m[3][0]
            m31 = self.m[3][0]*a.m[0][1] + self.m[3][1]*a.m[1][1] + self.m[3][2]*a.m[2][1] + self.m[3][3]*a.m[3][1]
            m32 = self.m[3][0]*a.m[0][2] + self.m[3][1]*a.m[1][2] + self.m[3][2]*a.m[2][2] + self.m[3][3]*a.m[3][2]
            m33 = self.m[3][0]*a.m[0][3] + self.m[3][1]*a.m[1][3] + self.m[3][2]*a.m[2][3] + self.m[3][3]*a.m[3][3]
            
            self.m[0][0] = m00
            self.m[0][1] = m01
            self.m[0][2] = m02
            self.m[0][3] = m03
            
            self.m[1][0] = m10
            self.m[1][1] = m11
            self.m[1][2] = m12
            self.m[1][3] = m13
            
            self.m[2][0] = m20
            self.m[2][1] = m21
            self.m[2][2] = m22
            self.m[2][3] = m23
            
            self.m[3][0] = m30
            self.m[3][1] = m31
            self.m[3][2] = m32
            self.m[3][3] = m33
        else:
            raise TypeError("unsupported operand type for *")
        return self
    
    def __div__(a, b):
        """Matrix division
        We accept only division by a scalar. 
        """
        cdef Transform aa, bb, res
        cdef double s
        cdef int ta, tb
        
        ta = isinstance(a, Transform)
        tb = isinstance(b, Transform)
        
        if not ta and tb:
            try:
                s = 1./a
            except TypeError:
                raise TypeError("unsupported operand type for *")
            
            res = Transform.__new__(Transform)
            bb = b
            res.m[0][0] = s * bb.m[0][0]
            res.m[0][1] = s * bb.m[0][1]
            res.m[0][2] = s * bb.m[0][2]
            res.m[0][3] = s * bb.m[0][3]
        
            res.m[1][0] = s * bb.m[1][0]
            res.m[1][1] = s * bb.m[1][1]
            res.m[1][2] = s * bb.m[1][2]
            res.m[1][3] = s * bb.m[1][3]
            
            res.m[2][0] = s * bb.m[2][0]
            res.m[2][1] = s * bb.m[2][1]
            res.m[2][2] = s * bb.m[2][2]
            res.m[2][3] = s * bb.m[2][3]
            
            res.m[3][0] = s * bb.m[3][0]
            res.m[3][1] = s * bb.m[3][1]
            res.m[3][2] = s * bb.m[3][2]
            res.m[3][3] = s * bb.m[3][3]
            return res
        elif not tb and ta:
            try:
                s = 1./b
            except TypeError:
                raise TypeError("unsupported operand type for *")
            
            res = Transform.__new__(Transform)
            aa = a
            res.m[0][0] = s * aa.m[0][0]
            res.m[0][1] = s * aa.m[0][1]
            res.m[0][2] = s * aa.m[0][2]
            res.m[0][3] = s * aa.m[0][3]
        
            res.m[1][0] = s * aa.m[1][0]
            res.m[1][1] = s * aa.m[1][1]
            res.m[1][2] = s * aa.m[1][2]
            res.m[1][3] = s * aa.m[1][3]
            
            res.m[2][0] = s * aa.m[2][0]
            res.m[2][1] = s * aa.m[2][1]
            res.m[2][2] = s * aa.m[2][2]
            res.m[2][3] = s * aa.m[2][3]
            
            res.m[3][0] = s * aa.m[3][0]
            res.m[3][1] = s * aa.m[3][1]
            res.m[3][2] = s * aa.m[3][2]
            res.m[3][3] = s * aa.m[3][3]
            return res
        else:
            raise TypeError("unsupported operand type for *")
    
    def __idiv__(self, double s):
        """Inline Matrix division (v1 *= v2)
         We accept only division by a scalar.
        """
        s = 1./s
        self.m[0][0] *= s
        self.m[0][1] *= s
        self.m[0][2] *= s
        self.m[0][3] *= s
    
        self.m[1][0] *= s
        self.m[1][1] *= s
        self.m[1][2] *= s
        self.m[1][3] *= s
        
        self.m[2][0] *= s
        self.m[2][1] *= s
        self.m[2][2] *= s
        self.m[2][3] *= s
        
        self.m[3][0] *= s
        self.m[3][1] *= s
        self.m[3][2] *= s
        self.m[3][3] *= s
        return self
    
    def set(self, *args):
        """
        We accept 16 arguments setting all values.
        Sequence of sequence of size 3x3 setting all values.
           
                      m11 m12 m13 m14
        Matrix =   m21 m22 m23 m24
                      m31 m32 m33 m34
                      m41 m42 m43 m44
        """
        cdef int l, row, col
        
        l = len(args)
        if l == 1:
            args = args[0]
            l = len(args)
        
        if l == 0:
            self.m[0][0] = 1.
            self.m[1][1] = 1.
            self.m[2][2] = 1.
            self.m[3][3] = 1.
        
        elif l == 16:
                row, col = 0,0
                for row from 0 <= row < 4:
                    for col from 0 <= col < 4:
                        self.m[row][col] = args[row*4 + col]
        elif l == 1:
                args = args[0]
                assert len(args) == 4
                assert len(args[0]) == 4
                row, col = 0,0
                for row from 0 <= row < 4:
                    for col from 0 <= col < 4:
                        self.m[row][col] = args[row][col]
        
        else:
            raise IndexError("Expected sequence of floats with size 4x4 or length 16")
        
    cpdef Transform zero(self):
        """
        set all values to zero
        """
        self.m[0][0] = 0.; self.m[0][1] = 0.; self.m[0][2] = 0.; self.m[0][3] = 0.
        self.m[1][0] = 0.; self.m[1][1] = 0.; self.m[1][2] = 0.; self.m[1][3] = 0.
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 0.; self.m[2][3] = 0.
        self.m[3][0] = 0.; self.m[3][1] = 0.; self.m[3][2] = 0.; self.m[3][3] = 0.
        return self
        
    cpdef Transform identity(self):
        """
        set identity matrix
        """
        self.m[0][0] = 1.; self.m[0][1] = 0.; self.m[0][2] = 0.; self.m[0][3] = 0.
        self.m[1][0] = 0.; self.m[1][1] = 1.; self.m[1][2] = 0.; self.m[1][3] = 0.
        self.m[2][0] = 0.; self.m[2][1] = 0.; self.m[2][2] = 1.; self.m[2][3] = 0.
        self.m[3][0] = 0.; self.m[3][1] = 0.; self.m[3][2] = 0.; self.m[3][3] = 1.
        return self
        
    cpdef double det(self):
        """
        Determinand of matrix
        """
        return  (self.m[0][0]*self.m[1][1] - self.m[0][1]*self.m[1][0])*(self.m[2][2]*self.m[3][3] - self.m[2][3]*self.m[3][2])\
                - (self.m[0][0]*self.m[1][2] - self.m[0][2]*self.m[1][0])*(self.m[2][1]*self.m[3][3] - self.m[2][3]*self.m[3][1])\
                +(self.m[0][0]*self.m[1][3] - self.m[0][3]*self.m[1][0])*(self.m[2][1]*self.m[3][2] - self.m[2][2]*self.m[3][1])\
                + (self.m[0][1]*self.m[1][2] - self.m[0][2]*self.m[1][1])*(self.m[2][0]*self.m[3][3] - self.m[2][3]*self.m[3][0])\
                -(self.m[0][1]*self.m[1][3] - self.m[0][3]*self.m[1][1])*(self.m[2][0]*self.m[3][2] - self.m[2][2]*self.m[3][0])\
                + (self.m[0][2]*self.m[1][3] - self.m[0][3]*self.m[1][2])*(self.m[2][0]*self.m[3][1] - self.m[2][1]*self.m[3][0])
    
    cpdef Transform transpose(self):
        """
        Transpose of matrix
        """
        cdef double s
        cdef double m01, m02, m03
        cdef double m10, m12, m13
        cdef double m20, m21, m23
        cdef double m30, m31, m32
        
        m01 = self.m[1][0]
        m02 = self.m[2][0]
        m03 = self.m[3][0]
        
        m10 = self.m[0][1]
        m12 = self.m[2][1]
        m13 = self.m[3][1]
        
        m20 = self.m[0][2]
        m21 = self.m[1][2]
        m23 = self.m[3][2]
        
        m30 = self.m[0][3]
        m31 = self.m[1][3]
        m32 = self.m[2][3]
        
        self.m[0][1] = m01 ; self.m[0][2] = m02 ; self.m[0][3] = m03
        self.m[1][0] = m10 ; self.m[1][2] = m12 ; self.m[1][3] = m13
        self.m[2][0] = m20 ; self.m[2][1] = m21 ; self.m[2][3] = m23
        self.m[3][0] = m30 ; self.m[3][1] = m31 ; self.m[3][2] = m32
        
        return self
        
    cpdef Transform invert(self):
        """
        Inverse of matrix
        """
        cdef double s
        cdef double m00, m01, m02, m03
        cdef double m10, m11, m12, m13
        cdef double m20, m21, m22, m23
        cdef double m30, m31, m32, m33
        
        s = self.det()
        if s == 0.0:
            return False
        
        s = 1. / s
        m00 = s*(self.m[1][1]*(self.m[2][2]*self.m[3][3] - self.m[2][3]*self.m[3][2]) + self.m[1][2]*(self.m[2][3]*self.m[3][1] - self.m[2][1]*self.m[3][3]) + self.m[1][3]*(self.m[2][1]*self.m[3][2] - self.m[2][2]*self.m[3][1]))
        m01 = s*(self.m[2][1]*(self.m[0][2]*self.m[3][3] - self.m[0][3]*self.m[3][2]) + self.m[2][2]*(self.m[0][3]*self.m[3][1] - self.m[0][1]*self.m[3][3]) + self.m[2][3]*(self.m[0][1]*self.m[3][2] - self.m[0][2]*self.m[3][1]))
        m02 = s*(self.m[3][1]*(self.m[0][2]*self.m[1][3] - self.m[0][3]*self.m[1][2]) + self.m[3][2]*(self.m[0][3]*self.m[1][1] - self.m[0][1]*self.m[1][3]) + self.m[3][3]*(self.m[0][1]*self.m[1][2] - self.m[0][2]*self.m[1][1]))
        m03 = s*(self.m[0][1]*(self.m[1][3]*self.m[2][2] - self.m[1][2]*self.m[2][3]) + self.m[0][2]*(self.m[1][1]*self.m[2][3] - self.m[1][3]*self.m[2][1]) + self.m[0][3]*(self.m[1][2]*self.m[2][1] - self.m[1][1]*self.m[2][2]))
        
        m10 = s*(self.m[1][2]*(self.m[2][0]*self.m[3][3] - self.m[2][3]*self.m[3][0]) + self.m[1][3]*(self.m[2][2]*self.m[3][0] - self.m[2][0]*self.m[3][2]) + self.m[1][0]*(self.m[2][3]*self.m[3][2] - self.m[2][2]*self.m[3][3]))
        m11 = s*(self.m[2][2]*(self.m[0][0]*self.m[3][3] - self.m[0][3]*self.m[3][0]) + self.m[2][3]*(self.m[0][2]*self.m[3][0] - self.m[0][0]*self.m[3][2]) + self.m[2][0]*(self.m[0][3]*self.m[3][2] - self.m[0][2]*self.m[3][3]))
        m12 = s*(self.m[3][2]*(self.m[0][0]*self.m[1][3] - self.m[0][3]*self.m[1][0]) + self.m[3][3]*(self.m[0][2]*self.m[1][0] - self.m[0][0]*self.m[1][2]) + self.m[3][0]*(self.m[0][3]*self.m[1][2] - self.m[0][2]*self.m[1][3]))
        m13 = s*(self.m[0][2]*(self.m[1][3]*self.m[2][0] - self.m[1][0]*self.m[2][3]) + self.m[0][3]*(self.m[1][0]*self.m[2][2] - self.m[1][2]*self.m[2][0]) + self.m[0][0]*(self.m[1][2]*self.m[2][3] - self.m[1][3]*self.m[2][2]))
        
        m20 = s*(self.m[1][3]*(self.m[2][0]*self.m[3][1] - self.m[2][1]*self.m[3][0]) + self.m[1][0]*(self.m[2][1]*self.m[3][3] - self.m[2][3]*self.m[3][1]) + self.m[1][1]*(self.m[2][3]*self.m[3][0] - self.m[2][0]*self.m[3][3]))
        m21 = s*(self.m[2][3]*(self.m[0][0]*self.m[3][1] - self.m[0][1]*self.m[3][0]) + self.m[2][0]*(self.m[0][1]*self.m[3][3] - self.m[0][3]*self.m[3][1]) + self.m[2][1]*(self.m[0][3]*self.m[3][0] - self.m[0][0]*self.m[3][3]))
        m22 = s*(self.m[3][3]*(self.m[0][0]*self.m[1][1] - self.m[0][1]*self.m[1][0]) + self.m[3][0]*(self.m[0][1]*self.m[1][3] - self.m[0][3]*self.m[1][1]) + self.m[3][1]*(self.m[0][3]*self.m[1][0] - self.m[0][0]*self.m[1][3]))
        m23 = s*(self.m[0][3]*(self.m[1][1]*self.m[2][0] - self.m[1][0]*self.m[2][1]) + self.m[0][0]*(self.m[1][3]*self.m[2][1] - self.m[1][1]*self.m[2][3]) + self.m[0][1]*(self.m[1][0]*self.m[2][3] - self.m[1][3]*self.m[2][0]))
        
        m30 = s*(self.m[1][0]*(self.m[2][2]*self.m[3][1] - self.m[2][1]*self.m[3][2]) + self.m[1][1]*(self.m[2][0]*self.m[3][2] - self.m[2][2]*self.m[3][0]) + self.m[1][2]*(self.m[2][1]*self.m[3][0] - self.m[2][0]*self.m[3][1]))
        m31 = s*(self.m[2][0]*(self.m[0][2]*self.m[3][1] - self.m[0][1]*self.m[3][2]) + self.m[2][1]*(self.m[0][0]*self.m[3][2] - self.m[0][2]*self.m[3][0]) + self.m[2][2]*(self.m[0][1]*self.m[3][0] - self.m[0][0]*self.m[3][1]))
        m32 = s*(self.m[3][0]*(self.m[0][2]*self.m[1][1] - self.m[0][1]*self.m[1][2]) + self.m[3][1]*(self.m[0][0]*self.m[1][2] - self.m[0][2]*self.m[1][0]) + self.m[3][2]*(self.m[0][1]*self.m[1][0] - self.m[0][0]*self.m[1][1]))
        m33 = s*(self.m[0][0]*(self.m[1][1]*self.m[2][2] - self.m[1][2]*self.m[2][1]) + self.m[0][1]*(self.m[1][2]*self.m[2][0] - self.m[1][0]*self.m[2][2]) + self.m[0][2]*(self.m[1][0]*self.m[2][1] - self.m[1][1]*self.m[2][0]))
        
        self.m[0][0] = m00 ; self.m[0][1] = m01 ; self.m[0][2] = m02 ; self.m[0][3] = m03
        self.m[1][0] = m10 ; self.m[1][1] = m11 ; self.m[1][2] = m12 ; self.m[1][3] = m13
        self.m[2][0] = m20 ; self.m[2][1] = m21 ; self.m[2][2] = m22 ; self.m[2][3] = m23
        self.m[3][0] = m30 ; self.m[3][1] = m31 ; self.m[3][2] = m32 ; self.m[3][3] = m33
        
        return self
        
    def map(self, *args):
        """
        We accept point as multiple argument, sequence like arguments and
        sequence of multiple points.
        """
        cdef int i, l, objects
        cdef double x, y, z
        cdef double rx, ry, rz
        
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
        x, y, z = 0.,0.,0.
        
        for i from 0 <= i < objects:
            arg = args[i]
            l = len(arg)
            
            if l == 3:
                x, y, z = arg
            elif l == 2:
                x, y = arg
            elif l == 1:
                x = arg[0]
            else:
                raise ValueError("Expected one, two or three numbers.")
            
            rx = self.m[0][0]*x + self.m[0][1]*y + self.m[0][2]*z + self.m[0][3]
            ry = self.m[1][0]*x + self.m[1][1]*y + self.m[1][2]*z + self.m[1][3]
            rz = self.m[2][0]*x + self.m[2][1]*y + self.m[2][2]*z + self.m[2][3]
                
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
    
    def translate(self, *args):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        cdef Transform trans
        cdef int l
        cdef double dx, dy, dz
        
        dx, dy, dz = 0.,0.,0.
        
        l = len(args)
        if l == 1:
            args = args[0]
            if not isinstance(args, float) and not isinstance(args, int):
                l = len(args) # Sequence object
        
        if l == 3:
            dx, dy, dz = args
        elif l == 2:
            dx, dy = args
        elif l == 1:
            dx = args
        else:
            raise ValueError("Expected one, two or three numbers.")
        
        # identity matrix
        trans = Transform.__new__(Transform)
        trans.m[0][0] = 1.; trans.m[1][1] = 1.
        trans.m[2][2] = 1.; trans.m[3][3] = 1.
        
        trans.m[0][3] = dx
        trans.m[1][3] = dy
        trans.m[2][3] = dz
        
        self *= trans
        return self
        
    def scale(self, *args):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        cdef Transform trans
        cdef int l
        cdef double sx, sy, sz
        
        sx, sy, sz = 1.,1.,1.
        
        l = len(args)
        if l == 1:
            args = args[0]
            if not isinstance(args, float) and not isinstance(args, int):
                l = len(args) # Sequence object
        
        if l == 3:
            sx, sy, sz = args
        elif l == 2:
            sx, sy = args
        elif l == 1:
            sx = args
        else:
            raise ValueError("Expected one, two or three numbers.")
            
        # identity matrix
        trans = Transform.__new__(Transform)
        trans.m[0][0] = 1.; trans.m[1][1] = 1.
        trans.m[2][2] = 1.; trans.m[3][3] = 1.
        
        trans.m[0][0] = sx
        trans.m[1][1] = sy
        trans.m[2][2] = sz
        
        self *= trans
        return self
    
    cpdef Transform rotateX(self, double x):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        cdef Transform trans
        cdef double cosx, sinx
        
        cosx = cos(x)
        sinx = sin(x)
        
        # identity matrix
        trans = Transform.__new__(Transform)
        trans.m[0][0] = 1.; trans.m[1][1] = 1.
        trans.m[2][2] = 1.; trans.m[3][3] = 1.
        
        trans.m[1][1] = cosx
        trans.m[2][2] = cosx
        trans.m[2][1] = sinx
        trans.m[1][2] = -sinx
        
        self *= trans
        return self
    
    cpdef Transform rotateY(self, double y):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        cdef Transform trans
        cdef double cosy, siny
        
        cosy = cos(y)
        siny = sin(y)
        
        # identity matrix
        trans = Transform.__new__(Transform)
        trans.m[0][0] = 1.; trans.m[1][1] = 1.
        trans.m[2][2] = 1.; trans.m[3][3] = 1.
        
        trans.m[0][0] = cosy
        trans.m[2][2] = cosy
        trans.m[2][0] = -siny
        trans.m[0][2] = siny
        
        self *= trans
        return self
    
    cpdef Transform rotateZ(self, double z):
        """
        We accept both multiple argument
        and sequence like arguments.
        """
        cdef Transform trans
        cdef double cosz, sinz
        
        cosz = cos(z)
        sinz = sin(z)
        
        # identity matrix
        trans = Transform.__new__(Transform)
        trans.m[0][0] = 1.; trans.m[1][1] = 1.
        trans.m[2][2] = 1.; trans.m[3][3] = 1.
        
        trans.m[0][0] = cosz
        trans.m[1][1] = cosz
        trans.m[1][0] = sinz
        trans.m[0][1] = -sinz
        
        self *= trans
        return self
    
    cpdef Transform rotateAxisCenter(self, double angle, _axis, _center = (0.,0.,0.)):
        """Construct 4x4 rotation matrix.
        """
        #cdef Point axis, center
        cdef double sin_angle, cos_angle, one_minus_cos_angle
        
        sin_angle = sin(angle)
        cos_angle = cos(angle)
        one_minus_cos_angle = 1. - cos_angle
        
        center = Point(_center)
        axis = Vector(_axis)
        
        if angle != 0.:
            if abs(axis.lengthSquared - 1.) > EPSILON:
                axis.unit()

            self.m[0][0] = axis.x*axis.x*one_minus_cos_angle + cos_angle
            self.m[0][1] = axis.x*axis.y*one_minus_cos_angle - axis.z*sin_angle
            self.m[0][2] = axis.x*axis.z*one_minus_cos_angle + axis.y*sin_angle

            self.m[1][0] = axis.y*axis.x*one_minus_cos_angle + axis.z*sin_angle
            self.m[1][1] = axis.y*axis.y*one_minus_cos_angle + cos_angle
            self.m[1][2] = axis.y*axis.z*one_minus_cos_angle - axis.x*sin_angle

            self.m[2][0] = axis.z*axis.x*one_minus_cos_angle - axis.y*sin_angle
            self.m[2][1] = axis.z*axis.y*one_minus_cos_angle + axis.x*sin_angle
            self.m[2][2] = axis.z*axis.z*one_minus_cos_angle + cos_angle

            if center.x != 0. or center.y != 0. or center.z != 0.:
                self.m[0][3] = -((self.m[0][0]-1.0)*center.x + self.m[0][1]*center.y + self.m[0][2]*center.z)
                self.m[1][3] = -(self.m[1][0]*center.x + (self.m[1][1]-1.0)*center.y + self.m[1][2]*center.z)
                self.m[2][3] = -(self.m[2][0]*center.x + self.m[2][1]*center.y + (self.m[2][2]-1.0)*center.z)

            self.m[3][0] = self.m[3][1] = self.m[3][2] = 0.
            self.m[3][3] = 1.

        return self