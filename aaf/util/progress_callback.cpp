
#include "progress_callback.h"

HRESULT STDMETHODCALLTYPE
Progress::ProgressCallback ()
{
    //std::cout << " progress = " << progress << "\n";
    //progress++;

    HRESULT result = AAFRESULT_SUCCESS;

    if (callback_func != NULL)
    {
    result = callback_func();
    }
    //exit(-1);
	return result;
}

ULONG STDMETHODCALLTYPE
Progress::AddRef ()
{
	return ++_referenceCount;
}

ULONG STDMETHODCALLTYPE
Progress::Release ()
{
    aafUInt32 r = --_referenceCount;
    if (r == 0) {
        delete this;
    }
    return r;
}

HRESULT STDMETHODCALLTYPE
Progress::QueryInterface (REFIID iid, void ** ppIfc)
{
    if (ppIfc == 0)
        return AAFRESULT_NULL_PARAM;

    if (memcmp(&iid, &IID_IUnknown, sizeof(IID)) == 0) {
        IUnknown* unk = (IUnknown*) this;
        *ppIfc = (void*) unk;
        AddRef ();
        return AAFRESULT_SUCCESS;
    } else if (memcmp(&iid, &IID_IAAFProgress, sizeof(IID)) == 0) {
        IAAFProgress* cpa = this;
        *ppIfc = (void*) cpa;
        AddRef ();
        return AAFRESULT_SUCCESS;
    } else {
        return E_NOINTERFACE;
    }
}

HRESULT Progress::Create(IAAFProgress** ppProgress, HRESULT (*callback_func)())
{
    if (ppProgress == 0)
        return AAFRESULT_NULL_PARAM;

    IAAFProgress* result = new Progress();
    if (result == 0)
        return AAFRESULT_NOMEMORY;

    Progress* result_python = dynamic_cast<Progress*>(result);
    result_python->callback_func = callback_func;

    result->AddRef();
    *ppProgress = result;
    return AAFRESULT_SUCCESS;
}

Progress::Progress()
: _referenceCount(0)
{
    progress = 0;
    callback_func = NULL;
}

Progress::~Progress()
{
    assert(_referenceCount == 0);
}

HRESULT CreateProgressCallback(IAAFProgress** pProgress, HRESULT(*callback_func)())
{
    return Progress::Create(pProgress, callback_func);

}
