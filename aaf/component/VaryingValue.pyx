cdef class VaryingValue(Parameter):
    def __cinit__(self):
        self.iid = lib.IID_IAAFVaryingValue
        self.auid = lib.AUID_AAFVaryingValue
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFVaryingValue)

        Parameter.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, ParameterDef param not None, InterpolationDef interp not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize(param.ptr, interp.ptr))

    def interpolation_def(self):
        cdef InterpolationDef inter_def = InterpolationDef.__new__(InterpolationDef)
        error_check(self.ptr.GetInterpolationDefinition(&inter_def.ptr))
        inter_def.query_interface()
        inter_def.root = self.root
        return inter_def.resolve()

    def count(self):
        cdef lib.aafUInt32 value
        error_check(self.ptr.CountControlPoints(&value))
        return value

    def points(self):
        cdef ControlPointIter iter = ControlPointIter.__new__(ControlPointIter)
        error_check(self.ptr.GetControlPoints(&iter.ptr))
        iter.root = self.root
        return iter

    def add_point(self, time, value):

        cdef ControlPoint point = ControlPoint(self.root(), self, time, value)
        error_check(self.ptr.AddControlPoint(point.ptr))
        return point


    def value_at(self, time):
        """
        Get the varying value at a specified time, Only currently works for step and linear interpolation.
        """

        interp_def = self.interpolation_def()

        if not interp_def.name in ('LinearInterp', 'StepInterp'):
            raise NotImplementedError("value_at not implemented for %s" % interp_def.name)


        cdef lib.aafInt32 buffer_size

        error_check(self.ptr.GetValueBufLen(&buffer_size))

        cdef lib.aafRational_t time_t
        cdef lib.aafRational_t value_t

        cdef lib.aafInt32 bytes_read

        fraction_to_aafRational(time, time_t)

        error_check(self.ptr.GetInterpolatedValue(time_t,
                                                  sizeof(value_t),
                                                  <lib.aafDataBuffer_t> &value_t,
                                                  &bytes_read
                                                  ))
        if bytes_read != sizeof(value_t):
            raise IOError("invalid read size")

        return aafRational_to_fraction(value_t)
