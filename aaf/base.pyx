
cimport lib
from .util cimport error_check, query_interface

from .metadef cimport ClassDef
from .iterator cimport PropIter

from dictionary cimport Dictionary

cdef class AUID(object):
    def __init__(self):
        pass
    cdef lib.aafUID_t get_auid(self):
        return self.auid
    cdef lib.GUID get_iid(self):
        return self.iid
    
    cdef void from_auid(self, lib.aafUID_t auid):
        self.auid = auid
        
    cdef void from_iid(self, lib.GUID iid):
        self.iid = iid
        
    def __repr__(self):
        return '<%s.%s of %s at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            self.to_string(),
            id(self),
        )
        
    def to_string(self):
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
        
        query_interface(obj.get(), &self.base_ptr, lib.IID_IUnknown)

    cdef lib.IUnknown **get(self):
        return &self.base_ptr
    
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
        
        query_interface(obj.get(), <lib.IUnknown **> &self.obj_ptr, lib.IID_IAAFObject)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.obj_ptr
    
    def initialize(self, *args, **kwargs):
        raise NotImplementedError("initialize not implemented for object")
    
    def dictionary(self):
        cdef Dictionary d = Dictionary()
        error_check(self.obj_ptr.GetDictionary(&d.ptr))
        return d
    
    def definition(self):
        cdef ClassDef class_def = ClassDef()
        error_check(self.obj_ptr.GetDefinition(&class_def.ptr))
        
        return ClassDef(class_def)
    
    def properties(self):
        cdef PropIter prop_iter = PropIter()
        error_check(self.obj_ptr.GetProperties(&prop_iter.ptr))
        return prop_iter
    
    def count_properties(self):
        cdef lib.aafUInt32 count
        error_check(self.obj_ptr.CountProperties(&count))
        return count
    
    property class_auid:
        def __get__(self):
            cdef AUID auid = AUID()
            auid.auid = self.auid
            return auid
    
    property class_name:
        def __get__(self):
            obj_def = self.definition()
            return obj_def.name
        
            