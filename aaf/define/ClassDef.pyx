cdef class ClassDef(MetaDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFClassDef
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFClassDef)
            
        MetaDef.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def parent(self):
        cdef ClassDef classdef = ClassDef.__new__(ClassDef)
        error_check(self.ptr.GetParent(&classdef.ptr))
        classdef.query_interface()
        classdef.root = self.root
        return classdef
            
    def propertydefs(self):
        cdef PropertyDefsIter propdefs_iter = PropertyDefsIter.__new__(PropertyDefsIter)
        error_check(self.ptr.GetPropertyDefs(&propdefs_iter.ptr))
        propdefs_iter.root = self.root
        return propdefs_iter