
#include "AAF.h"
#include "AAFResult.h"

#include <iostream>
#include <assert.h>
#include <stdio.h>
#include <string.h>


class Progress : public IAAFProgress
{
    // Defeat gcc warning about private ctor/dtor and no friends
    // Note that this dummy function cannot itself be called because
    // it requires a constructed Progress object.
    friend void dummyFriend(Progress);

public:
    virtual HRESULT STDMETHODCALLTYPE ProgressCallback( void);
    virtual ULONG STDMETHODCALLTYPE AddRef( void);
    virtual ULONG STDMETHODCALLTYPE Release( void);
    virtual HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid,
                                                     /* [iid_is][out] */ void **ppvObject);

    static HRESULT Create(IAAFProgress** pProgress, HRESULT (*callback_func)());
    int progress;
    HRESULT (*callback_func)();

private:

    Progress();

    virtual ~Progress();

    aafUInt32 _referenceCount;
};

HRESULT CreateProgressCallback(IAAFProgress** pProgress, HRESULT(*callback_func)());
