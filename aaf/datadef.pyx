cimport lib
from .util cimport error_check, query_interface, register_object

from libcpp.map cimport map
from libcpp.string cimport string
from libcpp.pair cimport pair

from .base cimport AAFObject, AAFBase, AUID

from libcpp.vector cimport vector
from libcpp.string cimport string
from wstring cimport  wstring, wideToString

cpdef dict DataDefMap = {}
cpdef dict CodecDefMap = {}
cpdef dict ContainerDefMap = {}


cdef register_defs(map[string, lib.aafUID_t] def_map, dict d, replace=[]):
    cdef pair[string, lib.aafUID_t] def_pair
    cdef AUID auid_obj 
    for pair in def_map:
        auid_obj = AUID()
        auid_obj.from_auid(pair.second)
        name = pair.first
        for n in replace:
            name = name.replace(n, '')
        d[name.lower()] = auid_obj
    
register_defs(lib.get_datadef_map(), DataDefMap, ["kAAFDataDef_"])
register_defs(lib.get_codecdef_map(), CodecDefMap, ["kAAFCodecDef_",'kAAFCodec'])
register_defs(lib.get_container_def_map(), ContainerDefMap, ["kAAFContainerDef_"])



cdef class DefObject(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(DefObject, self).__init__(obj)
        self.iid = lib.IID_IAAFDefObject
        self.auid = lib.AUID_AAFDefObject
        self.defobject_ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.defobject_ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.defobject_ptr
    
    def __dealloc__(self):
        if self.defobject_ptr:
            self.defobject_ptr.Release()
            
    property name:
        def __get__(self):
            cdef lib.aafUInt32 sizeInBytes = 0
            error_check(self.defobject_ptr.GetNameBufLen(&sizeInBytes))
            
            cdef int sizeInChars = (sizeInBytes / sizeof(lib.aafCharacter)) + 1
            cdef vector[lib.aafCharacter] buf = vector[lib.aafCharacter](sizeInChars)
            
            error_check(self.defobject_ptr.GetName(&buf[0], sizeInChars*sizeof(lib.aafCharacter) ))
            
            cdef wstring name = wstring(&buf[0])
            return wideToString(name)
            

cdef class DataDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(DataDef, self).__init__(obj)
        self.iid = lib.IID_IAAFDataDef
        self.auid = lib.AUID_AAFDataDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def initialize(self, object def_type, bytes):
        pass
    
cdef class ParameterDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(ParameterDef, self).__init__(obj)
        self.iid = lib.IID_IAAFParameterDef
        self.auid = lib.AUID_AAFParameterDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class PluginDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(PluginDef, self).__init__(obj)
        self.iid = lib.IID_IAAFPluginDef
        self.auid = lib.AUID_AAFPluginDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

cdef class CodecDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(CodecDef, self).__init__(obj)
        self.iid = lib.IID_IAAFCodecDef
        self.auid = lib.AUID_AAFCodecDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class OperationDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(OperationDef, self).__init__(obj)
        self.iid = lib.IID_IAAFOperationDef
        self.auid = lib.AUID_AAFOperationDef
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
cdef class KLVDataDef(DefObject):
    def __init__(self, AAFBase obj = None):
        super(KLVDataDef, self).__init__(obj)
        self.iid = lib.IID_IAAFKLVDataDefinition
        self.auid = lib.AUID_AAFKLVDataDefinition
        self.ptr = NULL
        if not obj:
            return
        
        query_interface(obj.get(), <lib.IUnknown **> &self.ptr, self.iid)
    
    cdef lib.IUnknown **get(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

register_object(DefObject)           
register_object(DataDef)
register_object(ParameterDef)
register_object(PluginDef)
register_object(CodecDef)
register_object(OperationDef)
register_object(KLVDataDef)