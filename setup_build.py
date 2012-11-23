#!/usr/bin/python2
# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
import os
import glob
import shutil

from distutils.core import setup
from distutils.extension import Extension

try:
    from Cython.Distutils import build_ext
except ImportError:
    print >>sys.stderr, "Cython is required to build occmodel"
    sys.exit(1)

try:
    import geotools
except ImportError:
    print >>sys.stderr, "geotools is required to build occmodel"
    sys.exit(1)

viewer = True
try:
    import gltools
except ImportError:
    viewer = False
    
#sys.argv.append('build_ext')
#sys.argv.extend(['sdist','--formats=gztar,zip'])
#sys.argv.append('bdist_wininst')

# create config file
sys.dont_write_bytecode = True
import version

CONFIG = 'occmodel/@src/Config.pxi'
if not os.path.exists(CONFIG) and 'sdist' not in sys.argv:
    with open(CONFIG, 'w') as fh:
        fh.write("__version__ = '%s'\n" % version.STRING)
        args = version.MAJOR, version.MINOR, version.BUILD
        fh.write("__version_info__ = (%d,%d,%d)\n" % args)

OCC = \
'''FWOSPlugin PTKernel TKAdvTools TKBO TKBRep TKBin TKBinL TKBinTObj TKBinXCAF TKBool
TKCAF TKCDF TKFeat TKFillet TKG2d TKG3d TKGeomAlgo TKGeomBase TKHLR TKIGES TKLCAF
TKMath TKMesh TKOffset TKPCAF TKPLCAF TKPShape TKPrim TKSTEP TKSTEP209 TKSTEPAttr
TKSTEPBase TKSTL TKService TKShHealing TKShapeSchema TKStdLSchema TKStdSchema
TKTObj TKTopAlgo TKV2d TKV3d TKVRML TKXCAF TKXCAFSchema TKXDEIGES TKXDESTEP 
TKXMesh TKXSBase TKXml TKXmlL TKXmlTObj TKXmlXCAF TKernel'''

# platform specific settings
OBJECTS, LIBS, LINK_ARGS, COMPILE_ARGS = [],[],[],[]
if sys.platform == 'win32':
    COMPILE_ARGS.append('/EHsc')
    OCCINCLUDE = r"C:\vs9include\oce"
    OCCLIBS = []
    OBJECTS = [name + '.lib' for name in OCC.split()] + ['occmodel.lib',]
else:
    OCCINCLUDE = '/usr/include/oce'
    OCCLIBS = OCC.split()
    LIBS.append("occmodel")
    LIBS.append("pthread")
    COMPILE_ARGS.append("-fpermissive")

EXTENSIONS = [
    Extension("occmodel",
        sources = ["occmodel/occmodel.pyx"],
        depends = glob.glob("occmodel/@src/*.pxd") + \
                  glob.glob("occmodel/@src/*.pxi"),
        include_dirs = ['occmodel/@src', OCCINCLUDE],
        library_dirs = ['occmodel'],
        libraries = LIBS + OCCLIBS,
        extra_link_args = LINK_ARGS,
        extra_compile_args = COMPILE_ARGS,
        extra_objects = OBJECTS,
        language="c++"
    )
]

# only build viewer of gltools is available
if viewer:
    EXTENSIONS.append(
        Extension("occmodelviewer", sources = ["occmodel/occmodelviewer.pyx"]),
    )

classifiers = '''\
Development Status :: 4 - Beta
Environment :: MacOS X
Environment :: Win32 (MS Windows)
Environment :: X11 Applications
Intended Audience :: Science/Research
License :: OSI Approved :: GNU General Public License v2 (GPLv2)
Operating System :: OS Independent
Programming Language :: Cython
Topic :: Scientific/Engineering
'''

try:
    setup(
      name = 'occmodel',
        version = version.STRING,
        description = 'Easy access to the OpenCASCADE library',
        long_description =  \
'''**occmodel** is a small library which gives a high level access
to the OpenCASCADE modelling kernel.

For most users a direct use of the OpenCASCADE modelling
kernel can be quite a hurdle as it is a huge library.

The geometry can be visualized with the included viewer.
This viewer is utilizing modern OpenGL methods like GLSL
shaders and vertex buffers to ensure visual quality and
maximum speed. To use the viewer OpenGL version 2.1 is
needed.
''',
        classifiers = [value for value in classifiers.split("\n") if value],
        author='Runar Tenfjord',
        author_email = 'runar.tenfjord@gmail.com',
        license = 'GPLv2',
        download_url='http://pypi.python.org/pypi/occmodel/',
        url = 'http://github.com/tenko/occmodel',
        platforms = ['any'],
        scripts = ['occmodel/occmodeldemo.py'],
        ext_modules = EXTENSIONS,
      cmdclass = {'build_ext': build_ext}
    )
except:
    print('Traceback\n:%s\n' % str(sys.exc_info()[-2]))
    sys.exit(1)