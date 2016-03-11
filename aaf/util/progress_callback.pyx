
cdef object PROGRESS_CALLBACK = None

def set_progress_callback(callback):
    """Warning exceptions raised during callback function will be ignored
    """
    setup_progress_callback()

    global PROGRESS_CALLBACK
    PROGRESS_CALLBACK = callback

cdef lib.HRESULT progress_callback_handler()with gil:

    global PROGRESS_CALLBACK
    if PROGRESS_CALLBACK:
        PROGRESS_CALLBACK()

    return lib.AAFRESULT_SUCCESS

cdef setup_progress_callback():
    cdef lib.IAAFProgress *p = NULL
    try:
        error_check(lib.CreateProgressCallback(&p, progress_callback_handler))
        error_check(lib.AAFSetProgressCallback(p))
    except:
        raise
    finally:
        if p:
            p.Release()
