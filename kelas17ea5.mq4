//+------------------------------------------------------------------+
//|                                                    kelas17ea5.mq4 |
//|                        Copyright 2023, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

extern int MaxLayer = 10;
extern double LotSize = 0.01;
extern double StopLoss = 100;
extern double TakeProfit = 200;
input int RSIPeriod = 14; // RSI period
input double RSIBuy = 70; // RSI buy threshold
input double RSISell = 30; // RSI sell threshold

int ticket = 0;
#define INIT_SUCCEEDED 0
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if (TakeProfit <= 0)
    {
        TakeProfit = 200;
    }
    // Initialization code here
    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // Deinitialization code here
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Main trading logic here
    if (newbar())
    {
        // Logic to execute when a new bar is formed
        int index = 1; // Current bar index
        double rsi = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, 0);
        
        if (isBullishEngulfing(index) && rsi >= RSIBuy)
        {
            Print("Bullish Engulfing pattern detected at bar ", index, " with RSI ", rsi);
            OpenPosition(OP_BUY); // Open buy position
        }
        if (isBearishEngulfing(index) && rsi <= RSISell)
        {
            Print("Bearish Engulfing pattern detected at bar ", index, " with RSI ", rsi);
            OpenPosition(OP_SELL); // Open sell position
        }
    }
}

//+------------------------------------------------------------------+
//| Function to check if a new bar has formed                        |
//+------------------------------------------------------------------+
bool newbar()
{
    static datetime lastTime = 0;
    datetime currentTime = iTime(NULL, 0, 0);
    if (currentTime != lastTime)
    {
        lastTime = currentTime;
        return true;
    }
    return false;
}

// Function to check for Bullish Engulfing pattern
bool isBullishEngulfing(int index)
{
    return (Close[index + 1] < Open[index + 1] && // Previous candle is bearish
            Close[index] > Open[index] &&         // Current candle is bullish
            Open[index] < Close[index + 1] &&     // Current open is below previous close
            Close[index] > Open[index + 1]);      // Current close is above previous open
}

// Function to check for Bearish Engulfing pattern
bool isBearishEngulfing(int index)
{
    return (Close[index + 1] > Open[index + 1] && // Previous candle is bullish
            Close[index] < Open[index] &&         // Current candle is bearish
            Open[index] > Close[index + 1] &&     // Current open is above previous close
            Close[index] < Open[index + 1]);      // Current close is below previous open
}

// Function to open a position
void OpenPosition(int orderType)
{
    double price = (orderType == OP_BUY) ? Ask : Bid;
    double sl = (orderType == OP_BUY) ? price - StopLoss * Point : price + StopLoss * Point;
    double tp = (orderType == OP_BUY) ? price + TakeProfit * Point : price - TakeProfit * Point;

    int orderTicket = OrderSend(Symbol(), orderType, LotSize, price, 3, sl, tp, "Engulfing Signal", 0, 0, clrGreen);
    if (orderTicket < 0)
    {
        Print("Failed to open order. Error: ", GetLastError());
    }
    else
    {
        Print("Order opened successfully. Ticket: ", orderTicket);
    }
}