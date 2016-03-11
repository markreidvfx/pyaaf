cdef class FileDescriptor(EssenceDescriptor):
    def __cinit__(self):
        self.iid = lib.IID_IAAFFileDescriptor
        self.auid = lib.AUID_AAFFileDescriptor
        self.file_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.file_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.file_ptr, lib.IID_IAAFFileDescriptor)

        EssenceDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.file_ptr:
            self.file_ptr.Release()

    property sample_rate:
        def __set__(self, value):
            cdef lib.aafRational_t rate
            fraction_to_aafRational(value, rate)
            error_check(self.file_ptr.SetSampleRate(rate))
        def __get__(self):
            return self['SampleRate']

    property container_format:
        def __set__(self, value):
            cdef ContainerDef cont_def = self.dictionary().lookup_containerdef(value)
            error_check(self.file_ptr.SetContainerFormat(cont_def.ptr))
        def __get__(self):
            cdef ContainerDef cont_def = ContainerDef.__new__(ContainerDef)
            error_check(self.file_ptr.GetContainerFormat(&cont_def.ptr))
            cont_def.query_interface()
            cont_def.root = self.root
            auid = cont_def['Identification']

            for key,value in ContainerDefMap.items():
                if value == auid:
                    return key
            return cont_def.name
