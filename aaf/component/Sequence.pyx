cdef class Sequence(Segment):
    def __cinit__(self):
        self.iid = lib.IID_IAAFSequence
        self.auid = lib.AUID_AAFSequence
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFSequence)

        Segment.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, media_kind not None):

        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        cdef DataDef media_datadef
        media_datadef = self.dictionary().lookup_datadef(media_kind)
        error_check(self.ptr.Initialize(media_datadef.ptr))

    def component_at(self, lib.aafUInt32 index):
        """
        return the component at the given index
        """

        cdef Component component = Component.__new__(Component)
        with nogil:
            ret = self.ptr.GetComponentAt(index, &component.comp_ptr)
        error_check(ret)

        component.query_interface()
        component.root = self.root
        return component.resolve()


    def component_at_time(self, time):
        """
        return the component at a given time (position in edit units)
        """

        return self.component_at(self.index_at_time(time))

    def index_at_time(self, time):
        """
        return the index of the component at a given time (position in edit units)
        """
        length  = 0

        last_position = None
        last_component = None
        last_index = None

        for index, position, component in self.positions():

            # if component is a transition it will have the same position
            # as the next item in the sequence
            if isinstance(component, Transition):
                if time >= position and time <= position +component.length:
                    return last_index

            if last_component:
                if position >= time:
                    return last_index

            last_component = component
            last_index = index

        return last_index

    def time_at_index(self, index):
        """
        return the time (position in edit units) of a given index
        """
        for i, position, component in self.positions():
            if index == i:
                return position

        raise IndexError()

    def positions(self):
        """
        yields (index, edit_start_time, component) of items in the sequence
        """
        length = 0

        cdef lib.aafUInt32 count
        error_check(self.ptr.CountComponents(&count))

        for i in range(count):
            component = self.component_at(i)
            if isinstance(component, Transition):
                length -= component.length
                yield (i, length, component)
            else:
                yield (i, length, component)
                length += component.length


    def components(self):
        cdef ComponentIter comp_inter = ComponentIter.__new__(ComponentIter)
        with nogil:
            ret = self.ptr.GetComponents(&comp_inter.ptr)
        error_check(ret)
        comp_inter.root = self.root
        return comp_inter

    def insert(self, lib.aafUInt32 index, Component component not None):
        """
        Insert Component at given index
        """
        error_check(self.ptr.InsertComponentAt(index, component.comp_ptr))

    def append(self, Component component not None):
        """
        Append Component at end of Sequence
        """
        error_check(self.ptr.AppendComponent(component.comp_ptr))

    def prepend(self, Component component not None):
        """
        Prepend Component at beginning of Sequence
        """
        error_check(self.ptr.PrependComponent(component.comp_ptr))

    def remove(self, lib.aafUInt32 index):
        """
        Remove Component at given index
        """
        error_check(self.ptr.RemoveComponentAt(index))

    property count:
        """
        Number of Components in Sequence
        """
        def __get__(self):
            cdef lib.aafUInt32 value
            error_check(self.ptr.CountComponents(&value))
            return value
