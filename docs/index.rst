.. pyaaf documentation master file, created by
   sphinx-quickstart on Fri Aug 30 14:25:46 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to pyaaf's documentation!
=================================

Python Bindings for the Advanced Authoring Format (AAF)


Building From Source
--------------------

First you need to download the AAF-devel-libs for your platform

http://sourceforge.net/projects/aaf/files/AAF-devel-libs/1.1.6

If your platform isn't there then you'll need to download the full SDK
and build it yourself


::

    $ https://github.com/markreidvfx/pyaaf.git
    $ cd pyaaf
    $ export AAF_ROOT=path/to/root/of/AAF-devel-libs
    $ export LD_LIBRARY_PATH=AAF_ROOT/bin:$LD_LIBRARY_PATH #or DYLD_LIBRARY_PATH on mac
    $ virtualenv venv
    $ . venv/bin/activate
    $ pip install cython nose
    $ make test
    
 

API Reference
=============

Contents:

.. toctree::
   :maxdepth: 2
   
   api/base
   api/storage
   api/dictionary
   api/components
   api/component
   api/essence
   api/define
   api/base



Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

