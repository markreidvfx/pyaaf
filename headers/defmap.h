#include <AAFDataDefs.h>
#include <AAFCodecDefs.h>
#include <AAFContainerDefs.h>
#include <AAFCompressionDefs.h>
#include <AAFTypes.h>
#include <AAFEssenceFormats.h>
#include <map>
#include <string>


std::map<std::string, aafUID_t> get_datadef_map()
{
    std::map<std::string, aafUID_t> def_map;
    #define MAP_ADD( NAME ) def_map[ #NAME ] = NAME;
    MAP_ADD(kAAFDataDef_Picture)
    MAP_ADD(kAAFDataDef_Picture)
    MAP_ADD(kAAFDataDef_LegacyPicture)
    MAP_ADD(kAAFDataDef_Matte)
    MAP_ADD(kAAFDataDef_PictureWithMatte)
    MAP_ADD(kAAFDataDef_Sound)
    MAP_ADD(kAAFDataDef_LegacySound)
    MAP_ADD(kAAFDataDef_Timecode)
    MAP_ADD(kAAFDataDef_LegacyTimecode)
    MAP_ADD(kAAFDataDef_Edgecode)
    MAP_ADD(kAAFDataDef_DescriptiveMetadata)
    MAP_ADD(kAAFDataDef_Auxiliary)
    MAP_ADD(kAAFDataDef_Unknown)
    #undef MAP_ADD

    return def_map;
    
}

std::map<std::string, aafUID_t> get_codecdef_map()
{
    std::map<std::string, aafUID_t> def_map;
    #define MAP_ADD( NAME ) def_map[ #NAME ] = NAME;
    MAP_ADD(kAAFCodecDef_None)
    MAP_ADD(kAAFCodecDef_PCM)
    MAP_ADD(kAAFCodecDef_WAVE)
    MAP_ADD(kAAFCodecDef_AIFC)
    MAP_ADD(kAAFCodecDef_JPEG)
    MAP_ADD(kAAFCodecDef_CDCI)
    MAP_ADD(kAAFCodecDef_RGBA)
    MAP_ADD(kAAFCodecDef_VC3)
    MAP_ADD(kAAFCodecDef_DNxHD)
    MAP_ADD(kAAFCodecFlavour_None)
    MAP_ADD(kAAFCodecFlavour_DV_Based_100Mbps_1080x50I)
    MAP_ADD(kAAFCodecFlavour_DV_Based_100Mbps_1080x5994I)
    MAP_ADD(kAAFCodecFlavour_DV_Based_100Mbps_720x50P)
    MAP_ADD(kAAFCodecFlavour_DV_Based_100Mbps_720x5994P)
    MAP_ADD(kAAFCodecFlavour_DV_Based_25Mbps_525_60)
    MAP_ADD(kAAFCodecFlavour_DV_Based_25Mbps_625_50)
    MAP_ADD(kAAFCodecFlavour_DV_Based_50Mbps_525_60)
    MAP_ADD(kAAFCodecFlavour_DV_Based_50Mbps_625_50)
    MAP_ADD(kAAFCodecFlavour_IEC_DV_525_60)
    MAP_ADD(kAAFCodecFlavour_IEC_DV_625_50)
    MAP_ADD(kAAFCodecFlavour_LegacyDV_525_60)
    MAP_ADD(kAAFCodecFlavour_LegacyDV_625_50)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_50Mbps_625x50I)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_50Mbps_525x5994I)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_40Mbps_625x50I)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_40Mbps_525x5994I)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_30Mbps_625x50I)
    MAP_ADD(kAAFCodecFlavour_SMPTE_D10_30Mbps_525x5994I)
    MAP_ADD(kAAFCodecFlavour_VC3_1235)
    MAP_ADD(kAAFCodecFlavour_VC3_1237)
    MAP_ADD(kAAFCodecFlavour_VC3_1238)
    MAP_ADD(kAAFCodecFlavour_VC3_1241)
    MAP_ADD(kAAFCodecFlavour_VC3_1242)
    MAP_ADD(kAAFCodecFlavour_VC3_1243)
    MAP_ADD(kAAFCodecFlavour_VC3_1244)
    MAP_ADD(kAAFCodecFlavour_VC3_1250)
    MAP_ADD(kAAFCodecFlavour_VC3_1251)
    MAP_ADD(kAAFCodecFlavour_VC3_1252)
    MAP_ADD(kAAFCodecFlavour_VC3_1253)
    MAP_ADD(kAAFCodecFlavour_VC3_1254)
    #undef MAP_ADD
    
    return def_map;
    
}

