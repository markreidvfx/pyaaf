
cimport lib

from .base cimport AAFBase, AAFObject, AUID
from .define cimport DataDef, ContainerDef, ContainerDefMap, DataDefMap, ExtEnumDefMap
from .util cimport error_check, query_interface, register_object, lookup_object
from .iterator cimport CodecDefIter, ClassDefIter, TypeDefIter, PluginDefIter, KLVDataDefIter, LoadedPluginIter
from wstring cimport wstring,toWideString

cdef class Dictionary(AAFObject):
    def __init__(self, AAFBase obj = None):
        super(Dictionary, self).__init__(obj)
        self.iid = lib.IID_IAAFDictionary
        self.auid = lib.AUID_AAFDictionary
        self.ptr = NULL
        self.ptr2 = NULL
        self.create = CreateInstance(self)
        if not obj:
            return
        
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDictionary)
        query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr2, lib.IID_IAAFDictionary2)
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
    def lookup_datadef(self, bytes name):
        cdef AUID auid = DataDefMap[name.lower()]
        cdef DataDef definition =  DataDef()
        error_check(self.ptr.LookupDataDef(auid.get_auid(), &definition.ptr ))
        return DataDef(definition)
    
    def lookup_containerdef(self, bytes name):
        cdef AUID auid = ContainerDefMap[name.lower()]
        cdef ContainerDef definition = ContainerDef()
        error_check(self.ptr.LookupContainerDef(auid.get_auid(), &definition.ptr ))
        return ContainerDef(definition)
        
    def class_defs(self):
        cdef ClassDefIter def_iter = ClassDefIter()
        error_check(self.ptr.GetClassDefs(&def_iter.ptr))
        return def_iter

    def codec_defs(self):
        cdef CodecDefIter def_iter = CodecDefIter()
        error_check(self.ptr.GetCodecDefs(&def_iter.ptr))
        return def_iter
    
    def type_defs(self):
        cdef TypeDefIter def_iter = TypeDefIter()
        error_check(self.ptr.GetTypeDefs(&def_iter.ptr))
        return def_iter
    
    def plugin_defs(self):
        cdef PluginDefIter def_iter = PluginDefIter()
        error_check(self.ptr.GetPluginDefs(&def_iter.ptr))
        return def_iter
     
    def klvdata_defs(self):
        cdef KLVDataDefIter def_iter = KLVDataDefIter()
        error_check(self.ptr2.GetKLVDataDefs(&def_iter.ptr))
        return def_iter
     
    def operation_defs(self):
        prop = self.get('OperationDefinitions', None)
        if prop:
            return prop.value
        return []
    
    def parameter_defs(self):
        prop = self.get('ParameterDefinitions', [])
        if prop:
            return prop.value
        return []

    def data_defs(self):
        prop = self.get('DataDefinitions', [])
        if prop:
            return prop.value
        return []
    
    def container_defs(self):
        prop = self.get('ContainerDefinitions', [])
        if prop:
            return prop.value
        return []
    
    def interpolation_defs(self):
        prop = self.get('InterpolationDefinitions', [])
        if prop:
            return prop.value
        return []
                
    def taggedvalue_defs(self):
        prop = self.get('TaggedValueDefinitions', [])
        if prop:
            return prop.value
        return []
        
cdef class PluginManager(object):
    def __init__(self):
        error_check(lib.AAFGetPluginManager(&self.ptr))

    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
            
    def loaded_plugins(self, bytes category):
        """
        categories are:
            -codec
            -effect
            -interpolation
        """

        cdef LoadedPluginIter plugin_iter = LoadedPluginIter()
        cdef AUID cat = ExtEnumDefMap["plugincategory_%s" % category.lower()]
        error_check(self.ptr.EnumLoadedPlugins(cat.get_auid(), &plugin_iter.ptr))
        
        return plugin_iter
            
cdef class CreateInstance(object):

    def __init__(self, Dictionary dictionary):
        self.class_name = None
        self.dictionary = dictionary
        
    def __getattr__(self, name):
        self.class_name = name
        
        return self.create_instance
    
    def from_name(self, bytes name, *args, **kwargs):
        
        obj_type = lookup_object(name)
        
        
        dummy = obj_type()
        
        cdef AUID iid_obj = dummy.class_iid
        cdef AUID auid_obj = dummy.class_auid

        cdef lib.GUID iid = iid_obj.get_iid()
        cdef lib.aafUID_t auid = auid_obj.get_auid()
        
        cdef AAFBase unknown = AAFBase()
                
        error_check(self.dictionary.ptr.CreateInstance(auid, iid,
                                         &unknown.base_ptr))
        
        obj = obj_type(unknown)
        
        obj.initialize(*args, **kwargs)

        return obj
        
        
    def create_instance(self, *args, **kwargs):
        
        return self.from_name( self.class_name, *args, **kwargs)
    
register_object(Dictionary)
