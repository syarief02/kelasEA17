//+------------------------------------------------------------------+
//|                                EA BU ATR BreakEven Engulfing.mq4 |
//|                                  Copyright 2024, BuBat's Trading |
//|                                 https://twitter.com/SyariefAzman |
//+------------------------------------------------------------------+
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// sourcesatr
#define Version            "1.01"
#property version          Version
#property link "https://m.me/EABudakUbat"
#property description "This is a ATR BreakEven Engulfing EA "
#property description "recommended timeframe M5, choose ranging pair."
#property description " "
#property description "Recommended using a cent account for 100 usd capital"
#property description " "
#property description "Join our Telegram channel : t.me/EABudakUbat"
#property description "Facebook : m.me/EABudakUbat"
#property description "+60194961568 (Budak Ubat)"
#property icon "\\Images\\bupurple.ico";
#property strict
#include <stdlib.mqh>
#include <WinUser32.mqh>
#define Copyright "Copyright © 2023, BuBat's Trading"
#property copyright Copyright
//+------------------------------------------------------------------+
//| Name of the EA                                                   |
//+------------------------------------------------------------------+
#define ExpertName       "[https://t.me/SyariefAzman] "
extern string EA_Name = ExpertName;
string Owner = "BUDAK UBAT";
string Contact = "WHATSAPP/TELEGRAM : +60194961568";
string MB_CAPTION = ExpertName + " v" + Version + " | " + Copyright;
// Input parameters
extern int MaxLayer = 10;
extern double LotSize = 0.01; // Keep this declaration
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

datetime lastTradeTime = 0; // Variable to store the last trade time

// Function to return authorization message
string AuthMessage() {
    return "Your authorization message here."; // Customize as needed
}

// Function to count buy orders
int CountBuy() {
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderType() == OP_BUY && OrderSymbol() == Symbol()) {
                count++;
            }
        }
    }
    return count;
}

// Function to count sell orders
int CountSell() {
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderType() == OP_SELL && OrderSymbol() == Symbol()) {
                count++;
            }
        }
    }
    return count;
}

// Function to check if a new day has started
bool IsNewDay()
{
    static datetime lastDay = 0;
    datetime currentDay = iTime(NULL, PERIOD_D1, 0);
    if (currentDay != lastDay)
    {
        lastDay = currentDay;
        return true;
    }
    return false;
}

// Function to check if a trade has been made in the last day
bool HasTradedInLastDay()
{
    return (lastTradeTime != 0 && TimeCurrent() - lastTradeTime < 86400); // 86400 seconds in a day
}

// Function to open a trade based on the daily candle
void OpenTradeBasedOnDailyCandle()
{
    double dailyOpen = iOpen(NULL, PERIOD_D1, 0);
    double dailyClose = iClose(NULL, PERIOD_D1, 0);

    if (dailyClose > dailyOpen) // Bullish candle
    {
        OpenBuyOrder();
    }
    else if (dailyClose < dailyOpen) // Bearish candle
    {
        OpenSellOrder();
    }
}

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
    //-- Get Date String
   datetime Today = StrToTime(StringConcatenate(Year(), ".", Month(), ".", Day()));
   string Date = TimeToStr(TimeCurrent(), TIME_DATE + TIME_MINUTES + TIME_SECONDS); //"yyyy.mm.dd"
//--EA Comment--

     {
      Comment(
         "\n ", Copyright,
         "\n ", Date, "\n",
         "\n ", AuthMessage(), "\n",
         "\n ", EA_Name,
         "\n Starting Lot: ", LotSize,
         "\n Equity: $", NormalizeDouble(AccountInfoDouble(ACCOUNT_EQUITY), 2),
         "\n Buy: ", CountBuy(), " | Sell: ", CountSell(),
         "\n");
     }
    // Main(); // Removed the call to Main() since it's undefined
    // Check if a new day has started and if no trades have been made in the last day
    if (IsNewDay() && !HasTradedInLastDay())
    {
        OpenTradeBasedOnDailyCandle(); // Open trade based on the daily candle
        lastTradeTime = TimeCurrent(); // Update last trade time
    }

    // Existing trading logic...
    ApplyTrailingAndBreakeven(BreakevenPips, TrailingPips);
    ApplyATRTrailingStop(ATRPeriod, ATRMultiplier);
    StopLossManagement();   // Manage SL for all open positions on every tick
}

