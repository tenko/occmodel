Introduction
============

occmodel is a small library which gives a high level access
to the OpenCASCADE modelling kernel.

For most users a direct use of the OpenCASCADE modelling
kernel can be quite a hurdle as it is a huge library.

The geometry can be visualized with the included viewer.
This viewer is utilizing modern OpenGL methods like GLSL
shaders and vertex buffers to ensure visual quality and
maximum speed. To use the viewer OpenGL version 2.1 is
needed.

Most of the code have been adapted from the freecad (GPL 2).

The license is GPL v2.

Building
========

 * Python 2.7/3.x and Cython 0.17 or later.
 * A working installation of OpenCASCADE (OCE prefered)
 * The geotools_ library.
 * The optional viewer and demo needs the gltools_ library.

Note that currently I can not find a way to install the required
Cython 'pxd' files with distutils and this file has to be copied
manually.

On the Windows platform installers are available on the
pypi_ web site. It is possible to build the module from source
with the help of the express edition of Visual Studio, but the
process is rather involved compared to Linux.

To complete the windows installation the OpenCASCADE dll's must be
installed and placed in the system path. Prebuilt binaries are available
on the OCE_ project site. The python 2.7 module is linked against
'OCE-0.10.0-Win-MSVC2008.zip' and the python 3.3 module is
linked against 'OCE-0.10.0-Win-MSVC2010.zip'.

Documentation
=============

See online Sphinx docs_

.. _docs: http://tenko.github.com/occmodel/index.html

.. _geotools: http://github.com/tenko/geotools

.. _gltools: https://github.com/tenko/gltools

.. _pypi: http://pypi.python.org/pypi/occmodel

.. _OCE: https://github.com/tpaviot/oce/downloads