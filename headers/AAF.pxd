
cdef extern from "AAFStoredObjectIDs.h":
    pass

cdef extern from "AAF.h":

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
        
    cdef GUID IID_IAAFPluginManager
    cdef cppclass IAAFPluginManager(IUnknown):
        HRESULT RegisterSharedPlugins()
    
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
    
    cdef aafUID_t AUID_AAFDictionary
    cdef GUID IID_IAAFDictionary
    cdef cppclass IAAFDictionary(IUnknown):
        HRESULT CreateInstance(
            aafUID_t id,
            GUID riid,
            IUnknown ** ppvObject
        )
        HRESULT LookupDataDef(
            aafUID_t &dataDefinitionId,
            IAAFDataDef ** ppDataDef
        )
        
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
        HRESULT LookupMob(
            aafMobID_t &mobID,
            IAAFMob ** ppMob
        )
    # MetaDefinitions
    
    cdef GUID IID_IAAFMetaDefinition
    cdef cppclass IAAFMetaDefinition(IUnknown):
        HRESULT GetNameBufLen(aafUInt32 *pBufSize)
        HRESULT GetName(
            aafCharacter *pName,
            aafUInt32  bufSize
        )
    
    cdef GUID IID_IAAFClassDef
    cdef cppclass IAAFClassDef(IUnknown):
        pass
        
    cdef GUID IID_IAAFPropertyDef
    cdef cppclass IAAFPropertyDef(IUnknown):
        pass
    
    cdef GUID IID_IAAFTypeDef
    cdef cppclass IAAFTypeDef(IUnknown):
        HRESULT GetTypeCategory(eAAFTypeCategory_t *pTid)
        
    cdef GUID IID_IAAFTypeDefCharacter
    cdef cppclass IAAFTypeDefCharacter(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefEnum
    cdef cppclass IAAFTypeDefEnum(IUnknown):
        HRESULT GetElementType(IAAFTypeDef ** ppTypeDef)
        HRESULT CountElements(aafUInt32 *pCount)
        HRESULT GetElementName(
            aafUInt32  index,
            aafCharacter *  pOutValue,
            aafUInt32  bufSize
        )
        HRESULT GetElementNameBufLen(
            aafUInt32  index,
            aafUInt32 *  pLen
        )
        HRESULT GetElementValue(
            aafUInt32  index,
            aafInt64 *  pOutValue
        )
        HRESULT GetNameFromValue(
            IAAFPropertyValue * pValue,
            aafCharacter *  pName,
            aafUInt32  bufSize
        )
        HRESULT GetNameBufLenFromValue(
            IAAFPropertyValue * pValue,
            aafUInt32 *  pLen
        )

    cdef GUID IID_IAAFTypeDefExtEnum
    cdef cppclass IAAFTypeDefExtEnum(IUnknown):
        HRESULT CountElements(aafUInt32 *pCount)
        HRESULT GetElementName(
            aafUInt32  index,
            aafCharacter *  pOutValue,
            aafUInt32  bufSize
        )
        HRESULT GetElementNameBufLen(
            aafUInt32  index,
            aafUInt32 *  pLen
        )
        HRESULT GetElementValue(
            aafUInt32  index,
            aafUID_t *  pOutValue
        )
        
        HRESULT GetNameFromValue(
            IAAFPropertyValue * pValue,
            aafCharacter *  pName,
            aafUInt32  bufSize
        )
        HRESULT GetNameBufLenFromValue(
            IAAFPropertyValue * pValue,
            aafUInt32 *  pLen
        )
        

    cdef GUID IID_IAAFTypeDefFixedArray
    cdef cppclass IAAFTypeDefFixedArray(IUnknown):
        HRESULT GetElements(
            IAAFPropertyValue *PSetPropVal,
            IEnumAAFPropertyValues ** ppEnum
        )

    cdef GUID IID_IAAFTypeDefIndirect
    cdef cppclass IAAFTypeDefIndirect(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefInt
    cdef cppclass IAAFTypeDefInt(IUnknown):
        HRESULT GetSize(aafUInt32 *pSize)
        HRESULT IsSigned(aafBoolean_t *pSigned)
        HRESULT GetInteger(
            IAAFPropertyValue *pPropVal,
            aafMemPtr_t  pVal,
            aafUInt32 valSize
        )

    cdef GUID IID_IAAFTypeDefObjectRef
    cdef cppclass IAAFTypeDefObjectRef(IUnknown):
        HRESULT GetObjectType(IAAFClassDef ** ppObjType)
        HRESULT GetObject(
            IAAFPropertyValue * pPropVal,
            GUID iid,
            IUnknown ** ppObject
        )

    cdef GUID IID_IAAFTypeDefOpaque
    cdef cppclass IAAFTypeDefOpaque(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefRecord
    cdef cppclass IAAFTypeDefRecord(IUnknown):
        HRESULT GetCount(aafUInt32 *pCount)
        HRESULT GetMemberType(
            aafUInt32  index,
            IAAFTypeDef **ppTypeDef
        )
        HRESULT GetMemberName(
            aafUInt32  index,
            aafCharacter *  pName,
            aafUInt32  bufSize
        )
        HRESULT GetMemberNameBufLen(
            aafUInt32  index,
            aafUInt32 *pLen
        )
        HRESULT GetValue(
            IAAFPropertyValue * pInPropVal,
            aafUInt32  index,
            IAAFPropertyValue **ppOutPropVal
        )
        
    cdef GUID IID_IAAFTypeDefRename
    cdef cppclass IAAFTypeDefRename(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefSet
    cdef cppclass IAAFTypeDefSet(IUnknown):
        HRESULT GetElements(
            IAAFPropertyValue *PSetPropVal,
            IEnumAAFPropertyValues ** ppEnum
        )

    cdef GUID IID_IAAFTypeDefStream
    cdef cppclass IAAFTypeDefStream(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefString
    cdef cppclass IAAFTypeDefString(IUnknown):
        HRESULT GetCount(
            IAAFPropertyValue *pPropVal,
            aafUInt32 * pCount
        )
        HRESULT GetElements(
            IAAFPropertyValue *pPropVal,
            aafMemPtr_t  pBuffer,
            aafUInt32  bufferSize,
        )
            

    cdef GUID IID_IAAFTypeDefStrongObjRef
    cdef cppclass IAAFTypeDefStrongObjRef(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefVariableArray
    cdef cppclass IAAFTypeDefVariableArray(IUnknown):
        HRESULT GetType(IAAFTypeDef ** ppTypeDef)
        HRESULT GetCount(
            IAAFPropertyValue * pPropVal,
            aafUInt32 *  pCount,
        )
        HRESULT GetElements(
            IAAFPropertyValue *PSetPropVal,
            IEnumAAFPropertyValues ** ppEnum
        )

    cdef GUID IID_IAAFTypeDefVariableArrayEx
    cdef cppclass IAAFTypeDefVariableArrayEx(IUnknown):
        pass

    cdef GUID IID_IAAFTypeDefWeakObjRef
    cdef cppclass IAAFTypeDefWeakObjRef(IUnknown):
        pass
        
    # Properties
    
    cdef GUID IID_IAAFProperty
    cdef cppclass IAAFProperty(IUnknown):
        HRESULT GetDefinition(IAAFPropertyDef **ppPropDef)
        HRESULT GetValue(IAAFPropertyValue **ppValue)
    
    cdef GUID IID_IAAFPropertyValue
    cdef cppclass IAAFPropertyValue(IUnknown):
        HRESULT GetType(IAAFTypeDef **ppTypeDef)
        
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
        
    # File Locators
    
    cdef aafUID_t AUID_AAFLocator
    cdef GUID IID_IAAFLocator
    cdef cppclass IAAFLocator(IUnknown):
        pass
        
    # EssenceAccess
    
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
        
    cdef aafUID_t AUID_AAFEssenceDescriptor 
    cdef GUID IID_IAAFEssenceDescriptor
    cdef cppclass IAAFEssenceDescriptor(IUnknown):
        pass
        
    cdef aafUID_t AUID_AAFFileDescriptor
    cdef GUID IID_IAAFFileDescriptor
    cdef cppclass IAAFFileDescriptor(IUnknown):
        pass
        
    cdef aafUID_t AUID_AAFWAVEDescriptor
    cdef GUID IID_IAAFWAVEDescriptor
    cdef cppclass IAAFWAVEDescriptor(IUnknown):
        pass
    
    cdef aafUID_t AUID_AAFDigitalImageDescriptor
    cdef GUID IID_IAAFDigitalImageDescriptor
    cdef cppclass IAAFDigitalImageDescriptor(IUnknown):
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

    cdef aafUID_t AUID_AAFCDCIDescriptor
    cdef GUID IID_IAAFCDCIDescriptor
    cdef cppclass IAAFCDCIDescriptor(IUnknown):
        HRESULT SetComponentWidth(aafInt32  ComponentWidth)
        HRESULT GetComponentWidth(aafInt32  *pComponentWidth)
        HRESULT SetHorizontalSubsampling(aafUInt32 HorizontalSubsampling)
        HRESULT GetHorizontalSubsampling(aafUInt32 *HorizontalSubsampling)
        HRESULT SetVerticalSubsampling(aafUInt32 VerticalSubsampling)
        HRESULT GetVerticalSubsampling(aafUInt32 *pVerticalSubsampling)
        HRESULT SetColorRange(aafUInt32 ColorRange)
        HRESULT GetColorRange(aafUInt32 *  pColorRange)
        
    # Mobs
    
    cdef aafUID_t AUID_AAFMob
    cdef GUID IID_IAAFMob
    cdef cppclass IAAFMob(IUnknown):
        HRESULT GetMobID(aafMobID_t *pMobID)
        HRESULT GetNameBufLen(aafUInt32 *pBufSize)
        HRESULT GetName(
            aafCharacter *pName,
            aafUInt32  bufSize
        )
        HRESULT SetName(aafCharacter *pName)
        HRESULT GetSlots(IEnumAAFMobSlots **ppEnum)
        HRESULT CountSlots(aafNumSlots_t *  pNumSlots)
        HRESULT AppendNewTimelineSlot(
            aafRational_t  editRate,
            IAAFSegment * pSegment,
            aafSlotID_t  slotID,
            aafCharacter  *pSlotName,
            aafPosition_t  origin,
            IAAFTimelineMobSlot ** ppNewSlot
        )
        
    cdef aafUID_t AUID_AAFMasterMob
    cdef GUID IID_IAAFMasterMob
    cdef cppclass IAAFMasterMob(IUnknown):
        HRESULT Initialize()
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
    
    cdef aafUID_t AUID_AAFMasterMob2
    cdef GUID IID_IAAFMasterMob2
    cdef cppclass IAAFMasterMob2(IUnknown):
        pass
    
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
        HRESULT GetEssenceDescriptor(IAAFEssenceDescriptor ** ppEssence)
    
    cdef aafUID_t AUID_AAFMobSlot
    cdef GUID IID_IAAFMobSlot
    cdef cppclass IAAFMobSlot(IUnknown):
        HRESULT GetSegment(IAAFSegment ** ppResult)
    
    cdef aafUID_t AUID_AAFTimelineMobSlot
    cdef GUID IID_IAAFTimelineMobSlot
    cdef cppclass IAAFTimelineMobSlot(IUnknown):
        pass
    
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
    
    cdef aafUID_t AUID_AAFSegment
    cdef GUID IID_IAAFSegment
    cdef cppclass IAAFSegment(IUnknown):
        pass
        
    cdef aafUID_t AUID_AAFSequence
    cdef GUID IID_IAAFSequence
    cdef cppclass IAAFSequence(IUnknown):
        HRESULT Initialize(IAAFDataDef * pDataDef)
        HRESULT GetComponents(IEnumAAFComponents ** ppEnum)
    
    cdef aafUID_t AUID_AAFSourceReference
    cdef GUID IID_IAAFSourceReference
    cdef cppclass IAAFSourceReference(IUnknown):
        pass
        
    cdef aafUID_t AUID_AAFSourceClip
    cdef GUID IID_IAAFSourceClip
    cdef cppclass IAAFSourceClip(IUnknown):
        HRESULT Initialize(
            IAAFDataDef * pDataDef,
            aafLength_t&  length,
            aafSourceRef_t  sourceRef
        )
        HRESULT ResolveRef(IAAFMob ** ppMob)

    cdef aafUID_t AUID_AAFOperationGroup
    cdef GUID IID_IAAFOperationGroup
    cdef cppclass IAAFOperationGroup(IUnknown):
        HRESULT CountSourceSegments(aafUInt32 *  pResult)
        HRESULT GetInputSegmentAt(
            aafUInt32  index,
            IAAFSegment ** ppInputSegment
        )
        
        
    cdef aafUID_t AUID_AAFNestedScope
    cdef GUID IID_IAAFNestedScope
    cdef cppclass IAAFNestedScope(IUnknown):
        HRESULT GetSegments(IEnumAAFSegments ** ppEnum)
        
    ## IEnumAAFs
    
    cdef GUID IID_IEnumAAFComponents
    cdef cppclass IEnumAAFComponents(IUnknown):
        HRESULT NextOne(IAAFComponent ** ppComponent)
        
    cdef GUID IID_IEnumAAFMobs
    cdef cppclass IEnumAAFMobs(IUnknown):
        HRESULT NextOne(IAAFMob ** ppMob)
        
    cdef GUID IID_IEnumAAFMobSlots
    cdef cppclass IEnumAAFMobSlots(IUnknown):
        HRESULT NextOne(IAAFMobSlot ** ppMob)
    
    
    cdef GUID IID_IEnumAAFProperties
    cdef cppclass IEnumAAFProperties(IUnknown):
        HRESULT NextOne(IAAFProperty ** ppMob)
        
    cdef GUID IID_IEnumAAFPropertyValues
    cdef cppclass IEnumAAFPropertyValues(IUnknown):
        HRESULT NextOne(IAAFPropertyValue ** ppPropertyValue)
        
    cdef GUID IID_IEnumAAFSegments
    cdef cppclass IEnumAAFSegments(IUnknown):
        HRESULT NextOne(IAAFSegment ** ppSegment)
        
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
            
    
    cdef HRESULT AAFLoad(char *dllname)
    cdef HRESULT AAFGetPluginManager(IAAFPluginManager **ppPluginManager)
