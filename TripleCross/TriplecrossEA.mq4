#include	<Forex-Trading-EA/TripleCross/Filters/TripleCrossFilter.mqh>

// Function for pip conversion
double	PipSize(string symbol)	{
	double	point = MarketInfo(symbol, MODE_POINT);
	int		digits = (int)MarketInfo(symbol, MODE_DIGITS);
	return( ((digits%2)==1) ? point*10 : point);
}
double	PipsToPrice(double pips, string symbol)	{	return(pips*PipSize(symbol));	}

// Inputs
input	int	InpFastMAPeriods = 5, InpMediumMAPeriods = 8, InpSlowMAPeriods = 13;
input	ENUM_MA_METHOD	InpFastMAMethod = MODE_SMA, InpMediumMAMethod = MODE_SMA, InpSlowMAMethod = MODE_SMA;
input	double	InpStopLossPips = 25.0, InpTakeProfitPips = 25.0, InpOrderSize = 1.0;
input	string	InpTradeComment = "TripleCrossV2";
input	int	InpMagicNumber = 201301;

double	TakeProfit, StopLoss;
CTripleCrossFilter	*Filter;

// Initialize
int OnInit() {
	if (!IsDemo())	return(INIT_FAILED);	
	Filter = new CTripleCrossFilter(InpFastMAPeriods, InpFastMAMethod, InpMediumMAPeriods, InpMediumMAMethod, InpSlowMAPeriods, InpSlowMAMethod);
	if (Filter.InitResult()!=INIT_SUCCEEDED)	return(Filter.InitResult());
	int	result = ValidateInputs();	
	if (result!=INIT_SUCCEEDED)	return(result);
	IsNewBar();
   return(result);
}

// Deinitialize
void OnDeinit(const int reason) {
	delete	Filter;
}

// Tick function
void OnTick() {
	if (!IsTesting() && !Filter.TradeAllowed())	return;
	if (!IsNewBar())	return;
	Filter.UpdateFilter();
	switch(Filter.ExitFilter()) {
		case OFX_FILTER_BUY:	CloseTrade(ORDER_TYPE_BUY);	break;
		case OFX_FILTER_SELL:	CloseTrade(ORDER_TYPE_SELL);	break;
	}
	switch(Filter.EntryFilter()) {
		case OFX_FILTER_BUY:	OpenTrade(ORDER_TYPE_BUY);	break;
		case OFX_FILTER_SELL:	OpenTrade(ORDER_TYPE_SELL);	break;
	}
	return;
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)  { }

int	ValidateInputs() {
	if (InpTakeProfitPips<=0 || InpStopLossPips<=0) {
		Print("SL and TP must be > 0");
		return(INIT_PARAMETERS_INCORRECT);
	}
	TakeProfit = PipsToPrice(InpTakeProfitPips, Symbol());
	StopLoss = PipsToPrice(InpStopLossPips, Symbol());
	return(INIT_SUCCEEDED);
}

// Check for new bar
bool	IsNewBar() {
	static datetime	currentTime = 0;
	bool	result = (currentTime != Time[0]);
	if (result) currentTime = Time[0];
	return(result);
}

// Open trade
void	OpenTrade(ENUM_ORDER_TYPE	orderType) {
	double	takeProfitPrice, stopLossPrice, openPrice;
	if (orderType==ORDER_TYPE_BUY) {
		openPrice = Ask;
		takeProfitPrice = openPrice+TakeProfit;
		stopLossPrice = Bid-StopLoss;
	} else {
		openPrice = Bid;
		takeProfitPrice = openPrice-TakeProfit;
		stopLossPrice = Ask+StopLoss;
	}
	int	ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, stopLossPrice, takeProfitPrice, InpTradeComment, InpMagicNumber);
}

// Close trade
bool	CloseTrade(ENUM_ORDER_TYPE	orderType) {
	bool	result = true;
	PrintFormat("Closing %s orders due to signal", EnumToString(orderType));
	int	cnt = OrdersTotal();
	for (int i = cnt-1; i>=0; i--) {
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
			if (OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber && OrderType()==orderType) {
				result &= OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrYellow);
			}
		}
	}
	return(result);
}
