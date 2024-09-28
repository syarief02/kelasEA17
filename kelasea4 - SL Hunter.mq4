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
input double LotSize = 0.01; // Initial lot size for trades
input int TakeProfit = 100;  // Take Profit in pips
input int StopLoss = 50;    // Stop Loss in pips
input int FastMAPeriod = 3;  // Period for the fast moving average (3 minutes)
input int SlowMAPeriod = 15;  // Period for the slow moving average (15 minutes)
// Removed MartingaleMultiplier
input int StartHour = 8;    // Start trading hour (London session)
input int EndHour = 17;     // End trading hour (New York session)

// Global variables
int ticket = 0; // Variable to store the order ticket number
double prevMA5 = 0; // Previous value of MA5
double prevMA20 = 0; // Previous value of MA20
double currentLotSize = LotSize; // Current lot size
bool lastTradeWasLoss = false; // Flag to indicate if the last trade was a loss
datetime lastBarTime = 0; // Time of the last bar

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("EA initialized."); // Print initialization message
    return(INIT_SUCCEEDED); // Return initialization success
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("EA deinitialized. Reason: ", reason); // Print deinitialization message with reason
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    if(IsNewBar() && IsTradingTime()) // Check if a new bar has formed and if it's within trading hours
    {
        int signal = CheckMACrossover(); // Check for MA crossover signal
        
        if(signal == 1)  // Buy signal
        {
            // Removed CheckLastTradeResult call
            double tpPrice = Ask + TakeProfit * Point; // Calculate Take Profit price in points
            double slPrice = (StopLoss > 0) ? Ask - StopLoss * Point : 0; // Calculate Stop Loss price in points, or 0 if no SL
            ticket = OrderSend(Symbol(), OP_BUY, currentLotSize, Ask, 3, slPrice, tpPrice, "MA Crossover Buy", 0, 0, clrGreen); // Send buy order
            
            if(ticket > 0) // Check if order was successful
            {
                Print("EA entered a BUY trade. Ticket: ", ticket); // Print success message
                lastTradeWasLoss = false; // Reset loss flag
                // Removed ModifyTrades call
            }
            else
            {
                HandleOrderSendError(); // Handle order send error
            }
        }
        else if(signal == -1)  // Sell signal
        {
            // Removed CheckLastTradeResult call
            double tpPrice = Bid - TakeProfit * Point; // Calculate Take Profit price in points
            double slPrice = (StopLoss > 0) ? Bid + StopLoss * Point : 0; // Calculate Stop Loss price in points, or 0 if no SL
            ticket = OrderSend(Symbol(), OP_SELL, currentLotSize, Bid, 3, slPrice, tpPrice, "MA Crossover Sell", 0, 0, clrRed); // Send sell order
            
            if(ticket > 0) // Check if order was successful
            {
                Print("EA entered a SELL trade. Ticket: ", ticket); // Print success message
                lastTradeWasLoss = false; // Reset loss flag
                // Removed ModifyTrades call
            }
            else
            {
                HandleOrderSendError(); // Handle order send error
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+

// Check if a new bar has formed
bool IsNewBar()
{
    datetime currentBarTime = iTime(Symbol(), Period(), 0); // Get the time of the current bar
    if(currentBarTime != lastBarTime) // Check if the current bar time is different from the last bar time
    {
        lastBarTime = currentBarTime; // Update the last bar time
        return true; // Return true if a new bar has formed
    }
    return false; // Return false if no new bar has formed
}

// Check if it's within trading hours
bool IsTradingTime()
{
    int currentHour = Hour(); // Get the current hour
    return (currentHour >= StartHour && currentHour < EndHour); // Return true if within trading hours
}

// Check for MA crossover
int CheckMACrossover()
{
    double ma3 = iMA(Symbol(), Period(), FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0); // Calculate MA3
    double ma15 = iMA(Symbol(), Period(), SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0); // Calculate MA15
    
    if(prevMA5 != 0 && prevMA20 != 0) // Ensure previous values are set
    {
        if(prevMA5 <= prevMA20 && ma3 > ma15) // Check for bullish crossover
            return 1;  // Buy signal
        else if(prevMA5 >= prevMA20 && ma3 < ma15) // Check for bearish crossover
            return -1; // Sell signal
    }
    
    prevMA5 = ma3; // Update previous MA3 value
    prevMA20 = ma15; // Update previous MA15 value
    
    return 0;  // No signal
}

// Removed CheckLastTradeResult function

// Removed ModifyTrades function

// Handle OrderSend errors
void HandleOrderSendError()
{
    int error = GetLastError(); // Get last error
    Print("Failed to enter trade. Error: ", error); // Print general error message
    ResetLastError(); // Reset last error
}