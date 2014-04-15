
cimport lib

from base cimport AAFBase, AAFObject
from dictionary cimport Dictionary

from .util cimport error_check, query_interface, register_object, lookup_object, AUID, MobID
from .iterator cimport EssenceDataIter, MobIter
from .mob cimport Mob
from .essence cimport EssenceData
from wstring cimport wstring,toWideString
import os
import weakref
        
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
    
    def __init__(self, bytes path, bytes mode = b'r'):
        """__init__(path, mode = 'r')
        
        :param str path: AAF file path, set to `None` if in opening in transient mode.
        :param str mode: Similar to python's native open function modes.

        modes:
        
            * ``"r"`` readonly
            
            * ``"w"`` write
            
            * ``"rw"`` readonly or modify
            
            * ``"t"`` transient in memory file
        
        """
        
        #self.proxy = IAAFFileProxy()
        #self.proxy = IAAFFileProxy.__new__(IAAFFileProxy)
        
        if not path:
            path = b""
        
        cdef wstring w_path = toWideString(path)
        
        mode = mode.lower()
        
        if mode == 'r':
            error_check(lib.AAFFileOpenExistingRead(w_path.c_str(),
                                                    0,
                                                    &self.ptr))
        elif mode == 'rw':
            self.setup_new_file(path, mode)
        elif mode == 'w':
            self.setup_new_file(path, mode)
        elif mode == 't':
            self.setup_new_file(path, mode)
        else:
            raise ValueError("invalid mode: %s" % mode)
        self.mode = mode
        self.query_interface()
        
    cdef object setup_new_file(self, bytes path, bytes mode=b'w'):
            
        # setup product id
        cdef lib.aafUID_t productUID
        productUID.Data1 = 0x97e04c67
        productUID.Data2 = 0xdbe6
        productUID.Data3 = 0x4d11
        for i,value in enumerate((0xbc,0xd7,0x3a,0x3a,0x42,0x53,0xa2,0xef)):
            productUID.Data4[i] = value

        productInfo = self.productInfo
        
        company_name = "CompanyName"
        product_name = "pyaaf"
        product_version_string = "0"
        
        productInfo.companyName = <lib.aafCharacter* > toWideString(company_name).c_str()
        productInfo.productName = <lib.aafCharacter* > toWideString(product_name).c_str()
        productInfo.productVersionString = <lib.aafCharacter* > toWideString(product_version_string).c_str()
        productInfo.productID = productUID
        
        cdef wstring w_path = toWideString(path)
        cdef lib.aafUID_t kind = lib.kAAFFileKind_Aaf4KBinary
        
        if mode == 'rw' and os.path.exists(path):
            #d = dict(productUID)
            error_check(lib.AAFFileOpenExistingModify(w_path.c_str(),
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
        
        error_check(lib.AAFFileOpenNewModifyEx(w_path.c_str(), 
                                               &kind, 0, &productInfo, 
                                               &self.ptr))
    def save(self,bytes path = None):
        """save(path = None)
        
        Save AAF file to disk. If path is ``None`` and the mode is ``"rw"`` or ``"w"`` it will overwrite or modify
        the current file. If path is supplied, a new file will be created, (Save Copy As).
        If the extension of the path is ``".xml"`` a xml file will be saved.
        
        :param path: optional path to new aaf file.
        :type path: `str` or `None`
        
        .. note::
        
            If file mode is ``"t"`` or ``"r"`` and path is ``None``, nothing will happen
        """
        if not path:
            # If in 't' or 'r' mode do nothing
            if self.mode == 'rw' or self.mode == 'w':
                error_check(self.ptr.Save())
            return
        
        cdef File new_file = File(path, 'w')
        
        error_check(self.ptr.SaveCopyAs(new_file.ptr))
        
        return new_file

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
            header.root = weakref.proxy(self)
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

cdef class Header(AAFObject):
    """
    Header object for AAF File. This object is mainly used to get the 
    :class:`aaf.dictionary.Dictionary` and 
    :class:`ContentStorage`  objects for the AAF file
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFHeader
        self.auid = lib.AUID_AAFHeader
        self.ptr = NULL
    
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFHeader)
            
        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def dictionary(self):
        """
        :returns: :class:`aaf.dictionary.Dictionary`
        """
        cdef Dictionary dictionary = Dictionary.__new__(Dictionary)
        error_check(self.ptr.GetDictionary(&dictionary.ptr))
        dictionary.query_interface()
        dictionary.root = self.root
        return dictionary

    def storage(self):
        """
        :returns: :class:`aaf.storage.ContentStorage`
        """
        cdef ContentStorage content_storage = ContentStorage.__new__(ContentStorage)
        error_check(self.ptr.GetContentStorage(&content_storage.ptr))
        content_storage.query_interface()
        content_storage.root = self.root
        return content_storage
    
         
cdef class ContentStorage(AAFObject):
    """
    This object has all Mobs and Essence Data in the file 
    """
    def __cinit__(self):
        self.iid = lib.IID_IAAFContentStorage
        self.auid = lib.AUID_AAFContentStorage
        self.ptr = NULL

    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr

    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFContentStorage)
            
        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def count_mobs(self):
        """
        Total number of mobs in AAF File
        
        :returns: int
        """
        cdef lib.aafUInt32 mobCount
        error_check(self.ptr.CountMobs(lib.kAAFAllMob, &mobCount))
        return mobCount
    
    def add_mob(self, Mob mob not None):
        """add_mob(mob)
        
        Add a :class:`aaf.mob.Mob` object to ContentStorage
        
        :param aaf.mob.Mob mob: Mob object to add.
        """
        error_check(self.ptr.AddMob(mob.ptr))
        
    def remove_mob(self, Mob mob not None):
        """remove_mob(mob)
        
        Remove a :class:`aaf.mob.Mob` object from ContentStorage.
        
        :param aaf.mob.Mob mob: Mob object to remove.
        """
        
        error_check(self.ptr.RemoveMob(mob.ptr))
        
    def lookup_mob(self, mobID):
        """lookup_mob(mobID)
        
        Looks up the Mob that matches the given mob id.
        
        :param mobID: 9d of :class:`aaf.mob.Mob` to lookup.
        :type mobID: :class:`aaf.util.MobID` or :class:`str`
        :returns: :class:`aaf.mob.Mob`
        """
        
        cdef Mob mob = Mob.__new__(Mob)
        cdef MobID mobID_obj = MobID(mobID)
        
        error_check(self.ptr.LookupMob(mobID_obj.mobID, &mob.ptr))
        mob.query_interface()
        mob.root = self.root
        return mob.resolve()
        

    def mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter`` that iterates over all :class:`aaf.mob.Mob` objects in the AAF file.
        
        :returns: :class:`aaf.iterator.MobIter`
        """
        
        cdef MobIter mob_iter = MobIter.__new__(MobIter)
        
        cdef lib.aafSearchCrit_t search_crit
        
        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFAllMob

        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.mobs
        mob_iter.root = self.root
        return mob_iter
    
    def master_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.MasterMob` objects in the AAF file.
        
        :returns: :class:`aaf.iterator.MobIter`
        """
        
        cdef MobIter mob_iter = MobIter.__new__(MobIter)
        
        cdef lib.aafSearchCrit_t search_crit
        
        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFMasterMob
        
        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.master_mobs
        mob_iter.root = self.root
        return mob_iter
    
    def composition_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.CompositionMob` objects in the AAF file.
        
        :returns: :class:`aaf.iterator.MobIter`
        """
        
        cdef MobIter mob_iter = MobIter.__new__(MobIter)
        
        cdef lib.aafSearchCrit_t search_crit
        
        search_crit.searchTag = lib.kAAFByMobKind
        search_crit.tags.mobKind = lib.kAAFCompMob
        
        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.composition_mobs
        mob_iter.root = self.root
        return mob_iter
    
    def toplevel_mobs(self):
        """
        Returns a :class:`aaf.iterator.MobIter` that iterates over all :class:`aaf.mob.CompositionMob` 
        objects in the AAF file with ``"UsageType""`` property set to ``"Usage_TopLevel"``. 
        
        :returns: :class:`aaf.iterator.MobIter`
        """
        cdef MobIter mob_iter = MobIter.__new__(MobIter)
        
        cdef lib.aafSearchCrit_t search_crit
        
        search_crit.searchTag = lib.kAAFByCompositionMobUsageCode
        search_crit.tags.usageCode = lib.kAAFUsage_TopLevel
        
        error_check(self.ptr.GetMobs(&search_crit, &mob_iter.ptr))
        mob_iter._clone_iter = self.toplevel_mobs
        mob_iter.root = self.root
        return mob_iter
    
    def essence_data(self):
        """
        Returns a :class:`aaf.iterator.EssenceDataIter` that iterates over all 
        embedded :class:`aaf.essence.EssenceData` in AAF file.
        
        :returns: :class:`aaf.iterator.EssenceDataIter`
        """
        
        cdef EssenceDataIter data_iter = EssenceDataIter.__new__(EssenceDataIter)
        error_check(self.ptr.EnumEssenceData(&data_iter.ptr))
        data_iter.root = self.root
        return data_iter
    
    def add_essence_data(self, EssenceData data not None):
        error_check(self.ptr.AddEssenceData(data.ptr))
    
    def remove_essence_data(self, EssenceData data not None):
        error_check(self.ptr.RemoveEssenceData(data.ptr))
    
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
    
        
register_object(Header)
register_object(ContentStorage)
register_object(Identification)

# Handy alias.
open = File
