// Including all inputs at the top for easier access
input int InpFastMAPeriods = 5;
input ENUM_MA_METHOD InpFastMAMethod = MODE_SMA;
input int InpMediumMAPeriods = 8;
input ENUM_MA_METHOD InpMediumMAMethod = MODE_SMA;
input int InpSlowMAPeriods = 13;
input ENUM_MA_METHOD InpSlowMAMethod = MODE_SMA;
input double InpStopLossPips = 25.0;
input double InpTakeProfitPips = 25.0;
input double InpOrderSize = 1.0;
input string InpTradeComment = "TripleCross";
input int InpMagicNumber = 2005021;
double TakeProfit;
double StopLoss;

// Function to determine the pip size
double PipSize(string symbol) {
    return (MarketInfo(symbol, MODE_POINT) * ((int)MarketInfo(symbol, MODE_DIGITS) % 2 == 1 ? 10 : 1));
}

// Function to convert pips to price
double PipsToPrice(double pips, string symbol) {
    return pips * PipSize(symbol);
}

// Function to validate the inputs
int ValidateInputs() {
    // Check if Fast < Medium < Slow
    if (InpFastMAPeriods >= InpMediumMAPeriods || InpMediumMAPeriods >= InpSlowMAPeriods) {
        Print("Fast must be < Medium < Slow");
        return INIT_PARAMETERS_INCORRECT;
    }
    // Check if all periods are greater than zero
    if (InpFastMAPeriods < 1) {
        Print("All periods must be >= 1");
        return INIT_PARAMETERS_INCORRECT;
    }
    // Check if SL and TP are positive
    if (InpTakeProfitPips <= 0 || InpStopLossPips <= 0) {
        Print("SL and TP must be > 0");
        return INIT_PARAMETERS_INCORRECT;
    }
    // Convert SL and TP to a decimal matching price format
    TakeProfit = PipsToPrice(InpTakeProfitPips, Symbol());
    StopLoss = PipsToPrice(InpStopLossPips, Symbol());
    return INIT_SUCCEEDED;
}

// Function to check if it is a new bar
bool IsNewBar() {
    static datetime currentTime = 0;
    bool isNewBar = (currentTime != Time[0]);
    if (isNewBar) currentTime = Time[0];
    return isNewBar;
}

// Function to filter the trade signal
int TradeFilter() {
    double fma1 = iMA(Symbol(), Period(), InpFastMAPeriods, 0, InpFastMAMethod, PRICE_CLOSE, 1);
    double mma1 = iMA(Symbol(), Period(), InpMediumMAPeriods, 0, InpMediumMAMethod, PRICE_CLOSE, 1);
    double sma1 = iMA(Symbol(), Period(), InpSlowMAPeriods, 0, InpSlowMAMethod, PRICE_CLOSE, 1);

    if (fma1 > mma1 && mma1 > sma1) return 1;
    else if (fma1 < mma1 && mma1 < sma1) return -1;
    return 0;
}

// Function to place a trade
void OpenTrade(ENUM_ORDER_TYPE orderType) {
    double openPrice = orderType == ORDER_TYPE_BUY ? Ask : Bid;
    double takeProfitPrice = openPrice + (orderType == ORDER_TYPE_BUY ? TakeProfit : -TakeProfit);
    double stopLossPrice = openPrice - (orderType == ORDER_TYPE_BUY ? StopLoss : -StopLoss);

    OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, stopLossPrice, takeProfitPrice, InpTradeComment, InpMagicNumber);
}

// Expert initialization function
int OnInit() {
    if (!IsDemo()) return INIT_FAILED;
    int result = ValidateInputs();
    if (result != INIT_SUCCEEDED) return result;
    IsNewBar();
    return result;
}

// Expert tick function
void OnTick() {
    if (!IsNewBar()) return;
    int signal = TradeFilter();
    if (signal == 1) OpenTrade(ORDER_TYPE_BUY);
    else if (signal == -1) OpenTrade(ORDER_TYPE_SELL);
}

// Expert deinitialization function
void OnDeinit(const int reason) {
    // Empty
}

// ChartEvent function
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
    // Empty
}