std::map<std::string, aafUID_t> get_container_def_map()
{
    std::map<std::string, aafUID_t> def_map;
    #define MAP_ADD( NAME ) def_map[ #NAME ] = NAME;
    MAP_ADD(kAAFContainerDef_External)
    MAP_ADD(kAAFContainerDef_OMF)
    MAP_ADD(kAAFContainerDef_AAF)
    MAP_ADD(kAAFContainerDef_AAFMSS)
    MAP_ADD(kAAFContainerDef_AAFKLV)
    MAP_ADD(kAAFContainerDef_AAFXML)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_50Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_50Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_50Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_50Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_50Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_50Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_40Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_40Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_40Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_40Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_40Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_40Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_30Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_30Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_625x50I_30Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_30Mbps_DefinedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_30Mbps_ExtendedTemplate)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_SMPTE_D10_525x5994I_30Mbps_PictureOnly)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_IECDV_525x5994I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_IECDV_525x5994I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_IECDV_625x50I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_IECDV_625x50I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_IECDV_525x5994I_25Mbps_SMPTE322M)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_IECDV_525x5994I_25Mbps_SMPTE322M)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_IECDV_625x50I_25Mbps_SMPTE322M)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_IECDV_625x50I_25Mbps_SMPTE322M)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_IECDV_UndefinedSource_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_IECDV_UndefinedSource_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_525x5994I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_525x5994I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_625x50I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_625x50I_25Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_525x5994I_50Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_525x5994I_50Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_625x50I_50Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_625x50I_50Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_1080x5994I_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_1080x5994I_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_1080x50I_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_1080x50I_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_720x5994P_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_720x5994P_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_720x50P_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_720x50P_100Mbps)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_DVbased_UndefinedSource)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_DVbased_UndefinedSource)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_MPEGES_VideoStream0_SID)
    MAP_ADD(kAAFContainerDef_MXFGC_CustomClosedGOPwrapped_MPEGES_VideoStream1_SID)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Uncompressed_525x5994I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Uncompressed_525x5994I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Linewrapped_Uncompressed_525x5994I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Uncompressed_625x50I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Uncompressed_625x50I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Linewrapped_Uncompressed_625x50I_720_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Uncompressed_525x5994P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Uncompressed_525x5994P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Linewrapped_Uncompressed_525x5994P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Uncompressed_625x50P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Uncompressed_625x50P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Linewrapped_Uncompressed_625x50P_960_422)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Broadcast_Wave_audio_data)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Broadcast_Wave_audio_data)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_AES3_audio_data)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_AES3_audio_data)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_Alaw_Audio)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_Alaw_Audio)
    MAP_ADD(kAAFContainerDef_MXFGC_Customwrapped_Alaw_Audio)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_AVCbytestream_VideoStream0_SID)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_VC3)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_VC3)
    MAP_ADD(kAAFContainerDef_MXFGC_Framewrapped_VC1)
    MAP_ADD(kAAFContainerDef_MXFGC_Clipwrapped_VC1)
    MAP_ADD(kAAFContainerDef_MXFGC_Generic_Essence_Multiple_Mappings)
    MAP_ADD(kAAFContainerDef_RIFFWAVE)
    MAP_ADD(kAAFContainerDef_JFIF)
    MAP_ADD(kAAFContainerDef_AIFFAIFC)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220X_1080p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_145_1080p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220_1080p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_36_1080p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220X_1080i)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_145_1080i)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220_1080i)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_145_1440_1080i)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220X_720p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_220_720p)
    MAP_ADD(kAAFContainerDef_MXFGC_Avid_DNX_145_720p)
    #undef MAP_ADD
    
    return def_map;
}

std::map<std::string, aafUID_t> get_compressiondef_map()
{
    std::map<std::string, aafUID_t> def_map;
    #define MAP_ADD( NAME ) def_map[ #NAME ] = NAME;

    MAP_ADD(kAAFCompressionDef_AAF_CMPR_FULL_JPEG)
    MAP_ADD(kAAFCompressionDef_AAF_CMPR_AUNC422)
    MAP_ADD(kAAFCompressionDef_LegacyDV)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_50Mbps_625x50I)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_50Mbps_525x5994I)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_40Mbps_625x50I)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_40Mbps_525x5994I)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_30Mbps_625x50I)
    MAP_ADD(kAAFCompressionDef_SMPTE_D10_30Mbps_525x5994I)
    MAP_ADD(kAAFCompressionDef_IEC_DV_525_60)
    MAP_ADD(kAAFCompressionDef_IEC_DV_625_50)
    MAP_ADD(kAAFCompressionDef_DV_Based_25Mbps_525_60)
    MAP_ADD(kAAFCompressionDef_DV_Based_25Mbps_625_50)
    MAP_ADD(kAAFCompressionDef_DV_Based_50Mbps_525_60)
    MAP_ADD(kAAFCompressionDef_DV_Based_50Mbps_625_50)
    MAP_ADD(kAAFCompressionDef_DV_Based_100Mbps_1080x5994I)
    MAP_ADD(kAAFCompressionDef_DV_Based_100Mbps_1080x50I)
    MAP_ADD(kAAFCompressionDef_DV_Based_100Mbps_720x5994P)
    MAP_ADD(kAAFCompressionDef_DV_Based_100Mbps_720x50P)
    MAP_ADD(kAAFCompressionDef_VC3_1)
    MAP_ADD(kAAFCompressionDef_Avid_DNxHD_Legacy)
    #undef MAP_ADD
    return def_map;
}

