cdef extern from "AAFPlugin.h":
    #cdef aafUID_t AUID_AAFInterpolator
    cdef GUID IID_IAAFInterpolator

    cdef cppclass IAAFInterpolator(IUnknown):
        HRESULT SetParameter(IAAFParameter * pParameter)

    #cdef aafUID_t AUID_AAFPlugin
    cdef GUID IID_IAAFPlugin
    cdef cppclass IAAFPlugin(IUnknown):
        pass
