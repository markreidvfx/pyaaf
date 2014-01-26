
cimport lib
from .util cimport error_check, query_interface, resolve_object, AUID

from .define cimport ClassDef
from .iterator cimport PropIter
#from .resolve import resolve_object

from dictionary cimport Dictionary

cdef class AAFBase(object):
    def __init__(self,AAFBase obj = None):
        self.base_ptr = NULL
        self.iid = lib.IID_IUnknown
        if not obj:
            return
        
        query_interface(obj.get_ptr(), &self.base_ptr, lib.IID_IUnknown)

    cdef lib.IUnknown **get_ptr(self):
        return &self.base_ptr
    
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
    def __init__(self, AAFBase obj = None):
        super(AAFObject, self).__init__(obj)
        self.obj_ptr = NULL
        self.iid = lib.IID_IAAFObject
        self.auid = lib.AUID_AAFObject
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.obj_ptr, lib.IID_IAAFObject)
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.obj_ptr
    
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
        cdef Dictionary d = Dictionary()
        error_check(self.obj_ptr.GetDictionary(&d.ptr))
        return d
    
    def classdef(self):
        """
        Returns the Class Definition
        """
        cdef ClassDef class_def = ClassDef()
        error_check(self.obj_ptr.GetDefinition(&class_def.ptr))
        
        return ClassDef(class_def)
    
    def properties(self):
        """
        Returns a property Iterator
        """
        cdef PropIter prop_iter = PropIter()
        error_check(self.obj_ptr.GetProperties(&prop_iter.ptr))
        return prop_iter
    
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