std::map<std::string, std::pair< aafUID_t, std::string > > get_essenceformats_def_map()
{
    std::map<std::string, std::pair< aafUID_t, std::string > > def_map;
    #define MAP_ADD( NAME, TYPE) def_map[ #NAME ] =  std::pair<aafUID_t, std::string >(NAME, #TYPE) ;
    MAP_ADD(kAAFCompression, operand.expAuid)
    MAP_ADD(kAAFPixelFormat, operand.expPixelFormat)
    MAP_ADD(kAAFFrameLayout, operand.expFrameLayout)
    MAP_ADD(kAAFFieldDominance, operand.expFieldDom)
    MAP_ADD(kAAFStoredRect, operand.expRect)
    MAP_ADD(kAAFDisplayRect, operand.expRect)
    MAP_ADD(kAAFSampledRect, operand.expRect)
    MAP_ADD(kAAFPixelSize, operand.expInt16)
    MAP_ADD(kAAFAspectRatio, operand.expRational)
    MAP_ADD(kAAFAlphaTransparency, operand.expInt32)
    MAP_ADD(kAAFGamma, operand.expRational)
    MAP_ADD(kAAFImageAlignmentFactor, operand.expInt32)
    MAP_ADD(kAAFVideoLineMap, operand.expLineMap)
    MAP_ADD(kAAFWillTransferLines, operand.expBoolean)
    MAP_ADD(kAAFIsCompressed, operand.expBoolean)
    MAP_ADD(kAAFLineLength, operand.expInt32)
    // exclusive to RGBA codec
    MAP_ADD(kAAFRGBCompLayout, operand.expCompArray)
    MAP_ADD(kAAFRGBCompSizes, operand.expCompSizeArray)
    MAP_ADD(kAAFRGBPalette, operand.expPointer)
    MAP_ADD(kAAFRGBPaletteLayout, operand.expCompArray)
    MAP_ADD(kAAFRGBPaletteSizes, operand.expCompSizeArray)
    //exclusive to CDCI codec
    MAP_ADD(kAAFCDCICompWidth, operand.expInt32)
    MAP_ADD(kAAFCDCIHorizSubsampling, operand.expUInt32)
    MAP_ADD(kAAFCDCIColorSiting, operand.expColorSiting)
    MAP_ADD(kAAFCDCIBlackLevel, operand.expUInt32)
    MAP_ADD(kAAFCDCIWhiteLevel, operand.expUInt32)
    MAP_ADD(kAAFCDCIColorRange, operand.expUInt32)
    MAP_ADD(kAAFCDCIPadBits, operand.expInt16)
    MAP_ADD(kAAFFieldStartOffset, ?operand.expUInt32)
    MAP_ADD(kAAFFieldEndOffset, ?operand.expUInt32)
    //Legacy
    MAP_ADD(kAAFLegacyCDCI, ?operand.expUInt32)
    MAP_ADD(kAAFResolutionID, operand.expUInt32)
    MAP_ADD(kAAFAudioSampleBits, operand.expInt32)
    MAP_ADD(kAAFMaxSampleBytes, ?operand.expUInt32)
    MAP_ADD(kAAFSampleRate, ?operand.expUInt32)
    MAP_ADD(kAAFSampleFormat, ?operand.expUInt32)
    MAP_ADD(kAAFNumChannels, operand.expUInt32)
    MAP_ADD(kAAFPadBytesPerRow, ?operand.expUInt32)
    MAP_ADD(kAAFCompressionQuality, ?operand.expUInt32)
    MAP_ADD(kAAFLegacyAUIDs, ?operand.expUInt32) 
    MAP_ADD(kAAFEssenceElementKey, ?operand.expUInt32) 
    MAP_ADD(kAAFPhysicalTrackNum, ?operand.expUInt32) 
    MAP_ADD(kAAFNumThreads, ?operand.expUInt32) 
    MAP_ADD(kAAFBufferLayout, ?operand.expUInt32)
    
    #undef MAP_ADD
    
    return def_map;
}
