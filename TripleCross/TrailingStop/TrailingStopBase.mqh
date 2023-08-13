

#include	<Orchard/OOP/OOP10/Common/CommonBase.mqh>


/**
 * @class CTrailingStopBase
 * @brief Base class for trailing stops.
 * 
 * This class provides basic functionality for handling trailing stops in trading.
 * It extends the CCommonBase class and provides methods to update and apply trailing stops.
 */

class CTrailingStopBase : public CCommonBase {
private:
    int mMagicNumber; ///< Magic number associated with the order.

protected:

	/**
     * @brief Constructor that initializes with a magic number.
     * @param magicNumber Magic number associated with the order.
     */
    CTrailingStopBase(int magicNumber);

	/**
     * @brief Constructor that initializes with a symbol, timeframe, and magic number.
     * @param symbol Trading symbol.
     * @param timeframe Timeframe for the order.
     * @param magicNumber Magic number associated with the order.
     */
    CTrailingStopBase(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber);

	/// @brief Destructor.
    ~CTrailingStopBase();

	 /**
     * @brief Initialize the trailing stop.
     * @param magicNumber Magic number associated with the order.
     * @return Initialization result.
     */
    int Init(int magicNumber);

	/// @brief Update common values for the trailing stop.
    void UpdateCommonValues() { return; }

	/// @brief Apply the trailing stop to the order.
    void ApplyTrailingStop() { return; }

public:
	/// @brief Update the trailing stop for all orders.
    void UpdateTrailingStop();

	/**
     * @brief Update the trailing stop for a specific order.
     * @param ticket Ticket number of the order.
     */
    void UpdateTrailingStop(int ticket);
};

CTrailingStopBase::CTrailingStopBase(int magicNumber) : CCommonBase() {
    Init(magicNumber);
}

CTrailingStopBase::CTrailingStopBase(string symbol, ENUM_TIMEFRAMES timeframe, int magicNumber) : CCommonBase(symbol, timeframe) {
    Init(magicNumber);
}

CTrailingStopBase::~CTrailingStopBase() {}

int CTrailingStopBase::Init(int magicNumber) {
    if (InitResult() != INIT_SUCCEEDED) return InitResult();
    mMagicNumber = magicNumber;
    return INIT_SUCCEEDED;
}

void CTrailingStopBase::UpdateTrailingStop() {
    UpdateCommonValues();
    int orderCount = OrdersTotal();
    for (int i = orderCount - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == mSymbol && OrderMagicNumber() == mMagicNumber) {
            ApplyTrailingStop();
        }
    }
}

void CTrailingStopBase::UpdateTrailingStop(int ticket) {
    if (!OrderSelect(ticket, SELECT_BY_TICKET)) return;
    if (OrderSymbol() == mSymbol && OrderMagicNumber() == mMagicNumber && OrderCloseTime() == 0) {
        UpdateCommonValues();
        ApplyTrailingStop();
    }
}
