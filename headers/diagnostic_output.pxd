
cdef extern from "diagnostic_output.h":
    cdef HRESULT CreateDiagnosticOutputCallback(IAAFDiagnosticOutput** pOutput, HRESULT (*callback_func)(aafCharacter *, size_t))
    cdef cppclass DiagnosticOutput(IAAFDiagnosticOutput):
        pass
