cdef class Timecode(object):

    def __init__(self, lib.aafFrameOffset_t start_frame = 0, drop = "NonDrop", lib.aafUInt16 fps = 25):

        self.start_frame = start_frame
        self.drop = drop
        self.fps = fps

    def __repr__(self):
        return '<%s.%s of start_frame:%i drop:%s fps:%i at 0x%x>' % (
            self.__class__.__module__,
            self.__class__.__name__,
            self.start_frame, self.drop, self.fps,
            id(self))
    cdef lib.aafTimecode_t get_timecode_t(self):
        return self.timecode

    property start_frame:
        def __get__(self):
            return self.timecode.startFrame
        def __set__(self, lib.aafFrameOffset_t value):
            self.timecode.startFrame = value

    property drop:
        def __get__(self):
            if self.timecode.drop == lib.kAAFTcNonDrop:
                return "nondrop"
            else:
                return 'drop'

        def __set__(self, value):
            if value.lower() == "nondrop":
                self.timecode.drop = lib.kAAFTcNonDrop
            elif value.lower() == 'drop':
                self.timecode.drop = lib.kAAFTcNonDrop
            else:
                raise ValueError('invalid drop type: %s. must be "drop" or "nondrop"' % value)
    property fps:
        def __get__(self):
            return self.timecode.fps
        def __set__(self, lib.aafUInt16 value):
            self.timecode.fps = value
