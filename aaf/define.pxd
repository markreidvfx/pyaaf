cimport lib
from .base cimport AAFBase

cdef class MetaDef(AAFBase):
    cdef lib.IAAFMetaDefinition *meta_ptr
    
cdef class ClassDef(MetaDef):
    cdef lib.IAAFClassDef *ptr
    
cdef class PropertyDef(MetaDef):
    cdef lib.IAAFPropertyDef *ptr

# TypeDefs

cdef class TypeDef(MetaDef):
    cdef lib.IAAFTypeDef *typedef_ptr
    
cdef object resolve_typedef(TypeDef typedef)
 
cdef class TypeDefCharacter(TypeDef):
    cdef lib.IAAFTypeDefCharacter *ptr

cdef class TypeDefEnum(TypeDef):
    cdef lib.IAAFTypeDefEnum *ptr

cdef class TypeDefExtEnum(TypeDef):
    cdef lib.IAAFTypeDefExtEnum *ptr

cdef class TypeDefFixedArray(TypeDef):
    cdef lib.IAAFTypeDefFixedArray *ptr

cdef class TypeDefIndirect(TypeDef):
    cdef lib.IAAFTypeDefIndirect *ptr

# Note Opaque inherits TypeDefIndirect
cdef class TypeDefOpaque(TypeDefIndirect):
    cdef lib.IAAFTypeDefOpaque *opaque_ptr
    
cdef class TypeDefInt(TypeDef):
    cdef lib.IAAFTypeDefInt *ptr

# Note TypeDefWeakObjRef and TypeDefWeakObjRef inherit
cdef class TypeDefObjectRef(TypeDef):
    cdef lib.IAAFTypeDefObjectRef *ref_ptr
    
cdef class TypeDefStrongObjRef(TypeDefObjectRef):
    cdef lib.IAAFTypeDefStrongObjRef *ptr

cdef class TypeDefWeakObjRef(TypeDefObjectRef):
    cdef lib.IAAFTypeDefWeakObjRef *ptr

cdef class TypeDefRecord(TypeDef):
    cdef lib.IAAFTypeDefRecord *ptr

cdef class TypeDefRename(TypeDef):
    cdef lib.IAAFTypeDefRename *ptr

cdef class TypeDefSet(TypeDef):
    cdef lib.IAAFTypeDefSet *ptr

cdef class TypeDefStream(TypeDef):
    cdef lib.IAAFTypeDefStream *ptr

cdef class TypeDefString(TypeDef):
    cdef lib.IAAFTypeDefString *ptr

cdef class TypeDefVariableArray(TypeDef):
    cdef lib.IAAFTypeDefVariableArray *ptr

cdef object resolve_typedef(TypeDef typedef)
