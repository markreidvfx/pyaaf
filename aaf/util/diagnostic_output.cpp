
#include "diagnostic_output.h"

HRESULT STDMETHODCALLTYPE
DiagnosticOutput::PutString(aafCharacter_constptr  pString)
{
    HRESULT result = AAFRESULT_SUCCESS;

    size_t size = 0;

    if (callback_func != NULL && pString != NULL)
    {
        size = wcslen(pString);
        result = callback_func(pString, size);
        return result;
    }

    return result;
}

ULONG STDMETHODCALLTYPE
DiagnosticOutput::AddRef ()
{
	return ++_referenceCount;
}

ULONG STDMETHODCALLTYPE
DiagnosticOutput::Release ()
{
    aafUInt32 r = --_referenceCount;
    if (r == 0) {
        delete this;
    }
    return r;
}

HRESULT STDMETHODCALLTYPE
DiagnosticOutput::QueryInterface (REFIID iid, void ** ppIfc)
{
    if (ppIfc == 0)
        return AAFRESULT_NULL_PARAM;

    if (memcmp(&iid, &IID_IUnknown, sizeof(IID)) == 0) {
        IUnknown* unk = (IUnknown*) this;
        *ppIfc = (void*) unk;
        AddRef ();
        return AAFRESULT_SUCCESS;
    } else if (memcmp(&iid, &IID_IAAFDiagnosticOutput, sizeof(IID)) == 0) {
        IAAFDiagnosticOutput* cpa = this;
        *ppIfc = (void*) cpa;
        AddRef ();
        return AAFRESULT_SUCCESS;
    } else {
        return E_NOINTERFACE;
    }
}

HRESULT DiagnosticOutput::Create(IAAFDiagnosticOutput** pOutput, HRESULT (*callback_func)(aafCharacter_constptr, size_t))
{
    if (pOutput == 0)
        return AAFRESULT_NULL_PARAM;

    IAAFDiagnosticOutput* result = new DiagnosticOutput();
    if (result == 0)
        return AAFRESULT_NOMEMORY;

    DiagnosticOutput * result_python = dynamic_cast<DiagnosticOutput*>(result);
    result_python->callback_func = callback_func;

    result->AddRef();
    *pOutput = result;
    return AAFRESULT_SUCCESS;
}

DiagnosticOutput::DiagnosticOutput()
: _referenceCount(0)
{
    callback_func = NULL;
}

DiagnosticOutput::~DiagnosticOutput()
{
    assert(_referenceCount == 0);
}

HRESULT CreateDiagnosticOutputCallback(IAAFDiagnosticOutput** pOutput, HRESULT(*callback_func)(aafCharacter_constptr, size_t))
{

    return DiagnosticOutput::Create(pOutput, callback_func);

}
