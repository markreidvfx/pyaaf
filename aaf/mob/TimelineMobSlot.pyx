
cdef class TimelineMobSlot(MobSlot):
    def __cinit__(self, AAFBase obj = None):
        self.iid = lib.IID_IAAFTimelineMobSlot
        self.auid = lib.AUID_AAFTimelineMobSlot
        self.ptr = NULL
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFTimelineMobSlot)

        MobSlot.query_interface(self, obj)
            
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def initialize(self):
        error_check(self.ptr.Initialize())
    
    property origin:
    
        def __get__(self):
            cdef lib.aafPosition_t origin
            error_check(self.ptr.GetOrigin(&origin))
            return origin
        
        def __set__(self, lib.aafPosition_t value):
            error_check(self.ptr.SetOrigin(value))
            
    property editrate:
    
        def __get__(self):
            cdef lib.aafRational_t rate
            error_check(self.ptr.GetEditRate(&rate))
            return AAFFraction(rate.numerator, rate.denominator)
        
        def __set__(self,value):
            cdef lib.aafRational_t rate
            fraction_to_aafRational(value,rate)
            error_check(self.ptr.SetEditRate(rate))
            