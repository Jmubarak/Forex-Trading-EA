#include <Forex-Trading-EA/TripleCross/Common/CommonBase.mqh>

/**
 * @enum ENUM_OFX_FILTER_DIRECTION
 * @brief Defines the filter directions for entry and exit.
 */
enum ENUM_OFX_FILTER_DIRECTION {
    OFX_FILTER_BUY,
    OFX_FILTER_SELL,
    OFX_FILTER_BOTH,
    OFX_FILTER_NONE
};

/**
 * @class CFilterBase
 * @brief Base class for filtering trading entry and exit.
 * 
 * This class provides basic functionality for handling entry and exit filters in trading.
 */
class CFilterBase : public CCommonBase {
protected:
    ENUM_OFX_FILTER_DIRECTION mEntryFilter; ///< Entry filter direction.
    ENUM_OFX_FILTER_DIRECTION mExitFilter;  ///< Exit filter direction.

    /**
     * @brief Initialize the filter.
     * @return Initialization result.
     */
    int Init();

public:
    /// @brief Default constructor.
    CFilterBase() : CCommonBase() { Init(); }

    /**
     * @brief Constructor with symbol and timeframe.
     * @param symbol Trading symbol.
     * @param timeframe Timeframe for the order.
     */
    CFilterBase(string symbol, ENUM_TIMEFRAMES timeframe) : CCommonBase(symbol, timeframe) { Init(); }

    /// @brief Destructor.
    ~CFilterBase() {}

    /// @brief Update the filter values (virtual method to be overridden by derived classes).
    virtual void UpdateFilter() { return; }

    /**
     * @brief Get the entry filter direction.
     * @return Entry filter direction.
     */
    virtual ENUM_OFX_FILTER_DIRECTION EntryFilter() { return mEntryFilter; }

    /**
     * @brief Get the exit filter direction.
     * @return Exit filter direction.
     */
    virtual ENUM_OFX_FILTER_DIRECTION ExitFilter() { return mExitFilter; }
};

int CFilterBase::Init() {
    if (InitResult() != INIT_SUCCEEDED) return InitResult();

    mEntryFilter = OFX_FILTER_NONE;
    mExitFilter = OFX_FILTER_NONE;

    return INIT_SUCCEEDED;
}
