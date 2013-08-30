from libc.stddef cimport wchar_t
from libc.stdint cimport int64_t, uint64_t

cdef extern from *:
    ctypedef signed char aafInt8 "signed char"
    ctypedef signed short int aafInt16 "signed short int"
    ctypedef signed int aafInt32 "signed int"
    ctypedef int64_t aafInt64
    
    ctypedef unsigned char aafUInt8 "unsigned char"
    ctypedef unsigned short int aafUInt16 "unsigned short int"
    ctypedef unsigned int aafUInt32 "unsigned int"
    ctypedef uint64_t aafUInt64
    
    ctypedef aafInt32 aafBoolean_t 
    
    ctypedef unsigned int DWORD "unsigned int"
    ctypedef unsigned short WORD "unsigned short"
    ctypedef unsigned char BYTE "unsigned char"
    
    ctypedef aafInt32 AAFRESULT
    
    ctypedef int SCODE
    ctypedef int HRESULT
    
    ctypedef wchar_t aafCharacter    
    
    ctypedef unsigned char * aafMemPtr_t "unsigned char *"
    ctypedef aafUInt8 * aafDataBuffer_t "aafUInt8 *"
    

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
        
        
    # Mob specific data types
    
    ctypedef aafInt64 aafLength_t
    
    # Types for mob slots
    ctypedef aafInt64 aafPosition_t
    ctypedef aafInt64 aafFrameOffset_t
    ctypedef aafInt64 aafFrameLength_t
    ctypedef aafUInt32 aafSlotID_t
    
    ctypedef aafUInt32 aafNumSlots_t

        
    ctypedef aafInt32 aafMobKind_t
    
    cdef enum aafMobKind_e:
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
    
    cdef enum aafFadeType_e:
        kAAFFadeNone
        kAAFFadeLinearAmp
        kAAFFadeLinearPower
    
    ctypedef struct aafDefaultFade_t:
        aafLength_t fadeLength
        aafFadeType_t fadeType
        aafRational_t fadeEditUnit
        aafBoolean_t valid

    # Data Types for Search Criteria and Iterators
     
    ctypedef aafInt32 aafSearchTag_t
    
    cdef enum aafSearchTag_e:
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
    
    cdef union tags_t:
        aafMobID_t mobID
        aafMobKind_t mobKind
        aafUID_t usageCode
        
    ctypedef struct aafSearchCrit_t:
        aafSearchTag_t searchTag
        tags_t tags
    
 
    ctypedef aafInt32 aafColorSpace_t
    
    cdef enum aafColorSpace_e: 
        kAAFColorSpaceRGB
        kAAFColorSpaceYUV
        kAAFColorSpaceYIQ
        kAAFColorSpaceHSI
        kAAFColorSpaceHSV 
        kAAFColorSpaceYCrCb 
        kAAFColorSpaceYDrDb
        kAAFColorSpaceCMYK
        
    ctypedef aafInt32 aafFrameLayout_t
    
    cdef enum aafFrameLayout_e:
        kAAFFullFrame
        kAAFSeparateFields
        kAAFOneField
        kAAFMixedFields
        kAAFSegmentedFrame
            
    ctypedef aafInt32 aafCompressEnable_t
    
    cdef enum aafCompressEnable_e:
        kAAFCompressionEnable
        kAAFCompressionDisable

    #  Enum indicating general category of stored (property) data
    
    ctypedef aafInt32 eAAFTypeCategory_t
    
    cdef enum eAAFTypeCategory_e:
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

        