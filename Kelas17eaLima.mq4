//+------------------------------------------------------------------+
//|                                            Kelas17eaLima.mq4     |
//|                        Copyright 2023, Your Name                 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name"
#property link "https://www.mql5.com"
#property version "1.00"
#property strict

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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    if (TakeProfit <= 0)
        TakeProfit = 200;
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
    Main();
    ApplyTrailingAndBreakeven(BreakevenPips, TrailingPips);
    ApplyATRTrailingStop(ATRPeriod, ATRMultiplier);
}

bool newbar() {
    static datetime lastTime = 0;
    datetime currentTime = Time[0];
    if (currentTime != lastTime) {
        lastTime = currentTime;
        return true;
    }
    return false;
}

void Main() {
    if (!newbar()) return;
    // Print("newbar");
    int latestBarIndex = 1; // Index of the latest bar

    double rsiValue = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, latestBarIndex);

    if (isBullishEngulfing(latestBarIndex) && rsiValue >= RSIBuy) {
        // Add your logic for bullish engulfing pattern with RSI filter
        Print("Bullish Engulfing detected at the latest bar with RSI >= ", RSIBuy);
        OpenBuyOrder();
    }
    if (isBearishEngulfing(latestBarIndex) && rsiValue <= RSISell) {
        // Add your logic for bearish engulfing pattern with RSI filter
        Print("Bearish Engulfing detected at the latest bar with RSI <= ", RSISell);
        OpenSellOrder();
    }

    // ... existing Main() function code ...
}

// Function to check for Bullish Engulfing pattern
bool isBullishEngulfing(int index) {
    double open1 = iOpen(NULL, 0, index + 1);
    double close1 = iClose(NULL, 0, index + 1);
    double open2 = iOpen(NULL, 0, index);
    double close2 = iClose(NULL, 0, index);

    return (close1 < open1 && close2 > open2 && close2 > open1 && close1 < open2);
}

// Function to check for Bearish Engulfing pattern
bool isBearishEngulfing(int index) {
    double open1 = iOpen(NULL, 0, index + 1);
    double close1 = iClose(NULL, 0, index + 1);
    double open2 = iOpen(NULL, 0, index);
    double close2 = iClose(NULL, 0, index);

    return (close1 > open1 && close2 < open2 && close2 < open1 && close1 > open2);
}

// Function to open a BUY order
void OpenBuyOrder() {
    double price = Ask;
    double sl = price - StopLoss * Point;
    double tp = price + TakeProfit * Point;

    ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, "Buy Order", MagicNumber, 0, Green);
    if (ticket < 0) {
        Print("Error opening BUY order: ", GetLastError());
    } else {
        Print("BUY order opened successfully");
    }
}

// Function to open a SELL order
void OpenSellOrder() {
    double price = Bid;
    double sl = price + StopLoss * Point;
    double tp = price - TakeProfit * Point;

    ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, "Sell Order", MagicNumber, 0, Red);
    if (ticket < 0) {
        Print("Error opening SELL order: ", GetLastError());
    } else {
        Print("SELL order opened successfully");
    }
}

// Function: ApplyATRTrailingStop
void ApplyATRTrailingStop(int atrPeriod, double atrMultiplier)
{
    double atrValue = iATR(NULL, 0, atrPeriod, 0) * atrMultiplier;
    int trailingPips = (int)(atrValue / Point);
    
    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
            {
                double newStop;
                if(OrderType() == OP_BUY)
                {
                    newStop = NormalizeDouble(Bid - trailingPips * Point, Digits);
                    if(newStop > OrderStopLoss())
                    {
                       bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrNONE);
                       if(result)
                       {
                           Print("Trailing stop applied successfully");
                       }
                       else
                       {
                           Print("Failed to apply trailing stop");
                       }
                    }
                }
                else if(OrderType() == OP_SELL)
                {
                    newStop = NormalizeDouble(Ask + trailingPips * Point, Digits);
                    if(newStop < OrderStopLoss())
                    {
                        bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrNONE);
                        if(result)
                        {
                            Print("Trailing stop applied successfully");
                        }
                        else
                        {
                            Print("Failed to apply trailing stop");
                        }
                    }
                }
            }
        }
    }
}

// Function: ApplyFixedTrailingStop
void ApplyFixedTrailingStop(int trailingPips)
{
    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
            {
                double newStop;
                if(OrderType() == OP_BUY)
                {
                    newStop = NormalizeDouble(Bid - trailingPips * Point, Digits);
                    if(newStop > OrderStopLoss())
                    {
                        bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrNONE);
                        if(result)
                        {
                            Print("Trailing stop applied successfully");
                        }
                        else
                        {
                            Print("Failed to apply trailing stop");
                        }
                    }
                }
                else if(OrderType() == OP_SELL)
                {
                    newStop = NormalizeDouble(Ask + trailingPips * Point, Digits);
                    if(newStop < OrderStopLoss())
                    {
                        bool result = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, OrderTakeProfit(), 0, clrNONE);
                        if(result)
                        {
                            Print("Trailing stop applied successfully");
                        }
                        else
                        {
                            Print("Failed to apply trailing stop");
                        }
                    }
                }
            }
        }
    }
}

// Function: MoveToBreakeven
void MoveToBreakeven(int breakevenPips)
{
    for(int i=OrdersTotal()-1; i>=0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol())
            {
                double entryPrice = OrderOpenPrice();
                double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
                double distance;

                if(OrderType() == OP_BUY)
                {
                    distance = (currentPrice - entryPrice) / Point;
                    if(distance >= breakevenPips && OrderStopLoss() < entryPrice)
                    {
                        bool result = OrderModify(OrderTicket(), entryPrice, entryPrice, OrderTakeProfit(), 0, clrNONE);
                        if(result)
                        {
                            Print("Breakeven applied successfully");
                        }
                        else
                        {
                            Print("Failed to apply breakeven");
                        }
                    }
                }
                else if(OrderType() == OP_SELL)
                {
                    distance = (entryPrice - currentPrice) / Point;
                    if(distance >= breakevenPips && OrderStopLoss() > entryPrice)
                    {
                        bool result = OrderModify(OrderTicket(), entryPrice, entryPrice, OrderTakeProfit(), 0, clrNONE);
                        if(result)
                        {
                            Print("Breakeven applied successfully");
                        }
                        else
                        {
                            Print("Failed to apply breakeven");
                        }
                    }
                }
            }
        }
    }
}

// Function: ApplyTrailingAndBreakeven
void ApplyTrailingAndBreakeven(int breakevenPips, int trailingPips)
{
    // First, move to breakeven
    MoveToBreakeven(breakevenPips);
    
    // Then, apply trailing stop
    ApplyFixedTrailingStop(trailingPips);
}