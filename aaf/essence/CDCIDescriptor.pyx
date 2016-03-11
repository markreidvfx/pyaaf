cdef class CDCIDescriptor(DigitalImageDescriptor):
    """
    The CDCIDescriptor class specifies that a file SourceMob is associated with video
    essence formatted with one luminance component and two color-difference components
    as specified in this document.
    Informative note: This format is commonly known as YCbCr.
    The CDCIDescriptor class is a sub-class of the DigitalImageDescriptor class.
    A CDCIDescriptor object shall be owned by a file SourceMob.
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFCDCIDescriptor
        self.auid = lib.AUID_AAFCDCIDescriptor
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFCDCIDescriptor)

        DigitalImageDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self , root):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.ptr.Initialize())

    property component_width:
        """
        The ComponentWidth property.  Specifies the number of bits
        used to store each component.  Typical values can be 8, 10,
        12, 14, or 16, but others are permitted by the reference
        implementation.  Each component in a sample is packed
        contiguously; the sample is filled with the number of bits
        specified by the optional PaddingBits property.  If the
        PaddingBits property is omitted, samples are packed
        contiguously.
        """
        def __set__(self, lib.aafInt32 value):
            error_check(self.ptr.SetComponentWidth(value))
        def __get__(self):
            cdef lib.aafInt32 value
            error_check(self.ptr.GetComponentWidth(&value))
            return value

    property horizontal_subsampling:
        """
        The HorizontalSubsampling property.  Specifies the ratio of
        luminance sampling to chrominance sampling in the horizontal direction.
        For 4:2:2 video, the value is 2, which means that there are twice as
        many luminance values as there are color-difference values.
        Another typical value is 1; however other values are permitted by
        the reference implementation.
        """
        def __set__(self, lib.aafUInt32 value):
            error_check(self.ptr.SetHorizontalSubsampling(value))
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.GetHorizontalSubsampling(&value))
            return value

    property vertical_subsampling:
        """
        The VerticalSubsampling property.  Specifies the ratio of
        luminance sampling to chrominance sampling in the vertical direction.
        For 4:2:2 video, the value is 2, which means that there are twice as
        many luminance values as there are color-difference values.
        Another typical value is 1; however other values are permitted by
        the reference implementation.
        """
        def __set__(self, lib.aafUInt32 value):
            error_check(self.ptr.SetVerticalSubsampling(value))
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.GetVerticalSubsampling(&value))
            return value

    property color_range:
        """
        The ColorRange property.  Specifies the range of allowable
        digital chrominance component values.  Chrominance values are
        unsigned and the range is centered on 128 for 8-bit video and 512
        for 10-bit video.  This value is used for both chrominance
        components.
        """
        def __set__(self, lib.aafUInt32 value):
            error_check(self.ptr.SetColorRange(value))
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.GetColorRange(&value))
            return value
