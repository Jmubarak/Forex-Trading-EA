
class CCommonBase {

private:

protected:	//	Members

	int					mDigits;
	string				mSymbol;
	ENUM_TIMEFRAMES	mTimeframe;
	
	string				mInitMessage;
	int					mInitResult;

protected:	//	Constructors

	//
	//	Constructors
	//
	CCommonBase()																		{	Init(_Symbol,	(ENUM_TIMEFRAMES)_Period);				}
	CCommonBase(string symbol)														{	Init(symbol,	(ENUM_TIMEFRAMES)_Period);				}
	CCommonBase(ENUM_TIMEFRAMES timeframe)										{	Init(_Symbol,	timeframe);									}
	CCommonBase(string symbol, ENUM_TIMEFRAMES timeframe)					{	Init(symbol,	timeframe);									}

	//
	//	Destructors
	//
	~CCommonBase()	{};
	
	int					Init(string symbol, ENUM_TIMEFRAMES timeframe);

protected:	//	Functions

	int					SetInitResult(string initMessage, int initResult)	{	mInitMessage = initMessage; mInitResult = initResult; return(initResult);	}
	
public:	//	Properties

	int					InitResult()												{	return(mInitResult);											}
	string				InitMessage()												{	return(mInitMessage);										}
	
public:	//	Functions

	bool					TradeAllowed()												{	return(MarketInfo(mSymbol, MODE_TRADEALLOWED)>0);	}	
};

int	CCommonBase::Init(string symbol, ENUM_TIMEFRAMES timeframe) {

	SetInitResult("", INIT_SUCCEEDED);
	
	mSymbol		=	symbol;
	mTimeframe	=	timeframe;
	mDigits		=	(int)MarketInfo(symbol, MODE_DIGITS);
	
	return(INIT_SUCCEEDED);
	
}
