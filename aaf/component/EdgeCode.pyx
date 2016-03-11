cdef class EdgeCode(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEdgecode
        self.auid = lib.AUID_AAFEdgecode
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEdgecode)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    def __init__(self, root, lib.aafLength_t length = 0, lib.aafFrameOffset_t start_frame = 0,
                  film_kind = "35mm", code_format = "keycode", header = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef lib.aafFilmType_t film_kind_t = FilmTypeMap[film_kind.lower()]
        cdef lib.aafEdgeType_t edge_type = EdgeTypeMap[code_format.lower()]

        cdef lib.aafEdgecode_t edge_code

        cdef char * c_header

        edge_code.startFrame = start_frame
        edge_code.filmKind = film_kind_t
        edge_code.codeFormat = edge_type

        # Zero Terminate out header
        memset(<void *> edge_code.header, '\0', 8)

        if header:
            if len(header) > 8:
                raise ValueError("header can only be 8 or less characters")

        error_check(self.ptr.Initialize(length, edge_code))

        if header:
            self.header = header


    property header:

        def __get__(self):
            cdef lib.aafEdgecode_t edge_code

            error_check(self.ptr.GetEdgecode(&edge_code))

            return edge_code.header.decode("ascii")

        def __set__(self, value not None):

            if len(value) > 8:
                raise ValueError("header can only be 8 or less characters")

            int_list = [0 for i in xrange(8)]

            cdef lib.aafUInt8 int_value

            for i, item in enumerate(value):
                int_value = ord(item)
                int_list[i] = int_value

            self['Header'].value = int_list
