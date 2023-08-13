#include "FilterBase.mqh"

/**
 * @class CTripleCrossFilter
 * @brief Implements a filter strategy based on the Triple Cross method.
 * 
 * This class extends the CFilterBase class and provides methods to update filters based on the Triple Cross strategy using moving averages.
 */
class CTripleCrossFilter : public CFilterBase {
protected:
    int mFastMAPeriod;             ///< Period for the fast moving average.
    ENUM_MA_METHOD mFastMAMethod;  ///< Method for the fast moving average.
    int mMediumMAPeriod;           ///< Period for the medium moving average.
    ENUM_MA_METHOD mMediumMAMethod;///< Method for the medium moving average.
    int mSlowMAPeriod;             ///< Period for the slow moving average.
    ENUM_MA_METHOD mSlowMAMethod;  ///< Method for the slow moving average.

    /**
     * @brief Initialize the filter with provided parameters.
     * @return Initialization result.
     */
    int Init(int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod);

public:
    /**
     * @brief Constructor with moving average parameters.
     */
    CTripleCrossFilter(int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod)
    : CFilterBase() {
        Init(fastMAPeriod, fastMAMethod, mediumMAPeriod, mediumMAMethod, slowMAPeriod, slowMAMethod);
    }

    /**
     * @brief Constructor with symbol, timeframe, and moving average parameters.
     */
    CTripleCrossFilter(string symbol, ENUM_TIMEFRAMES timeframe, int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod)
    : CFilterBase(symbol, timeframe) {
        Init(fastMAPeriod, fastMAMethod, mediumMAPeriod, mediumMAMethod, slowMAPeriod, slowMAMethod);
    }

    /// @brief Destructor.
    ~CTripleCrossFilter() {}

    /// @brief Update the filter values based on the Triple Cross strategy.
    void UpdateFilter();
};

int CTripleCrossFilter::Init(int fastMAPeriod, ENUM_MA_METHOD fastMAMethod, int mediumMAPeriod, ENUM_MA_METHOD mediumMAMethod, int slowMAPeriod, ENUM_MA_METHOD slowMAMethod) {
    if (InitResult() != INIT_SUCCEEDED) return InitResult();

    // Ensure the periods are in a sequence
    if (fastMAPeriod >= mediumMAPeriod || mediumMAPeriod >= slowMAPeriod) {
        return SetInitResult("Fast must be < medium must be < slow", INIT_PARAMETERS_INCORRECT);
    }

    // Ensure all MA periods are positive
    if (fastMAPeriod < 1) {
        return SetInitResult("MA periods must be >=1", INIT_PARAMETERS_INCORRECT);
    }

    mFastMAPeriod = fastMAPeriod;
    mFastMAMethod = fastMAMethod;
    mMediumMAPeriod = mediumMAPeriod;
    mMediumMAMethod = mediumMAMethod;
    mSlowMAPeriod = slowMAPeriod;
    mSlowMAMethod = slowMAMethod;

    return INIT_SUCCEEDED;
}

void CTripleCrossFilter::UpdateFilter() {
    // Calculate moving averages for bars 1 and 2
    double fma1 = iMA(Symbol(), Period(), mFastMAPeriod, 0, mFastMAMethod, PRICE_CLOSE, 1);
    double fma2 = iMA(Symbol(), Period(), mFastMAPeriod, 0, mFastMAMethod, PRICE_CLOSE, 2);
    double mma1 = iMA(Symbol(), Period(), mMediumMAPeriod, 0, mMediumMAMethod, PRICE_CLOSE, 1);
    double mma2 = iMA(Symbol(), Period(), mMediumMAPeriod, 0, mMediumMAMethod, PRICE_CLOSE, 2);
    double sma1 = iMA(Symbol(), Period(), mSlowMAPeriod, 0, mSlowMAMethod, PRICE_CLOSE, 1);
    double sma2 = iMA(Symbol(), Period(), mSlowMAPeriod, 0, mSlowMAMethod, PRICE_CLOSE, 2);

    // Set entry filter based on moving average alignment
    if (fma1 > mma1 && mma1 > sma1 && (fma2 <= mma2 || mma2 <= sma2)) {
        mEntryFilter = OFX_FILTER_BUY;
    } else if (fma1 < mma1 && mma1 < sma1 && (fma2 >= mma2 || mma2 >= sma2)) {
        mEntryFilter = OFX_FILTER_SELL;
    } else {
        mEntryFilter = OFX_FILTER_NONE;
    }

    // Set exit filter based on fast MA compared to slow MA
    if (fma1 < sma1) {
        mExitFilter = OFX_FILTER_BUY;
    } else if (fma1 > sma1) {
        mExitFilter = OFX_FILTER_SELL;
    } else {
        mExitFilter = OFX_FILTER_NONE;
    }
}