// Function to check for Bullish Engulfing pattern
bool isBullishEngulfing(int index) {
    double open1 = iOpen(Symbol(), 0, index + 1);
    double close1 = iClose(Symbol(), 0, index + 1);
    double open2 = iOpen(Symbol(), 0, index);
    double close2 = iClose(Symbol(), 0, index);

    return (close1 < open1 && close2 > open2 && close2 > open1 && close1 < open2);
}

// Function to check for Bearish Engulfing pattern
bool isBearishEngulfing(int index) {
    double open1 = iOpen(Symbol(), 0, index + 1);
    double close1 = iClose(Symbol(), 0, index + 1);
    double open2 = iOpen(Symbol(), 0, index);
    double close2 = iClose(Symbol(), 0, index);

    return (close1 > open1 && close2 < open2 && close2 < open1 && close1 > open2);
}

// Function to open a BUY order
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

// Function to open a SELL order
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

// Function: ApplyATRTrailingStop
void ApplyATRTrailingStop(int atrPeriod, double atrMultiplier)
{
    double atrValue = iATR(Symbol(), 0, atrPeriod, 0) * atrMultiplier;
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
                           Print("Failed to apply trailing stop: ", GetLastError());
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
                            Print("Failed to apply trailing stop: ", GetLastError());
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
    ApplyATRTrailingStop(ATRPeriod, ATRMultiplier); // Changed to call the existing function
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
                            Print("Failed to apply breakeven: ", GetLastError());
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
                            Print("Failed to apply breakeven: ", GetLastError());
                        }
                    }
                }
            }
        }
    }
}

// Function: StopLossManagement
void StopLossManagement()
{
    double ma_value = iMA(NULL, 0, 30, 0, MODE_SMA, PRICE_CLOSE, 0); // Hardcoded MA period
    double sl_diff = 12 * Point; // Hardcoded SL distance in pips
    double minStopLevel = 10 * Point; // Hardcoded minimum stop level

    // Loop through all open orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) 
        {
            double price = Close[0]; // Current price

            Print("Processing order ", OrderTicket(), ". Type: ", OrderType(), ". Price: ", price, ". MA: ", ma_value);

            if (OrderType() == OP_BUY)
            {
                // Check if price is above the MA before setting SL for Buy
                if (price > ma_value)
                {
                    double new_stop_loss_buy = ma_value - sl_diff;

                    // Ensure the SL is at least minStopLevel away from Ask price
                    if (Ask - new_stop_loss_buy < minStopLevel)
                    {
                        new_stop_loss_buy = Ask - minStopLevel;  // Fallback to minStopLevel
                    }

                    // Modify SL if required
                    if (OrderStopLoss() < new_stop_loss_buy || OrderStopLoss() == 0) 
                    {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), new_stop_loss_buy, OrderTakeProfit(), 0, clrRed))
                        {
                            Print("Stop Loss for Buy Order Adjusted to: ", new_stop_loss_buy);
                        }
                        else
                        {
                            Print("Failed to modify Buy order Stop Loss: ", GetLastError());
                        }
                    }
                }
            }
            else if (OrderType() == OP_SELL)
            {
                // Check if price is below the MA before setting SL for Sell
                if (price < ma_value)
                {
                    double new_stop_loss_sell = ma_value + sl_diff;

                    // Ensure the SL is at least minStopLevel away from Bid price
                    if (new_stop_loss_sell - Bid < minStopLevel)
                    {
                        new_stop_loss_sell = Bid + minStopLevel;  // Fallback to minStopLevel
                    }

                    // Modify SL if required
                    if (OrderStopLoss() > new_stop_loss_sell || OrderStopLoss() == 0)
                    {
                        if (OrderModify(OrderTicket(), OrderOpenPrice(), new_stop_loss_sell, OrderTakeProfit(), 0, clrRed))
                        {
                            Print("Stop Loss for Sell Order Adjusted to: ", new_stop_loss_sell);
                        }
                        else
                        {
                            Print("Failed to modify Sell order Stop Loss: ", GetLastError());
                        }
                    }
                }
            }
        }
        else
        {
            Print("Failed to select order: ", GetLastError());
        }
    }
}

// ... Additional functions can be added as needed ...

//+------------------------------------------------------------------+