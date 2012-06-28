# -*- coding: utf-8 -*-
# This is code is commercial software.
# Copyright 2007 by Runar Tenfjord, Tenko.
import sys
import os
import glob
import shutil

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

sys.argv.append('build_ext')
sys.argv.append('--inplace')

OCCLIBS = [
    'FWOSPlugin',
    'PTKernel',
    'TKAdvTools',
    'TKBO',
    'TKBRep',
    'TKBin',
    'TKBinL',
    'TKBinTObj',
    'TKBinXCAF',
    'TKBool',
    'TKCAF',
    'TKCDF',
    'TKFeat',
    'TKFillet',
    'TKG2d',
    'TKG3d',
    'TKGeomAlgo',
    'TKGeomBase',
    'TKHLR',
    'TKIGES',
    'TKLCAF',
    'TKMath',
    'TKMesh',
    'TKOffset',
    'TKPCAF',
    'TKPLCAF',
    'TKPShape',
    'TKPrim',
    'TKSTEP',
    'TKSTEP209',
    'TKSTEPAttr',
    'TKSTEPBase',
    'TKSTL',
    'TKService',
    'TKShHealing',
    'TKShapeSchema',
    'TKStdLSchema',
    'TKStdSchema',
    'TKTObj',
    'TKTopAlgo',
    'TKV2d',
    'TKV3d',
    'TKVRML',
    'TKXCAF',
    'TKXCAFSchema',
    'TKXDEIGES',
    'TKXDESTEP',
    'TKXMesh',
    'TKXSBase',
    'TKXml',
    'TKXmlL',
    'TKXmlTObj',
    'TKXmlXCAF',
    'TKernel',
]

try:
    setup(
      name = 'occmodel',
      ext_modules=[
        Extension("occmodel",
                    sources=["occmodel.pyx"],
                    depends = ["liboccmodel.a", "src/OCCModelLib.pxd"] + glob.glob("src/*.pxi"),
                    include_dirs = ['src', '/usr/include/oce'],
                    library_dirs = ['.'],
                    libraries = ["occmodel", "GL", "glut", "pthread"] + OCCLIBS,
                    extra_compile_args = ["-fpermissive"],
                    language="c++"),
        ],
        
      cmdclass = {'build_ext': build_ext}
    )
except:
    print('Traceback\n:%s\n' % str(sys.exc_info()[-2]))
else:
    print('\n')