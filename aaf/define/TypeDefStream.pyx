cdef class TypeDefStream(TypeDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFTypeDefStream

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFTypeDefStream)

        TypeDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def size(self, PropertyValue p_value):
        """
        Returns number of bytes contained in the referenced property value
        """
        cdef lib.aafInt64 size
        error_check(self.ptr.GetSize(p_value.ptr, &size))
        return size

    def position(self, PropertyValue p_value):
        cdef lib.aafInt64 position
        error_check(self.ptr.GetPosition(p_value.ptr, &position))
        return position

    def set_position(self, PropertyValue p_value, lib.aafInt64 position):
        error_check(self.ptr.SetPosition(p_value.ptr, position))

    def read(self, PropertyValue p_value, lib.aafUInt32 readsize):


        readsize = min(readsize, self.size(p_value) - self.position(p_value))

        if readsize <= 0:
            return None

        cdef vector[lib.UChar] buf = vector[lib.UChar](readsize)
        cdef lib.aafUInt32 bytes_read = 0
        cdef string s
        hr = self.ptr.Read(p_value.ptr,
                                  readsize,
                                  <lib.aafMemPtr_t> &buf[0],
                                  &bytes_read
                                  )

        error_check(hr)

        s = string(<char * > &buf[0], bytes_read)
        return s


    def value(self,PropertyValue p_value):

        cdef TypeDefStreamDataIter data_iter = TypeDefStreamDataIter.__new__(TypeDefStreamDataIter)
        data_iter.stream_typedef = self
        data_iter.value = p_value
        data_iter.root = self.root
        data_iter._clone_iter = lambda v=p_value: self.value(v)
        return data_iter
