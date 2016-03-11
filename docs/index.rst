.. pyaaf documentation master file, created by
   sphinx-quickstart on Fri Aug 30 14:25:46 2013.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to pyaaf's documentation!
=================================

Python Bindings for the `Advanced Authoring Format (AAF)
<http://aaf.sourceforge.net/>`_.

Basic Demo
----------

::

    import aaf

    f = aaf.open("path/to/file.aaf", "r")

    # get the main composition
    main_compostion = f.storage.toplevel_mobs()[0]

    # print the name of the composition
    print main_compostion.name

    # AAFObjects have properties that can be accessed like a dictionary
    # print out the creation time
    print main_compostion['CreationTime'].value

    # video, audio and other track types are stored in slots
    # on a mob object.

    for slot in main_compostion.slots():
        segment = slot.segment
        print segment

Installing
----------
The lastest release can be downloaded `here
<https://github.com/markreidvfx/pyaaf/releases>`_.

Building From Source
--------------------

First you need to download the AAF-devel-libs for your platform

http://sourceforge.net/projects/aaf/files/AAF-devel-libs/1.1.6


If your platform isn't there then you'll need to download the full AAF SDK
and build it yourself.

.. note::
    On Windows the prebuild AAF-devel-libs need the
    Microsoft Visual C++ 2010 Redistributable Package (x86_, x64_).

    For Python <= 3.2 you will need the `Visual C++ Compiler for Python 2.7`_ or Visual Studio 2008.

    For Python >= 3.3 you will need the `Windows 7 SDK`_ or Visual Studio 2010.
    To setup the Windows SDK for python I'd recommend following `this guide here`_.

.. _x86: https://www.microsoft.com/en-ca/download/details.aspx?id=5555
.. _x64: https://www.microsoft.com/en-ca/download/details.aspx?id=14632
.. _Visual C++ Compiler for Python 2.7: https://www.microsoft.com/en-ca/download/details.aspx?id=44266
.. _Windows 7 SDK: https://www.microsoft.com/en-us/download/details.aspx?id=3138
.. _this guide here: http://blog.ionelmc.ro/2014/12/21/compiling-python-extensions-on-windows/#for-python-3-4


To build inplace and test.

::

    $ git clone https://github.com/markreidvfx/pyaaf.git
    $ cd pyaaf
    $ export AAF_ROOT=path/to/root/of/AAF-devel-libs
    $ python setup.py build_ext --inplace
    $ nosetest


API Reference
=============

Contents:

.. toctree::
   :maxdepth: 3

   api/storage
   api/mob
   api/component
   api/essence
   api/dictionary
   api/util
   api/base
   api/property
   api/define
   api/iterator

Further Reading
===============

`AAF SDK Reference Manual <http://aaf.sourceforge.net/docs>`_

`aafobjectspec-v1.1.pdf <http://aaf.cvs.sourceforge.net/viewvc/aaf/AAF/doc/aafobjectspec-v1.1.pdf>`_

`aafeditprotocol.pdf <http://aaf.cvs.sourceforge.net/viewvc/aaf/AAF/doc/aafeditprotocol.pdf>`_

`aafstoredformatspec-v1.0.1.pdf <http://aaf.cvs.sourceforge.net/viewvc/aaf/AAF/doc/aafstoredformatspec-v1.0.1.pdf>`_

`aafcontainerspec-v1.0.1.pdf <http://aaf.cvs.sourceforge.net/viewvc/aaf/AAF/doc/aafcontainerspec-v1.0.1.pdf>`_


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
