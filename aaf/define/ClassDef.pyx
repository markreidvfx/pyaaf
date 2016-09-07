cdef class ClassDef(MetaDef):
    def __cinit__(self):
        self.ptr = NULL
        self.iid = lib.IID_IAAFClassDef

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFClassDef)

        MetaDef.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, AUID class_id not None,
                             ClassDef parent not None,
                             name not None, is_concrete=True):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_meta_instance(self, lib.AUID_AAFClassDef)

        cdef AAFCharBuffer name_buf = AAFCharBuffer(name)

        error_check(self.ptr.Initialize(class_id.auid,
                                        parent.ptr,
                                        name_buf.get_ptr(),
                                        is_concrete))

    def register_optional_propertydef(self, TypeDef property_typdef not None,
                                      AUID property_auid not None, property_name not None):

        cdef AAFCharBuffer buf = AAFCharBuffer(property_name)

        cdef PropertyDef propertydef = PropertyDef.__new__(PropertyDef)
        error_check(self.ptr.RegisterOptionalPropertyDef(property_auid.get_auid(), buf.get_ptr(), property_typdef.typedef_ptr, &propertydef.ptr))
        propertydef.query_interface()
        propertydef.root = self.root
        return propertydef

    def count_propertydefs(self):
        cdef lib.aafUInt32 count
        error_check(self.ptr.CountPropertyDefs(&count))

        return count

    def lookup_propertydef_by_id(self, AUID auid):

        cdef PropertyDef propertydef = PropertyDef.__new__(PropertyDef)

        error_check(self.ptr.LookupPropertyDef(auid.get_auid(), &propertydef.ptr))
        propertydef.query_interface()
        propertydef.root = self.root
        return propertydef

    def parent(self):
        cdef ClassDef classdef = ClassDef.__new__(ClassDef)
        result = self.ptr.GetParent(&classdef.ptr)

        if result == lib.AAFRESULT_SUCCESS:
            classdef.query_interface()
            classdef.root = self.root
            return classdef

        elif result == lib.AAFRESULT_IS_ROOT_CLASS:
            return None
        else:
            error_check(result)

    def propertydefs(self):
        cdef PropertyDefsIter propdefs_iter = PropertyDefsIter.__new__(PropertyDefsIter)
        error_check(self.ptr.GetPropertyDefs(&propdefs_iter.ptr))
        propdefs_iter.root = self.root
        return propdefs_iter

    def all_propertydefs(self):

        item = self

        while item:
            for p in item.propertydefs():
                yield p
            item = item.parent()
