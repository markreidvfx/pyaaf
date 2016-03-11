cdef class EssenceAccess(EssenceMultiAccess):
    def __cinit__(self):
        self.iid = lib.IID_IAAFEssenceAccess
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFEssenceAccess)

        EssenceMultiAccess.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def get_emptyfileformat(self):
        cdef EssenceFormat format =  EssenceFormat.__new__(EssenceFormat)
        error_check(self.ptr.GetEmptyFileFormat(&format.ptr))
        format.query_interface()
        format.root = self.root
        return format

    def set_fileformat(self, EssenceFormat format):

        error_check(self.ptr.PutFileFormat(format.ptr))

    def get_fileformat(self, EssenceFormat template = None):
        if not template:
            template = self.get_fileformat_parameters()

        cdef EssenceFormat format = EssenceFormat.__new__(EssenceFormat)

        error_check(self.ptr.GetFileFormat(template.ptr, &format.ptr))
        format.query_interface()
        format.root = self.root
        return format


    def get_fileformat_parameters(self):
        cdef EssenceFormat format = EssenceFormat.__new__(EssenceFormat)
        error_check(self.ptr.GetFileFormatParameterList(&format.ptr))
        format.query_interface()
        format.root = self.root
        return format

    def index_sample_size(self,lib.aafPosition_t index):
        """
        The size in bytes of the given sample
        """
        cdef lib.aafLength_t sample_size
        error_check(self.ptr.GetIndexedSampleSize(self.datadef.ptr, index, &sample_size))
        return sample_size

    def seek(self, lib.aafPosition_t index):
        """
        Seek to Given frame index in essence, Useful only on reading, you can't seek aound while writing
        essence.
        """
        error_check(self.ptr.Seek(index))

    def read(self, lib.aafUInt32 nb_samples=1):
        """
        Read a given number of samples from an opened essence stream.
        This call will only return a single channel of essence from an
        interleaved stream.
        A video sample is a frame.
        """

        cdef lib.aafUInt32 samples_read
        cdef lib.aafUInt32 bytes_read
        cdef lib.aafUInt32 sample_size = self.max_sample_size
        cdef vector[lib.UChar] buf = vector[lib.UChar](sample_size*nb_samples)

        cdef string s

        hr = self.ptr.ReadSamples(nb_samples,
                                 sample_size*nb_samples,
                                 &buf[0],
                                 &samples_read,
                                 &bytes_read)

        if hr == lib.AAFRESULT_EOF:
            return None
        else:
            error_check(hr)

        s = string(<char * > &buf[0], bytes_read)
        return s

    def complete_write(self):
        """
        Handle any format related writing at the end and adjust mob
        lengths.  Must be called before releasing a write essence
        access.
        """
        error_check(self.ptr.CompleteWrite())

    def write(self, data, lib.aafUInt32 samples=1, data_type = 'bytes'):
        """
        Writes data to the given essence stream.
        A single video frame is ONE sample.
        Data Length must be large enough to hold the total sample size.
        """
        data_type = data_type.lower()
        cdef lib.aafUInt32 samples2

        if isinstance(data, bytes) or data_type == "bytes":
            return essence_write_bytes(self, data, samples)
        elif data_type == 'uint16':
            return essence_write_samples[lib.aafUInt16](self, data, samples, 0)
        elif data_type == 'uint8':
            return essence_write_samples[lib.aafUInt8](self, data, samples, 0)
        else:
            raise ValueError("data_type: %s not supported" % str(data_type))

    property samples:
        """
        The number of samples in the essence
        """
        def __get__(self):
            cdef lib.aafLength_t result
            error_check(self.ptr.CountSamples(self.datadef.ptr, &result))
            return result

    property max_sample_size:
        """
        The size in bytes of the largest sample in the essence.
        """
        def __get__(self):
            cdef lib.aafLength_t max_size
            error_check(self.ptr.GetLargestSampleSize(self.datadef.ptr, &max_size))
            return max_size

    property codec_flavour:
        def __set__(self, value):
            cdef AUID auid = CodecDefMap[value.lower()]
            error_check(self.ptr.SetEssenceCodecFlavour(auid.get_auid()))

    property codec_name:
        def __get__(self):
            cdef AAFCharBuffer name = AAFCharBuffer()
            name.size = 1024
            error_check(self.ptr.GetCodecName(name.size, name.get_ptr()))

            return name.read_str()

    property codecID:
        def __get__(self):
            cdef AUID auid = AUID()
            error_check(self.ptr.GetCodecID(&auid.auid))
            return auid




cdef object essence_write_bytes(EssenceAccess essence, bytes data, lib.aafUInt32 samples):
    cdef lib.aafUInt32 size = len(data)
    cdef lib.aafUInt32 byte_size = len(data)
    cdef lib.aafUInt32 samples_written =0
    cdef lib.aafUInt32 bytes_written =0


    #print len(buf), byte_size, buf.size(),samples

    error_check(essence.ptr.WriteSamples(samples,
                                         byte_size,
                                         <lib.aafUInt8 *> data,
                                         &samples_written,
                                         &bytes_written
                                         ))
    #print 'wrote', samples_written,bytes_written,samples
    return samples_written,bytes_written

cdef object essence_write_samples(EssenceAccess essence, data, lib.aafUInt32 samples, aaf_integral data_type):

    cdef lib.aafUInt32 size = len(data)
    cdef lib.aafUInt32 byte_size = sizeof(aaf_integral) * size
    cdef vector[aaf_integral] buf = vector[aaf_integral](size)

    for i,v in enumerate(data):
        buf[i] = v

    cdef lib.aafUInt32 samples_written =0
    cdef lib.aafUInt32 bytes_written =0
    error_check(essence.ptr.WriteSamples(samples,
                                         byte_size,
                                         <lib.aafUInt8 *> &buf[0],
                                         &samples_written,
                                         &bytes_written
                                         ))
    return samples_written,bytes_written
    #print 'wrote samples', samples_written, size
    #print 'wrote bytes', bytes_written, byte_size
