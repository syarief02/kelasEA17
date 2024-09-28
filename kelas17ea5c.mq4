//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code here
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Cleanup code here
}

//+------------------------------------------------------------------+
//| Function to open a BUY order                                      |
//+------------------------------------------------------------------+
void OpenBuyOrder() {
    double price = Ask;
    double sl = price - StopLoss * Point;
    double tp = price + TakeProfit * Point;

     ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, "Buy Order", MagicNumber, 0, clrGreen);
    if (ticket < 0) {
        Print("Error opening BUY order: ", GetLastError());
    } else {
        Print("BUY order opened successfully");
    }
}

//+------------------------------------------------------------------+
//| Function to open a SELL order                                     |
//+------------------------------------------------------------------+
void OpenSellOrder() {
    double price = Bid;
    double sl = price + StopLoss * Point;
    double tp = price - TakeProfit * Point;

     ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, "Sell Order", MagicNumber, 0, clrRed);
    if (ticket < 0) {
        Print("Error opening SELL order: ", GetLastError());
    } else {
        Print("SELL order opened successfully");
    }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    Main(); // Call the main trading logic
}

//+------------------------------------------------------------------+
//| Function to check for Bullish Engulfing pattern                  |
//+------------------------------------------------------------------+
bool isBullishEngulfing(int index) {
    double open1 = iOpen(NULL, 0, index + 1);
    double close1 = iClose(NULL, 0, index + 1);
    double open2 = iOpen(NULL, 0, index);
    double close2 = iClose(NULL, 0, index);

    return (close1 < open1 && close2 > open2 && close2 > open1 && close1 < open2);
}

//+------------------------------------------------------------------+
//| Function to check for Bearish Engulfing pattern                  |
//+------------------------------------------------------------------+
bool isBearishEngulfing(int index) {
    double open1 = iOpen(NULL, 0, index + 1);
    double close1 = iClose(NULL, 0, index + 1);
    double open2 = iOpen(NULL, 0, index);
    double close2 = iClose(NULL, 0, index);

    return (close1 > open1 && close2 < open2 && close2 < open1 && close1 > open2);
}

//+------------------------------------------------------------------+
//| Function to check for a new bar                                  |
//+------------------------------------------------------------------+
bool newbar() {
    static datetime lastTime = 0;
    datetime currentTime = Time[0];
    if (currentTime != lastTime) {
        lastTime = currentTime;
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Main function to handle trading logic                             |
//+------------------------------------------------------------------+
void Main() {
    if (!newbar()) return; // Check for a new bar
    int latestBarIndex = 1; // Index of the latest bar

    double rsiValue = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, latestBarIndex);

    if (isBullishEngulfing(latestBarIndex) && rsiValue >= RSIBuy) {
        Print("Bullish Engulfing detected at the latest bar with RSI >= ", RSIBuy);
        OpenBuyOrder();
    }
    if (isBearishEngulfing(latestBarIndex) && rsiValue <= RSISell) {
        Print("Bearish Engulfing detected at the latest bar with RSI <= ", RSISell);
        OpenSellOrder();
    }
}

//+------------------------------------------------------------------+
//| Input parameters                                                  |
//+------------------------------------------------------------------+
extern int MaxLayer = 10;
extern double LotSize = 0.01;
extern double StopLoss = 100;
extern double TakeProfit = 200;
extern int RSIPeriod = 14; // RSI period input parameter
extern double RSIBuy = 70; // RSI value for BUY input parameter
extern double RSISell = 30; // RSI value for SELL input parameter
extern int BreakevenPips = 20; // Pips to move to breakeven
extern int TrailingPips = 10; // Pips for trailing stop
extern int MagicNumber = 12345; // Magic number input parameter
extern int ATRPeriod = 14; // ATR period input parameter
extern double ATRMultiplier = 1.5; // ATR multiplier input parameter

// Global variables
int ticket = 0;

//+------------------------------------------------------------------+
//| Custom function example                                           |
//+------------------------------------------------------------------+
void CustomFunction()
{
    // Custom logic here
}

//+------------------------------------------------------------------+
