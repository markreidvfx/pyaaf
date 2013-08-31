cimport lib

from .util cimport error_check
from .mob cimport Mob,MobSlot
from .property cimport Property,PropertyValue
from .component cimport Component, Segment

cdef class BaseIterator(object):
    pass

cdef class ComponentIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef Component comp = Component()
        ret = self.ptr.NextOne(&comp.comp_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Component(comp).resolve()
        else:
            error_check(ret)

cdef class MobSlotIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def __iter__(self):
        return self
    
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
        
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef Mob mob = Mob()
        ret = self.ptr.NextOne(&mob.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Mob(mob).resolve()
        else:
            error_check(ret)
            
cdef class PropIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef Property prop = Property()
        ret = self.ptr.NextOne(&prop.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Property(prop)
        else:
            error_check(ret)

cdef class PropValueIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef PropertyValue value = PropertyValue()
        ret = self.ptr.NextOne(&value.ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return PropertyValue(value)
        else:
            error_check(ret)
            
cdef class SegmentIter(BaseIterator):
    def __init__(self):
        self.ptr = NULL
        
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def __iter__(self):
        return self
    
    def __next__(self):
        cdef Segment seg = Segment()
        ret = self.ptr.NextOne(&seg.seg_ptr)
        
        if ret == lib.AAFRESULT_NO_MORE_OBJECTS:
            raise StopIteration()
        elif ret == lib.AAFRESULT_SUCCESS:
            return Segment(seg).resolve()
        else:
            error_check(ret)