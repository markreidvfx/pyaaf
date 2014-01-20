
cimport lib
from .util cimport error_check, query_interface, resolve_object

from .define cimport ClassDef
from .iterator cimport PropIter
#from .resolve import resolve_object

from dictionary cimport Dictionary

import uuid

cdef class AUID(object):
    def __init__(self, auid = None):
    
        if not auid:
            return
        
        auid = uuid.UUID(str(auid))
        items = auid.urn.replace('urn:uuid:', '').split('-')

        self.auid.Data1 = int(items[0], 16)
        self.auid.Data2 = int(items[1], 16)
        self.auid.Data3 = int(items[2], 16)
        
        self.auid.Data4[0] = int(items[3][:2], 16)
        self.auid.Data4[1] = int(items[3][2:4], 16)
        
        self.auid.Data4[2] = int(items[4][:2], 16)
        self.auid.Data4[3] = int(items[4][2:4], 16)
        self.auid.Data4[4] = int(items[4][4:6], 16)
        self.auid.Data4[5] = int(items[4][6:8], 16)
        self.auid.Data4[6] = int(items[4][8:10], 16)
        self.auid.Data4[7] = int(items[4][10:12], 16)
        
    cdef lib.aafUID_t get_auid(self):
        return self.auid
    cdef lib.GUID get_iid(self):
        return self.iid
    
    cdef void from_auid(self, lib.aafUID_t auid):
        self.auid = auid
        
    cdef void from_iid(self, lib.GUID iid):
        self.iid = iid
        
    def to_UUID(self):
        return uuid.UUID(str(self))
        
    def __richcmp__(x, y, int op):
        if op == 2:
            if isinstance(x, uuid.UUID):
                x = x.urn
                
            if isinstance(y, uuid.UUID):
                y = y.urn
            
            if str(x) == str(y):
                return True
            return False
        raise NotImplemented("richcmp %d not not Implemented" % op)
        
    def __repr__(self):
        return '<%s.%s of %s at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            str(self),
            id(self),
        )
        
    def __str__(self):
        return "urn:uuid:%08x-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x" % (
        self.auid.Data1, self.auid.Data2, self.auid.Data3,
        self.auid.Data4[0], self.auid.Data4[1], self.auid.Data4[2], self.auid.Data4[3],
        self.auid.Data4[4], self.auid.Data4[5], self.auid.Data4[6], self.auid.Data4[7]
        )

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
            auid.iid = self.iid
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
                return p.value
        raise KeyError("Key %s not found" % x)
    
    def __setitem__(self, x, y):
        for p in self.properties():
            if p.name == x:
                p.value = y
                return
            
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
            auid.auid = self.auid
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
