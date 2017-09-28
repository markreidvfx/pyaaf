cdef class File(AAFBase):
    """AAF File Object. This is the entry point object for most of the API.
    It is recommended to create this object with the `aaf.open` alias.
    Creating this object is designed to be like python's native open function.

    For example. Opening existing AAF file readonly::

         f = aaf.open("/path/to/aaf_file.aaf", 'r')

    Opening new AAF file overwriting existing one::

         f = aaf.open("/path/to/aaf_file.aaf", 'w')

    Opening existing AAF in read and write::

         f = aaf.open("/path/to/aaf_file.aaf", 'rw')

    Opening New Transient in memory file::

         f = aaf.open()
         or
         f = aaf.open(None, 't')

    .. note::

        Opening AAF formatted xml files is untested

    """

    def __cinit__(self):
        self.ptr= NULL
        self.iid = lib.IID_IAAFFile

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFFile)

        AAFBase.query_interface(self, obj)

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    def __dealloc__(self):
        if self.ptr:
            ret = self.ptr.Close()
            if not (ret == lib.AAFRESULT_SUCCESS or ret == lib.AAFRESULT_NOT_OPEN):
                error_check(ret)
            self.ptr.Release()

    def __init__(self, path = None, mode = None, identification = None):
        """__init__(path, mode = 'r')

        :param str path: AAF file path, set to `None` if in opening in transient mode.
        :param str mode: Similar to python's native open function modes.
        :param dict identification: a dict of info about the application creating this file
        modes:

            * ``"r"`` readonly

            * ``"w"`` write

            * ``"rw"`` readonly or modify

            * ``"t"`` transient in memory file

        identification keys:
            * company_name str
            * product_name str
            * product_id AUID
            * product_version_string str
        """



        if path is None:
            path = ""
            mode = 't'

        if path and mode is None:
            mode = 'r'

        cdef AAFCharBuffer path_buf = AAFCharBuffer(path)
        cdef lib.HRESULT result
        cdef lib.aafCharacter *path_ptr

        mode = mode.lower()

        if mode == 'r':
            path_ptr = path_buf.get_ptr()
            with nogil:
                result = lib.AAFFileOpenExistingRead(path_ptr,
                                                     0,
                                                     &self.ptr)

            error_check(result)
        elif mode == 'rw':
            self.setup_new_file(path, mode, identification)
        elif mode == 'w':
            self.setup_new_file(path, mode, identification)
        elif mode == 't':
            self.setup_new_file(path, mode, identification)
        else:
            raise ValueError("invalid mode: %s" % mode)
        self.mode = mode
        self.query_interface()

    cdef object setup_new_file(self, path, mode='w', identification=None):

        cdef AAFCharBuffer path_buf = AAFCharBuffer(path)

        ident = identification or {}
        # not sure were this uuid came from, I might have just made it up
        cdef AUID product_id = ident.get('product_id', AUID('97e04c67-dbe6-4d11-bcd7-3a3a4253a2ef'))
        cdef AAFCharBuffer company_name = AAFCharBuffer(ident.get("company_name", "CompanyName"))
        cdef AAFCharBuffer product_name = AAFCharBuffer(ident.get("product_name", "PyAAF"))
        cdef AAFCharBuffer product_version_string = AAFCharBuffer(ident.get("product_version_string", "0.9.0"))

        productInfo = self.productInfo
        productInfo.companyName = company_name.get_ptr()
        productInfo.productName = product_name.get_ptr()
        productInfo.productVersionString = product_version_string.get_ptr()
        productInfo.productID = product_id.get_auid()

        cdef lib.aafUID_t kind = lib.kAAFFileKind_Aaf4KBinary

        if mode == 'rw' and os.path.exists(path):
            error_check(lib.AAFFileOpenExistingModify(path_buf.get_ptr(),
                                                      0, &productInfo,
                                                      &self.ptr))
            return

        elif mode == 't':
            error_check(lib.AAFFileOpenTransient(&productInfo, &self.ptr))
            return

        if os.path.exists(path):
            os.remove(path)

        name, ext = os.path.splitext(path)



        if ext.lower() in ('.xml'):
            kind = lib.kAAFFileKind_AafXmlText

        error_check(lib.AAFFileOpenNewModifyEx(path_buf.get_ptr(),
                                               &kind, 0, &productInfo,
                                               &self.ptr))
    def save(self, path = None, identification = None):
        """save(path = None)

        Save AAF file to disk. If path is ``None`` and the mode is ``"rw"`` or ``"w"`` it will overwrite or modify
        the current file. If path is supplied, a new file will be created, (Save Copy As).
        If the extension of the path is ``".xml"`` a xml file will be saved.

        :param path: optional path to new aaf file.
        :type path: `str` or `None`
        :param dict identification: a dict of info about the application creating this file

        .. note::

            If file mode is ``"t"`` or ``"r"`` and path is ``None``, nothing will happen
        """
        if not path:
            # If in 't' or 'r' mode do nothing
            if self.mode == 'rw' or self.mode == 'w':
                error_check(self.ptr.Save())
            return

        cdef File new_file = File(path, 'w', identification)

        error_check(self.ptr.SaveCopyAs(new_file.ptr))

        new_file.close()

    def close(self):
        """Close the file. A closed file cannot be read or written any more."""
        error_check(self.ptr.Close())

    property header:
        """
        :class:`Header` object for AAF file.
        """
        def __get__(self):
            cdef Header header = Header.__new__(Header)
            error_check(self.ptr.GetHeader(&header.ptr))
            header.query_interface()
            header.root = weakref.ref(self)
            return header

    property storage:
        """
        :class:`ContentStorage` object for AAF File. This has the Mob and EssenceData objects.
        """
        def __get__(self):
            return self.header.storage()

    property dictionary:
        """
        :class:`aaf.dictionary.Dictionary` for AAF file.  The dictionary property has DefinitionObject objects.
        """
        def __get__(self):
            return self.header.dictionary()

    property create:
        """
        AAFObject Factory property.  Used for creating new AAFObjects.

        example::

            # create a empty aaf file.
            f = aaf.open("/path/to/new_aaf_file.aaf", "w")

            # use create factory to make a MasterMob.
            mob = f.create.MasterMob()

            # add MasterMob object to file.
            f.storage.add_mob(mob)
        """
        def __get__(self):
            return self.header.dictionary().create
