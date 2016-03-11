cimport lib

from .util cimport error_check, AUID
from .base cimport AAFObject
from .mob cimport Mob,MobSlot
from .property cimport Property, PropertyItem, PropertyValue, TaggedValue
from .component cimport Component, Segment, Parameter, ControlPoint
from .define cimport ClassDef,PropertyDef, TypeDef, CodecDef, PluginDef, KLVDataDef, resolve_typedef
from .essence cimport EssenceData, Locator

cdef class BaseIterator(object):
    def __cinit__(self):
        self._clone_iter = None

    def __init__(self):
        raise TypeError("%s cannot be instantiated from Python" %  self.__class__.__name__)

    def __getitem__(self, index):

        if isinstance(index, slice):
            return self._getslice(index)

        index = int(index)

        if index < 0:
            index = len(self) + index

        if index < 0:
            raise IndexError("index out of range")

        for i, item in enumerate(self):
            if i == index:
                return item
        raise IndexError("index out of range")

    def _getslice(self, slice_object):

        l = []

        for i in xrange(*slice_object.indices(len(self))):
            l.append(self[i])
        return l

    def __iter__(self):
        if self._clone_iter:
            return self._clone_iter()

        return self.clone()

    def __len__(self):
        i = 0
        for item in self:
            i += 1

        return i


cdef class ClassDefIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef ClassDefIter value = ClassDefIter.__new__(ClassDefIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef ClassDef value = ClassDef.__new__(ClassDef)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class CodecDefIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef CodecDefIter value = CodecDefIter.__new__(CodecDefIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef CodecDef value = CodecDef.__new__(CodecDef)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class ComponentIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef ComponentIter value = ComponentIter.__new__(ComponentIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Component value = Component.__new__(Component)

        with nogil:
            ret = self.ptr.NextOne(&value.comp_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class ControlPointIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef ControlPointIter value = ControlPointIter.__new__(ControlPointIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef ControlPoint value = ControlPoint.__new__(ControlPoint)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class EssenceDataIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef EssenceDataIter value = EssenceDataIter.__new__(EssenceDataIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef EssenceData value = EssenceData.__new__(EssenceData)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class KLVDataDefIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef KLVDataDefIter value = KLVDataDefIter.__new__(KLVDataDefIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef KLVDataDef value = KLVDataDef.__new__(KLVDataDef)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class LoadedPluginIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef LoadedPluginIter value = LoadedPluginIter.__new__(LoadedPluginIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef AUID auid = AUID()
        with nogil:
            ret = self.ptr.NextOne(&auid.auid)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return auid
        else:
            error_check(ret)

cdef class LocatorIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef LocatorIter value = LocatorIter.__new__(LocatorIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Locator value = Locator.__new__(Locator)
        with nogil:
            ret = self.ptr.NextOne(&value.loc_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)


cdef class MobSlotIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef MobSlotIter value = MobSlotIter.__new__(MobSlotIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef MobSlot value = MobSlot.__new__(MobSlot)
        with nogil:
            ret = self.ptr.NextOne(&value.slot_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class MobIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef MobIter value = MobIter.__new__(MobIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Mob value = Mob.__new__(Mob)

        cdef lib.IAAFMob **ptr = &value.ptr

        with nogil:
            ret = self.ptr.NextOne(ptr)


        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class ParamIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef ParamIter value = ParamIter.__new__(ParamIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Parameter value = Parameter.__new__(Parameter)
        with nogil:
            ret = self.ptr.NextOne(&value.param_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class PluginDefIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PluginDefIter value = PluginDefIter.__new__(PluginDefIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef PluginDef value = PluginDef.__new__(PluginDef)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class PropIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PropIter value = PropIter.__new__(PropIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Property value = Property.__new__(Property)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class PropItemIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PropItemIter value = PropItemIter.__new__(PropItemIter)
        cdef AAFObject new_obj = AAFObject.__new__(AAFObject)

        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        new_obj.query_interface(self.parent)
        value.parent = new_obj
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef PropertyItem item = PropertyItem.__new__(PropertyItem)
        cdef AAFObject new_obj = AAFObject.__new__(AAFObject)
        cdef Property value = Property.__new__(Property)

        cdef lib.IAAFProperty **ptr = &value.ptr

        with nogil:
            ret = self.ptr.NextOne(ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()

        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            new_obj.query_interface(self.parent)
            item.parent = new_obj
            item.property_def = value.property_def()
            item.root = self.root
            return item

        else:
            error_check(ret)

cdef class PropertyDefsIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PropertyDefsIter value = PropertyDefsIter.__new__(PropertyDefsIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef PropertyDef value = PropertyDef.__new__(PropertyDef)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class PropValueIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PropValueIter value = PropValueIter.__new__(PropValueIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef PropertyValue value = PropertyValue.__new__(PropertyValue)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class PropValueResolveIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef PropValueResolveIter value = PropValueResolveIter.__new__(PropValueResolveIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef PropertyValue value = PropertyValue.__new__(PropertyValue)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.value
        else:
            error_check(ret)

cdef class SegmentIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef SegmentIter value = SegmentIter.__new__(SegmentIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef Segment value = Segment.__new__(Segment)
        with nogil:
            ret = self.ptr.NextOne(&value.seg_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value.resolve()
        else:
            error_check(ret)

cdef class TaggedValueIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef TaggedValueIter value = TaggedValueIter.__new__(TaggedValueIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef TaggedValue value = TaggedValue.__new__(TaggedValue)
        with nogil:
            ret = self.ptr.NextOne(&value.ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return value
        else:
            error_check(ret)

cdef class TypeDefIter(BaseIterator):
    def __cinit__(self):
        self.ptr = NULL

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def reset(self):
        error_check(self.ptr.Reset())

    def clone(self):
        cdef TypeDefIter value = TypeDefIter.__new__(TypeDefIter)
        error_check(self.ptr.Clone(&value.ptr))
        value.root = self.root
        return value

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef TypeDef value = TypeDef.__new__(TypeDef)
        with nogil:
            ret = self.ptr.NextOne(&value.typedef_ptr)

        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            value.query_interface()
            value.root = self.root
            return resolve_typedef(value)
        else:
            error_check(ret)

cdef class TypeDefStreamDataIter(BaseIterator):
    def __cinit__(self):
        self.readsize = 2048

    def __iter__(self):
        return self

    def reset(self):
        self.stream_typedef.set_position(self.value, 0)

    def __next__(self):
        data = self.stream_typedef.read(self.value, self.readsize)
        if data:
            return data
        else:
            #reset streams position
            self.stream_typedef.set_position(self.value, 0)
            raise StopIteration()
