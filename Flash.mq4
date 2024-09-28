#property copyright "Copyright 2024, ZaF"
#property link      "https://www.zaf.my"
#property version   "1.00"
#property strict

// Global variables
datetime lastBarTime = 0;

// Input parameters
input int MagicNumber = 12345;

// Initialize function
int OnInit()
{
    // Initialization code here
    return(INIT_SUCCEEDED);
}

// Deinitialize function
void OnDeinit(const int reason)
{
    // Cleanup code here
}

// Main trading function
void OnTick()
{
    // Check for new bar
    if (IsNewBar())
    {
        // Look for signal
        if (CheckForSignal())
        {
            // Execute trade based on signal
            ExecuteTrade();
        }
    }
}

// Function to check for new bar
bool IsNewBar()
{
    datetime currentBarTime = iTime(NULL, 0, 0);
    if (currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        return true;
    }
    return false;
}

// Function to check for signal (placeholder)
bool CheckForSignal()
{
    // TODO: Implement your signal logic here
    // Return true if a signal is detected, false otherwise
    return false;
}

// Function to execute trade (placeholder)
void ExecuteTrade()
{
    // TODO: Implement your trade execution logic here
    // This function will be called when a signal is detected
}

//usage 
//ApplyATRTrailingStop(14, 1.5); // ATR period of 14 with a multiplier of 1.5
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


//usage 
//ApplyFixedTrailingStop(30); // Apply a trailing stop of 30 pips
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

//usage 
//MoveToBreakeven(20); // Move stop loss to breakeven after 20 pips profit
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

//usage 
//ApplyTrailingAndBreakeven(20, 10); // Move to breakeven after 20 pips, then apply trailing stop of 10 pips
// Function: ApplyTrailingAndBreakeven
void ApplyTrailingAndBreakeven(int breakevenPips, int trailingPips)
{
    // First, move to breakeven
    MoveToBreakeven(breakevenPips);
    
    // Then, apply trailing stop
    ApplyFixedTrailingStop(trailingPips);
}