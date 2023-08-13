/**
 * @class CCommonBase
 * @brief Base class providing common functionalities for trading strategies.
 * 
 * This class encapsulates common properties and methods that are shared across different trading strategies.
 */
class CCommonBase {
protected:
    int mDigits;                 ///< Number of decimal places for the trading symbol.
    string mSymbol;              ///< Trading symbol.
    ENUM_TIMEFRAMES mTimeframe;  ///< Timeframe for the trading strategy.
    
    string mInitMessage;         ///< Initialization message.
    int mInitResult;             ///< Result of the initialization.

    /**
     * @brief Initialize the base with provided symbol and timeframe.
     * @return Initialization result.
     */
    int Init(string symbol, ENUM_TIMEFRAMES timeframe);

    /**
     * @brief Set the initialization result and message.
     * @return Initialization result.
     */
    int SetInitResult(string initMessage, int initResult) {
        mInitMessage = initMessage;
        mInitResult = initResult;
        return initResult;
    }

public:
    /// @brief Default constructor.
    CCommonBase() : CCommonBase(_Symbol, (ENUM_TIMEFRAMES)_Period) {}

    /**
     * @brief Constructor with symbol.
     */
    CCommonBase(string symbol) : CCommonBase(symbol, (ENUM_TIMEFRAMES)_Period) {}

    /**
     * @brief Constructor with timeframe.
     */
    CCommonBase(ENUM_TIMEFRAMES timeframe) : CCommonBase(_Symbol, timeframe) {}

    /**
     * @brief Constructor with symbol and timeframe.
     */
    CCommonBase(string symbol, ENUM_TIMEFRAMES timeframe) {
        Init(symbol, timeframe);
    }

    /// @brief Destructor.
    ~CCommonBase() {}

    /// @brief Get the initialization result.
    int InitResult() const { return mInitResult; }

    /// @brief Get the initialization message.
    string InitMessage() const { return mInitMessage; }

    /// @brief Check if trading is allowed for the symbol.
    bool TradeAllowed() const { return MarketInfo(mSymbol, MODE_TRADEALLOWED) > 0; }
};

int CCommonBase::Init(string symbol, ENUM_TIMEFRAMES timeframe) {
    SetInitResult("", INIT_SUCCEEDED);
    
    mSymbol = symbol;
    mTimeframe = timeframe;
    mDigits = (int)MarketInfo(symbol, MODE_DIGITS);
    
    return INIT_SUCCEEDED;
}
