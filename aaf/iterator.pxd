
cimport lib

cdef class BaseIterator(object):
    pass

cdef class PropIter(BaseIterator):
    cdef lib.IEnumAAFProperties *ptr
    
cdef class PropValueIter(BaseIterator):
    cdef lib.IEnumAAFPropertyValues *ptr

cdef class MobIter(BaseIterator):
    cdef lib.IEnumAAFMobs *ptr

cdef class MobSlotIter(BaseIterator):
    cdef lib.IEnumAAFMobSlots *ptr
    

    