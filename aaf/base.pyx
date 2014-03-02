
cimport lib
from .util cimport error_check, query_interface, resolve_object, AUID

from .define cimport ClassDef
from .iterator cimport PropIter
#from .resolve import resolve_object

from dictionary cimport Dictionary

cdef class AAFBase(object):
    def __cinit__(self):
        self.base_ptr = NULL
        self.iid = lib.IID_IUnknown
        self.root = None
          
    def __init__(self, AAFBase obj = None):
        raise TypeError("%s cannot be instantiated from Python" %  self.__class__.__name__)

    cdef lib.IUnknown **get_ptr(self):
        return &self.base_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            return
        query_interface(obj.get_ptr(), &self.base_ptr, lib.IID_IUnknown)
    
    cdef resolve(self):
        return resolve_object(self)

    def __dealloc__(self):
        if self.base_ptr:
            self.base_ptr.Release()
            
    property class_iid:
        def __get__(self):
            cdef AUID auid = AUID()
            auid.from_iid(self.iid)
            return auid
            
            

cdef class AAFObject(AAFBase):
    def __cinit__(self):
        self.obj_ptr = NULL
        self.iid = lib.IID_IAAFObject
        self.auid = lib.AUID_AAFObject
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.obj_ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.obj_ptr, lib.IID_IAAFObject)
            
        AAFBase.query_interface(self, obj)
        
    def __dealloc__(self):
        if self.obj_ptr:
            self.obj_ptr.Release()
        
    def __getitem__(self, x):
        for p in self.properties():
            if p.name == x:
                return p
        raise KeyError("Key %s not found" % x)
    
    def keys(self):
        """
        Return a list of the AAFObjects property names
        """
        return [p.name for p in self.properties()]
    
    def has_key(self, bytes key):
        """
        Test for the presence of key in the AAFObject property names
        """
        if key in self.keys():
            return True
        return False
    
    def get(self, key, default=None):
        """
        Return the property value for key if key is in the AAFObject, else default. 
        If default is not given, it defaults to None, so that this method never raises a KeyError.
        """
        if self.has_key(key):
            return self[key]
        return default
    
    def initialize(self, *args, **kwargs):
        """
        This method gets call when a new instance of a AAFObject is created.
        """
        raise NotImplementedError("initialize not implemented for object")
    
    def dictionary(self):
        """
        Returns the Dictionary Object the AAFObject belongs to.
        """
        cdef Dictionary d = Dictionary.__new__(Dictionary)
        error_check(self.obj_ptr.GetDictionary(&d.ptr))
        d.query_interface()
        d.root = self.root
        return d
    
    def classdef(self):
        """
        Returns the Class Definition
        """
        cdef ClassDef class_def = ClassDef.__new__(ClassDef)
        error_check(self.obj_ptr.GetDefinition(&class_def.ptr))
        class_def.query_interface()
        class_def.root = self.root
        return class_def
    
    def properties(self):
        """
        Returns a property Iterator
        """
        cdef PropIter prop_iter = PropIter.__new__(PropIter)
        error_check(self.obj_ptr.GetProperties(&prop_iter.ptr))
        prop_iter.root = self.root
        return prop_iter
    
    def __repr__(self):
        name = self.name
        if name:
            return '<%s.%s %s at 0x%x>' % (
                    self.__class__.__module__,
                    self.__class__.__name__,
                    str(name), 
                    id(self),
                    )
        else:
            return '<%s.%s at 0x%x>' % (
                    self.__class__.__module__,
                    self.__class__.__name__,
                    id(self),
                    )
    
    
    property class_auid:
        """
        The AUID of the AAFObject
        """
        def __get__(self):
            cdef AUID auid = AUID()
            auid.from_auid(self.auid)
            return auid
        
    property name:
        """
        The name of the AAFObject, None if Object doesn't have a "Name" property.
        """
        def __get__(self):
            for p in self.properties():
                if p.name == "Name":
                    name = p.value
                    if name:
                        return name
            return None
    
    property class_name:
        """
        Resolved class name for AAFOBject from its ClassDef.
        """
        def __get__(self):
            obj_def = self.classdef()
            return obj_def.name
