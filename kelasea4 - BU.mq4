//+------------------------------------------------------------------+
//|                                                     kelasea4.mq4 |
//|                        Copyright 2023, Your Name or Company Name |
//|                                             https://www.yourwebsite.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Your Name or Company Name"
#property link      "https://www.yourwebsite.com"
#property version   "1.00"
#property strict

// Input parameters
input double LotSize = 0.01;
input int StopLoss = 100;
input int TakeProfit = 200;
input int FastMAPeriod = 5;  // Period for the fast moving average (MA5)
input int SlowMAPeriod = 20; // Period for the slow moving average (MA20)

// Global variables
int ticket = 0;
double prevMA5 = 0;
double prevMA20 = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialization code here
    return(INIT_SUCCEEDED);
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
    // Check for new bar
    if(IsNewBar())
    {
        // Check for MA crossover
        int signal = CheckMACrossover();
        
        if(signal == 1)  // Buy signal
        {
            // Close any existing sell orders
            if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() == OP_SELL)
            {
                if(!OrderClose(ticket, OrderLots(), Ask, 3, clrRed))
                {
                    Print("Failed to close SELL order. Error: ", GetLastError());
                }
            }
            
            // Open a buy order
            ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "MA Crossover Buy", 0, 0, clrGreen);
            
            // Print entry message
            if(ticket > 0)
            {
                Print("EA entered a BUY trade. Ticket: ", ticket);
            }
            else
            {
                Print("Failed to enter BUY trade. Error: ", GetLastError());
            }
        }
        else if(signal == -1)  // Sell signal
        {
            // Close any existing buy orders
            if(ticket > 0 && OrderSelect(ticket, SELECT_BY_TICKET) && OrderType() == OP_BUY)
            {
                if(!OrderClose(ticket, OrderLots(), Bid, 3, clrRed))
                {
                    Print("Failed to close BUY order. Error: ", GetLastError());
                }
            }
            
            // Open a sell order
            ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "MA Crossover Sell", 0, 0, clrRed);
            
            // Print entry message
            if(ticket > 0)
            {
                Print("EA entered a SELL trade. Ticket: ", ticket);
            }
            else
            {
                Print("Failed to enter SELL trade. Error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
// Global variables for new bar detection
datetime lastBarTime = 0;

// New bar function
bool IsNewBar()
{
    datetime currentBarTime = iTime(Symbol(), Period(), 0);
    if(currentBarTime != lastBarTime)
    {
        lastBarTime = currentBarTime;
        Print("A new bar has been formed.");
        return true;
    }
    return false;
}

// MA Crossover function
int CheckMACrossover()
{
    double ma5 = iMA(Symbol(), Period(), FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    double ma20 = iMA(Symbol(), Period(), SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    int signal = 0;
    
    if(prevMA5 != 0 && prevMA20 != 0) // Ensure previous values are set
    {
        if(prevMA5 <= prevMA20 && ma5 > ma20)
            signal = 1;  // Buy signal
        else if(prevMA5 >= prevMA20 && ma5 < ma20)
            signal = -1; // Sell signal
    }
    
    // Update previous values
    prevMA5 = ma5;
    prevMA20 = ma20;
    
    return signal;
}
