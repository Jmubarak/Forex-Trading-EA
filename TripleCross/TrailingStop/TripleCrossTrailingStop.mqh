#include "TrailingStopBase.mqh"

/**
 * @class CTripleCrossTrailingStop
 * @brief Implements a trailing stop strategy based on the Triple Cross method.
 * 
 * This class extends the CTrailingStopBase class and provides methods to update and apply trailing stops based on the Triple Cross strategy.
 */
class CTripleCrossTrailingStop : public CTrailingStopBase {
protected:    
    int mATRPeriod; ///< Period for the Average True Range (ATR) indicator.
    double mStopLossMultiplier, mTakeProfitMultiplier, mStopLossMin, mTakeProfitMin;  ///< Multipliers and minimum values for stop loss and take profit.
    double mATRValue, mStopLossValue, mTakeProfitValue; ///< Calculated values for ATR, stop loss, and take profit.

    /**
     * @brief Checks the validity of the provided parameters.
     * @return True if parameters are valid, false otherwise.
     */
    bool checkParams();

    /**
     * @brief Converts pips to price based on the symbol's point size.
     * @param pips Number of pips.
     * @param symbol Trading symbol.
     * @return Price equivalent of the provided pips.
     */
    double PipsToPrice(double pips, string symbol);

public:
    /**
     * @brief Constructor that initializes with a magic number and other parameters.
     * @param magicNumber Magic number associated with the order.
     * @param atrPeriod Period for the ATR indicator.
     * @param stopLossMultiplier Multiplier for stop loss.
     * @param takeProfitMultiplier Multiplier for take profit.
     * @param stopLossMinPips Minimum pips for stop loss.
     * @param takeProfitMinPips Minimum pips for take profit.
     */
    CTripleCrossTrailingStop(int magicNumber, int atrPeriod, double stopLossMultiplier, double takeProfitMultiplier, double stopLossMinPips, double takeProfitMinPips)
    : CTrailingStopBase(magicNumber) { Init(atrPeriod, stopLossMultiplier, takeProfitMultiplier, stopLossMinPips, takeProfitMinPips); }
    

     /**
     * @brief Constructor that initializes with a symbol, timeframe, magic number, and other parameters.
     * @param symbol Trading symbol.
     * @param timeframe Timeframe for the order.
     * @param magicNumber Magic number associated with the order.
     * @param atrPeriod Period for the ATR indicator.
     * @param stopLossMultiplier Multiplier for stop loss.
     * @param takeProfitMultiplier Multiplier for take profit.
     * @param stopLossMinPips Minimum pips for stop loss.
     * @param takeProfitMinPips Minimum pips for take profit.
     */
    CTripleCrossTrailingStop(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber, int atrPeriod, double stopLossMultiplier, double takeProfitMultiplier, double stopLossMinPips, double takeProfitMinPips)
    : CTrailingStopBase(symbol, timeframe, magicNumber) { Init(atrPeriod, stopLossMultiplier, takeProfitMultiplier, stopLossMinPips, takeProfitMinPips); }
    
    /// @brief Destructor.
    ~CTripleCrossTrailingStop() {}
    

    /// @brief Update common values for the trailing stop.
    void UpdateCommonValues();

     /// @brief Apply the trailing stop to the order.
    void ApplyTrailingStop();

    /**
     * @brief Initialize the trailing stop with provided parameters.
     * @param atrPeriod Period for the ATR indicator.
     * @param stopLossMultiplier Multiplier for stop loss.
     * @param takeProfitMultiplier Multiplier for take profit.
     * @param stopLossMinPips Minimum pips for stop loss.
     * @param takeProfitMinPips Minimum pips for take profit.
     * @return Initialization result.
     */
    int Init(int atrPeriod, double stopLossMultiplier, double takeProfitMultiplier, double stopLossMinPips, double takeProfitMinPips);
};

int CTripleCrossTrailingStop::Init(int atrPeriod, double stopLossMultiplier, double takeProfitMultiplier, double stopLossMinPips, double takeProfitMinPips) {
    if (InitResult() != INIT_SUCCEEDED)
        return(InitResult());

    if (!checkParams())
        return(INIT_PARAMETERS_INCORRECT);

    mATRPeriod = atrPeriod;
    mStopLossMultiplier = stopLossMultiplier;
    mTakeProfitMultiplier = takeProfitMultiplier;
    mStopLossMin = PipsToPrice(stopLossMinPips, mSymbol);
    mTakeProfitMin = PipsToPrice(takeProfitMinPips, mSymbol);

    return(INIT_SUCCEEDED);
}

bool CTripleCrossTrailingStop::checkParams() {
    // Check all parameters, return false if any are incorrect
    if (mATRPeriod <= 0) {
        SetInitResult("ATR period must be >0", INIT_PARAMETERS_INCORRECT);
        return false;
    }
    if (mStopLossMultiplier <= 0 || mTakeProfitMultiplier <= 0) {
        SetInitResult("Stop Loss and Take Profit multipliers must be >0", INIT_PARAMETERS_INCORRECT);
        return false;
    }
    if (mStopLossMinPips < 0 || mTakeProfitMinPips < 0) {
        SetInitResult("Stop Loss and Take Profit minimum pips must be >=0", INIT_PARAMETERS_INCORRECT);
        return false;
    }
    return true;
}

void CTripleCrossTrailingStop::UpdateCommonValues() {
    mATRValue = iATR(mSymbol, mTimeframe, mATRPeriod, 1);
    mStopLossValue = MathMax((mATRValue * mStopLossMultiplier), mStopLossMin);
    mTakeProfitValue = MathMax((mATRValue * mTakeProfitMultiplier), mTakeProfitMin);
}

void CTripleCrossTrailingStop::ApplyTrailingStop() {
    // Order modifications split into two functions
    ModifyStopLoss();
    ModifyTakeProfit();
}

void CTripleCrossTrailingStop::ModifyStopLoss() {
    double closePrice = ClosePrice(mSymbol, OrderType());
    double stopLossPrice = NormalizeDouble(Sub(closePrice, mStopLossValue, OrderType()), mDigits);
    if (_GT(stopLossPrice, OrderStopLoss(), OrderType()) || OrderStopLoss() == 0) {
        result = OrderModify(OrderTicket(), OrderOpenPrice(), stopLossPrice, OrderTakeProfit(), OrderExpiration());
    }
}

void CTripleCrossTrailingStop::ModifyTakeProfit() {
    double takeProfitPrice = NormalizeDouble(Add(OrderOpenPrice(), mTakeProfitValue, OrderType()), mDigits); 
    if ((takeProfitPrice != OrderTakeProfit()) || OrderTakeProfit() == 0) {
        result = OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), takeProfitPrice, OrderExpiration());
    }
}
