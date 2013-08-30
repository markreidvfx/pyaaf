
cimport lib

cimport datadef
from base cimport AAFBase, AAFObject, AUID
from .util cimport error_check, query_interface, register_object, lookup_object
from wstring cimport wstring,toWideString


cdef class Dictionary(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(Dictionary, self).__init__(obj)
        self.iid = lib.IID_IAAFDictionary
        self.auid = lib.AUID_AAFDictionary
        self.ptr = NULL
        self.create = CreateInstance(self)
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDictionary)
        
    def lookup_datadef(self, bytes name):
        
        cdef AUID auid = datadef.DataDefMap[name.lower()]
        cdef datadef.DataDef definition = datadef.DataDef()
        
        error_check(self.ptr.LookupDataDef(auid.get_auid(), &definition.ptr ))
        
        return datadef.DataDef(definition)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class CreateInstance(object):

    def __init__(self, Dictionary dictionary):
        self.class_name = None
        self.dictionary = dictionary
        
    def __getattr__(self, name):
        self.class_name = name
        
        return self.create_instance
    
    def from_name(self, bytes name, *args, **kwargs):
        
        obj_type = lookup_object(name)
        
        
        dummy = obj_type()
        
        cdef AUID iid_obj = dummy.class_iid
        cdef AUID auid_obj = dummy.class_auid

        cdef lib.GUID iid = iid_obj.get_iid()
        cdef lib.aafUID_t auid = auid_obj.get_auid()
        
        cdef AAFBase unknown = AAFBase()
                
        error_check(self.dictionary.ptr.CreateInstance(auid, iid,
                                         &unknown.base_ptr))
        
        obj = obj_type(unknown)
        
        obj.initialize(*args, **kwargs)

        return obj
        
        
    def create_instance(self, *args, **kwargs):
        
        return self.from_name( self.class_name, *args, **kwargs)
    
register_object(Dictionary)
