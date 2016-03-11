cdef class Identification(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFIdentification
        self.auid = lib.AUID_AAFIdentification
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, self.iid)
        AAFObject.query_interface(self, obj)

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()

    def __init__(self, root, company_name = None,
                             product_name = None,
                             product_version_string = None,
                             product_id = None):
        cdef Dictionary dictionary = root.dictionary
        dictionary.create_instance(self)

        if company_name is None:
            company_name = ""

        if product_name is None:
            product_name = ""

        if product_version_string is None:
            product_version_string = ""

        cdef AUID auid = AUID()

        if product_id:
            auid = AUID(product_id)

        cdef AAFCharBuffer company_name_buf = AAFCharBuffer.__new__(AAFCharBuffer)
        cdef AAFCharBuffer product_name_buf = AAFCharBuffer.__new__(AAFCharBuffer)
        cdef AAFCharBuffer product_version_string_buf = AAFCharBuffer.__new__(AAFCharBuffer)

        company_name_buf.write_str(company_name)
        product_name_buf.write_str(product_name)
        product_version_string_buf.write_str(product_version_string)

        error_check(self.ptr.Initialize( company_name_buf.get_ptr(),
                                         product_name_buf.get_ptr(),
                                         product_version_string_buf.get_ptr(),
                                         auid.get_auid()))
