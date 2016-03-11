from libc.stddef cimport wchar_t

cdef extern from *:
    ctypedef signed char aafInt8 "aafInt8"
    ctypedef signed short int aafInt16 "aafInt16"
    ctypedef signed int aafInt32 "aafInt32"
    ctypedef long long aafInt64 "aafInt64"

    ctypedef unsigned char aafUInt8 "aafUInt8"
    ctypedef unsigned short int aafUInt16 "aafUInt16"
    ctypedef unsigned int aafUInt32 "aafUInt32"
    ctypedef unsigned long long aafUInt64 "aafUInt64"

    ctypedef aafInt32 aafBoolean_t "aafBoolean_t"

    ctypedef unsigned int DWORD "DWORD"
    ctypedef unsigned short WORD "WORD"
    ctypedef unsigned char BYTE "BYTE"

    ctypedef aafInt32 AAFRESULT "AAFRESULT"

    ctypedef int SCODE "SCODE"
    ctypedef int HRESULT "HRESULT"

    ctypedef wchar_t aafCharacter "aafCharacter"

    ctypedef unsigned char UChar "unsigned char"

    ctypedef aafUInt8 * aafMemPtr_t "aafMemPtr_t"
    ctypedef aafUInt8 * aafDataBuffer_t "aafDataBuffer_t"

    ctypedef aafCharacter * aafString_t

    ctypedef aafInt32 aafFileFormat_t


