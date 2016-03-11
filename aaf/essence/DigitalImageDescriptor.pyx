cdef class DigitalImageDescriptor(FileDescriptor):
    """
    The DigitalImageDescriptor class specifies that a File SourceMob is associated with
    video essence that is formatted either using RGBA or luminance/chrominance formatting.
    The DigitalImageDescriptor class is a sub-class of the FileDescriptor class.
    The DigitalImageDescriptor class is an abstract class.
    """

    def __cinit__(self):
        self.iid = lib.IID_IAAFDigitalImageDescriptor
        self.auid = lib.AUID_AAFDigitalImageDescriptor
        self.im_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.im_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.im_ptr, lib.IID_IAAFDigitalImageDescriptor)

        FileDescriptor.query_interface(self, obj)

    def __dealloc__(self):
        if self.im_ptr:
            self.im_ptr.Release()

    property compression:
        def __set__(self, value):
            cdef AUID auid = CompressionDefMap[value.lower()]
            error_check(self.im_ptr.SetCompression(auid.get_auid()))

        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.im_ptr.GetCompression(&auid.auid))

            for key,value in CompressionDefMap.items():
                if value == auid:
                    return key

            raise ValueError("Unknown Compression")

    property stored_view:
        """
        The dimension of the stored view.  Typically this includes
        leading blank video lines, any VITC lines, as well as the active
        picture area. Set takes a tuple (width, height)
        """
        def __set__(self, size):
            cdef lib.aafUInt32 width = size[0]
            cdef lib.aafUInt32 height = size[1]
            #Note AAF has these backwords!
            error_check(self.im_ptr.SetStoredView(height,width))
        def __get__(self):
            cdef lib.aafUInt32 width
            cdef lib.aafUInt32 height

            error_check(self.im_ptr.GetStoredView(&height,&width))
            return (width, height)

    property sampled_view:
        """
        The dimensions of sampled view.  Typically this includes
        any VITC lines as well as the active picture area, but excludes
        leading blank video lines. Set takes a tuple (width, height x_offset, y_offset)
        """
        def __set__(self, rect):
            cdef lib.aafUInt32 width = rect[0]
            cdef lib.aafUInt32 height = rect[1]
            cdef lib.aafInt32 x_offset = rect[2]
            cdef lib.aafInt32 y_offset = rect[3]

            error_check(self.im_ptr.SetSampledView(height, width, x_offset, y_offset))

        def __get__(self):
            cdef lib.aafUInt32 width
            cdef lib.aafUInt32 height
            cdef lib.aafInt32 x_offset
            cdef lib.aafInt32 y_offset
            error_check(self.im_ptr.GetSampledView(&height, &width, &x_offset, &y_offset))
            return (width, height, x_offset, y_offset)

    property display_view:
        """
        the dimension of display view.  Typically this includes
        the active picture area, but excludes leading blank video lines
        and any VITC lines. Set takes a tuple (width, height x_offset, y_offset)
        """
        def __set__(self, rect):
            cdef lib.aafUInt32 width = rect[0]
            cdef lib.aafUInt32 height = rect[1]
            cdef lib.aafInt32 x_offset = rect[2]
            cdef lib.aafInt32 y_offset = rect[3]

            error_check(self.im_ptr.SetDisplayView(height, width, x_offset, y_offset))

        def __get__(self):
            cdef lib.aafUInt32 width
            cdef lib.aafUInt32 height
            cdef lib.aafInt32 x_offset
            cdef lib.aafInt32 y_offset
            error_check(self.im_ptr.GetDisplayView(&height, &width, &x_offset, &y_offset))
            return (width, height, x_offset, y_offset)
    property aspect_ratio:
        """
        Image Aspect Ratio.  This ratio describes the
        ratio between the horizontal size and the vertical size in the
        intended final image.
        """
        def __set__(self, value):
            cdef lib.aafRational_t ratio
            fraction_to_aafRational(value, ratio)
            error_check(self.im_ptr.SetImageAspectRatio(ratio))
        def __get__(self):
            return self['ImageAspectRatio']

    property layout:
        """
        The frame layout.  The frame layout describes whether all
        data for a complete sample is in one frame or is split into more
        than/ one field. Set Takes a str.

        Values are:
            "fullframe"      - Each frame contains a full sample in progressive
                               scan lines.
            "separatefields" - Each sample consists of two fields,
                               which when interlaced produce a full sample.
            "onefield"       - Each sample consists of two interlaced
                               fields, but only one field is stored in the
                               data stream.
            "mixxedfields"   - Similar to FullFrame, except the two fields

        Note: value is always converted to lowercase
        """

        def __set__(self, value):
            value = value.lower()
            if value == "none":
                value = None
            if value is None:
                pass

            cdef lib.aafFrameLayout_t layout = FrameLayout[value]

            error_check(self.im_ptr.SetFrameLayout(layout))

        def __get__(self):
            cdef lib.aafFrameLayout_t layout

            error_check(self.im_ptr.GetFrameLayout(&layout))
            print layout

            for key, value in FrameLayout.items():
                if value == layout:
                    return key

    property line_map:
        """
        The VideoLineMap property.  The video line map specifies the
        scan line in the analog source that corresponds to the beginning
        of each digitized field.  For single-field video, there is 1
        value in the array.  For interleaved video, there are 2 values
        in the array. Set Takes a Tuple, example: (0) or (0,1).
        """
        def __set__(self, value):
            if len(value) == 0 or len(value ) > 2:
                raise ValueError("line_map len must be 1 or 2")
            cdef lib.aafUInt32 numberElements = len(value)

            cdef lib.aafInt32 line_map[2]

            for i,value in enumerate(value):
                line_map[i] = value

            error_check(self.im_ptr.SetVideoLineMap(numberElements, line_map))
        def __get__(self):
            cdef lib.aafUInt32 numberElements
            error_check(self.im_ptr.GetVideoLineMapSize(&numberElements))

            cdef vector[lib.aafInt32] buf
            # I don't Know if its possible to have a line_map bigger then 2
            cdef lib.aafInt32 line_map[5]

            error_check(self.im_ptr.GetVideoLineMap(numberElements, line_map))

            l = []
            for i in xrange(numberElements):
                l.append(line_map[i])

            return tuple(l)

    property image_alignment:
        """
        Specifies the alignment when storing the digital essence.  For example, a value of 16
        means that the image is stored on 16-byte boundaries.  The
        starting point for a field will always be a multiple of 16 bytes.
        If the field does not end on a 16-byte boundary, it is padded
        out to the next 16-byte boundary.
        """
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.im_ptr.GetImageAlignmentFactor(&value))
            return value
        def __set__(self, lib.aafUInt32 value):
            error_check(self.im_ptr.SetImageAlignmentFactor(value))
