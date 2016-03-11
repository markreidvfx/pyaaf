
#include "AAF.h"
#include "AAFResult.h"

#include <iostream>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <wchar.h>

class DiagnosticOutput : public IAAFDiagnosticOutput
{
    // Defeat gcc warning about private ctor/dtor and no friends
    // Note that this dummy function cannot itself be called because
    // it requires a constructed Progress object.
    friend void dummyFriend(DiagnosticOutput);

public:
    virtual HRESULT STDMETHODCALLTYPE PutString(aafCharacter_constptr  pString);
    virtual ULONG STDMETHODCALLTYPE AddRef( void);
    virtual ULONG STDMETHODCALLTYPE Release( void);
    virtual HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid,
                                                     /* [iid_is][out] */ void **ppvObject);

    static HRESULT Create(IAAFDiagnosticOutput ** pOutput, HRESULT (*callback_func)(aafCharacter_constptr, size_t));
    HRESULT (*callback_func)(aafCharacter_constptr, size_t);

private:

    DiagnosticOutput();

    virtual ~DiagnosticOutput();

    aafUInt32 _referenceCount;
};

HRESULT CreateDiagnosticOutputCallback(IAAFDiagnosticOutput** pOutput, HRESULT(*callback_func)(aafCharacter_constptr, size_t));
