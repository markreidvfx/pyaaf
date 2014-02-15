cimport lib

from .util cimport error_check, AUID
from .mob cimport Mob,MobSlot
from .property cimport Property,PropertyValue, TaggedValue
from .component cimport Component, Segment, Parameter, ControlPoint
from .define cimport ClassDef,PropertyDef, TypeDef, CodecDef, PluginDef, KLVDataDef
from .essence cimport EssenceData

cdef class BaseIterator(object):
    def __cinit__(self):
        self._clone_iter = None
    
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
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef ClassDefIter iterable = ClassDefIter()
        error_check(self.ptr.Clone(&iterable.ptr))
        return iterable
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef ClassDef classdef = ClassDef()
        ret = self.ptr.NextOne(&classdef.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return ClassDef(classdef)
        else:
            error_check(ret)

cdef class CodecDefIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef CodecDefIter iterable = CodecDefIter()
        error_check(self.ptr.Clone(&iterable.ptr))
        return iterable
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)

    def __next__(self):
        cdef CodecDef codecdef = CodecDef()
        ret = self.ptr.NextOne(&codecdef.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return CodecDef(codecdef)
        else:
            error_check(ret)

cdef class ComponentIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef ComponentIter iter = ComponentIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
            
    def __next__(self):
        cdef Component comp = Component()
        ret = self.ptr.NextOne(&comp.comp_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Component(comp).resolve()
        else:
            error_check(ret)
            
cdef class ControlPointIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
    
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef ControlPointIter iter = ControlPointIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef ControlPoint point = ControlPoint()
        ret = self.ptr.NextOne(&point.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return ControlPoint(point).resolve()
        else:
            error_check(ret)
            
cdef class EssenceDataIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef EssenceDataIter iter = EssenceDataIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef EssenceData data = EssenceData()
        ret = self.ptr.NextOne(&data.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return EssenceData(data)
        else:
            error_check(ret)
            
cdef class KLVDataDefIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef KLVDataDefIter iter = KLVDataDefIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
            
    def __next__(self):
        cdef KLVDataDef klv_def = KLVDataDef()
        ret = self.ptr.NextOne(&klv_def.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return KLVDataDef(klv_def)
        else:
            error_check(ret)

cdef class LoadedPluginIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef LoadedPluginIter iter = LoadedPluginIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
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
        ret = self.ptr.NextOne(&auid.auid)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return auid
        else:
            error_check(ret)

cdef class MobSlotIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef MobSlotIter iterable = MobSlotIter()
        error_check(self.ptr.Clone(&iterable.ptr))
        return iterable
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef MobSlot slot = MobSlot()
        ret = self.ptr.NextOne(&slot.slot_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return MobSlot(slot).resolve()
        else:
            error_check(ret)
            
cdef class MobIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef MobIter iterable = MobIter()
        error_check(self.ptr.Clone(&iterable.ptr))
        return iterable
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef Mob mob = Mob()
        ret = self.ptr.NextOne(&mob.ptr)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Mob(mob).resolve()
        else:
            error_check(ret)

cdef class ParamIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef ParamIter iter = ParamIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef Parameter param = Parameter()
        ret = self.ptr.NextOne(&param.param_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Parameter(param).resolve()
        else:
            error_check(ret)

cdef class PluginDefIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef PluginDefIter iter = PluginDefIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef PluginDef plug_def = PluginDef()
        ret = self.ptr.NextOne(&plug_def.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return PluginDef(plug_def)
        else:
            error_check(ret)
            
cdef class PropIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef PropIter iter = PropIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef Property prop = Property()
        ret = self.ptr.NextOne(&prop.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Property(prop)
        else:
            error_check(ret)
            
cdef class PropertyDefsIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef PropertyDefsIter iter = PropertyDefsIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef PropertyDef propdef = PropertyDef()
        ret = self.ptr.NextOne(&propdef.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return PropertyDef(propdef)
        else:
            error_check(ret)

cdef class PropValueIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef PropValueIter iter = PropValueIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter

    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef PropertyValue value = PropertyValue()
        ret = self.ptr.NextOne(&value.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return PropertyValue(value)
        else:
            error_check(ret)

cdef class PropValueResolveIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef PropValueResolveIter iter = PropValueResolveIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef PropertyValue value = PropertyValue()
        ret = self.ptr.NextOne(&value.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return PropertyValue(value).value
        else:
            error_check(ret)
            
cdef class SegmentIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef SegmentIter iter = SegmentIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef Segment seg = Segment()
        ret = self.ptr.NextOne(&seg.seg_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Segment(seg).resolve()
        else:
            error_check(ret)
            
cdef class TaggedValueIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef TaggedValueIter iter = TaggedValueIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef TaggedValue tag = TaggedValue()
        ret = self.ptr.NextOne(&tag.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return TaggedValue(tag)
        else:
            error_check(ret)

cdef class TypeDefIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def reset(self):
        error_check(self.ptr.Reset())
        
    def clone(self):
        cdef TypeDefIter iter = TypeDefIter()
        error_check(self.ptr.Clone(&iter.ptr))
        return iter
    
    def skip(self, lib.aafUInt32  count = 1):
        ret = self.ptr.Skip(count)
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise IndexError("skip count exceeded number of remaining objects")
        elif ret == lib.AAFRESULT_SUCCESS:
            return
        else:
            error_check(ret)
    
    def __next__(self):
        cdef TypeDef type_def = TypeDef()
        ret = self.ptr.NextOne(&type_def.typedef_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return TypeDef(type_def).resolve()
        else:
            error_check(ret)
            
cdef class TypeDefStreamDataIter(BaseIterator):
    def __init__(self):
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
