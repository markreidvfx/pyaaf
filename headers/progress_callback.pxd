
cdef extern from "progress_callback.h":
    cdef HRESULT CreateProgressCallback(IAAFProgress** ppProgress, HRESULT (*callback_func)())
    cdef cppclass Progress(IAAFProgress):
        pass
