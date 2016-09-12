cdef class MasterMob(Mob):
    def __cinit__(self):
        self.iid = lib.IID_IAAFMasterMob2
        self.auid = lib.AUID_AAFMasterMob
        self.mastermob_ptr = NULL
        self.mastermob2_ptr = NULL
        self.mastermob3_ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.mastermob_ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob_ptr, lib.IID_IAAFMasterMob)

        if not self.mastermob2_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob2_ptr, lib.IID_IAAFMasterMob2)

        if not self.mastermob3_ptr:
            query_interface(obj.get_ptr(), <lib.IUnknown**>&self.mastermob3_ptr, lib.IID_IAAFMasterMob3)

        Mob.query_interface(self, obj)

    def __init__(self, root, name = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        error_check(self.mastermob_ptr.Initialize())
        if name:
            self.name = name

    def new_phys_source_ref(self, edit_rate, lib.aafSlotID_t  slotID, media_kind, SourceRef ref, lib.aafLength_t  srcRefLength):
        """new_phys_source_ref(edit_rate, slotID, media_kind, ref, srcRefLength)
        """
        cdef lib.aafRational_t edit_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        error_check(self.mastermob_ptr.NewPhysSourceRef(edit_rate_t,
                                                  slotID,
                                                  data_def.ptr,
                                                  ref.get_aafSourceRef_t(),
                                                  srcRefLength))

    def open_essence(self, lib.aafSlotID_t  slotID, mode = 'r', bool compression = False):
        """open_essence(slotID, mode = "r", compression = False)

        Opens a single channel of a file mob and returns EssenceAccess Object.

        :param int slotID: mob slotID to open essence data.
        :param str mode: essence open mode "r" for read, "a" for append.
        :param bool compression: decompress encoded data, (if supportedd).

        :returns: :class:`aaf.essence.EssenceAccess`.
        """

        slot = self.slot_at(slotID)

        cdef EssenceAccess access = EssenceAccess.__new__(EssenceAccess)

        cdef lib.aafMediaOpenMode_t mode_t = lib.kAAFMediaOpenReadOnly
        cdef lib.aafCompressEnable_t compression_t

        if mode.lower() == 'r':
            mode_t = lib.kAAFMediaOpenReadOnly

        elif mode.lower() == 'a':
            mode_t == lib.kAAFMediaOpenAppend

        else:
            raise ValueError("invalid mode %s" % mode)

        if compression:
            compression_t = lib.kAAFCompressionEnable
        else:
            compression_t = lib.kAAFCompressionDisable


        error_check(self.mastermob_ptr.OpenEssence(slotID,
                                                   NULL,
                                                   mode_t,
                                                   lib.kAAFCompressionDisable,
                                                   &access.ptr))
        access.query_interface()
        access.datadef = slot.datadef()
        access.root = self.root
        return access

    def create_essence(self,lib.aafSlotID_t slot_index,
                            media_kind,
                            codec_name,
                            edit_rate, sample_rate,
                            bool compress=False,
                            Locator locator=None,
                            fileformat = "aaf"):
        """create_essence(slot_index, media_kind, codec_name, edit_rate, sample_rate, compress = False, locator = None, fileformat = "aaf")
        """

        cdef DataDef media_datadef
        media_datadef = self.dictionary().lookup_datadef(media_kind)

        cdef lib.aafRational_t edit_rate_t
        cdef lib.aafRational_t sample_rate_t
        fraction_to_aafRational(edit_rate, edit_rate_t)
        fraction_to_aafRational(sample_rate, sample_rate_t)

        cdef AUID codec = CodecDefMap[codec_name.lower()]
        cdef AUID container = ContainerDefMap[fileformat.lower()]

        cdef Locator loc
        if locator:
            loc = locator
        else:
            loc = Locator.__new__(Locator)

        cdef EssenceAccess access = EssenceAccess.__new__(EssenceAccess)

        cdef lib.aafCompressEnable_t enable = lib.kAAFCompressionEnable
        if not compress:
            enable = lib.kAAFCompressionDisable

        error_check(self.mastermob_ptr.CreateEssence( slot_index,
                                                      media_datadef.ptr,
                                                      codec.get_auid(),
                                                      edit_rate_t,
                                                      sample_rate_t,
                                                      enable,
                                                      loc.loc_ptr,
                                                      container.get_auid(),
                                                      &access.ptr
                                                      ))
        access.query_interface()
        access.datadef = media_datadef
        access.root = self.root
        return access

    def import_video_essence(self, path, object frame_rate):
        """import_video_essence(path, frame_rate)

        Import raw dnxhd video stream from file.

        :param str path: path to dnxhd file
        :param frame_rate: frame rate of dnxhd file
        """

        cdef bytes c_path
        if isinstance(path, bytes):
            c_path = path
        else:
            c_path = path.encode("ascii")


        f = open(path, 'rb')
        dnx_header = f.read(640)
        f.close()

        if len(dnx_header) != 640:
            raise ValueError("Invalid DNxHD file: header to Short")

        header_prefix = (0x00, 0x00, 0x02, 0x80, 0x01)

        if header_prefix != unpack(">BBBBB", dnx_header[:5]):
            raise ValueError("Invalid DNxHD file: header magick number wrong")

        width, height = unpack(">24xhh", dnx_header[:28])
        codec_id = unpack(">40xi", dnx_header[:44])[0]

        slot_index = 0

        for slot in self.slots():
            slot_index = max(slot_index, slot.slotID)

        slot_index += 1

        cdef EssenceAccess essence

        essence = self.create_essence(slot_index,
                                     'picture',
                                     "DNxHD",
                                     frame_rate,
                                     frame_rate,
                                     compress = False)

        essence.codec_flavour = "Flavour_VC3_%d" % codec_id

        video = open(path)
        readsize = essence.max_sample_size

        cdef FILE* cfile

        cfile = fopen(c_path, 'rb')
        if cfile == NULL:
            raise ValueError()

        cdef unsigned char data[1024]

        cdef size_t buffer_size = 1024
        cdef size_t result =0

        cdef lib.aafUInt32 samples_written =0
        cdef lib.aafUInt32 bytes_written =0

        try:
            while True:
                result = fread(data, 1, buffer_size, cfile)
                if result == 0:
                    break

                error_check(essence.ptr.WriteSamples(1,
                                                     result,
                                                     data,
                                                     &samples_written,
                                                     &bytes_written))
            essence.complete_write()
        finally:
            fclose(cfile)

        return self.slot_at(slot_index)

    def import_audio_essence(self, path, lib.aafUInt32 channels, object sample_rate, object edit_rate = None):
        """import_audio_essence(path, channels, sample_rate)

        Import raw PCM audio stream from file.

        :param str path: path to pcm file
        :param int channels: number of channels in pcm file
        :param sample_rate: sample rate of pcm file
        """

        cdef bytes c_path

        if isinstance(path, bytes):
            c_path = path
        else:
            c_path = path.encode("ascii")

        slot_index = 0
        for slot in self.slots():
            slot_index = max(slot_index, slot.slotID)
        slot_index += 1

        audio_essences = []

        if edit_rate is None:
            edit_rate = sample_rate

        cdef EssenceAccess essence

        # Add essences for each audio channel
        for i in xrange(channels):
            essence = self.create_essence(slot_index+i,
                                         'sound',
                                         "PCM",
                                         edit_rate,
                                         sample_rate,
                                         compress = False)

            essence.codec_flavour = "Flavour_None"
            format = essence.get_emptyfileformat()
            format['AudioSampleBits'] = 16
            format['NumChannels'] = 1
            essence.set_fileformat(format)
            audio_essences.append(essence)

        #audio = open(path)

        # each sample is 2 bytes
        readsize = 2

        cdef FILE* cfile

        cfile = fopen(c_path, 'rb')

        if cfile == NULL:
            raise ValueError()

        cdef unsigned char data[2]
        cdef size_t result =0

        cdef lib.aafUInt32 samples_written =0
        cdef lib.aafUInt32 bytes_written =0

        try:
            while True:
                for essence in audio_essences:
                    result = fread(data, 1,2, cfile)
                    if result != 2:
                        break

                    error_check(essence.ptr.WriteSamples(1,
                                                     2,
                                                     data,
                                                     &samples_written,
                                                     &bytes_written))
                if result != 2:
                    break

            for essence in audio_essences:
                essence.complete_write()
        finally:
            fclose(cfile)

        return self.slot_at(slot_index)


    def add_master_slot(self, media_kind, lib.aafSlotID_t source_slotID, SourceMob source_mob,
                        lib.aafSlotID_t master_slotID, slot_name=None):
        """add_master_slot(media_kind, source_slotID, source_mob, master_slotID, slot_name = None)
        Add a slot that references the specified a slot in the specified Source Mob.
        """
        cdef DataDef media_datadef
        media_datadef = self.dictionary().lookup_datadef(media_kind)

        if not slot_name:
            slot_name = ""

        cdef AAFCharBuffer slot_name_buf = AAFCharBuffer(slot_name)

        error_check(self.mastermob_ptr.AddMasterSlot(media_datadef.ptr,
                                                     source_slotID,
                                                     source_mob.src_ptr,
                                                     master_slotID,
                                                     slot_name_buf.get_ptr()))
        for slot in self.slots():
            if slot.slotID == master_slotID:
                return slot

        raise RuntimeError("could not find added master slot")

    def add_master_slot_with_sequence(self, media_kind, lib.aafSlotID_t source_slotID, SourceMob source_mob,
                                      lib.aafSlotID_t master_slotID, slot_name = None):
        """add_master_slot_with_sequence(media_kind, source_slotID, source_mob, master_slotID, slot_name = None)
        """

        cdef DataDef media_datadef
        media_datadef = self.dictionary().lookup_datadef(media_kind)

        if not slot_name:
            slot_name = b""

        cdef AAFCharBuffer slot_name_buf = AAFCharBuffer(slot_name)

        error_check(self.mastermob3_ptr.AddMasterSlotWithSequence(media_datadef.ptr,
                                                     source_slotID,
                                                     source_mob.src_ptr,
                                                     master_slotID,
                                                     slot_name_buf.get_ptr()))
        for slot in self.slots():
            if slot.slotID == master_slotID:
                return slot

        raise RuntimeError("could not find added master slot")

    def __dealloc__(self):

        if self.mastermob_ptr:
            self.mastermob_ptr.Release()
        if self.mastermob2_ptr:
            self.mastermob2_ptr.Release()
