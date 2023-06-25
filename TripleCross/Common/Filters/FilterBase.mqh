

#include	<Forex-Trading-EA/TripleCross/Common/CommonBase.mqh>

enum ENUM_OFX_FILTER_DIRECTION {
	OFX_FILTER_BUY,
	OFX_FILTER_SELL,
	OFX_FILTER_BOTH,
	OFX_FILTER_NONE
};

class CFilterBase : public CCommonBase {

private:

protected:	// member variables

	ENUM_OFX_FILTER_DIRECTION	mEntryFilter;
	ENUM_OFX_FILTER_DIRECTION	mExitFilter;
	
protected:	// constructors

	CFilterBase()															:	CCommonBase()							{	Init();	}
	CFilterBase(string symbol, ENUM_TIMEFRAMES timeframe)		:	CCommonBase(symbol, timeframe)	{	Init();	}
	~CFilterBase()																											{	}
	
	int			Init();

public:

	virtual void								UpdateFilter()		{	return;						}
	virtual ENUM_OFX_FILTER_DIRECTION	EntryFilter()		{	return(mEntryFilter);	}
	virtual ENUM_OFX_FILTER_DIRECTION	ExitFilter()		{	return(mExitFilter);		}

};

int		CFilterBase::Init() {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());
	
	mEntryFilter		=	OFX_FILTER_NONE;
	mExitFilter			=	OFX_FILTER_NONE;

	return(INIT_SUCCEEDED);
	
}