cdef extern from "AAFTypes.h":

    ctypedef struct aafUID_t:
        aafUInt32 Data1
        aafUInt16 Data2
        aafUInt16 Data3
        aafUInt8  Data4[8]
    ctypedef const aafUID_t& aafUID_constref "const aafUID_t&"

    ctypedef struct aafMobID_t:
        aafUInt8 SMPTELabel[12]
        aafUInt8 length
        aafUInt8 instanceHigh
        aafUInt8 instanceMid
        aafUInt8 instanceLow
        aafUID_t material

    ctypedef struct aafRational_t:
        aafInt32 numerator
        aafInt32 denominator

    ctypedef struct aafRect_t:
        aafInt32 xOffset
        aafInt32 yOffset
        aafInt32 xSize
        aafInt32 ySize

    ctypedef aafInt32 aafProductReleaseType_t

    ctypedef struct aafProductVersion_t:
        aafUInt16 major
        aafUInt16 minor
        aafUInt16 tertiary
        aafUInt16 patchLevel
        aafProductReleaseType_t type

    ctypedef struct aafProductIdentification_t:
        aafCharacter * companyName
        aafCharacter * productName
        aafCharacter * productVersionString
        aafUID_t productID
        aafCharacter * platform #optional
        aafProductVersion_t * productVersion #optional

    ctypedef aafInt64 aafFrameOffset_t
    ctypedef aafInt32 aafDropType_t

    cdef enum aafDropType_e "_aafDropType_e":
        kAAFTcNonDrop
        kAAFTcDrop

    ctypedef struct aafTimecode_t:
        aafFrameOffset_t startFrame
        aafDropType_t  drop
        aafUInt16 fps

    # Mob specific data types

    ctypedef aafInt64 aafLength_t

    # Types for mob slots
    ctypedef aafInt64 aafPosition_t
    ctypedef aafInt64 aafFrameOffset_t
    ctypedef aafInt64 aafFrameLength_t
    ctypedef aafUInt32 aafSlotID_t

    ctypedef aafUInt32 aafNumSlots_t

    ctypedef struct aafMediaCriteria_t:
        pass

    ctypedef aafInt32 aafDepend_t

    ctypedef aafInt32 aafIncMedia_t

    ctypedef aafInt32 aafMediaOpenMode_t

    cdef enum aafMediaOpenMode_e "_aafMediaOpenMode_e":
        kAAFMediaOpenReadOnly
        kAAFMediaOpenAppend

    ctypedef aafInt32 aafMobKind_t

    cdef enum aafMobKind_e "_aafMobKind_e":
        kAAFCompMob
        kAAFMasterMob
        kAAFFileMob
        kAAFTapeMob
        kAAFFilmMob
        kAAFPrimaryMob
        kAAFAllMob
        kAAFPhysicalMob

    ctypedef struct aafSourceRef_t:
        aafMobID_t sourceID
        aafSlotID_t sourceSlotID
        aafPosition_t startTime

    ctypedef aafInt32 aafFadeType_t

    cdef enum aafFadeType_e "_aafFadeType_e":
        kAAFFadeNone
        kAAFFadeLinearAmp
        kAAFFadeLinearPower

    ctypedef struct aafDefaultFade_t:
        aafLength_t fadeLength
        aafFadeType_t fadeType
        aafRational_t fadeEditUnit
        aafBoolean_t valid

    # Typedefs specific to edgecode and timecode
    ctypedef aafInt32 aafEdgeType_t
    ctypedef aafInt32 aafFilmType_t

    ctypedef aafUInt8 aafEdgecodeHeader_t[8]

    cdef enum aafEdgeType_e "_aafEdgeType_e":
        kAAFEtNull
        kAAFEtKeycode
        kAAFEtEdgenum4
        kAAFEtEdgenum5
        kAAFEtHeaderSize

    cdef enum aafFilmType_e "_aafFilmType_e":
        kAAFFtNull
        kAAFFt35MM
        kAAFFt16MM
        kAAFFt8MM
        kAAFFt65MM

    ctypedef struct aafEdgecode_t:
        aafFrameOffset_t   startFrame
        aafFilmType_t   filmKind
        aafEdgeType_t codeFormat
        aafEdgecodeHeader_t header

    # Operation Group Types

    ctypedef aafInt32 aafInterpKind_t

    cdef enum aafInterpKind_e "_aafInterpKind_e":
        kAAFConstInterp
        kAAFLinearInterp

    ctypedef aafInt32 aafEditHint_t

    cdef enum aafEditHint_e "_aafEditHint_e":
        kAAFNoEditHint
        kAAFProportional
        kAAFRelativeLeft
        kAAFRelativeRight
        kAAFRelativeFixed

    ctypedef aafInt32 aafProductReleaseType_t

    cdef enum aafProductReleaseType_e "_aafProductReleaseType_e":
        kAAFVersionUnknown
        kAAFVersionReleased
        kAAFVersionDebug
        kAAFVersionPatched
        kAAFVersionBeta
        kAAFVersionPrivateBuild

    # Data Types for Search Criteria and Iterators

    ctypedef aafInt32 aafSearchTag_t
    ctypedef aafInt32 aafDefinitionKind_t
    ctypedef aafInt32 aafCriteriaType_t
    ctypedef aafInt32 aafDefinitionCritType_t
    ctypedef aafInt32 aafIdentificationCritType_t

    ctypedef aafInt32 eAAFByteOrder_t

    cdef enum eAAFByteOrder_e "_eAAFByteOrder_e":
        kAAFByteOrderLittle
        kAAFByteOrderBig

    cdef enum aafSearchTag_e "_aafSearchTag_e":
        kAAFNoSearch
        kAAFByMobID
        kAAFByMobKind
        kAAFByName
        kAAFByClass
        kAAFByDataDef
        kAAFByMediaCrit
        kAAFByUsageCode
        kAAFByMasterMobUsageCode
        kAAFBySourceMobUsageCode
        kAAFByCompositionMobUsageCode

    cdef enum aafCriteriaType_e "_aafCriteriaType_e":
        kAAFAnyRepresentation
        kAAFFastestRepresentation
        kAAFBestFidelityRepresentation
        kAAFSmallestRepresentation

    cdef union tags_t:
        aafMobID_t mobID
        aafMobKind_t mobKind
        aafString_t name
        aafUID_t objClass
        aafUID_t datadef
        aafCriteriaType_t mediaCrit
        aafUID_t usageCode

    ctypedef struct aafSearchCrit_t:
        aafSearchTag_t searchTag
        tags_t tags

    cdef union def_tags_t:
        aafDefinitionKind_t defKind
        aafString_t name
        aafUID_t objClass

    ctypedef struct aafDefinitionCrit_t:
        aafDefinitionCritType_t type
        def_tags_t tags

    cdef union identification_tags_t:
        aafUID_t productID
        aafUID_t generation
        aafProductVersion_t referenceImplementationVersion

    ctypedef struct aafIdentificationCrit_t:
        aafIdentificationCritType_t type
        identification_tags_t tags

    ctypedef aafInt32 aafColorSpace_t

    cdef enum aafColorSpace_e "_aafColorSpace_e":
        kAAFColorSpaceRGB
        kAAFColorSpaceYUV
        kAAFColorSpaceYIQ
        kAAFColorSpaceHSI
        kAAFColorSpaceHSV
        kAAFColorSpaceYCrCb
        kAAFColorSpaceYDrDb
        kAAFColorSpaceCMYK

    ctypedef aafInt32 aafColorSiting_t

    cdef enum aafColorSiting_e "_aafColorSiting_e":
        kAAFCoSiting
        kAAFAveraging
        kAAFThreeTap
        kAAFQuincunx
        kAAFRec601
        kAAFUnknownSiting

    ctypedef aafInt32 aafAppendOption_t

    cdef enum aafAppendOption_e "_aafAppendOption_e":
        kAAFAppend
        kAAFForceOverwrite

    ctypedef aafInt32 aafPulldownKind_t

    cdef enum aafPulldownKind_e "_aafPulldownKind_e":
        kAAFTwoThreePD
        kAAFPALPD
        kAAFOneToOneNTSC
        kAAFOneToOnePAL
        kAAFVideoTapNTSC
        kAAFOneToOneHDSixty
        kAAFTwentyFourToSixtyPD
        kAAFTwoToOnePD

    ctypedef aafInt32 aafPulldownDir_t

    cdef enum aafPulldownDir_e "_aafPulldownDir_e":
        kAAFTapeToFilmSpeed
        kAAFFilmToTapeSpeed

    ctypedef aafInt32 aafPhaseFrame_t

    ctypedef aafInt32 aafFrameLayout_t

    cdef enum aafFrameLayout_e "_aafFrameLayout_e":
        kAAFFullFrame
        kAAFSeparateFields
        kAAFOneField
        kAAFMixedFields
        kAAFSegmentedFrame

    ctypedef aafInt32 aafCompressEnable_t

    cdef enum aafCompressEnable_e "_aafCompressEnable_e":
        kAAFCompressionEnable
        kAAFCompressionDisable

    #  Enum indicating general category of stored (property) data

    ctypedef aafInt32 eAAFTypeCategory_t

    cdef enum eAAFTypeCategory_e "_eAAFTypeCategory_e":
        kAAFTypeCatUnknown       # can only occur in damaged files
        kAAFTypeCatInt           # any integral type
        kAAFTypeCatCharacter     # any character type
        kAAFTypeCatStrongObjRef  # strong object reference
        kAAFTypeCatWeakObjRef    # weak object reference
        kAAFTypeCatRename        # renamed type
        kAAFTypeCatEnum          # enumerated type
        kAAFTypeCatFixedArray    # fixed-size array
        kAAFTypeCatVariableArray # variably-sized array
        kAAFTypeCatSet           # set of strong object references or set of weak object references
        kAAFTypeCatRecord        # a structured type
        kAAFTypeCatStream        # potentially huge amount of data
        kAAFTypeCatString        # null-terminated variably-sized array of characters
        kAAFTypeCatExtEnum       # extendible enumerated type
        kAAFTypeCatIndirect      # type must be determined at runtime
        kAAFTypeCatOpaque        # type can be determined at runtime
        kAAFTypeCatEncrypted     # type can be determined at runtime but bits are encrypted

cdef extern from "AAFExtEnum.h":
    cdef aafUID_t kAAFUsage_TopLevel
