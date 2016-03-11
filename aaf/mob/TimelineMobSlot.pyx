
cdef class TimelineMobSlot(MobSlot):
    def __cinit__(self):
        self.iid = lib.IID_IAAFTimelineMobSlot2
        self.auid = lib.AUID_AAFTimelineMobSlot
        self.ptr = NULL
        self.ptr2 = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr, lib.IID_IAAFTimelineMobSlot2)

        if not self.ptr2:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.ptr2, lib.IID_IAAFTimelineMobSlot2)

        MobSlot.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

        if self.ptr2:
            self.ptr2.Release()

    def __init__(self, root):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr2.Initialize())


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

    property mark_in:

        def __get__(self):
            return self['MarkIn'].value

        def __set__(self, value):
            self['MarkIn'].value = value

    property mark_out:

        def __get__(self):
            return self['MarkOut'].value

        def __set__(self, value):
            self['MarkOut'].value = value

    property user_pos:

        def __get__(self):
            return self['UserPos'].value

        def __set__(self, value):
            self['UserPos'].value = value
