
cdef extern from "AAFStoredObjectIDs.h":
    pass

cdef extern from "AAF.h" nogil:

    ctypedef struct GUID:
        DWORD Data1
        WORD Data2
        WORD Data3
        BYTE Data4[8]

    cdef GUID IID_IUnknown
    cdef cppclass IUnknown:
        HRESULT QueryInterface(GUID riid, void **ppvObj)
        HRESULT AddRef()
        HRESULT Release()

    cdef aafUID_t AUID_AAFObject
    cdef GUID IID_IAAFObject
    cdef cppclass IAAFObject(IUnknown):
        HRESULT CountProperties(aafUInt32 *pCount)
        HRESULT GetDefinition(IAAFClassDef **ppClassDef)
        HRESULT GetProperties(IEnumAAFProperties **ppEnum)
        HRESULT GetDictionary(IAAFDictionary **ppDictionary)
        HRESULT GetPropertyValue(IAAFPropertyDef * pPropDef, IAAFPropertyValue ** ppPropVal)
        HRESULT SetPropertyValue(IAAFPropertyDef * pPropDef, IAAFPropertyValue * pPropVal)
        HRESULT IsPropertyPresent(IAAFPropertyDef * pPropDef, aafBoolean_t*  pResult)
        HRESULT CreateOptionalPropertyValue(IAAFPropertyDef * pPropDef, IAAFPropertyValue ** ppPropVal)
        HRESULT RemoveOptionalProperty(IAAFPropertyDef * pPropDef)

    cdef GUID IID_IAAFPluginManager
    cdef cppclass IAAFPluginManager(IUnknown):
        HRESULT RegisterSharedPlugins()
        HRESULT EnumLoadedPlugins(
            aafUID_t &categoryID,
            IEnumAAFLoadedPlugins ** ppEnum
        )
        HRESULT CreatePluginDefinition(
            aafUID_t&  pluginDefID,
            IAAFDictionary * pDictionary,
            IAAFDefObject**  ppPluginDef,
        )
        HRESULT CreateInstance(
            GUID  & rclsid,
            IUnknown *  pUnkOuter,
            GUID  &riid,
            void **  ppPlugin
        )


    cdef aafUID_t AUID_AAFFile
    cdef GUID IID_IAAFFile
    cdef cppclass IAAFFile(IUnknown):
        HRESULT Open()
        HRESULT SaveCopyAs(IAAFFile* pDestFile)
        HRESULT Save()
        HRESULT Close()
        HRESULT GetHeader(IAAFHeader **ppHeader)

    cdef aafUID_t AUID_AAFHeader
    cdef GUID IID_IAAFHeader
    cdef cppclass IAAFHeader(IUnknown):
        HRESULT GetDictionary(IAAFDictionary **ppDictionary)
        HRESULT GetContentStorage(IAAFContentStorage **ppStorage)
        HRESULT AddMob(IAAFMob * pMob)

    cdef aafUID_t AUID_AAFHeader2
    cdef GUID IID_IAAFHeader2
    cdef cppclass IAAFHeader2(IUnknown):
        HRESULT GetOperationalPattern(aafUID_t *  pOperationalPatternID)
        HRESULT SetOperationalPattern(aafUID_t &  operationalPatternID)

    cdef aafUID_t AUID_AAFDictionary
    cdef GUID IID_IAAFDictionary
    cdef cppclass IAAFDictionary(IUnknown):
        HRESULT CreateInstance(aafUID_t id, GUID riid, IUnknown ** ppvObject)
        HRESULT CreateMetaInstance(aafUID_t & id, GUID riid, IUnknown ** ppMetaDefinition)
        HRESULT LookupClassDef(aafUID_constref  classId, IAAFClassDef ** ppClassDef)
        HRESULT LookupTypeDef(aafUID_t &dataDefinitionId, IAAFTypeDef ** ppTypeDef)
        HRESULT LookupDataDef(aafUID_t &dataDefinitionId, IAAFDataDef ** ppDataDef)
        HRESULT LookupCodecDef(aafUID_t &dataDefinitionId, IAAFCodecDef ** ppParmDef)
        HRESULT LookupContainerDef(aafUID_t &dataDefinitionId, IAAFContainerDef ** ppParmDef)
        HRESULT RegisterTypeDef(IAAFTypeDef * pTypeDef)
        HRESULT RegisterOperationDef(IAAFOperationDef * pOperationDef)
        HRESULT RegisterParameterDef(IAAFParameterDef * pParmDef)
        HRESULT RegisterCodecDef(IAAFCodecDef *pParmDef)
        HRESULT RegisterContainerDef(IAAFContainerDef * pParmDef)
        HRESULT RegisterInterpolationDef(IAAFInterpolationDef * pInterpolationDef)
        HRESULT GetClassDefs(IEnumAAFClassDefs ** ppEnum)
        HRESULT GetCodecDefs(IEnumAAFCodecDefs ** ppEnum)
        HRESULT GetTypeDefs(IEnumAAFTypeDefs ** ppEnum)
        HRESULT GetPluginDefs(IEnumAAFPluginDefs ** ppEnum)

    cdef aafUID_t AUID_AAFDictionary2
    cdef GUID IID_IAAFDictionary2
    cdef cppclass IAAFDictionary2(IUnknown):
        HRESULT GetKLVDataDefs(IEnumAAFKLVDataDefs ** ppEnum)
        HRESULT RegisterTaggedValueDef(IAAFTaggedValueDefinition * pDef)
        HRESULT LookupTaggedValueDef(aafUID_t &defId, IAAFTaggedValueDefinition ** ppDef)

    cdef aafUID_t AUID_AAFContentStorage
    cdef GUID IID_IAAFContentStorage
    cdef cppclass IAAFContentStorage(IUnknown):
        HRESULT CountMobs(
            aafMobKind_t mobKind,
            aafNumSlots_t *pResult
        )
        HRESULT GetMobs(
            aafSearchCrit_t *pSearchCriteria,
            IEnumAAFMobs **ppEnum
        )
        HRESULT AddMob(IAAFMob * pMob)
        HRESULT RemoveMob(IAAFMob * pMob)
        HRESULT LookupMob(
            aafMobID_t &mobID,
            IAAFMob ** ppMob
        )
        HRESULT CountEssenceData(aafUInt32 *pResult)
        HRESULT IsEssenceDataPresent(
            aafMobID_t &mobID,
            aafFileFormat_t fmt,
            aafBoolean_t *  pResult
        )
        HRESULT EnumEssenceData(IEnumAAFEssenceData ** ppEnum)
        HRESULT AddEssenceData(IAAFEssenceData * pEssenceData)
        HRESULT RemoveEssenceData(IAAFEssenceData * pEssenceData)
        HRESULT LookupEssenceData(
            aafMobID_t &mobID,
            IAAFEssenceData ** ppEssenceData
        )

    cdef aafUID_t AUID_AAFIdentification
    cdef GUID IID_IAAFIdentification
    cdef cppclass IAAFIdentification(IUnknown):
        HRESULT Initialize(aafCharacter *companyName,
                           aafCharacter *productName,
                           aafCharacter *productVersionString,
                           aafUID_t  &productID)

    # Properties

    cdef GUID IID_IAAFProperty
    cdef cppclass IAAFProperty(IUnknown):
        HRESULT GetDefinition(IAAFPropertyDef **ppPropDef)
        HRESULT GetValue(IAAFPropertyValue **ppValue)

    cdef GUID IID_IAAFPropertyValue
    cdef cppclass IAAFPropertyValue(IUnknown):
        HRESULT GetType(IAAFTypeDef **ppTypeDef)
        HRESULT IsDefinedType(aafBoolean_t *  pIsDefined)

    cdef aafUID_t AUID_AAFTaggedValue
    cdef GUID IID_IAAFTaggedValue
    cdef cppclass IAAFTaggedValue(IUnknown):
        HRESULT Initialize(
            aafCharacter * pName,
            IAAFTypeDef * pTypeDef,
            aafUInt32  valueSize,
            aafDataBuffer_t  pValue
        )
        HRESULT GetTypeDefinition(IAAFTypeDef ** ppTypeDef)
        HRESULT SetValue(
            aafUInt32  valueSize,
            aafDataBuffer_t  pValue
        )


    # MetaDefinitions

    cdef GUID IID_IAAFMetaDefinition
    cdef cppclass IAAFMetaDefinition(IUnknown):
        HRESULT Initialize(aafUID_constref  id, aafCharacter * pName, aafCharacter * pDescription)
        HRESULT GetAUID(aafUID_t *  pAuid)
        HRESULT SetName(aafCharacter *pName)
        HRESULT GetName(aafCharacter *pName, aafUInt32  bufSize)
        HRESULT GetNameBufLen(aafUInt32 *pBufSize)
        HRESULT SetDescription(aafCharacter *pDescription)
        HRESULT GetDescription(aafCharacter *pDescription, aafUInt32  bufSize)
        HRESULT GetDescriptionBufLen(aafUInt32 *  pBufSize)

    cdef GUID IID_IAAFClassDef
    cdef cppclass IAAFClassDef(IUnknown):
        HRESULT Initialize(
            aafUID_constref  classID,
            IAAFClassDef * pParentClass,
            aafCharacter * pClassName,
            aafBoolean_t  isConcrete
        )
        HRESULT GetPropertyDefs(IEnumAAFPropertyDefs ** ppEnum)
        HRESULT CountPropertyDefs(aafUInt32 *  pCount)
        HRESULT RegisterNewPropertyDef(
            aafUID_constref  id,
            aafCharacter * pName,
            IAAFTypeDef * pTypeDef,
            aafBoolean_t  isOptional,
            aafBoolean_t  isUniqueIdentifier,
            IAAFPropertyDef ** ppPropDef
        )
        HRESULT RegisterOptionalPropertyDef(
            aafUID_constref  id,
            aafCharacter  * pName,
            IAAFTypeDef * pTypeDef,
            IAAFPropertyDef ** ppPropDef
        )
        HRESULT LookupPropertyDef(aafUID_t & propID, IAAFPropertyDef ** ppPropDef)
        HRESULT GetName(aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetNameBufLen(aafUInt32 *  pBufSize)
        HRESULT GetParent(IAAFClassDef ** ppClassDef)
        HRESULT IsConcrete(aafBoolean_t*  pResult)
        HRESULT IsRoot(aafBoolean_t*  isRoot)
        HRESULT IsUniquelyIdentified(aafBoolean_t*  pIsUniquelyIdentified)
        HRESULT GetUniqueIdentifier(IAAFPropertyDef ** ppUniqueIdentifier)
        HRESULT CreateInstance(GUID riid, IUnknown ** ppvObject)


    cdef GUID IID_IAAFPropertyDef
    cdef cppclass IAAFPropertyDef(IUnknown):
        HRESULT GetTypeDef(IAAFTypeDef ** ppTypeDef)
        HRESULT GetIsOptional(aafBoolean_t *  pIsOptional)
        HRESULT GetIsUniqueIdentifier(aafBoolean_t *  pIsUniqueIdentifier)
        HRESULT GetNameBufLen(aafUInt32 *  pBufSize)
        HRESULT GetName(aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT SetDescription(aafCharacter *  pDescription)
        HRESULT GetDescriptionBufLen(aafUInt32 *  pBufSize)
        HRESULT GetDescription( aafCharacter *  pDescription, aafUInt32  bufSize)


    cdef GUID IID_IAAFTypeDef
    cdef cppclass IAAFTypeDef(IUnknown):
        HRESULT GetTypeCategory(eAAFTypeCategory_t *pTid)
        HRESULT RawAccessType(IAAFTypeDef ** ppRawTypeDef)

    cdef aafUID_t AUID_AAFTypeDefCharacter
    cdef GUID IID_IAAFTypeDefCharacter
    cdef cppclass IAAFTypeDefCharacter(IUnknown):
        HRESULT CreateValueFromCharacter(aafCharacter  character, IAAFPropertyValue ** ppCharacterValue)
        HRESULT GetCharacter(IAAFPropertyValue * pCharacterValue, aafCharacter *  pCharacter)
        HRESULT SetCharacter(IAAFPropertyValue * pCharacterValue, aafCharacter  character)

    cdef aafUID_t AUID_AAFTypeDefEnum
    cdef GUID IID_IAAFTypeDefEnum
    cdef cppclass IAAFTypeDefEnum(IUnknown):
        HRESULT Initialize(
            aafUID_constref  id,
            IAAFTypeDef * pType,
            aafInt64 *  pElementValues,
            aafString_t *  pElementNames,
            aafUInt32  numElems,
            aafCharacter *pTypeName
        )
        HRESULT CreateValueFromName(aafCharacter *Name, IAAFPropertyValue ** ppPropVal)
        HRESULT GetElementType(IAAFTypeDef ** ppTypeDef)
        HRESULT GetElementValue(aafUInt32  index, aafInt64 *  pOutValue)
        HRESULT GetElementName(aafUInt32  index, aafCharacter *  pOutValue, aafUInt32  bufSize)
        HRESULT GetElementNameBufLen(aafUInt32  index, aafUInt32 *  pLen)
        HRESULT CountElements(aafUInt32 *pCount)
        HRESULT GetNameFromValue(IAAFPropertyValue * pValue, aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetNameBufLenFromValue(IAAFPropertyValue * pValue, aafUInt32 *  pLen)
        HRESULT GetNameFromInteger(aafInt64  value, aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetNameBufLenFromInteger(aafInt64  value, aafUInt32 *  pLen)
        HRESULT GetIntegerValue(IAAFPropertyValue * pPropValIn, aafInt64 *  pValueOut)
        HRESULT SetIntegerValue(IAAFPropertyValue *pPropValToSet, aafInt64  valueIn)
        HRESULT RegisterSize(aafUInt32  enumSize)

    cdef aafUID_t AUID_AAFTypeDefExtEnum
    cdef GUID IID_IAAFTypeDefExtEnum
    cdef cppclass IAAFTypeDefExtEnum(IUnknown):
        HRESULT Initialize(aafUID_constref  id, aafCharacter *pTypeName)
        HRESULT CreateValueFromName(aafCharacter *Name, IAAFPropertyValue ** ppPropVal)
        HRESULT CountElements(aafUInt32 *pCount)
        HRESULT GetElementValue(aafUInt32  index, aafUID_t *  pOutValue)
        HRESULT GetElementName(aafUInt32  index, aafCharacter *  pOutValue, aafUInt32  bufSize)
        HRESULT GetElementNameBufLen(aafUInt32  index, aafUInt32 *  pLen)
        HRESULT GetNameFromValue(IAAFPropertyValue * pValue, aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetNameBufLenFromValue(IAAFPropertyValue * pValue, aafUInt32 *  pLen)
        HRESULT GetNameFromAUID(aafUID_constref  value, aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetNameBufLenFromAUID(aafUID_constref  value, aafUInt32 *  pLen)
        HRESULT GetAUIDValue(IAAFPropertyValue * pPropValIn, aafUID_t *  pValueOut)
        HRESULT SetAUIDValue(IAAFPropertyValue * pPropValToSet, aafUID_constref  valueIn)
        HRESULT AppendElement(aafUID_constref  value, aafCharacter *pName)

    cdef aafUID_t AUID_AAFTypeDefFixedArray
    cdef GUID IID_IAAFTypeDefFixedArray
    cdef cppclass IAAFTypeDefFixedArray(IUnknown):
        HRESULT Initialize(
            aafUID_constref  id,
            IAAFTypeDef * pTypeDef,
            aafUInt32  nElements,
            aafCharacter *pTypeName
        )
        HRESULT GetType(IAAFTypeDef ** ppTypeDef)
        HRESULT GetCount(aafUInt32 *  pCount)
        HRESULT CreateValueFromValues(IAAFPropertyValue ** ppElementValues, aafUInt32  numElements, IAAFPropertyValue ** ppPropVal)
        HRESULT CreateValueFromCArray(aafMemPtr_t  pInitData, aafUInt32  initDataSize, IAAFPropertyValue ** ppPropVal)
        HRESULT GetElementValue(IAAFPropertyValue * pInPropVal, aafUInt32  index, IAAFPropertyValue ** ppOutPropVal)
        HRESULT GetCArray(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT SetElementValue(IAAFPropertyValue * pPropVal, aafUInt32  index, IAAFPropertyValue * pMemberPropVal)
        HRESULT SetCArray(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT GetElements(IAAFPropertyValue *PSetPropVal, IEnumAAFPropertyValues ** ppEnum)

    cdef aafUID_t AUID_AAFTypeDefIndirect
    cdef GUID IID_IAAFTypeDefIndirect
    cdef cppclass IAAFTypeDefIndirect(IUnknown):
        HRESULT CreateValueFromActualValue(IAAFPropertyValue * pActualValue, IAAFPropertyValue ** ppIndirectPropertyValue)
        HRESULT CreateValueFromActualData(
            IAAFTypeDef * pActualType,
            aafMemPtr_t  pInitData,
            aafUInt32  initDataSize,
            IAAFPropertyValue ** ppIndirectPropertyValue
        )
        HRESULT GetActualValue(IAAFPropertyValue * pIndirectPropertyValue, IAAFPropertyValue ** ppActualPropertyValue)
        HRESULT GetActualSize(IAAFPropertyValue * pIndirectPropertyValue, aafUInt32 *  pActualSize)
        HRESULT GetActualType(IAAFPropertyValue * pIndirectPropertyValue, IAAFTypeDef ** pActualType)
        HRESULT GetActualData(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)

    cdef aafUID_t AUID_AAFTypeDefInt
    cdef GUID IID_IAAFTypeDefInt
    cdef cppclass IAAFTypeDefInt(IUnknown):
        HRESULT Initialize(
            aafUID_constref  id,
            aafUInt8  intSize,
            aafBoolean_t  isSigned,
            aafCharacter *pTypeName
        )
        HRESULT CreateValue(aafMemPtr_t  pVal, aafUInt32  valSize, IAAFPropertyValue ** ppPropVal)
        HRESULT GetInteger(IAAFPropertyValue *pPropVal, aafMemPtr_t  pVal, aafUInt32 valSize)
        HRESULT SetInteger(IAAFPropertyValue * pPropVal, aafMemPtr_t  pVal, aafUInt32  valSize)
        HRESULT GetSize(aafUInt32 *pSize)
        HRESULT IsSigned(aafBoolean_t *pSigned)

    cdef aafUID_t AUID_AAFTypeDefObjectRef
    cdef GUID IID_IAAFTypeDefObjectRef
    cdef cppclass IAAFTypeDefObjectRef(IUnknown):
        HRESULT GetObjectType(IAAFClassDef ** ppObjType)
        HRESULT CreateValue(IUnknown * pObj, IAAFPropertyValue ** ppPropVal)
        HRESULT GetObject(IAAFPropertyValue * pPropVal, GUID iid, IUnknown ** ppObject)
        HRESULT SetObject(IAAFPropertyValue * pPropVal, IUnknown * pObject)

    cdef aafUID_t AUID_AAFTypeDefOpaque
    cdef GUID IID_IAAFTypeDefOpaque
    cdef cppclass IAAFTypeDefOpaque(IUnknown):
        HRESULT GetActualTypeID(IAAFPropertyValue * pOpaquePropertyValue, aafUID_t *  pActualTypeID)
        HRESULT GetHandle(
            IAAFPropertyValue * pPropVal,
            aafUInt32  handleSize,
            aafDataBuffer_t  pHandle,
            aafUInt32*  bytesRead
        )
        HRESULT GetHandleBufLen(IAAFPropertyValue * pPropVal, aafUInt32 *  pLen)
        HRESULT SetHandle(IAAFPropertyValue * pPropVal, aafUInt32  handleSize, aafDataBuffer_t  pHandle)
        HRESULT CreateValueFromHandle(aafMemPtr_t  pInitData, aafUInt32  initDataSize, IAAFPropertyValue ** ppOpaquePropertyValue)

    cdef aafUID_t AUID_AAFTypeDefRecord
    cdef GUID IID_IAAFTypeDefRecord
    cdef cppclass IAAFTypeDefRecord(IUnknown):
        HRESULT Initialize(
            aafUID_constref  id,
            IAAFTypeDef ** ppMemberTypes,
            aafCharacter **  pMemberNames,
            aafUInt32  numMembers,
            aafCharacter *pTypeName
        )
        HRESULT GetMemberType(aafUInt32  index, IAAFTypeDef **ppTypeDef)
        HRESULT GetMemberName(aafUInt32  index, aafCharacter *  pName, aafUInt32  bufSize)
        HRESULT GetMemberNameBufLen(aafUInt32  index, aafUInt32 *pLen)
        HRESULT CreateValueFromValues(IAAFPropertyValue ** pMemberValues, aafUInt32  numMembers, IAAFPropertyValue ** ppPropVal)
        HRESULT CreateValueFromStruct(aafMemPtr_t  pInitData, aafUInt32  initDataSize, IAAFPropertyValue ** ppPropVal)
        HRESULT GetValue(IAAFPropertyValue * pInPropVal, aafUInt32  index, IAAFPropertyValue **ppOutPropVal)
        HRESULT GetStruct(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT SetValue(IAAFPropertyValue * pPropVal, aafUInt32  index, IAAFPropertyValue * pMemberPropVal)
        HRESULT SetStruct(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT GetCount(aafUInt32 *pCount)
        HRESULT RegisterMembers(aafUInt32 *  pOffsets, aafUInt32  numMembers, aafUInt32  structSize)

    cdef aafUID_t AUID_AAFTypeDefRename
    cdef GUID IID_IAAFTypeDefRename
    cdef cppclass IAAFTypeDefRename(IUnknown):
        HRESULT Initialize(aafUID_constref  id, IAAFTypeDef * pBaseType, aafCharacter * pTypeName)
        HRESULT GetBaseType(IAAFTypeDef ** ppBaseType)
        HRESULT GetBaseValue(IAAFPropertyValue * pInPropVal, IAAFPropertyValue ** ppOutPropVal)
        HRESULT CreateValue(IAAFPropertyValue * pInPropVal, IAAFPropertyValue ** ppOutPropVal)

    cdef aafUID_t AUID_AAFTypeDefSet
    cdef GUID IID_IAAFTypeDefSet
    cdef cppclass IAAFTypeDefSet(IUnknown):
        HRESULT Initialize(aafUID_constref  id, IAAFTypeDef * pTypeDef, aafCharacter * pTypeName)
        HRESULT GetElementType(IAAFTypeDef ** ppTypeDef)
        HRESULT AddElement(IAAFPropertyValue * pSetPropertyValue, IAAFPropertyValue * pElementPropertyValue)
        HRESULT RemoveElement(IAAFPropertyValue * pSetPropertyValue, IAAFPropertyValue * pElementPropertyValue)
        HRESULT ContainsElement(
            IAAFPropertyValue * pSetPropertyValue,
            IAAFPropertyValue * pElementPropertyValue,
            aafBoolean_t*  pContainsElement
        )
        HRESULT GetCount(IAAFPropertyValue * pSetPropertyValue, aafUInt32 *  pCount)
        HRESULT CreateKey(aafDataBuffer_t  pKeyPtr, aafUInt32  length, IAAFPropertyValue ** ppKey)
        HRESULT LookupElement(
            IAAFPropertyValue * pSetPropertyValue,
            IAAFPropertyValue * pKey,
            IAAFPropertyValue ** ppElementPropertyValue
        )
        HRESULT ContainsKey(
            IAAFPropertyValue * pSetPropertyValue,
            IAAFPropertyValue * pKey,
            aafBoolean_t*  pContainsKey
        )
        HRESULT GetElements(IAAFPropertyValue *PSetPropVal, IEnumAAFPropertyValues ** ppEnum)


    cdef aafUID_t AUID_AAFTypeDefStream
    cdef GUID IID_IAAFTypeDefStream
    cdef cppclass IAAFTypeDefStream(IUnknown):
        HRESULT GetSize(IAAFPropertyValue * pStreamPropertyValue, aafInt64 *  pSize)
        HRESULT SetSize(IAAFPropertyValue * pStreamPropertyValue, aafInt64  newSize)
        HRESULT Read(
            IAAFPropertyValue * pStreamPropertyValue,
            aafUInt32  dataSize,
            aafMemPtr_t  pData,
            aafUInt32 *  bytesRead
        )
        HRESULT Write(IAAFPropertyValue * pStreamPropertyValue, aafUInt32  dataSize, aafMemPtr_t  pData)
        HRESULT GetPosition(IAAFPropertyValue * pStreamPropertyValue, aafInt64 *  pPosition)
        HRESULT SetPosition(IAAFPropertyValue * pStreamPropertyValue, aafInt64  newPosition)
        HRESULT Append(IAAFPropertyValue * pStreamPropertyValue, aafUInt32  dataSize, aafMemPtr_t  pData)
        HRESULT HasStoredByteOrder(IAAFPropertyValue * pStreamPropertyValue, aafBoolean_t *  pHasByteOrder)
        HRESULT GetStoredByteOrder(IAAFPropertyValue * pStreamPropertyValue, eAAFByteOrder_t *  pByteOrder)
        HRESULT SetStoredByteOrder(IAAFPropertyValue * pStreamPropertyValue, eAAFByteOrder_t  byteOrder)
        HRESULT ClearStoredByteOrder(IAAFPropertyValue * pStreamPropertyValue)
        HRESULT ReadElements(
            IAAFPropertyValue * pStreamPropertyValue,
            IAAFTypeDef * pElementType,
            aafUInt32  dataSize,
            aafMemPtr_t  pData,
            aafUInt32 *  pBytesRead
        )
        HRESULT WriteElements(
            IAAFPropertyValue * pStreamPropertyValue,
            IAAFTypeDef * pElementType,
            aafUInt32  dataSize,
            aafMemPtr_t  pData
        )
        AppendElements(
            IAAFPropertyValue * pStreamPropertyValue,
            IAAFTypeDef * pElementType,
            aafUInt32  dataSize,
            aafMemPtr_t  pData
        )

    cdef aafUID_t AUID_AAFTypeDefString
    cdef GUID IID_IAAFTypeDefString
    cdef cppclass IAAFTypeDefString(IUnknown):
        HRESULT Initialize(aafUID_constref  id, IAAFTypeDef * pTypeDef, aafCharacter *pTypeName)
        HRESULT GetType(IAAFTypeDef ** ppTypeDef)
        HRESULT GetCount(IAAFPropertyValue * pPropVal, aafUInt32 *  pCount)
        HRESULT CreateValueFromCString(aafMemPtr_t  pInitData, aafUInt32  initDataSize, IAAFPropertyValue ** ppPropVal)
        HRESULT SetCString(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT AppendElements(IAAFPropertyValue * pInPropVal, aafMemPtr_t  pElements)
        HRESULT GetElements(IAAFPropertyValue *pPropVal, aafMemPtr_t  pBuffer, aafUInt32  bufferSize)

    cdef aafUID_t AUID_AAFTypeDefStrongObjRef
    cdef GUID IID_IAAFTypeDefStrongObjRef
    cdef cppclass IAAFTypeDefStrongObjRef(IUnknown):
        HRESULT Initialize(aafUID_constref  id, IAAFClassDef * pObjType, aafCharacter *pTypeName)

    cdef aafUID_t AUID_AAFTypeDefVariableArray
    cdef GUID IID_IAAFTypeDefVariableArray
    cdef cppclass IAAFTypeDefVariableArray(IUnknown):
        HRESULT Initialize(aafUID_constref  id, IAAFTypeDef * pTypeDef, aafCharacter  *pTypeName)
        HRESULT GetType(IAAFTypeDef ** ppTypeDef)
        HRESULT GetCount(IAAFPropertyValue * pPropVal, aafUInt32 *  pCount)
        HRESULT AppendElement(IAAFPropertyValue * pInPropVal, IAAFPropertyValue * pMemberPropVal)
        HRESULT CreateEmptyValue(IAAFPropertyValue ** ppPropVal)
        HRESULT CreateValueFromValues(IAAFPropertyValue ** pElementValues, aafUInt32  numElements, IAAFPropertyValue ** ppPropVal)
        HRESULT CreateValueFromCArray(aafMemPtr_t  pInitData, aafUInt32  initDataSize, IAAFPropertyValue ** ppPropVal)
        HRESULT GetElementValue(IAAFPropertyValue * pInPropVal, aafUInt32  index, IAAFPropertyValue ** ppOutPropVal)
        HRESULT GetCArray(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT SetElementValue(IAAFPropertyValue * pPropVal, aafUInt32  index, IAAFPropertyValue * pMemberPropVal)
        HRESULT SetCArray(IAAFPropertyValue * pPropVal, aafMemPtr_t  pData, aafUInt32  dataSize)
        HRESULT GetElements(IAAFPropertyValue *PSetPropVal, IEnumAAFPropertyValues ** ppEnum)

    cdef GUID IID_IAAFTypeDefVariableArrayEx
    cdef cppclass IAAFTypeDefVariableArrayEx(IUnknown):
        HRESULT PrependElement(IAAFPropertyValue * pInPropVal, IAAFPropertyValue * pMemberPropVal)
        HRESULT RemoveElement(IAAFPropertyValue * pInPropVal, aafUInt32  index)
        HRESULT InsertElement(IAAFPropertyValue * pInPropVal, aafUInt32  index, IAAFPropertyValue * pMemberPropVal)

    cdef aafUID_t AUID_AAFTypeDefWeakObjRef
    cdef GUID IID_IAAFTypeDefWeakObjRef
    cdef cppclass IAAFTypeDefWeakObjRef(IUnknown):
        HRESULT Initialize(
            aafUID_constref  id,
            IAAFClassDef * pObjType,
            aafCharacter * pTypeName,
            aafUInt32  ids,
            aafUID_t * pTargetSet
        )

    # Def Objects

    cdef aafUID_t AUID_AAFDefObject
    cdef GUID IID_IAAFDefObject
    cdef cppclass IAAFDefObject(IUnknown):
        HRESULT GetNameBufLen(aafUInt32 *pBufSize)
        HRESULT GetName(
            aafCharacter *pName,
            aafUInt32  bufSize
        )

    cdef aafUID_t AUID_AAFDataDef
    cdef GUID IID_IAAFDataDef
    cdef cppclass IAAFDataDef(IUnknown):
        HRESULT Initialize(
            aafUID_t &id,
            aafCharacter *pName,
            aafCharacter *pDescription
        )

    cdef aafUID_t AUID_AAFCodecDef
    cdef GUID IID_IAAFCodecDef
    cdef cppclass IAAFCodecDef(IUnknown):
        HRESULT EnumCodecFlavours(IEnumAAFCodecFlavours ** ppEnum)

    cdef aafUID_t AUID_AAFContainerDef
    cdef GUID IID_IAAFContainerDef
    cdef cppclass IAAFContainerDef(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)

    cdef aafUID_t AUID_AAFInterpolationDef
    cdef GUID IID_IAAFInterpolationDef
    cdef cppclass IAAFInterpolationDef(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)

    cdef aafUID_t AUID_AAFParameterDef
    cdef GUID IID_IAAFParameterDef
    cdef cppclass IAAFParameterDef(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription, IAAFTypeDef * pType)
        HRESULT GetTypeDefinition(IAAFTypeDef ** ppTypeDef)

    cdef aafUID_t AUID_AAFPluginDef
    cdef GUID IID_IAAFPluginDef
    cdef cppclass IAAFPluginDef(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)

    cdef aafUID_t AUID_AAFOperationDef
    cdef GUID IID_IAAFOperationDef
    cdef cppclass IAAFOperationDef(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)
        HRESULT GetDataDef(IAAFDataDef ** ppDataDef)
        HRESULT SetDataDef(IAAFDataDef * ppDataDef)
        HRESULT IsTimeWarp(aafBoolean_t *  bIsTimeWarp)
        HRESULT SetIsTimeWarp(aafBoolean_t  IsTimeWarp)
        HRESULT GetNumberInputs(aafInt32 *  pNumberInputs)
        HRESULT SetNumberInputs(aafInt32  NumberInputs)
        HRESULT GetCategory(aafUID_t*  pValue)
        HRESULT SetCategory(aafUID_t&  value)
        HRESULT AddParameterDef(IAAFParameterDef * pParameterDef)
        HRESULT GetParameterDefs(IEnumAAFParameterDefs ** ppEnum)

    cdef aafUID_t AUID_AAFKLVDataDefinition
    cdef GUID IID_IAAFKLVDataDefinition
    cdef cppclass IAAFKLVDataDefinition(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)

    cdef aafUID_t AUID_AAFTaggedValueDefinition
    cdef GUID IID_IAAFTaggedValueDefinition
    cdef cppclass IAAFTaggedValueDefinition(IUnknown):
        HRESULT Initialize(aafUID_t  &id, aafCharacter  *pName, aafCharacter  *pDescription)

    # File Locators

    cdef aafUID_t AUID_AAFLocator
    cdef GUID IID_IAAFLocator
    cdef cppclass IAAFLocator(IUnknown):
        HRESULT SetPath(aafCharacter* pPath)
        HRESULT GetPathBufLen(aafUInt32 *  pBufSize)
        HRESULT GetPath(
            aafCharacter *  pPath,
            aafUInt32  bufSize
        )

    cdef aafUID_t AUID_AAFNetworkLocator
    cdef GUID IID_IAAFNetworkLocator
    cdef cppclass IAAFNetworkLocator(IUnknown):
        HRESULT Initialize()

    # EssenceAccess

    cdef aafUID_t AUID_AAFEssenceData
    cdef GUID IID_IAAFEssenceData
    cdef cppclass IAAFEssenceData(IUnknown):
        HRESULT Initialize(IAAFSourceMob * pFileMob)
        HRESULT Write(
            aafUInt32  bytes,
            aafDataBuffer_t  buffer,
            aafUInt32 *  bytesWritten
        )
        HRESULT Read(
            aafUInt32  bytes,
            aafDataBuffer_t  buffer,
            aafUInt32 *  bytesRead
        )
        HRESULT SetPosition(aafPosition_t  offset)
        HRESULT GetPosition(aafPosition_t*  pOffset)
        HRESULT GetSize(aafLength_t *  pSize)
        HRESULT SetFileMob(IAAFSourceMob * pFileMob)
        HRESULT GetFileMob(IAAFSourceMob ** ppFileMob)
        HRESULT GetFileMobID(aafMobID_t *  pFileMobID)

    cdef GUID IID_IAAFEssenceFormat
    cdef cppclass IAAFEssenceFormat(IUnknown):
        HRESULT AddFormatSpecifier(
            aafUID_t &essenceFormatCode,
            aafInt32  valueSize,
            aafDataBuffer_t  value,
        )
        HRESULT GetFormatSpecifier(
            aafUID_constref  essenceFormatCode,
            aafInt32  valueSize,
            aafDataBuffer_t  value,
            aafInt32*  bytesRead
        )
        HRESULT NumFormatSpecifiers(aafInt32*  numSpecifiers)
        HRESULT GetIndexedFormatSpecifier(
            aafInt32  index,
            aafUID_t*  essenceFormatCode,
            aafInt32  valueSize,
            aafDataBuffer_t  value,
            aafInt32*  bytesRead
        )

    cdef GUID IID_IAAFEssenceMultiAccess
    cdef cppclass IAAFEssenceMultiAccess(IUnknown):
        pass

    cdef GUID IID_IAAFEssenceAccess
    cdef cppclass IAAFEssenceAccess(IUnknown):
        HRESULT GetCodecName(
            aafUInt32  namelen,
            aafCharacter *  name
        )
        HRESULT GetCodecID(aafUID_t *codecID)
        HRESULT GetEmptyFileFormat(IAAFEssenceFormat ** ops)
        HRESULT PutFileFormat(IAAFEssenceFormat * ops)
        HRESULT GetFileFormatParameterList(IAAFEssenceFormat ** ops)
        HRESULT GetFileFormat(
            IAAFEssenceFormat * opsTemplate,
            IAAFEssenceFormat ** opsResult
        )
        HRESULT WriteSamples(
            aafUInt32  nSamples,
            aafUInt32  buflen,
            aafDataBuffer_t  buffer,
            aafUInt32 *  samplesWritten,
            aafUInt32 *  bytesWritten
        )

        HRESULT CompleteWrite()
        HRESULT SetEssenceCodecFlavour(aafUID_t& flavour)
        HRESULT GetLargestSampleSize(
            IAAFDataDef * pDataDef,
            aafLength_t*  maxSize
        )
        HRESULT Seek(aafPosition_t  sampleFrameNum)
        HRESULT GetIndexedSampleSize(
            IAAFDataDef * pDataDef,
            aafPosition_t  frameNum,
            aafLength_t*  frameSize
        )
        HRESULT CountSamples(
            IAAFDataDef * pDataDef,
            aafLength_t *  result
        )
        HRESULT ReadSamples(
            aafUInt32  nSamples,
            aafUInt32  buflen,
            aafDataBuffer_t  buffer,
            aafUInt32 *  samplesRead,
            aafUInt32 *  bytesRead
        )

    cdef aafUID_t AUID_AAFEssenceDescriptor
    cdef GUID IID_IAAFEssenceDescriptor
    cdef cppclass IAAFEssenceDescriptor(IUnknown):
        HRESULT CountLocators(aafUInt32 *  pResult)
        HRESULT AppendLocator(IAAFLocator * pLocator)
        HRESULT PrependLocator(IAAFLocator * pLocator)
        HRESULT InsertLocatorAt(aafUInt32  index, IAAFLocator * pLocator)
        HRESULT GetLocatorAt(aafUInt32  index, IAAFLocator ** ppLocator)
        HRESULT RemoveLocatorAt(aafUInt32  index)
        HRESULT GetLocators(IEnumAAFLocators ** ppEnum)

    cdef aafUID_t AUID_AAFFileDescriptor
    cdef GUID IID_IAAFFileDescriptor
    cdef cppclass IAAFFileDescriptor(IUnknown):
        HRESULT SetLength(aafLength_t  length)
        HRESULT GetLength(aafLength_t *  pLength)
        HRESULT GetCodecDef(IAAFCodecDef **pCodecDef)
        HRESULT SetCodecDef(IAAFCodecDef * codecDef)
        HRESULT SetSampleRate(aafRational_t &rate)
        HRESULT GetSampleRate(aafRational_t *rate)
        HRESULT SetContainerFormat(IAAFContainerDef * format)
        HRESULT GetContainerFormat(IAAFContainerDef ** pFormat)

    cdef aafUID_t AUID_AAFWAVEDescriptor
    cdef GUID IID_IAAFWAVEDescriptor
    cdef cppclass IAAFWAVEDescriptor(IUnknown):
        HRESULT Initialize()
        HRESULT GetSummary(aafUInt32  size, aafUInt8 *  pSummary)
        HRESULT GetSummaryBufferSize(aafUInt32 *  pSize)
        HRESULT SetSummary(aafUInt32  size, aafUInt8 * pSummary)

    cdef aafUID_t AUID_AAFAIFCDescriptor
    cdef GUID IID_IAAFAIFCDescriptor
    cdef cppclass IAAFAIFCDescriptor(IUnknown):
        HRESULT Initialize()
        HRESULT GetSummary(aafUInt32  size, aafUInt8  *pSummary)
        HRESULT GetSummaryBufferSize(aafUInt32 *pSize)
        HRESULT SetSummary(aafUInt32  size, aafUInt8  *pSummary)

    cdef aafUID_t AUID_AAFTIFFDescriptor
    cdef GUID IID_IAAFTIFFDescriptor
    cdef cppclass IAAFTIFFDescriptor(IUnknown):
        HRESULT SetIsUniform(aafBoolean_t  IsUniform)
        HRESULT GetIsUniform(aafBoolean_t *  pIsUniform)
        HRESULT SetIsContiguous(aafBoolean_t  IsContiguous)
        HRESULT GetIsContiguous(aafBoolean_t *  pIsContiguous)
        HRESULT SetLeadingLines(aafInt32  LeadingLines)
        HRESULT GetLeadingLines(aafInt32 *  pLeadingLines)
        HRESULT SetTrailingLines(aafInt32  TrailingLines)
        HRESULT GetTrailingLines(aafInt32 *  pTrailingLines)
        HRESULT SetJPEGTableID(aafInt32 JPEGTableID)
        HRESULT GetJPEGTableID(aafInt32 * JPEGTableID)
        HRESULT GetSummary(aafUInt32  size, aafUInt8  *pSummary)
        HRESULT GetSummaryBufferSize(aafUInt32 *pSize)
        HRESULT SetSummary(aafUInt32  size, aafUInt8  *pSummary)

    cdef aafUID_t AUID_AAFDigitalImageDescriptor
    cdef GUID IID_IAAFDigitalImageDescriptor
    cdef cppclass IAAFDigitalImageDescriptor(IUnknown):
        HRESULT SetCompression(aafUID_t& compression)
        HRESULT GetCompression(aafUID_t* compression)
        HRESULT SetStoredView(
            aafUInt32  StoredHeight,
            aafUInt32  StoredWidth
        )
        HRESULT GetStoredView(
            aafUInt32  *pStoredHeight,
            aafUInt32  *pStoredHeight
        )
        HRESULT SetSampledView(
            aafUInt32  SampledHeight,
            aafUInt32  SampledWidth,
            aafInt32  SampledXOffset,
            aafInt32  SampledYOffset
        )
        HRESULT GetSampledView(
            aafUInt32 * pSampledHeight,
            aafUInt32 * pSampledWidth,
            aafInt32 * pSampledXOffset,
            aafInt32 * pSampledYOffset
        )
        HRESULT SetDisplayView(
            aafUInt32  DisplayHeight,
            aafUInt32  DisplayWidth,
            aafInt32  DisplayXOffset,
            aafInt32  DisplayYOffset
        )
        HRESULT GetDisplayView(
            aafUInt32 *  pDisplayHeight,
            aafUInt32 *  pDisplayWidth,
            aafInt32 *  pDisplayXOffset,
            aafInt32 *  pDisplayYOffset
        )
        HRESULT SetFrameLayout(aafFrameLayout_t FrameLayout)
        HRESULT GetFrameLayout(aafFrameLayout_t *pFrameLayout)
        HRESULT SetVideoLineMap(
            aafUInt32  numberElements,
            aafInt32 *  pVideoLineMap
        )
        HRESULT GetVideoLineMap(
            aafUInt32  numberElements,
            aafInt32 *  pVideoLineMap
        )
        HRESULT GetVideoLineMapSize(
            aafUInt32* pNumberElements
        )
        HRESULT SetImageAspectRatio(aafRational_t  ImageAspectRatio)
        HRESULT GetImageAspectRatio(aafRational_t  *pImageAspectRatio)
        HRESULT SetImageAlignmentFactor(aafUInt32  ImageAlignmentFactor)
        HRESULT GetImageAlignmentFactor(aafUInt32 *pImageAlignmentFactor)

    cdef aafUID_t AUID_AAFDigitalImageDescriptor2
    cdef GUID IID_IAAFDigitalImageDescriptor2
    cdef cppclass IAAFDigitalImageDescriptor2(IUnknown):
        HRESULT SetCompression(aafUID_t & compression)
        HRESULT GetCompression(aafUID_t * compression)

    cdef aafUID_t AUID_AAFCDCIDescriptor
    cdef GUID IID_IAAFCDCIDescriptor
    cdef cppclass IAAFCDCIDescriptor(IUnknown):
        HRESULT Initialize()
        HRESULT SetComponentWidth(aafInt32  ComponentWidth)
        HRESULT GetComponentWidth(aafInt32  *pComponentWidth)
        HRESULT SetHorizontalSubsampling(aafUInt32 HorizontalSubsampling)
        HRESULT GetHorizontalSubsampling(aafUInt32 *HorizontalSubsampling)
        HRESULT SetVerticalSubsampling(aafUInt32 VerticalSubsampling)
        HRESULT GetVerticalSubsampling(aafUInt32 *pVerticalSubsampling)
        HRESULT SetColorRange(aafUInt32 ColorRange)
        HRESULT GetColorRange(aafUInt32 *  pColorRange)

    cdef aafUID_t AUID_AAFRGBADescriptor
    cdef GUID IID_IAAFRGBADescriptor
    cdef cppclass IAAFRGBADescriptor(IUnknown):
        HRESULT Initialize()

    cdef aafUID_t AUID_AAFSoundDescriptor
    cdef GUID IID_IAAFSoundDescriptor
    cdef cppclass IAAFSoundDescriptor(IUnknown):
        HRESULT Initialize()

    cdef aafUID_t AUID_AAFPCMDescriptor
    cdef GUID IID_IAAFPCMDescriptor
    cdef cppclass IAAFPCMDescriptor(IUnknown):
        HRESULT Initialize()

    cdef aafUID_t AUID_AAFTapeDescriptor
    cdef GUID IID_IAAFTapeDescriptor
    cdef cppclass IAAFTapeDescriptor(IUnknown):
        HRESULT Initialize()

    cdef aafUID_t AUID_AAFPhysicalDescriptor
    cdef GUID IID_IAAFPhysicalDescriptor
    cdef cppclass IAAFPhysicalDescriptor(IUnknown):
        pass

    cdef aafUID_t AUID_AAFImportDescriptor
    cdef GUID IID_IAAFImportDescriptor
    cdef cppclass IAAFImportDescriptor(IUnknown):
        HRESULT Initialize()

    # Mobs

    cdef aafUID_t AUID_AAFMob
    cdef GUID IID_IAAFMob
    cdef cppclass IAAFMob(IUnknown):
        HRESULT GetMobID(aafMobID_t *pMobID)
        HRESULT SetMobID(aafMobID_t &pMobID)
        HRESULT GetNameBufLen(aafUInt32 *pBufSize)
        HRESULT GetName(
            aafCharacter *pName,
            aafUInt32  bufSize
        )
        HRESULT SetName(aafCharacter *pName)
        HRESULT CountSlots(aafNumSlots_t *  pNumSlots)
        HRESULT AppendSlot(IAAFMobSlot * pSlot)
        HRESULT PrependSlot(IAAFMobSlot * pSlot)
        HRESULT InsertSlotAt(aafUInt32  index, IAAFMobSlot * pSlot)
        HRESULT RemoveSlotAt(aafUInt32  index)
        HRESULT GetSlotAt(aafUInt32  index, IAAFMobSlot ** ppSlot)
        HRESULT GetSlots(IEnumAAFMobSlots ** ppEnum)
        HRESULT AppendComment(aafCharacter *  pCategory, aafCharacter *  pComment)
        HRESULT CountComments(aafUInt32 *  pNumComments)
        HRESULT GetComments(IEnumAAFTaggedValues ** ppEnum)
        HRESULT RemoveComment(IAAFTaggedValue * pComment)
        HRESULT AppendNewTimelineSlot(
            aafRational_t  editRate,
            IAAFSegment * pSegment,
            aafSlotID_t  slotID,
            aafCharacter  *pSlotName,
            aafPosition_t  origin,
            IAAFTimelineMobSlot ** ppNewSlot
        )
        HRESULT CloneExternal(
            aafDepend_t  resolveDependencies,
            aafIncMedia_t  includeMedia,
            IAAFFile * pDestFile,
            IAAFMob ** ppDestMob
        )
        HRESULT Copy(
            aafCharacter *pDestMobName,
            IAAFMob ** ppDestMob
        )

    cdef aafUID_t AUID_AAFMob2
    cdef GUID IID_IAAFMob2
    cdef cppclass IAAFMob2(IUnknown):
        HRESULT AppendAttribute(aafCharacter *pName, aafCharacter *pValue)


    cdef aafUID_t AUID_AAFMasterMob
    cdef GUID IID_IAAFMasterMob
    cdef cppclass IAAFMasterMob(IUnknown):
        HRESULT Initialize()
        HRESULT OpenEssence(
            aafSlotID_t  slotID,
            aafMediaCriteria_t*  mediaCrit,
            aafMediaOpenMode_t  openMode,
            aafCompressEnable_t  compEnable,
            IAAFEssenceAccess ** access
        )
        HRESULT CreateEssence(
            aafSlotID_t masterSlotID,
            IAAFDataDef * pMediaKind,
            aafUID_constref  codecID,
            aafRational_t editRate,
            aafRational_t samplerate,
            aafCompressEnable_t Enable,
            IAAFLocator *destination,
            aafUID_constref fileFormat,
            IAAFEssenceAccess **access
        )
        HRESULT AddMasterSlot(
            IAAFDataDef * pDataDef,
            aafSlotID_t  sourceSlotID,
            IAAFSourceMob * pSourceMob,
            aafSlotID_t  masterSlotID,
            aafCharacter *pSlotName
        )
        HRESULT AppendPhysSourceRef(
            aafRational_t  editrate,
            aafSlotID_t  aMobSlot,
            IAAFDataDef * pEssenceKind,
            aafSourceRef_t  ref,
            aafLength_t  srcRefLength
        )
        HRESULT NewPhysSourceRef(
            aafRational_t  editrate,
            aafSlotID_t  aMobSlot,
            IAAFDataDef * pEssenceKind,
            aafSourceRef_t  ref,
            aafLength_t  srcRefLength
        )

    cdef aafUID_t AUID_AAFMasterMob2
    cdef GUID IID_IAAFMasterMob2
    cdef cppclass IAAFMasterMob2(IUnknown):
        pass

    cdef aafUID_t AUID_AAFMasterMob3
    cdef GUID IID_IAAFMasterMob3
    cdef cppclass IAAFMasterMob3(IUnknown):
        HRESULT AddMasterSlotWithSequence(
            IAAFDataDef * pDataDef,
            aafSlotID_t  sourceSlotID,
            IAAFSourceMob * pSourceMob,
            aafSlotID_t  masterSlotID,
            aafCharacter * pSlotName
        )

    cdef aafUID_t AUID_AAFCompositionMob
    cdef GUID IID_IAAFCompositionMob
    cdef cppclass IAAFCompositionMob(IUnknown):
        HRESULT Initialize(aafCharacter *pName)

    cdef aafUID_t AUID_AAFCompositionMob2
    cdef GUID IID_IAAFCompositionMob2
    cdef cppclass IAAFCompositionMob2(IUnknown):
        pass

    cdef aafUID_t AUID_AAFSourceMob
    cdef GUID IID_IAAFSourceMob
    cdef cppclass IAAFSourceMob(IUnknown):
        HRESULT Initialize()
        HRESULT GetEssenceDescriptor(IAAFEssenceDescriptor ** ppEssence)
        HRESULT SetEssenceDescriptor(IAAFEssenceDescriptor * pEssence)
        HRESULT AddNilReference(
            aafSlotID_t  slotID,
            aafLength_t  length,
            IAAFDataDef * pDataDef,
            aafRational_t  editRate
        )
        HRESULT AppendTimecodeSlot(
            aafRational_t  editrate,
            aafSlotID_t  slotID,
            aafTimecode_t  startTC,
            aafFrameLength_t  length32
        )
        HRESULT AppendEdgecodeSlot(
            aafRational_t  editrate,
            aafSlotID_t  slotID,
            aafFrameOffset_t  startEC,
            aafFrameLength_t  length32,
            aafFilmType_t  filmKind,
            aafEdgeType_t  codeFormat,
            aafEdgecodeHeader_t  header
        )
        HRESULT AppendPhysSourceRef(
            aafRational_t  editrate,
            aafSlotID_t  aMobSlot,
            IAAFDataDef * pEssenceKind,
            aafSourceRef_t  ref,
            aafLength_t  srcRefLength
        )
        HRESULT NewPhysSourceRef(
            aafRational_t  editrate,
            aafSlotID_t  aMobSlot,
            IAAFDataDef * pEssenceKind,
            aafSourceRef_t  ref,
            aafLength_t  srcRefLength
        )
        HRESULT AddPulldownRef(
            aafAppendOption_t  addType,
            aafRational_t  editrate,
            aafSlotID_t  aMobSlot,
            IAAFDataDef * pEssenceKind,
            aafSourceRef_t  ref,
            aafLength_t  srcRefLength,
            aafPulldownKind_t  pulldownKind,
            aafPhaseFrame_t  phaseFrame,
            aafPulldownDir_t  direction
        )

    cdef aafUID_t AUID_AAFMobSlot
    cdef GUID IID_IAAFMobSlot
    cdef cppclass IAAFMobSlot(IUnknown):
        HRESULT GetSegment(IAAFSegment ** ppResult)
        HRESULT SetSegment(IAAFSegment * pSegment)
        HRESULT GetDataDef(IAAFDataDef ** ppResult)
        HRESULT GetSlotID(aafSlotID_t *  pResult)
        HRESULT SetSlotID(aafSlotID_t pSlotID)
        HRESULT GetPhysicalNum(aafUInt32  *number)
        HRESULT SetPhysicalNum(aafUInt32  number)
        HRESULT SetName(aafCharacter* pName)
        HRESULT GetNameBufLen(aafUInt32 *  pBufSize)
        HRESULT GetName(
            aafCharacter *  pName,
            aafUInt32  bufSize
        )

    cdef aafUID_t AUID_AAFTimelineMobSlot
    cdef GUID IID_IAAFTimelineMobSlot
    cdef cppclass IAAFTimelineMobSlot(IUnknown):
        HRESULT Initialize()
        HRESULT GetOrigin(aafPosition_t *pOrigin)
        HRESULT SetOrigin(aafPosition_t origin)
        HRESULT GetEditRate(aafRational_t* rate)
        HRESULT SetEditRate(aafRational_t& editRate)

    cdef aafUID_t AUID_AAFTimelineMobSlot2
    cdef GUID IID_IAAFTimelineMobSlot2
    cdef cppclass IAAFTimelineMobSlot2(IUnknown):
        HRESULT Initialize()

    cdef aafUID_t AUID_AAFEventMobSlot
    cdef GUID IID_IAAFEventMobSlot
    cdef cppclass IAAFEventMobSlot(IUnknown):
        pass

    cdef aafUID_t AUID_AAFStaticMobSlot
    cdef GUID IID_IAAFStaticMobSlot
    cdef cppclass IAAFStaticMobSlot(IUnknown):
        pass


    # Components

    cdef aafUID_t AUID_AAFComponent
    cdef GUID IID_IAAFComponent
    cdef cppclass IAAFComponent(IUnknown):
        HRESULT SetLength(aafLength_t& pLength)
        HRESULT GetLength(aafLength_t * pLength)
        HRESULT GetDataDef(IAAFDataDef ** ppDatadef)
        HRESULT SetDataDef(IAAFDataDef * pDataDef)
        HRESULT AppendKLVData(IAAFKLVData * pData)
        HRESULT CountKLVData(aafUInt32 *  pNumData)
        HRESULT GetKLVData(IEnumAAFKLVData ** ppEnum)
        HRESULT RemoveKLVData(IAAFKLVData * pData)

    cdef aafUID_t AUID_AAFSegment
    cdef GUID IID_IAAFSegment
    cdef cppclass IAAFSegment(IUnknown):
        HRESULT SegmentOffsetToTC(aafPosition_t *  pOffset, aafTimecode_t *  pTimecode)
        HRESULT SegmentTCToOffset(aafTimecode_t *  pTimecode, aafRational_t *  pEditRate, aafFrameOffset_t *  pOffset)

    cdef aafUID_t AUID_AAFTransition
    cdef GUID IID_IAAFTransition
    cdef cppclass IAAFTransition(IUnknown):
        HRESULT Initialize(
            IAAFDataDef * pDataDef,
            aafLength_t  length,
            aafPosition_t  cutPoint,
            IAAFOperationGroup * op
        )
        HRESULT GetCutPoint(aafPosition_t *cutPoint)
        HRESULT GetOperationGroup(IAAFOperationGroup ** groupObj)
        HRESULT SetCutPoint(aafPosition_t  cutPoint)
        HRESULT SetOperationGroup(IAAFOperationGroup * opgroup)

    cdef aafUID_t AUID_AAFSequence
    cdef GUID IID_IAAFSequence
    cdef cppclass IAAFSequence(IUnknown):
        HRESULT Initialize(IAAFDataDef * pDataDef)
        HRESULT AppendComponent(IAAFComponent * pComponent)
        HRESULT PrependComponent(IAAFComponent * pComponent)
        HRESULT InsertComponentAt(aafUInt32  index, IAAFComponent * pComponent)
        HRESULT GetComponentAt(aafUInt32  index, IAAFComponent ** ppComponent)
        HRESULT RemoveComponentAt(aafUInt32  index)
        HRESULT CountComponents(aafUInt32 *  pResult)
        HRESULT GetComponents(IEnumAAFComponents ** ppEnum)

    cdef aafUID_t AUID_AAFTimecode
    cdef GUID IID_IAAFTimecode
    cdef cppclass IAAFTimecode(IUnknown):
        HRESULT Initialize(
            aafLength_t  length,
            aafTimecode_t*  pTimecode
        )
        HRESULT GetTimecode(aafTimecode_t *  pTimecode)
        HRESULT SetTimecode(aafTimecode_t *  timecode)

    cdef aafUID_t AUID_AAFTimecodeStream
    cdef GUID IID_IAAFTimecodeStream
    cdef cppclass IAAFTimecodeStream(IUnknown):
        pass

    cdef aafUID_t AUID_AAFTimecodeStream12M
    cdef GUID IID_IAAFTimecodeStream12M
    cdef cppclass IAAFTimecodeStream12M(IUnknown):
        pass

    cdef aafUID_t AUID_AAFFiller
    cdef GUID IID_IAAFFiller
    cdef cppclass IAAFFiller(IUnknown):
        HRESULT Initialize(IAAFDataDef * pDataDef, aafLength_t  length)

    cdef aafUID_t AUID_AAFPulldown
    cdef GUID IID_IAAFPulldown
    cdef cppclass IAAFPulldown(IUnknown):
        HRESULT GetInputSegment(IAAFSegment ** ppInputSegment)
        HRESULT SetInputSegment(IAAFSegment * pInputSegment)
        HRESULT GetPulldownKind(aafPulldownKind_t *  pPulldownKind)
        HRESULT SetPulldownKind(aafPulldownKind_t  pulldownKind)
        HRESULT GetPulldownDirection(aafPulldownDir_t *  pPulldownDirection)
        HRESULT SetPulldownDirection(aafPulldownDir_t  pulldownDirection)
        HRESULT GetPhaseFrame(aafPhaseFrame_t *  pPhaseFrame)
        HRESULT SetPhaseFrame(aafPhaseFrame_t phaseFrame)

    cdef aafUID_t AUID_AAFSourceReference
    cdef GUID IID_IAAFSourceReference
    cdef cppclass IAAFSourceReference(IUnknown):
        HRESULT GetSourceID(aafMobID_t *  pSourceID)
        HRESULT SetSourceID(aafMobID_t & sourceID)
        HRESULT GetSourceMobSlotID(aafSlotID_t *  pMobSlotID)
        HRESULT SetSourceMobSlotID(aafSlotID_t   mobSlotID)

    cdef aafUID_t AUID_AAFSourceClip
    cdef GUID IID_IAAFSourceClip
    cdef cppclass IAAFSourceClip(IUnknown):
        HRESULT Initialize(
            IAAFDataDef * pDataDef,
            aafLength_t&  length,
            aafSourceRef_t  sourceRef
        )
        HRESULT GetFade(
            aafLength_t *  pFadeInLen,
            aafFadeType_t *  pFadeInType,
            aafBoolean_t *  pFadeInPresent,
            aafLength_t *  pFadeOutLen,
            aafFadeType_t *  pFadeOutType,
            aafBoolean_t *  pFadeOutPresent
        )
        HRESULT ResolveRef(IAAFMob ** ppMob)
        HRESULT GetSourceReference(aafSourceRef_t *  pSourceRef)
        HRESULT SetSourceReference(aafSourceRef_t  sourceRef)
        HRESULT SetFade(
            aafInt32  fadeInLen,
            aafFadeType_t  fadeInType,
            aafInt32  fadeOutLen,
            aafFadeType_t  fadeOutType
        )

    cdef aafUID_t AUID_AAFOperationGroup
    cdef GUID IID_IAAFOperationGroup
    cdef cppclass IAAFOperationGroup(IUnknown):
        HRESULT Initialize(IAAFDataDef * pDataDef, aafLength_t  length, IAAFOperationDef * operationDef)
        HRESULT GetOperationDefinition(IAAFOperationDef **ppOperationDef)
        HRESULT SetOperationDefinition(IAAFOperationDef * pOperationDef)
        HRESULT GetRender(IAAFSourceReference ** ppSourceRef)
        HRESULT IsATimeWarp(aafBoolean_t *  pIsTimeWarp)
        HRESULT GetBypassOverride(aafUInt32 *  pBypassOverride)
        HRESULT CountSourceSegments(aafUInt32 *  pResult)
        HRESULT IsValidTranOperation(aafBoolean_t *  pValidTransition)
        HRESULT CountParameters(aafUInt32 *  pResult)
        HRESULT AddParameter(IAAFParameter * pParameter)
        HRESULT AppendInputSegment(IAAFSegment * pSegment)
        HRESULT PrependInputSegment(IAAFSegment * pSegment)
        HRESULT InsertInputSegmentAt(aafUInt32  index, IAAFSegment * pSegment)
        HRESULT SetRender(IAAFSourceReference * pSourceRef)
        HRESULT SetBypassOverride(aafUInt32  bypassOverride)
        HRESULT GetParameters(IEnumAAFParameters **ppEnum)
        HRESULT LookupParameter(aafUID_t & argID, IAAFParameter ** ppParameter)
        HRESULT GetInputSegmentAt(aafUInt32  index, IAAFSegment ** ppInputSegment)
        HRESULT RemoveInputSegmentAt(aafUInt32  index)



    cdef aafUID_t AUID_AAFNestedScope
    cdef GUID IID_IAAFNestedScope
    cdef cppclass IAAFNestedScope(IUnknown):
        HRESULT AppendSegment(IAAFSegment * pSegment)
        HRESULT PrependSegment(IAAFSegment * pSegment)
        HRESULT InsertSegmentAt(aafUInt32  index, IAAFSegment * pSegment)
        HRESULT RemoveSegmentAt(aafUInt32  index)
        HRESULT CountSegments(aafUInt32 *  pResult)
        HRESULT GetSegmentAt(aafUInt32  index, IAAFSegment ** ppSegment)
        HRESULT GetSegments(IEnumAAFSegments ** ppEnum)

    cdef aafUID_t AUID_AAFScopeReference
    cdef GUID IID_IAAFScopeReference
    cdef cppclass IAAFScopeReference(IUnknown):
        HRESULT Create(aafUInt32  RelativeScope, aafUInt32  RelativeSlot)
        HRESULT Initialize(IAAFDataDef * pDataDef, aafUInt32  RelativeScope, aafUInt32  RelativeSlot)
        HRESULT GetRelativeScope(aafUInt32 *  pnRelativeScope)
        HRESULT GetRelativeSlot(aafUInt32 *  pnRelativeSlot)

    cdef aafUID_t AUID_AAFEssenceGroup
    cdef GUID IID_IAAFEssenceGroup
    cdef cppclass IAAFEssenceGroup(IUnknown):
        HRESULT SetStillFrame(IAAFSourceClip * pStillFrame)
        HRESULT GetStillFrame(IAAFSourceClip **ppStillFrame)
        HRESULT AppendChoice(IAAFSegment * pChoice)
        HRESULT PrependChoice(IAAFSegment * pChoice)
        HRESULT InsertChoiceAt(aafUInt32  index, IAAFSegment * pChoice)
        HRESULT CountChoices(aafUInt32 *pCount)
        HRESULT GetChoiceAt(aafUInt32  index, IAAFSegment  ** ppChoice)
        HRESULT RemoveChoiceAt(aafUInt32  index)

    cdef aafUID_t AUID_AAFSelector
    cdef GUID IID_IAAFSelector
    cdef cppclass IAAFSelector(IUnknown):
        HRESULT GetSelectedSegment(IAAFSegment ** ppSelSegment)
        HRESULT SetSelectedSegment(IAAFSegment * pSelSegment)
        HRESULT AppendAlternateSegment(IAAFSegment * pSegment)
        HRESULT GetNumAlternateSegments(aafInt32 *  pNumSegments)
        HRESULT EnumAlternateSegments(IEnumAAFSegments ** ppEnum)
        HRESULT RemoveAlternateSegment(IAAFSegment * pSelSegment)

    cdef aafUID_t AUID_AAFEdgecode
    cdef GUID IID_IAAFEdgecode
    cdef cppclass IAAFEdgecode(IUnknown):
        HRESULT Initialize(aafLength_t length, aafEdgecode_t  edgecode)
        HRESULT GetEdgecode(aafEdgecode_t *  edgecode)

    cdef aafUID_t AUID_AAFEvent
    cdef GUID IID_IAAFEvent
    cdef cppclass IAAFEvent(IUnknown):
        HRESULT GetPosition(aafPosition_t *  pPosition)
        HRESULT SetPosition(aafPosition_t  Position)
        HRESULT SetComment(aafCharacter * pComment)
        HRESULT GetComment(aafCharacter *  pComment, aafUInt32  bufSize)
        HRESULT GetCommentBufLen(aafUInt32 *  pBufSize)

    cdef aafUID_t AUID_AAFCommentMarker
    cdef GUID IID_IAAFCommentMarker
    cdef cppclass IAAFCommentMarker(IUnknown):
        HRESULT GetAnnotation(IAAFSourceReference ** ppResult)
        HRESULT SetAnnotation(IAAFSourceReference * pAnnotation)

    cdef aafUID_t AUID_AAFDescriptiveMarker
    cdef GUID IID_IAAFDescriptiveMarker
    cdef cppclass IAAFDescriptiveMarker(IUnknown):
        HRESULT Initialize()
        HRESULT SetDescribedSlotIDs(aafUInt32  numberElements, aafUInt32*  pDescribedSlotIDs)

    cdef aafUID_t AUID_IAAFKLVData
    cdef GUID IID_IAAFKLVData
    cdef cppclass IAAFKLVData(IUnknown):
        HRESULT Initialize(aafUID_t  key, aafUInt32  length, aafDataBuffer_t  pValue)

    cdef cppclass IAAFProgress(IUnknown):
        pass

    cdef cppclass IAAFDiagnosticOutput(IUnknown):
        pass

    ## Parameters

    cdef aafUID_t AUID_AAFParameter
    cdef GUID IID_IAAFParameter
    cdef cppclass IAAFParameter(IUnknown):
        HRESULT GetParameterDefinition(IAAFParameterDef **ppParmDef)
        HRESULT GetTypeDefinition(IAAFTypeDef **ppTypeDef)

    cdef aafUID_t AUID_AAFConstantValue
    cdef GUID IID_IAAFConstantValue
    cdef cppclass IAAFConstantValue(IUnknown):
        HRESULT Initialize(IAAFParameterDef * pParameterDef,
                           aafUInt32  valueSize,
                           aafDataBuffer_t  pValue
        )
        HRESULT GetValue(aafUInt32  valueSize,
                         aafDataBuffer_t  pValue,
                         aafUInt32*  bytesRead
        )
        HRESULT GetValueBufLen(aafUInt32 *  pLen)
        HRESULT GetTypeDefinition(IAAFTypeDef ** ppTypeDef)
        HRESULT SetValue(aafUInt32  valueSize, aafDataBuffer_t  pValue)

    cdef aafUID_t AUID_AAFVaryingValue
    cdef GUID IID_IAAFVaryingValue
    cdef cppclass IAAFVaryingValue(IUnknown):
        HRESULT Initialize(IAAFParameterDef * pParameterDef, IAAFInterpolationDef * pInterpolation)
        HRESULT AddControlPoint(IAAFControlPoint * pControlPoint)
        HRESULT GetControlPoints(IEnumAAFControlPoints ** ppEnum)
        HRESULT CountControlPoints(aafUInt32 *  pResult)
        HRESULT GetControlPointAt(aafUInt32  index, IAAFControlPoint ** ppControlPoint)
        HRESULT RemoveControlPointAt(aafUInt32  index)
        HRESULT GetInterpolationDefinition(IAAFInterpolationDef ** ppInterpolation)
        HRESULT GetValueBufLen(aafInt32 *  pLen)
        HRESULT GetInterpolatedValue(aafRational_t  inputValue,
                                     aafInt32  valueSize,
                                     aafDataBuffer_t  pValue,
                                     aafInt32 *  bytesRead
        )


    cdef aafUID_t AUID_AAFControlPoint
    cdef GUID IID_IAAFControlPoint
    cdef cppclass IAAFControlPoint(IUnknown):
        HRESULT Initialize(IAAFVaryingValue * pVaryingValue,
                           aafRational_t &time,
                           aafUInt32  valueSize,
                           aafDataBuffer_t  pValue
        )
        HRESULT GetTime(aafRational_t *  pTime)
        HRESULT GetEditHint(aafEditHint_t *  pEditHint)
        HRESULT GetValueBufLen(aafUInt32 *  pLen)
        HRESULT GetValue(aafUInt32  valueSize,
                         aafDataBuffer_t  pValue,
                         aafUInt32*  bytesRead
        )
        HRESULT SetTime(aafRational_t  pTime)
        HRESULT SetEditHint(aafEditHint_t  editHint)
        HRESULT GetTypeDefinition(IAAFTypeDef ** ppTypeDef)




    ## IEnumAAFs

    cdef GUID IID_IEnumAAFComponents
    cdef cppclass IEnumAAFComponents(IUnknown):
        HRESULT Clone(IEnumAAFComponents **ppEnum)
        HRESULT NextOne(IAAFComponent ** ppComponent)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFEssenceData
    cdef cppclass IEnumAAFEssenceData(IUnknown):
        HRESULT Clone(IEnumAAFEssenceData **ppEnum)
        HRESULT NextOne(IAAFEssenceData ** ppEssenceData)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFLoadedPlugins
    cdef cppclass IEnumAAFLoadedPlugins(IUnknown):
        HRESULT Clone(IEnumAAFLoadedPlugins **ppEnum)
        HRESULT NextOne(aafUID_t*  ppAAFPluginID)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFLocators
    cdef cppclass IEnumAAFLocators(IUnknown):
        HRESULT Clone(IEnumAAFLocators **ppEnum)
        HRESULT NextOne(IAAFLocator ** ppLocator)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFMobs
    cdef cppclass IEnumAAFMobs(IUnknown):
        HRESULT Clone(IEnumAAFMobs **ppEnum)
        HRESULT NextOne(IAAFMob ** ppMob)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()


    cdef GUID IID_IEnumAAFMobSlots
    cdef cppclass IEnumAAFMobSlots(IUnknown):
        HRESULT Clone(IEnumAAFMobSlots **ppEnum)
        HRESULT NextOne(IAAFMobSlot ** ppMob)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFProperties
    cdef cppclass IEnumAAFProperties(IUnknown):
        HRESULT Clone(IEnumAAFProperties **ppEnum)
        HRESULT NextOne(IAAFProperty ** ppMob)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFPropertyValues
    cdef cppclass IEnumAAFPropertyValues(IUnknown):
        HRESULT Clone(IEnumAAFPropertyValues **ppEnum)
        HRESULT NextOne(IAAFPropertyValue ** ppPropertyValue)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFSegments
    cdef cppclass IEnumAAFSegments(IUnknown):
        HRESULT Clone(IEnumAAFSegments **ppEnum)
        HRESULT NextOne(IAAFSegment ** ppSegment)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFParameters
    cdef cppclass IEnumAAFParameters(IUnknown):
        HRESULT Clone(IEnumAAFParameters **ppEnum)
        HRESULT NextOne(IAAFParameter ** ppParameter)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFParameterDefs
    cdef cppclass IEnumAAFParameterDefs(IUnknown):
        HRESULT Clone(IEnumAAFParameterDefs **ppEnum)
        HRESULT NextOne(IAAFParameterDef ** ppParameterDef)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFPropertyDefs
    cdef cppclass IEnumAAFPropertyDefs(IUnknown):
        HRESULT Clone(IEnumAAFPropertyDefs **ppEnum)
        HRESULT NextOne(IAAFPropertyDef ** ppParameter)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFClassDefs
    cdef cppclass IEnumAAFClassDefs(IUnknown):
        HRESULT Clone(IEnumAAFClassDefs **ppEnum)
        HRESULT NextOne(IAAFClassDef ** ppClassDefs)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFCodecDefs
    cdef cppclass IEnumAAFCodecDefs(IUnknown):
        HRESULT Clone(IEnumAAFCodecDefs **ppEnum)
        HRESULT NextOne(IAAFCodecDef ** ppCodecDefs)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFCodecFlavours
    cdef cppclass IEnumAAFCodecFlavours(IUnknown):
        HRESULT Clone(IEnumAAFCodecFlavours **ppEnum)
        HRESULT NextOne(aafUID_t *  pAAFCodecFlavour)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFControlPoints
    cdef cppclass IEnumAAFControlPoints(IUnknown):
        HRESULT Clone(IEnumAAFControlPoints **ppEnum)
        HRESULT NextOne(IAAFControlPoint ** ppControlPoints)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFTypeDefs
    cdef cppclass IEnumAAFTypeDefs(IUnknown):
        HRESULT Clone(IEnumAAFTypeDefs **ppEnum)
        HRESULT NextOne(IAAFTypeDef ** ppTypeDef)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFPluginDefs
    cdef cppclass IEnumAAFPluginDefs(IUnknown):
        HRESULT Clone(IEnumAAFPluginDefs **ppEnum)
        HRESULT NextOne(IAAFPluginDef ** ppPluginDefs)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFKLVDataDefs
    cdef cppclass IEnumAAFKLVDataDefs(IUnknown):
        HRESULT Clone(IEnumAAFKLVDataDefs **ppEnum)
        HRESULT NextOne(IAAFKLVDataDefinition ** ppKLVDataDefs)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef GUID IID_IEnumAAFTaggedValues
    cdef cppclass IEnumAAFTaggedValues(IUnknown):
        HRESULT Clone(IEnumAAFTaggedValues **ppEnum)
        HRESULT NextOne(IAAFTaggedValue ** ppTaggedValues)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    cdef cppclass IEnumAAFKLVData(IUnknown):
        HRESULT Clone(IEnumAAFKLVData **ppEnum)
        HRESULT NextOne(IAAFKLVData ** ppKLVData)
        HRESULT Skip(aafUInt32  count)
        HRESULT Reset()

    # File Functions

    cdef HRESULT AAFFileOpenExistingRead(
        aafCharacter *pFileName,
        aafUInt32 modeFlags,
        IAAFFile ** ppFile
        )

    cdef HRESULT AAFFileOpenExistingModify(
        aafCharacter *pFileName,
        aafUInt32 modeFlags,
        aafProductIdentification_t *pIdent,
        IAAFFile ** ppFile
        )

    cdef HRESULT AAFFileOpenNewModifyEx(
        aafCharacter * pFileName,
        aafUID_t * pFileKind,
        aafUInt32  modeFlags,
        aafProductIdentification_t * pIdent,
        IAAFFile ** ppFile
        )

    cdef HRESULT AAFFileOpenTransient(
        aafProductIdentification_t *pIdent,
        IAAFFile ** ppFile
        )

    cdef HRESULT AAFResultToTextBufLen(HRESULT  result,
                                       aafUInt32 *pResultTextSize )
    cdef HRESULT AAFResultToText(AAFRESULT  result,
                                 aafCharacter *  pResultText,
                                 aafUInt32  resultTextSize)

    cdef HRESULT AAFSetProgressCallback(IAAFProgress*  pProgress)
    cdef HRESULT AAFSetDiagnosticOutput(IAAFDiagnosticOutput*  pOutput)
    cdef HRESULT AAFGetLibraryVersion(aafProductVersion_t *  pVersion)
    cdef HRESULT AAFGetStaticLibraryVersion(aafProductVersion_t *  pVersion)
    cdef HRESULT AAFGetLibraryPathNameBufLen(aafUInt32 *  pBufSize)
    cdef HRESULT AAFGetLibraryPathName(aafCharacter *  pLibraryPathName, aafUInt32  bufSize)
    cdef HRESULT AAFLoad(char *dllname)
    cdef HRESULT AAFGetPluginManager(IAAFPluginManager **ppPluginManager)
