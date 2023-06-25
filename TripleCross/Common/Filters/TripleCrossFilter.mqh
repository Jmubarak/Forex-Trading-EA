
#include "FilterBase.mqh"

class CTripleCrossFilter : public CFilterBase {

private:

protected:	// member variables

	int				mFastMAPeriod;
	ENUM_MA_METHOD	mFastMAMethod;
	int				mMediumMAPeriod;
	ENUM_MA_METHOD	mMediumMAMethod;
	int				mSlowMAPeriod;
	ENUM_MA_METHOD	mSlowMAMethod;

protected:	//	Constructors

	int		Init(int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod);

public:	//	Constructors

	CTripleCrossFilter(	int	fastMAPeriod,		ENUM_MA_METHOD fastMAMethod,
								int	mediumMAPeriod,	ENUM_MA_METHOD mediumMAMethod,
								int	slowMAPeriod,		ENUM_MA_METHOD slowMAMethod)
										:	CFilterBase()
										{	Init(fastMAPeriod, fastMAMethod, mediumMAPeriod, mediumMAMethod, slowMAPeriod, slowMAMethod);	}
	CTripleCrossFilter(	string symbol, ENUM_TIMEFRAMES timeframe,
								int	fastMAPeriod,		ENUM_MA_METHOD fastMAMethod,
								int	mediumMAPeriod,	ENUM_MA_METHOD mediumMAMethod,
								int	slowMAPeriod,		ENUM_MA_METHOD slowMAMethod)
										:	CFilterBase(symbol, timeframe)
										{	Init(fastMAPeriod, fastMAMethod, mediumMAPeriod, mediumMAMethod, slowMAPeriod, slowMAMethod);	}
	~CTripleCrossFilter()		{	}
	
public:	//	Functions

	void								UpdateFilter();

};

int		CTripleCrossFilter::Init(int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod) {

	if (InitResult()!=INIT_SUCCEEDED)	return(InitResult());

	//	First check that the fast medium and slow are in a sequence
	if (fastMAPeriod>=mediumMAPeriod || mediumMAPeriod>=slowMAPeriod) {
		return(SetInitResult("Fast must be < medium must be < slow", INIT_PARAMETERS_INCORRECT));
	}

	//	All ma periods must be >0
	if (fastMAPeriod<1) {
		return(SetInitResult("MA periods must be >=1", INIT_PARAMETERS_INCORRECT));
	}

	mFastMAPeriod		=	fastMAPeriod;
	mFastMAMethod		=	fastMAMethod;
	mMediumMAPeriod	=	mediumMAPeriod;
	mMediumMAMethod	=	mediumMAMethod;
	mSlowMAPeriod		=	slowMAPeriod;
	mSlowMAMethod		=	slowMAMethod;
	
	return(INIT_SUCCEEDED);
	
}

void		CTripleCrossFilter::UpdateFilter() {

	//	Calculate fast, medium, slow ma for bars 1 and 2
	double	fma1	=	iMA(Symbol(), Period(), mFastMAPeriod, 0, mFastMAMethod, PRICE_CLOSE, 1);
	double	fma2	=	iMA(Symbol(), Period(), mFastMAPeriod, 0, mFastMAMethod, PRICE_CLOSE, 2);
	
	double	mma1	=	iMA(Symbol(), Period(), mMediumMAPeriod, 0, mMediumMAMethod, PRICE_CLOSE, 1);
	double	mma2	=	iMA(Symbol(), Period(), mMediumMAPeriod, 0, mMediumMAMethod, PRICE_CLOSE, 2);
	
	double	sma1	=	iMA(Symbol(), Period(), mSlowMAPeriod, 0, mSlowMAMethod, PRICE_CLOSE, 1);
	double	sma2	=	iMA(Symbol(), Period(), mSlowMAPeriod, 0, mSlowMAMethod, PRICE_CLOSE, 2);

	//	Set entry filter if bar 1 is aligned and bar 2 is not
	if (fma1>mma1 && mma1>sma1 && (fma2<=mma2 || mma2<=sma2) ) {	//	Buy
		mEntryFilter	=	OFX_FILTER_BUY;
	} else
	if (fma1<mma1 && mma1<sma1 && (fma2>=mma2 || mma2>=sma2) ) {	// Sell
		mEntryFilter	=	OFX_FILTER_SELL;
	} else {
		mEntryFilter	=	OFX_FILTER_NONE;
	}

	//	Set the exit filter based on fast ma compared to slow ma
	if (fma1<sma1)	{	//	going down so Close buy trades
		mExitFilter		=	OFX_FILTER_BUY;
	} else
	if (fma1>sma1) {	//	going up so close sell trades
		mExitFilter		=	OFX_FILTER_SELL;
	} else {
		mExitFilter		=	OFX_FILTER_NONE;
	}
	
	return;

}



