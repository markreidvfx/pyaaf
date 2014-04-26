
cimport lib

from .base cimport AAFBase, AAFObject
from .define cimport DefObject, TypeDef, DataDef, ContainerDef, OperationDef, ParameterDef, InterpolationDef, TypeDefMap, ContainerDefMap, DataDefMap, ExtEnumDefMap, InterpolationDefMap
from .util cimport error_check, query_interface, register_object, lookup_object, AUID
from .iterator cimport CodecDefIter, ClassDefIter, TypeDefIter, PluginDefIter, KLVDataDefIter, LoadedPluginIter
from wstring cimport wstring,toWideString

import traceback

cdef class Dictionary(AAFObject):
    def __cinit__(self):
        self.iid = lib.IID_IAAFDictionary
        self.auid = lib.AUID_AAFDictionary
        self.ptr = NULL
        self.ptr2 = NULL
        self.create = CreateInstance(self)
        
    cdef lib.IUnknown **get_ptr(self):
        return <lib.IUnknown **> &self.ptr
    
    cdef query_interface(self, AAFBase obj = None):
        if obj is None:
            obj = self
        else:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr, lib.IID_IAAFDictionary)
        
        if not self.ptr2:
            query_interface(obj.get_ptr(), <lib.IUnknown **> &self.ptr2, lib.IID_IAAFDictionary2)
            
        AAFObject.query_interface(self, obj)
    
    def __dealloc__(self):
        if self.ptr:
            self.ptr.Release()
        
        if self.ptr2:
            self.ptr2.Release()
            
    cdef create_instance(self, AAFObject obj):
        error_check(self.ptr.CreateInstance(obj.auid, obj.iid, obj.get_ptr()))
        obj.query_interface()
        obj.root = self.root
        
    def register_def(self, DefObject def_obj not None):
        cdef OperationDef op_def
        cdef ParameterDef param_def
        cdef InterpolationDef interp_def
        
        if isinstance(def_obj, OperationDef):
            op_def = def_obj
            error_check(self.ptr.RegisterOperationDef(op_def.ptr))
        elif isinstance(def_obj, ParameterDef):
            param_def = def_obj
            error_check(self.ptr.RegisterParameterDef(param_def.ptr))
        elif isinstance(def_obj, InterpolationDef):
            interp_def = def_obj
            error_check(self.ptr.RegisterInterpolationDef(interp_def.ptr))
        else:
            raise NotImplementedError("Not implented for def type")
        
    def lookup_datadef(self, bytes name):
        cdef AUID auid = DataDefMap[name.lower()]
        cdef DataDef definition =  DataDef.__new__(DataDef)
        error_check(self.ptr.LookupDataDef(auid.get_auid(), &definition.ptr ))
        definition.query_interface()
        definition.root = self.root
        return definition
    def lookup_typedef(self, bytes name not None):
        cdef AUID auid = TypeDefMap[name.lower()]
        cdef TypeDef definition = TypeDef.__new__(TypeDef)
        error_check(self.ptr.LookupTypeDef(auid.get_auid(), &definition.typedef_ptr))
        definition.query_interface()
        definition.root = self.root
        return definition.resolve()
    
    def lookup_containerdef(self, bytes name):
        cdef AUID auid = ContainerDefMap[name.lower()]
        cdef ContainerDef definition = ContainerDef.__new__(ContainerDef)
        error_check(self.ptr.LookupContainerDef(auid.get_auid(), &definition.ptr ))
        definition.query_interface()
        definition.root = self.root
        return definition
    
    def lookup_interpolatordef(self, bytes name):
        cdef PluginManager manager = PluginManager()
        
        cdef AUID auid = InterpolationDefMap[name.lower()]
        
        #cdef InterpolationDef definition = InterpolationDef.__new__(InterpolationDef)
        cdef DefObject definition = DefObject.__new__(DefObject)
        error_check(manager.ptr.CreatePluginDefinition(auid.get_auid(), self.ptr, &definition.defobject_ptr))
        return definition.resolve()

    def class_defs(self):
        cdef ClassDefIter def_iter = ClassDefIter.__new__(ClassDefIter)
        error_check(self.ptr.GetClassDefs(&def_iter.ptr))
        def_iter.root = self.root
        return def_iter

    def codec_defs(self):
        cdef CodecDefIter def_iter = CodecDefIter.__new__(CodecDefIter)
        error_check(self.ptr.GetCodecDefs(&def_iter.ptr))
        def_iter.root = self.root
        return def_iter
    
    def type_defs(self):
        cdef TypeDefIter def_iter = TypeDefIter.__new__(TypeDefIter)
        error_check(self.ptr.GetTypeDefs(&def_iter.ptr))
        def_iter.root = self.root
        return def_iter
    
    def plugin_defs(self):
        cdef PluginDefIter def_iter = PluginDefIter.__new__(PluginDefIter)
        error_check(self.ptr.GetPluginDefs(&def_iter.ptr))
        def_iter.root = self.root
        return def_iter
     
    def klvdata_defs(self):
        cdef KLVDataDefIter def_iter = KLVDataDefIter.__new__(KLVDataDefIter)
        error_check(self.ptr2.GetKLVDataDefs(&def_iter.ptr))
        def_iter.root = self.root
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

        cdef LoadedPluginIter plugin_iter = LoadedPluginIter.__new__(LoadedPluginIter)
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
        
        # first try and use init method all classes going forward should
        # implement this instead of old depricated initialize method
        
        try:
            return obj_type(self.dictionary.root, *args, **kwargs)
        except:
            pass
        
        # This code wiil get remove once __init__ is implemented on objects the
        # curretnly have initialize
        
        dummy = obj_type.__new__(obj_type)
        
        cdef AUID iid_obj = dummy.class_iid
        cdef AUID auid_obj = dummy.class_auid

        cdef lib.GUID iid = iid_obj.get_iid()
        cdef lib.aafUID_t auid = auid_obj.get_auid()
        
        cdef AAFBase unknown = AAFBase.__new__(AAFBase)
                
        error_check(self.dictionary.ptr.CreateInstance(auid, iid,
                                         &unknown.base_ptr))
        
        cdef AAFBase obj = obj_type.__new__(obj_type)
        
        obj.query_interface(unknown)
        obj.root = self.dictionary.root
        
        obj.initialize(*args, **kwargs)

        return obj
        
        
    def create_instance(self, *args, **kwargs):
        
        return self.from_name( self.class_name, *args, **kwargs)
    
register_object(Dictionary)
