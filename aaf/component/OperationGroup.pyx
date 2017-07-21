class ParametersHelper(object):
    def __init__(self, obj):
        self.obj = obj

    def __getitem__(self, index):
        for p in self.obj.parameters():
            if p.name == index:
                return p
        raise KeyError("Key %s not found" % index)
    def keys(self):
        """
        Return a list of the parameter names
        """
        return [p.name for p in self.obj.parameters()]

    def has_key(self, key):
        """
        Test for the presence of key in the parameter names
        """
        if key in self.keys():
            return True
        return False

    def get(self, key, default=None):
        """
        Return the parameter for key if key is in the obj, else default.
        If default is not given, it defaults to None, so that this method never raises a KeyError.
        """
        if self.has_key(key):
            return self[key]
        return default

cdef class OperationGroup(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFOperationGroup
        self.auid = lib.AUID_AAFOperationGroup
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFOperationGroup)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind, lib.aafLength_t length, OperationDef op_def not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        error_check(self.ptr.Initialize(data_def.ptr, length, op_def.ptr))

    def add_parameter(self, Parameter param not None):

        error_check(self.ptr.AddParameter(param.param_ptr))

    def input_segments(self):
        cdef Segment seg
        for i in xrange(self.nb_input_segments):
            seg = Segment.__new__(Segment)
            error_check(self.ptr.GetInputSegmentAt(i, &seg.seg_ptr))
            seg.query_interface()
            seg.root = self.root
            yield seg.resolve()

    def append(self, Segment seg not None):
        error_check(self.ptr.AppendInputSegment(seg.seg_ptr))

    def insert(self, lib.aafUInt32 index, Segment seg not None):
        error_check(self.ptr.InsertInputSegmentAt(index, seg.seg_ptr))

    def operationdef(self):
        cdef OperationDef op_def = OperationDef.__new__(OperationDef)
        error_check(self.ptr.GetOperationDefinition(&op_def.ptr))
        op_def.query_interface()
        op_def.root = self.root
        return op_def

    def parameters(self):
        cdef ParamIter param_iter = ParamIter.__new__(ParamIter)
        error_check(self.ptr.GetParameters(&param_iter.ptr))
        param_iter.root = self.root
        return param_iter

    property parameter:
        def __get__(self):
            helper = ParametersHelper(self)
            return helper

    property nb_input_segments:
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.CountSourceSegments(&value))
            return value

    property operation:
        def __get__(self):
            return self.operationdef().name

    property render:
        def __get__(self):
            cdef SourceReference source_ref = SourceReference.__new__(SourceReference)
            error_check(self.ptr.GetRender(&source_ref.ref_ptr))
            source_ref.query_interface()
            source_ref.root = self.root
            return source_ref.resolve()

        def __set__(self, SourceReference source_ref not None):
            error_check(self.ptr.SetRender(source_ref.ref_ptr))
