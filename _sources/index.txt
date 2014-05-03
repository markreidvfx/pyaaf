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
        
            
        
    
    
    
    

Building From Source
--------------------

First you need to download the AAF-devel-libs for your platform

http://sourceforge.net/projects/aaf/files/AAF-devel-libs/1.1.6

If your platform isn't there then you'll need to download the full SDK
and build it yourself. 


::

    $ git clone https://github.com/markreidvfx/pyaaf.git
    $ cd pyaaf
    $ export AAF_ROOT=path/to/root/of/AAF-devel-libs
    $ virtualenv venv
    $ . venv/bin/activate
    $ pip install cython nose
    $ make
    $ nosetests
    
 

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

