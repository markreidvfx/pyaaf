
cdef object PROGRESS_CALLBACK = None

def set_progress_callback(callback):
    """Warning exceptions raised during callback function will be ignored
    """
    global PROGRESS_CALLBACK
    PROGRESS_CALLBACK = callback

cdef lib.HRESULT progress_callback_handler():
    
    global PROGRESS_CALLBACK
    if PROGRESS_CALLBACK:
        PROGRESS_CALLBACK()

    return lib.AAFRESULT_SUCCESS

cdef setup_progress_callback():
    cdef lib.Progress *p = NULL
    try:
        error_check(lib.CreateProgressCallback(<lib.IAAFProgress **>&p, progress_callback_handler))
        error_check(lib.AAFSetProgressCallback(<lib.IAAFProgress *>p))
    except:
        raise
    finally:
        if p:
            p.Release()
