cdef class SourceClip(SourceReference):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSourceClip
        self.auid = lib.AUID_AAFSourceClip
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSourceClip)

        SourceReference.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind = None, lib.aafLength_t length = 0, SourceRef source_ref = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        if media_kind is None:
            media_kind = 'picture'

        cdef DataDef data_def = self.dictionary().lookup_datadef(media_kind)

        if source_ref is None:
            source_ref = SourceRef()

        error_check(self.ptr.Initialize(data_def.ptr, length, source_ref.get_aafSourceRef_t()))


    def resolve_ref(self):
        cdef Mob mob = Mob.__new__(Mob)
        cdef lib.HRESULT result

        with nogil:
            result = self.ptr.ResolveRef(&mob.ptr)

        if result == lib.AAFRESULT_MOB_NOT_FOUND:
            return None
        else:
            error_check(result)

        mob.query_interface()
        mob.root = self.root
        return mob.resolve()

    def resolve_slot(self):
        mob = self.resolve_ref()
        if mob:
            return mob.slot_at(self.source_ref.slot_id)

    def walk(self):

        slot = self.resolve_slot()
        if not slot:
            return

        segment = slot.segment

        if isinstance(segment, SourceClip):
            yield segment
            for item in segment.walk():
                yield item

        elif isinstance(segment, Sequence):
            clip = segment.component_at_time(self.start_time)
            if isinstance(clip, SourceClip):
                yield clip
                for item in clip.walk():
                    yield item
            else:
                raise NotImplementedError("Sequence returned %s not implemented" %  str(type(segment)))

        elif isinstance(segment, EssenceGroup):
            yield segment

        elif isinstance(segment, Filler):
            yield segment

        else:
            raise NotImplementedError("walking %s not implemented" %  str(type(segment)))



    property start_time:
        def __get__(self):
            return self.source_ref.start_time

        def __set__(self, value):
            source_ref = self.source_ref
            source_ref.start_time = value
            self.source_ref = source_ref

    property slot_id:
        def __get__(self):
            return self['SourceMobSlotID'].value

        def __set__(self, value):
            self['SourceMobSlotID'].value = value

    property mob_id:
        def __get__(self):
            return self['SourceID'].value

        def __set__(self, value):
            self['SourceID'].value = value

    property source_ref:

        def __get__(self):
            cdef SourceRef value = SourceRef.__new__(SourceRef)
            error_check(self.ptr.GetSourceReference(&value.source_ref))
            return value

        def __set__(self, SourceRef value):

            error_check(self.ptr.SetSourceReference(value.get_aafSourceRef_t()))
