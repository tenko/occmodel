cdef extern from "GL/gl.h":
    # AccumOp
    int GL_ACCUM
    int GL_LOAD
    int GL_RETURN
    int GL_MULT
    int GL_ADD

    # AlphaFunction
    int GL_NEVER
    int GL_LESS
    int GL_EQUAL
    int GL_LEQUAL
    int GL_GREATER
    int GL_NOTEQUAL
    int GL_GEQUAL
    int GL_ALWAYS

    # AttribMask
    int GL_CURRENT_BIT
    int GL_POINT_BIT
    int GL_LINE_BIT
    int GL_POLYGON_BIT
    int GL_POLYGON_STIPPLE_BIT
    int GL_PIXEL_MODE_BIT
    int GL_LIGHTING_BIT
    int GL_FOG_BIT
    int GL_DEPTH_BUFFER_BIT
    int GL_ACCUM_BUFFER_BIT
    int GL_STENCIL_BUFFER_BIT
    int GL_VIEWPORT_BIT
    int GL_TRANSFORM_BIT
    int GL_ENABLE_BIT
    int GL_COLOR_BUFFER_BIT
    int GL_HINT_BIT
    int GL_EVAL_BIT
    int GL_LIST_BIT
    int GL_TEXTURE_BIT
    int GL_SCISSOR_BIT
    int GL_ALL_ATTRIB_BITS

    # BeginMode
    int GL_POINTS
    int GL_LINES
    int GL_LINE_LOOP
    int GL_LINE_STRIP
    int GL_TRIANGLES
    int GL_TRIANGLE_STRIP
    int GL_TRIANGLE_FAN
    int GL_QUADS
    int GL_QUAD_STRIP
    int GL_POLYGON

    # BlendingFactorDest
    int GL_ZERO
    int GL_ONE
    int GL_SRC_COLOR
    int GL_ONE_MINUS_SRC_COLOR
    int GL_SRC_ALPHA
    int GL_ONE_MINUS_SRC_ALPHA
    int GL_DST_ALPHA
    int GL_ONE_MINUS_DST_ALPHA

    # BlendingFactorSrc
    int GL_DST_COLOR
    int GL_ONE_MINUS_DST_COLOR
    int GL_SRC_ALPHA_SATURATE

    # Boolean values
    int GL_FALSE
    int GL_TRUE

    # DataType
    int GL_BYTE
    int GL_UNSIGNED_BYTE
    int GL_SHORT
    int GL_UNSIGNED_SHORT
    int GL_INT
    int GL_UNSIGNED_INT
    int GL_FLOAT
    int GL_2_BYTES
    int GL_3_BYTES
    int GL_4_BYTES
    int GL_DOUBLE

    # DrawBufferMode
    int GL_NONE
    int GL_FRONT_LEFT
    int GL_FRONT_RIGHT
    int GL_BACK_LEFT
    int GL_BACK_RIGHT
    int GL_FRONT
    int GL_BACK
    int GL_LEFT
    int GL_RIGHT
    int GL_FRONT_AND_BACK
    int GL_AUX0
    int GL_AUX1
    int GL_AUX2
    int GL_AUX3
    int GL_CW
    int GL_CCW

    # ErrorCode
    int GL_NO_ERROR
    int GL_INVALID_ENUM
    int GL_INVALID_VALUE
    int GL_INVALID_OPERATION
    int GL_STACK_OVERFLOW
    int GL_STACK_UNDERFLOW
    int GL_OUT_OF_MEMORY

    # FeedBackMode
    int GL_2D
    int GL_3D
    int GL_3D_COLOR
    int GL_3D_COLOR_TEXTURE
    int GL_4D_COLOR_TEXTURE

    # FeedBackToken
    int GL_PASS_THROUGH_TOKEN
    int GL_POINT_TOKEN
    int GL_LINE_TOKEN
    int GL_POLYGON_TOKEN
    int GL_BITMAP_TOKEN
    int GL_DRAW_PIXEL_TOKEN
    int GL_COPY_PIXEL_TOKEN
    int GL_LINE_RESET_TOKEN

    # FogMode
    int GL_EXP
    int GL_EXP2

    # GetTarget
    int GL_CURRENT_COLOR
    int GL_CURRENT_INDEX
    int GL_CURRENT_NORMAL
    int GL_CURRENT_TEXTURE_COORDS
    int GL_CURRENT_RASTER_COLOR
    int GL_CURRENT_RASTER_INDEX
    int GL_CURRENT_RASTER_TEXTURE_COORDS
    int GL_CURRENT_RASTER_POSITION
    int GL_CURRENT_RASTER_POSITION_VALID
    int GL_CURRENT_RASTER_DISTANCE
    int GL_POINT_SMOOTH
    int GL_POINT_SIZE
    int GL_POINT_SIZE_RANGE
    int GL_POINT_SIZE_GRANULARITY
    int GL_LINE_SMOOTH
    int GL_LINE_WIDTH
    int GL_LINE_WIDTH_RANGE
    int GL_LINE_WIDTH_GRANULARITY
    int GL_LINE_STIPPLE
    int GL_LINE_STIPPLE_PATTERN
    int GL_LINE_STIPPLE_REPEAT
    int GL_LIST_MODE
    int GL_MAX_LIST_NESTING
    int GL_LIST_BASE
    int GL_LIST_INDEX
    int GL_POLYGON_MODE
    int GL_POLYGON_SMOOTH
    int GL_POLYGON_STIPPLE
    int GL_EDGE_FLAG
    int GL_CULL_FACE
    int GL_CULL_FACE_MODE
    int GL_FRONT_FACE
    int GL_LIGHTING
    int GL_LIGHT_MODEL_LOCAL_VIEWER
    int GL_LIGHT_MODEL_TWO_SIDE
    int GL_LIGHT_MODEL_AMBIENT
    int GL_SHADE_MODEL
    int GL_COLOR_MATERIAL_FACE
    int GL_COLOR_MATERIAL_PARAMETER
    int GL_COLOR_MATERIAL
    int GL_FOG
    int GL_FOG_INDEX
    int GL_FOG_DENSITY
    int GL_FOG_START
    int GL_FOG_END
    int GL_FOG_MODE
    int GL_FOG_COLOR
    int GL_DEPTH_RANGE
    int GL_DEPTH_TEST
    int GL_DEPTH_WRITEMASK
    int GL_DEPTH_CLEAR_VALUE
    int GL_DEPTH_FUNC
    int GL_ACCUM_CLEAR_VALUE
    int GL_STENCIL_TEST
    int GL_STENCIL_CLEAR_VALUE
    int GL_STENCIL_FUNC
    int GL_STENCIL_VALUE_MASK
    int GL_STENCIL_FAIL
    int GL_STENCIL_PASS_DEPTH_FAIL
    int GL_STENCIL_PASS_DEPTH_PASS
    int GL_STENCIL_REF
    int GL_STENCIL_WRITEMASK
    int GL_MATRIX_MODE
    int GL_NORMALIZE
    int GL_VIEWPORT
    int GL_MODELVIEW_STACK_DEPTH
    int GL_PROJECTION_STACK_DEPTH
    int GL_TEXTURE_STACK_DEPTH
    int GL_MODELVIEW_MATRIX
    int GL_PROJECTION_MATRIX
    int GL_TEXTURE_MATRIX
    int GL_ATTRIB_STACK_DEPTH
    int GL_CLIENT_ATTRIB_STACK_DEPTH
    int GL_ALPHA_TEST
    int GL_ALPHA_TEST_FUNC
    int GL_ALPHA_TEST_REF
    int GL_DITHER
    int GL_BLEND_DST
    int GL_BLEND_SRC
    int GL_BLEND
    int GL_LOGIC_OP_MODE
    int GL_INDEX_LOGIC_OP
    int GL_COLOR_LOGIC_OP
    int GL_AUX_BUFFERS
    int GL_DRAW_BUFFER
    int GL_READ_BUFFER
    int GL_SCISSOR_BOX
    int GL_SCISSOR_TEST
    int GL_INDEX_CLEAR_VALUE
    int GL_INDEX_WRITEMASK
    int GL_COLOR_CLEAR_VALUE
    int GL_COLOR_WRITEMASK
    int GL_INDEX_MODE
    int GL_RGBA_MODE
    int GL_DOUBLEBUFFER
    int GL_STEREO
    int GL_RENDER_MODE
    int GL_PERSPECTIVE_CORRECTION_HINT
    int GL_POINT_SMOOTH_HINT
    int GL_LINE_SMOOTH_HINT
    int GL_POLYGON_SMOOTH_HINT
    int GL_FOG_HINT
    int GL_TEXTURE_GEN_S
    int GL_TEXTURE_GEN_T
    int GL_TEXTURE_GEN_R
    int GL_TEXTURE_GEN_Q
    int GL_PIXEL_MAP_I_TO_I
    int GL_PIXEL_MAP_S_TO_S
    int GL_PIXEL_MAP_I_TO_R
    int GL_PIXEL_MAP_I_TO_G
    int GL_PIXEL_MAP_I_TO_B
    int GL_PIXEL_MAP_I_TO_A
    int GL_PIXEL_MAP_R_TO_R
    int GL_PIXEL_MAP_G_TO_G
    int GL_PIXEL_MAP_B_TO_B
    int GL_PIXEL_MAP_A_TO_A
    int GL_PIXEL_MAP_I_TO_I_SIZE
    int GL_PIXEL_MAP_S_TO_S_SIZE
    int GL_PIXEL_MAP_I_TO_R_SIZE
    int GL_PIXEL_MAP_I_TO_G_SIZE
    int GL_PIXEL_MAP_I_TO_B_SIZE
    int GL_PIXEL_MAP_I_TO_A_SIZE
    int GL_PIXEL_MAP_R_TO_R_SIZE
    int GL_PIXEL_MAP_G_TO_G_SIZE
    int GL_PIXEL_MAP_B_TO_B_SIZE
    int GL_PIXEL_MAP_A_TO_A_SIZE
    int GL_UNPACK_SWAP_BYTES
    int GL_UNPACK_LSB_FIRST
    int GL_UNPACK_ROW_LENGTH
    int GL_UNPACK_SKIP_ROWS
    int GL_UNPACK_SKIP_PIXELS
    int GL_UNPACK_ALIGNMENT
    int GL_PACK_SWAP_BYTES
    int GL_PACK_LSB_FIRST
    int GL_PACK_ROW_LENGTH
    int GL_PACK_SKIP_ROWS
    int GL_PACK_SKIP_PIXELS
    int GL_PACK_ALIGNMENT
    int GL_MAP_COLOR
    int GL_MAP_STENCIL
    int GL_INDEX_SHIFT
    int GL_INDEX_OFFSET
    int GL_RED_SCALE
    int GL_RED_BIAS
    int GL_ZOOM_X
    int GL_ZOOM_Y
    int GL_GREEN_SCALE
    int GL_GREEN_BIAS
    int GL_BLUE_SCALE
    int GL_BLUE_BIAS
    int GL_ALPHA_SCALE
    int GL_ALPHA_BIAS
    int GL_DEPTH_SCALE
    int GL_DEPTH_BIAS
    int GL_MAX_EVAL_ORDER
    int GL_MAX_LIGHTS
    int GL_MAX_CLIP_PLANES
    int GL_MAX_TEXTURE_SIZE
    int GL_MAX_PIXEL_MAP_TABLE
    int GL_MAX_ATTRIB_STACK_DEPTH
    int GL_MAX_MODELVIEW_STACK_DEPTH
    int GL_MAX_NAME_STACK_DEPTH
    int GL_MAX_PROJECTION_STACK_DEPTH
    int GL_MAX_TEXTURE_STACK_DEPTH
    int GL_MAX_VIEWPORT_DIMS
    int GL_MAX_CLIENT_ATTRIB_STACK_DEPTH
    int GL_SUBPIXEL_BITS
    int GL_INDEX_BITS
    int GL_RED_BITS
    int GL_GREEN_BITS
    int GL_BLUE_BITS
    int GL_ALPHA_BITS
    int GL_DEPTH_BITS
    int GL_STENCIL_BITS
    int GL_ACCUM_RED_BITS
    int GL_ACCUM_GREEN_BITS
    int GL_ACCUM_BLUE_BITS
    int GL_ACCUM_ALPHA_BITS
    int GL_NAME_STACK_DEPTH
    int GL_AUTO_NORMAL
    int GL_MAP1_COLOR_4
    int GL_MAP1_INDEX
    int GL_MAP1_NORMAL
    int GL_MAP1_TEXTURE_COORD_1
    int GL_MAP1_TEXTURE_COORD_2
    int GL_MAP1_TEXTURE_COORD_3
    int GL_MAP1_TEXTURE_COORD_4
    int GL_MAP1_VERTEX_3
    int GL_MAP1_VERTEX_4
    int GL_MAP2_COLOR_4
    int GL_MAP2_INDEX
    int GL_MAP2_NORMAL
    int GL_MAP2_TEXTURE_COORD_1
    int GL_MAP2_TEXTURE_COORD_2
    int GL_MAP2_TEXTURE_COORD_3
    int GL_MAP2_TEXTURE_COORD_4
    int GL_MAP2_VERTEX_3
    int GL_MAP2_VERTEX_4
    int GL_MAP1_GRID_DOMAIN
    int GL_MAP1_GRID_SEGMENTS
    int GL_MAP2_GRID_DOMAIN
    int GL_MAP2_GRID_SEGMENTS
    int GL_TEXTURE_1D
    int GL_TEXTURE_2D
    int GL_FEEDBACK_BUFFER_POINTER
    int GL_FEEDBACK_BUFFER_SIZE
    int GL_FEEDBACK_BUFFER_TYPE
    int GL_SELECTION_BUFFER_POINTER
    int GL_SELECTION_BUFFER_SIZE

    # GetTextureParameter
    int GL_TEXTURE_WIDTH
    int GL_TEXTURE_HEIGHT
    int GL_TEXTURE_INTERNAL_FORMAT
    int GL_TEXTURE_BORDER_COLOR
    int GL_TEXTURE_BORDER

    # HintMode
    int GL_DONT_CARE
    int GL_FASTEST
    int GL_NICEST

    # LightName
    int GL_LIGHT0
    int GL_LIGHT1
    int GL_LIGHT2
    int GL_LIGHT3
    int GL_LIGHT4
    int GL_LIGHT5
    int GL_LIGHT6
    int GL_LIGHT7

    # LightParameter
    int GL_AMBIENT
    int GL_DIFFUSE
    int GL_SPECULAR
    int GL_POSITION
    int GL_SPOT_DIRECTION
    int GL_SPOT_EXPONENT
    int GL_SPOT_CUTOFF
    int GL_CONSTANT_ATTENUATION
    int GL_LINEAR_ATTENUATION
    int GL_QUADRATIC_ATTENUATION

    # ListMode
    int GL_COMPILE
    int GL_COMPILE_AND_EXECUTE

    # LogicOp
    int GL_CLEAR
    int GL_AND
    int GL_AND_REVERSE
    int GL_COPY
    int GL_AND_INVERTED
    int GL_NOOP
    int GL_XOR
    int GL_OR
    int GL_NOR
    int GL_EQUIV
    int GL_INVERT
    int GL_OR_REVERSE
    int GL_COPY_INVERTED
    int GL_OR_INVERTED
    int GL_NAND
    int GL_SET

    # MaterialParameter
    int GL_EMISSION
    int GL_SHININESS
    int GL_AMBIENT_AND_DIFFUSE
    int GL_COLOR_INDEXES


    # MatrixMode
    int GL_MODELVIEW
    int GL_PROJECTION
    int GL_TEXTURE

    # PixelCopyType
    int GL_COLOR
    int GL_DEPTH
    int GL_STENCIL

    # PixelFormat
    int GL_COLOR_INDEX
    int GL_STENCIL_INDEX
    int GL_DEPTH_COMPONENT
    int GL_RED
    int GL_GREEN
    int GL_BLUE
    int GL_ALPHA
    int GL_RGB
    int GL_RGBA
    int GL_LUMINANCE
    int GL_LUMINANCE_ALPHA

    # PixelType
    int GL_BITMAP

    # PolygonMode
    int GL_POINT
    int GL_LINE
    int GL_FILL

    # RenderingMode
    int GL_RENDER
    int GL_FEEDBACK
    int GL_SELECT

    # ShadingModel
    int GL_FLAT
    int GL_SMOOTH

    # StencilOp
    int GL_KEEP
    int GL_REPLACE
    int GL_INCR
    int GL_DECR

    # StringName
    int GL_VENDOR
    int GL_RENDERER
    int GL_VERSION
    int GL_EXTENSIONS

    # TextureCoordName
    int GL_S
    int GL_T
    int GL_R
    int GL_Q

    # TextureEnvMode
    int GL_MODULATE
    int GL_DECAL

    # TextureEnvParameter
    int GL_TEXTURE_ENV_MODE
    int GL_TEXTURE_ENV_COLOR

    # TextureEnvTarget
    int GL_TEXTURE_ENV

    # TextureGenMode
    int GL_EYE_LINEAR
    int GL_OBJECT_LINEAR
    int GL_SPHERE_MAP

    # TextureGenParameter
    int GL_TEXTURE_GEN_MODE
    int GL_OBJECT_PLANE
    int GL_EYE_PLANE

    # TextureMagFilter
    int GL_NEAREST
    int GL_LINEAR

    # TextureMinFilter
    int GL_NEAREST_MIPMAP_NEAREST
    int GL_LINEAR_MIPMAP_NEAREST
    int GL_NEAREST_MIPMAP_LINEAR
    int GL_LINEAR_MIPMAP_LINEAR

    # TextureParameterName
    int GL_TEXTURE_MAG_FILTER
    int GL_TEXTURE_MIN_FILTER
    int GL_TEXTURE_WRAP_S
    int GL_TEXTURE_WRAP_T

    # TextureWrapMode
    int GL_CLAMP
    int GL_REPEAT

    # ClientAttribMask
    int GL_CLIENT_PIXEL_STORE_BIT
    int GL_CLIENT_VERTEX_ARRAY_BIT
    int GL_CLIENT_ALL_ATTRIB_BITS

    # polygon_offset
    int GL_POLYGON_OFFSET_FACTOR
    int GL_POLYGON_OFFSET_UNITS
    int GL_POLYGON_OFFSET_POINT
    int GL_POLYGON_OFFSET_LINE
    int GL_POLYGON_OFFSET_FILL

    # texture
    int GL_ALPHA4
    int GL_ALPHA8
    int GL_ALPHA12
    int GL_ALPHA16
    int GL_LUMINANCE4
    int GL_LUMINANCE8
    int GL_LUMINANCE12
    int GL_LUMINANCE16
    int GL_LUMINANCE4_ALPHA4
    int GL_LUMINANCE6_ALPHA2
    int GL_LUMINANCE8_ALPHA8
    int GL_LUMINANCE12_ALPHA4
    int GL_LUMINANCE12_ALPHA12
    int GL_LUMINANCE16_ALPHA16
    int GL_INTENSITY
    int GL_INTENSITY4
    int GL_INTENSITY8
    int GL_INTENSITY12
    int GL_INTENSITY16
    int GL_R3_G3_B2
    int GL_RGB4
    int GL_RGB5
    int GL_RGB8
    int GL_RGB10
    int GL_RGB12
    int GL_RGB16
    int GL_RGBA2
    int GL_RGBA4
    int GL_RGB5_A1
    int GL_RGBA8
    int GL_RGB10_A2
    int GL_RGBA12
    int GL_RGBA16
    int GL_TEXTURE_RED_SIZE
    int GL_TEXTURE_GREEN_SIZE
    int GL_TEXTURE_BLUE_SIZE
    int GL_TEXTURE_ALPHA_SIZE
    int GL_TEXTURE_LUMINANCE_SIZE
    int GL_TEXTURE_INTENSITY_SIZE
    int GL_PROXY_TEXTURE_1D
    int GL_PROXY_TEXTURE_2D

    # texture_object
    int GL_TEXTURE_PRIORITY
    int GL_TEXTURE_RESIDENT
    int GL_TEXTURE_BINDING_1D
    int GL_TEXTURE_BINDING_2D

    # vertex_array
    int GL_VERTEX_ARRAY
    int GL_NORMAL_ARRAY
    int GL_COLOR_ARRAY
    int GL_INDEX_ARRAY
    int GL_TEXTURE_COORD_ARRAY
    int GL_EDGE_FLAG_ARRAY
    int GL_VERTEX_ARRAY_SIZE
    int GL_VERTEX_ARRAY_TYPE
    int GL_VERTEX_ARRAY_STRIDE
    int GL_NORMAL_ARRAY_TYPE
    int GL_NORMAL_ARRAY_STRIDE
    int GL_COLOR_ARRAY_SIZE
    int GL_COLOR_ARRAY_TYPE
    int GL_COLOR_ARRAY_STRIDE
    int GL_INDEX_ARRAY_TYPE
    int GL_INDEX_ARRAY_STRIDE
    int GL_TEXTURE_COORD_ARRAY_SIZE
    int GL_TEXTURE_COORD_ARRAY_TYPE
    int GL_TEXTURE_COORD_ARRAY_STRIDE
    int GL_EDGE_FLAG_ARRAY_STRIDE
    int GL_VERTEX_ARRAY_POINTER
    int GL_NORMAL_ARRAY_POINTER
    int GL_COLOR_ARRAY_POINTER
    int GL_INDEX_ARRAY_POINTER
    int GL_TEXTURE_COORD_ARRAY_POINTER
    int GL_EDGE_FLAG_ARRAY_POINTER
    int GL_V2F
    int GL_V3F
    int GL_C4UB_V2F
    int GL_C4UB_V3F
    int GL_C3F_V3F
    int GL_N3F_V3F
    int GL_C4F_N3F_V3F
    int GL_T2F_V3F
    int GL_T4F_V4F
    int GL_T2F_C4UB_V3F
    int GL_T2F_C3F_V3F
    int GL_T2F_N3F_V3F
    int GL_T2F_C4F_N3F_V3F
    int GL_T4F_C4F_N3F_V4F

    ctypedef unsigned int GLenum
    ctypedef unsigned char GLboolean
    ctypedef unsigned int GLbitfield
    ctypedef signed char GLbyte
    ctypedef short GLshort
    ctypedef int GLint
    ctypedef int GLsizei
    ctypedef unsigned char GLubyte
    ctypedef unsigned short GLushort
    ctypedef unsigned int GLuint
    ctypedef float GLfloat
    ctypedef float GLclampf
    ctypedef double GLdouble
    ctypedef double GLclampd
    ctypedef void GLvoid
    
    void glAccum (GLenum op, GLfloat value)
    void glAlphaFunc (GLenum func, GLclampf ref)
    GLboolean glAreTexturesResident (GLsizei n, GLuint *textures, GLboolean *residences)
    void glArrayElement (GLint i)
    void glBegin (GLenum mode)
    void glBindTexture (GLenum target, GLuint texture)
    void glBitmap (GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, GLubyte *bitmap)
    void glBlendFunc (GLenum sfactor, GLenum dfactor)
    void glCallList (GLuint list)
    void glCallLists (GLsizei n, GLenum type, GLvoid *lists)
    void glClear (GLbitfield mask)
    void glClearAccum (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
    void glClearDepth (GLclampd depth)
    void glClearIndex (GLfloat c)
    void glClearStencil (GLint s)
    void glClipPlane (GLenum plane, GLdouble *equation)
    void glColor3b (GLbyte red, GLbyte green, GLbyte blue)
    void glColor3bv (GLbyte *v)
    void glColor3d (GLdouble red, GLdouble green, GLdouble blue)
    void glColor3dv (GLdouble *v)
    void glColor3f (GLfloat red, GLfloat green, GLfloat blue)
    void glColor3fv (GLfloat *v)
    void glColor3i (GLint red, GLint green, GLint blue)
    void glColor3iv (GLint *v)
    void glColor3s (GLshort red, GLshort green, GLshort blue)
    void glColor3sv (GLshort *v)
    void glColor3ub (GLubyte red, GLubyte green, GLubyte blue)
    void glColor3ubv (GLubyte *v)
    void glColor3ui (GLuint red, GLuint green, GLuint blue)
    void glColor3uiv (GLuint *v)
    void glColor3us (GLushort red, GLushort green, GLushort blue)
    void glColor3usv (GLushort *v)
    void glColor4b (GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha)
    void glColor4bv (GLbyte *v)
    void glColor4d (GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha)
    void glColor4dv (GLdouble *v)
    void glColor4f (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
    void glColor4fv (GLfloat *v)
    void glColor4i (GLint red, GLint green, GLint blue, GLint alpha)
    void glColor4iv (GLint *v)
    void glColor4s (GLshort red, GLshort green, GLshort blue, GLshort alpha)
    void glColor4sv (GLshort *v)
    void glColor4ub (GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha)
    void glColor4ubv (GLubyte *v)
    void glColor4ui (GLuint red, GLuint green, GLuint blue, GLuint alpha)
    void glColor4uiv (GLuint *v)
    void glColor4us (GLushort red, GLushort green, GLushort blue, GLushort alpha)
    void glColor4usv (GLushort *v)
    void glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
    void glColorMaterial (GLenum face, GLenum mode)
    void glColorPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer)
    void glCopyPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum type)
    void glCopyTexImage1D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border)
    void glCopyTexImage2D (GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border)
    void glCopyTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
    void glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
    void glCullFace (GLenum mode)
    void glDeleteLists (GLuint list, GLsizei range)
    void glDeleteTextures (GLsizei n, GLuint *textures)
    void glDepthFunc (GLenum func)
    void glDepthMask (GLboolean flag)
    void glDepthRange (GLclampd zNear, GLclampd zFar)
    void glDisable (GLenum cap)
    void glDisableClientState (GLenum array)
    void glDrawArrays (GLenum mode, GLint first, GLsizei count)
    void glDrawBuffer (GLenum mode)
    void glDrawElements (GLenum mode, GLsizei count, GLenum type, GLvoid *indices)
    void glDrawPixels (GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
    void glEdgeFlag (GLboolean flag)
    void glEdgeFlagPointer (GLsizei stride, GLvoid *pointer)
    void glEdgeFlagv (GLboolean *flag)
    void glEnable (GLenum cap)
    void glEnableClientState (GLenum array)
    void glEnd ()
    void glEndList ()
    void glEvalCoord1d (GLdouble u)
    void glEvalCoord1dv (GLdouble *u)
    void glEvalCoord1f (GLfloat u)
    void glEvalCoord1fv (GLfloat *u)
    void glEvalCoord2d (GLdouble u, GLdouble v)
    void glEvalCoord2dv (GLdouble *u)
    void glEvalCoord2f (GLfloat u, GLfloat v)
    void glEvalCoord2fv (GLfloat *u)
    void glEvalMesh1 (GLenum mode, GLint i1, GLint i2)
    void glEvalMesh2 (GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2)
    void glEvalPoint1 (GLint i)
    void glEvalPoint2 (GLint i, GLint j)
    void glFeedbackBuffer (GLsizei size, GLenum type, GLfloat *buffer)
    void glFinish ()
    void glFlush ()
    void glFogf (GLenum pname, GLfloat param)
    void glFogfv (GLenum pname, GLfloat *params)
    void glFogi (GLenum pname, GLint param)
    void glFogiv (GLenum pname, GLint *params)
    void glFrontFace (GLenum mode)
    void glFrustum (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
    GLuint glGenLists (GLsizei range)
    void glGenTextures (GLsizei n, GLuint *textures)
    void glGetBooleanv (GLenum pname, GLboolean *params)
    void glGetClipPlane (GLenum plane, GLdouble *equation)
    void glGetDoublev (GLenum pname, GLdouble *params)
    GLenum glGetError ()
    void glGetFloatv (GLenum pname, GLfloat *params)
    void glGetIntegerv (GLenum pname, GLint *params)
    void glGetLightfv (GLenum light, GLenum pname, GLfloat *params)
    void glGetLightiv (GLenum light, GLenum pname, GLint *params)
    void glGetMapdv (GLenum target, GLenum query, GLdouble *v)
    void glGetMapfv (GLenum target, GLenum query, GLfloat *v)
    void glGetMapiv (GLenum target, GLenum query, GLint *v)
    void glGetMaterialfv (GLenum face, GLenum pname, GLfloat *params)
    void glGetMaterialiv (GLenum face, GLenum pname, GLint *params)
    void glGetPixelMapfv (GLenum map, GLfloat *values)
    void glGetPixelMapuiv (GLenum map, GLuint *values)
    void glGetPixelMapusv (GLenum map, GLushort *values)
    void glGetPointerv (GLenum pname, GLvoid* *params)
    void glGetPolygonStipple (GLubyte *mask)
    GLubyte * glGetString (GLenum name)
    void glGetTexEnvfv (GLenum target, GLenum pname, GLfloat *params)
    void glGetTexEnviv (GLenum target, GLenum pname, GLint *params)
    void glGetTexGendv (GLenum coord, GLenum pname, GLdouble *params)
    void glGetTexGenfv (GLenum coord, GLenum pname, GLfloat *params)
    void glGetTexGeniv (GLenum coord, GLenum pname, GLint *params)
    void glGetTexImage (GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels)
    void glGetTexLevelParameterfv (GLenum target, GLint level, GLenum pname, GLfloat *params)
    void glGetTexLevelParameteriv (GLenum target, GLint level, GLenum pname, GLint *params)
    void glGetTexParameterfv (GLenum target, GLenum pname, GLfloat *params)
    void glGetTexParameteriv (GLenum target, GLenum pname, GLint *params)
    void glHint (GLenum target, GLenum mode)
    void glIndexMask (GLuint mask)
    void glIndexPointer (GLenum type, GLsizei stride, GLvoid *pointer)
    void glIndexd (GLdouble c)
    void glIndexdv (GLdouble *c)
    void glIndexf (GLfloat c)
    void glIndexfv (GLfloat *c)
    void glIndexi (GLint c)
    void glIndexiv (GLint *c)
    void glIndexs (GLshort c)
    void glIndexsv (GLshort *c)
    void glIndexub (GLubyte c)
    void glIndexubv (GLubyte *c)
    void glInitNames ()
    void glInterleavedArrays (GLenum format, GLsizei stride, GLvoid *pointer)
    GLboolean glIsEnabled (GLenum cap)
    GLboolean glIsList (GLuint list)
    GLboolean glIsTexture (GLuint texture)
    void glLightModelf (GLenum pname, GLfloat param)
    void glLightModelfv (GLenum pname, GLfloat *params)
    void glLightModeli (GLenum pname, GLint param)
    void glLightModeliv (GLenum pname, GLint *params)
    void glLightf (GLenum light, GLenum pname, GLfloat param)
    void glLightfv (GLenum light, GLenum pname, GLfloat *params)
    void glLighti (GLenum light, GLenum pname, GLint param)
    void glLightiv (GLenum light, GLenum pname, GLint *params)
    void glLineStipple (GLint factor, GLushort pattern)
    void glLineWidth (GLfloat width)
    void glListBase (GLuint base)
    void glLoadIdentity ()
    void GLLoadMatrixd "glLoadMatrixd" (GLdouble *m)
    void glLoadMatrixf (GLfloat *m)
    void glLoadName (GLuint name)
    void glLogicOp (GLenum opcode)
    void glMap1d (GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, GLdouble *points)
    void glMap1f (GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, GLfloat *points)
    void glMap2d (GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, GLdouble *points)
    void glMap2f (GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, GLfloat *points)
    void glMapGrid1d (GLint un, GLdouble u1, GLdouble u2)
    void glMapGrid1f (GLint un, GLfloat u1, GLfloat u2)
    void glMapGrid2d (GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2)
    void glMapGrid2f (GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2)
    void glMaterialf (GLenum face, GLenum pname, GLfloat param)
    void glMaterialfv (GLenum face, GLenum pname, GLfloat *params)
    void glMateriali (GLenum face, GLenum pname, GLint param)
    void glMaterialiv (GLenum face, GLenum pname, GLint *params)
    void glMatrixMode (GLenum mode)
    void GLMultMatrixd "glMultMatrixd" (GLdouble *m)
    void glMultMatrixf (GLfloat *m)
    void glNewList (GLuint list, GLenum mode)
    void glNormal3b (GLbyte nx, GLbyte ny, GLbyte nz)
    void glNormal3bv (GLbyte *v)
    void glNormal3d (GLdouble nx, GLdouble ny, GLdouble nz)
    void glNormal3dv (GLdouble *v)
    void glNormal3f (GLfloat nx, GLfloat ny, GLfloat nz)
    void glNormal3fv (GLfloat *v)
    void glNormal3i (GLint nx, GLint ny, GLint nz)
    void glNormal3iv (GLint *v)
    void glNormal3s (GLshort nx, GLshort ny, GLshort nz)
    void glNormal3sv (GLshort *v)
    void glNormalPointer (GLenum type, GLsizei stride, GLvoid *pointer)
    void glOrtho (GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar)
    void glPassThrough (GLfloat token)
    void glPixelMapfv (GLenum map, GLsizei mapsize, GLfloat *values)
    void glPixelMapuiv (GLenum map, GLsizei mapsize, GLuint *values)
    void glPixelMapusv (GLenum map, GLsizei mapsize, GLushort *values)
    void glPixelStoref (GLenum pname, GLfloat param)
    void glPixelStorei (GLenum pname, GLint param)
    void glPixelTransferf (GLenum pname, GLfloat param)
    void glPixelTransferi (GLenum pname, GLint param)
    void glPixelZoom (GLfloat xfactor, GLfloat yfactor)
    void glPointSize (GLfloat size)
    void glPolygonMode (GLenum face, GLenum mode)
    void glPolygonOffset (GLfloat factor, GLfloat units)
    void glPolygonStipple (GLubyte *mask)
    void glPopAttrib ()
    void glPopClientAttrib ()
    void glPopMatrix ()
    void glPopName ()
    void glPrioritizeTextures (GLsizei n, GLuint *textures, GLclampf *priorities)
    void glPushAttrib (GLbitfield mask)
    void glPushClientAttrib (GLbitfield mask)
    void glPushMatrix ()
    void glPushName (GLuint name)
    void glRasterPos2d (GLdouble x, GLdouble y)
    void glRasterPos2dv (GLdouble *v)
    void glRasterPos2f (GLfloat x, GLfloat y)
    void glRasterPos2fv (GLfloat *v)
    void glRasterPos2i (GLint x, GLint y)
    void glRasterPos2iv (GLint *v)
    void glRasterPos2s (GLshort x, GLshort y)
    void glRasterPos2sv (GLshort *v)
    void glRasterPos3d (GLdouble x, GLdouble y, GLdouble z)
    void glRasterPos3dv (GLdouble *v)
    void glRasterPos3f (GLfloat x, GLfloat y, GLfloat z)
    void glRasterPos3fv (GLfloat *v)
    void glRasterPos3i (GLint x, GLint y, GLint z)
    void glRasterPos3iv (GLint *v)
    void glRasterPos3s (GLshort x, GLshort y, GLshort z)
    void glRasterPos3sv (GLshort *v)
    void glRasterPos4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w)
    void glRasterPos4dv (GLdouble *v)
    void glRasterPos4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w)
    void glRasterPos4fv (GLfloat *v)
    void glRasterPos4i (GLint x, GLint y, GLint z, GLint w)
    void glRasterPos4iv (GLint *v)
    void glRasterPos4s (GLshort x, GLshort y, GLshort z, GLshort w)
    void glRasterPos4sv (GLshort *v)
    void glReadBuffer (GLenum mode)
    void glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
    void glRectd (GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2)
    void glRectdv (GLdouble *v1, GLdouble *v2)
    void glRectf (GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2)
    void glRectfv (GLfloat *v1, GLfloat *v2)
    void glRecti (GLint x1, GLint y1, GLint x2, GLint y2)
    void glRectiv (GLint *v1, GLint *v2)
    void glRects (GLshort x1, GLshort y1, GLshort x2, GLshort y2)
    void glRectsv (GLshort *v1, GLshort *v2)
    GLint glRenderMode (GLenum mode)
    void glRotated (GLdouble angle, GLdouble x, GLdouble y, GLdouble z)
    void glRotatef (GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
    void glScaled (GLdouble x, GLdouble y, GLdouble z)
    void glScalef (GLfloat x, GLfloat y, GLfloat z)
    void glScissor (GLint x, GLint y, GLsizei width, GLsizei height)
    void glSelectBuffer (GLsizei size, GLuint *buffer)
    void glShadeModel (GLenum mode)
    void glStencilFunc (GLenum func, GLint ref, GLuint mask)
    void glStencilMask (GLuint mask)
    void glStencilOp (GLenum fail, GLenum zfail, GLenum zpass)
    void glTexCoord1d (GLdouble s)
    void glTexCoord1dv (GLdouble *v)
    void glTexCoord1f (GLfloat s)
    void glTexCoord1fv (GLfloat *v)
    void glTexCoord1i (GLint s)
    void glTexCoord1iv (GLint *v)
    void glTexCoord1s (GLshort s)
    void glTexCoord1sv (GLshort *v)
    void glTexCoord2d (GLdouble s, GLdouble t)
    void glTexCoord2dv (GLdouble *v)
    void glTexCoord2f (GLfloat s, GLfloat t)
    void glTexCoord2fv (GLfloat *v)
    void glTexCoord2i (GLint s, GLint t)
    void glTexCoord2iv (GLint *v)
    void glTexCoord2s (GLshort s, GLshort t)
    void glTexCoord2sv (GLshort *v)
    void glTexCoord3d (GLdouble s, GLdouble t, GLdouble r)
    void glTexCoord3dv (GLdouble *v)
    void glTexCoord3f (GLfloat s, GLfloat t, GLfloat r)
    void glTexCoord3fv (GLfloat *v)
    void glTexCoord3i (GLint s, GLint t, GLint r)
    void glTexCoord3iv (GLint *v)
    void glTexCoord3s (GLshort s, GLshort t, GLshort r)
    void glTexCoord3sv (GLshort *v)
    void glTexCoord4d (GLdouble s, GLdouble t, GLdouble r, GLdouble q)
    void glTexCoord4dv (GLdouble *v)
    void glTexCoord4f (GLfloat s, GLfloat t, GLfloat r, GLfloat q)
    void glTexCoord4fv (GLfloat *v)
    void glTexCoord4i (GLint s, GLint t, GLint r, GLint q)
    void glTexCoord4iv (GLint *v)
    void glTexCoord4s (GLshort s, GLshort t, GLshort r, GLshort q)
    void glTexCoord4sv (GLshort *v)
    void glTexCoordPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer)
    void glTexEnvf (GLenum target, GLenum pname, GLfloat param)
    void glTexEnvfv (GLenum target, GLenum pname, GLfloat *params)
    void glTexEnvi (GLenum target, GLenum pname, GLint param)
    void glTexEnviv (GLenum target, GLenum pname, GLint *params)
    void glTexGend (GLenum coord, GLenum pname, GLdouble param)
    void glTexGendv (GLenum coord, GLenum pname, GLdouble *params)
    void glTexGenf (GLenum coord, GLenum pname, GLfloat param)
    void glTexGenfv (GLenum coord, GLenum pname, GLfloat *params)
    void glTexGeni (GLenum coord, GLenum pname, GLint param)
    void glTexGeniv (GLenum coord, GLenum pname, GLint *params)
    void glTexImage1D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, GLvoid *pixels)
    void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, GLvoid *pixels)
    void glTexParameterf (GLenum target, GLenum pname, GLfloat param)
    void glTexParameterfv (GLenum target, GLenum pname, GLfloat *params)
    void glTexParameteri (GLenum target, GLenum pname, GLint param)
    void glTexParameteriv (GLenum target, GLenum pname, GLint *params)
    void glTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, GLvoid *pixels)
    void glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels)
    void glTranslated (GLdouble x, GLdouble y, GLdouble z)
    void glTranslatef (GLfloat x, GLfloat y, GLfloat z)
    void glVertex2d (GLdouble x, GLdouble y)
    void glVertex2dv (GLdouble *v)
    void glVertex2f (GLfloat x, GLfloat y)
    void glVertex2fv (GLfloat *v)
    void glVertex2i (GLint x, GLint y)
    void glVertex2iv (GLint *v)
    void glVertex2s (GLshort x, GLshort y)
    void glVertex2sv (GLshort *v)
    void glVertex3d (GLdouble x, GLdouble y, GLdouble z)
    void glVertex3dv (GLdouble *v)
    void glVertex3f (GLfloat x, GLfloat y, GLfloat z)
    void glVertex3fv (GLfloat *v)
    void glVertex3i (GLint x, GLint y, GLint z)
    void glVertex3iv (GLint *v)
    void glVertex3s (GLshort x, GLshort y, GLshort z)
    void glVertex3sv (GLshort *v)
    void glVertex4d (GLdouble x, GLdouble y, GLdouble z, GLdouble w)
    void glVertex4dv (GLdouble *v)
    void glVertex4f (GLfloat x, GLfloat y, GLfloat z, GLfloat w)
    void glVertex4fv (GLfloat *v)
    void glVertex4i (GLint x, GLint y, GLint z, GLint w)
    void glVertex4iv (GLint *v)
    void glVertex4s (GLshort x, GLshort y, GLshort z, GLshort w)
    void glVertex4sv (GLshort *v)
    void glVertexPointer (GLint size, GLenum type, GLsizei stride, GLvoid *pointer)
    void glViewport (GLint x, GLint y, GLsizei width, GLsizei height)

cdef extern from "GL/glext.h":
    int GL_MULTISAMPLE
    int GL_LIGHT_MODEL_COLOR_CONTROL
    int GL_SEPARATE_SPECULAR_COLOR