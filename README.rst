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

 * Python 2.6 and Cython 0.17.
 * A working installation of OpenCASCADE (OCE prefered)
 * The geotools_ library.
 * The optional viewer and demo needs the gltools_ library.

The extension have only been build on the Linux platform.

Documentation
=============

See online Sphinx docs_

.. _docs: http://tenko.github.com/occmodel/index.html

.. _geotools: http://github.com/tenko/geotools

.. _gltools: https://github.com/tenko/gltools