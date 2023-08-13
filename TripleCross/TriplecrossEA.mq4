#include <Forex-Trading-EA/TripleCross/Filters/TripleCrossFilter.mqh>
#include <Forex-Trading-EA/TripleCross/TrailingStop/TripleCrossTrailingStop.mqh>
#include <Forex-Trading-EA/TripleCross/Common/CommonFunctions.mqh>

// Input parameters for the trading system
input int InpFastMAPeriod = 5;  
input ENUM_MA_METHOD InpFastMAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE InpFastMAPrice = PRICE_CLOSE;

input int InpMediumMAPeriod = 8;  
input ENUM_MA_METHOD InpMediumMAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE InpMediumMAPrice = PRICE_CLOSE;

input int InpSlowMAPeriod = 13; 
input ENUM_MA_METHOD InpSlowMAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE InpSlowMAPrice = PRICE_CLOSE;

input int InpATRPeriod = 8;
input double InpStopLossMultiplier = 2.0;
input double InpTakeProfitMultiplier = 2.0;
input double InpStopLossMinPips = 25.0;
input double InpTakeProfitMinPips = 25.0;

input double InpOrderSize = 1.0;
input string InpTradeComment = "TripleCross";
input int InpMagicNumber = 201371;

// Instances of filters and trailing stop
CTripleCrossFilter *Filter;
CTripleCrossTrailingStop *TrailingStop;

int OnInit() {
    if (!IsDemo()) return(INIT_FAILED); // Only for demo accounts

    Filter = new CTripleCrossFilter(InpFastMAPeriod, InpFastMAMethod, InpFastMAPrice,
                                    InpMediumMAPeriod, InpMediumMAMethod, InpMediumMAPrice,
                                    InpSlowMAPeriod, InpSlowMAMethod, InpSlowMAPrice);
    if (Filter.InitResult()!=INIT_SUCCEEDED) return(Filter.InitResult());

    TrailingStop = new CTripleCrossTrailingStop(InpMagicNumber, InpATRPeriod,
                                                 InpStopLossMultiplier, InpTakeProfitMultiplier,
                                                 InpStopLossMinPips, InpTakeProfitMinPips);
    if (TrailingStop.InitResult()!=INIT_SUCCEEDED) return(TrailingStop.InitResult());

    if (ValidateInputs()!=INIT_SUCCEEDED) return(ValidateInputs());
    
    IsNewBar(); // Check for the first bar

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
    delete Filter;
    delete TrailingStop;
}

void OnTick() {
    if (!IsTesting() && !Filter.TradeAllowed()) return;
    if (!IsNewBar()) return; 

    Filter.UpdateFilter(); 

    // Close existing trades if exit signal generated
    switch(Filter.ExitFilter()) {
        case OFX_FILTER_BUY: CloseTrade(ORDER_TYPE_BUY); break;
        case OFX_FILTER_SELL: CloseTrade(ORDER_TYPE_SELL); break;
    }
    
    // Open new trades if entry signal generated
    switch(Filter.EntryFilter()) {
        case OFX_FILTER_BUY: OpenTrade(ORDER_TYPE_BUY); break;
        case OFX_FILTER_SELL: OpenTrade(ORDER_TYPE_SELL); break;
    }

    // Update the trailing stop
    TrailingStop.UpdateTrailingStop();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {}

// Validate inputs if needed
int ValidateInputs() {
    return(INIT_SUCCEEDED);
}

// Function to check for a new bar
bool IsNewBar() {
    static datetime currentTime = 0;
    bool result = (currentTime != Time[0]);
    if (result) currentTime = Time[0];
    return(result);
}

// Open a new trade based on the type
void OpenTrade(ENUM_ORDER_TYPE orderType) {
    double openPrice = (orderType == ORDER_TYPE_BUY) ? Ask : Bid;
    int ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, 0, 0, InpTradeComment, InpMagicNumber);
    TrailingStop.UpdateTrailingStop(ticket);
}

// Close an existing trade based on the type
bool CloseTrade(ENUM_ORDER_TYPE orderType) {
    bool result = true;
    PrintFormat("Closing %s orders due to signal", EnumToString(orderType));
    int cnt = OrdersTotal();
    for (int i = cnt-1; i>=0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol()==Symbol() && OrderMagicNumber()==InpMagicNumber && OrderType()==orderType) {
                result &= OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 0, clrYellow);
            }
        }
    }
    return(result);
}
