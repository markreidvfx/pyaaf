cdef class Header(AAFObject):
    """
    Header object for AAF File. This object is mainly used to get the
    :class:`aaf.dictionary.Dictionary` and
    :class:`ContentStorage`  objects for the AAF file
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFHeader
        self.auid = lib.AUID_AAFHeader
        self.ptr = NULL
        self.ptr2 = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFHeader)

        if not self.ptr2:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr2, lib.IID_IAAFHeader2)

        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

        if self.ptr2:
           self.ptr2.Release()

    def dictionary(self):
        """
        :returns: :class:`aaf.dictionary.Dictionary`
        """
        cdef Dictionary dictionary = Dictionary.__new__(Dictionary)
        error_check(self.ptr.GetDictionary(&dictionary.ptr))
        dictionary.query_interface()
        dictionary.root = self.root
        return dictionary

    def storage(self):
        """
        :returns: :class:`aaf.storage.ContentStorage`
        """
        cdef ContentStorage content_storage = ContentStorage.__new__(ContentStorage)
        error_check(self.ptr.GetContentStorage(&content_storage.ptr))
        content_storage.query_interface()
        content_storage.root = self.root
        return content_storage

    property operational_pattern:
        def __get__(self):
            cdef AUID auid = AUID.__new__(AUID)
            error_check(self.ptr2.GetOperationalPattern(&auid.auid))
            return auid

        def __set__(self, value):
            cdef AUID auid = AUID(value)
            error_check(self.ptr2.SetOperationalPattern(auid.get_auid()))
