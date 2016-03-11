
cdef object DIAGNOSTIC_OUTPUT_CALLBACK = None

import sys

def set_diagnostic_output_callback(callback):
    """Warning exceptions raised during callback function will be ignored
    """
    setup_diagnostic_output_callback()
    global DIAGNOSTIC_OUTPUT_CALLBACK
    DIAGNOSTIC_OUTPUT_CALLBACK = callback

cdef lib.HRESULT diagnostic_output_handler(const lib.aafCharacter *p_message , size_t size)with gil:

    # copy message to AAFCharBuffer

    cdef AAFCharBuffer buf = AAFCharBuffer.__new__(AAFCharBuffer)
    buf.size = size
    memcpy(buf.get_ptr(), p_message, size * sizeof(lib.aafCharacter))

    string = buf.read_str()

    # send string to diagnostic callback or print to stderr if no callback set

    global DIAGNOSTIC_OUTPUT_CALLBACK

    if DIAGNOSTIC_OUTPUT_CALLBACK:
        DIAGNOSTIC_OUTPUT_CALLBACK(string)
    else:
        sys.stderr.write(string)

    return lib.AAFRESULT_SUCCESS

cdef setup_diagnostic_output_callback():
    cdef lib.IAAFDiagnosticOutput *p = NULL
    try:
        error_check(lib.CreateDiagnosticOutputCallback(&p, diagnostic_output_handler))
        error_check(lib.AAFSetDiagnosticOutput(p))
    except:
        raise
    finally:
        if p:
            p.Release()
