//+------------------------------------------------------------------+
//|                                       Smart MA Trailing Stop.mq4 |
//|                             Copyright 2024, Trade Smart FX Tools |
//|                                https://tradesmartfxtools.online/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Trade Smart FX Tools"
#property link      "https://tradesmartfxtools.online"
#property version   "1.01"
#property strict

// Global variables
input double ma_period = 30; // MA period
input double sl_distance_pips = 12; // User-defined distance for SL
input double lot_size = 0.1;
input double slippage = 3;
input color buy_color = clrBlue;
input color sell_color = clrRed;

// Array to store whether the alert has been triggered for each order
bool alertTriggered[];

string labelName = "tradesmartfxtools.online";
string labelText = "EA by tradesmartfxtools.online";
int labelFontSize = 18;
color labelColor = Yellow;
int spaceFromBottom = 50;

// Additional text for the updated version
string updatedLabelName = "updated_version_label";
string updatedLabelText = "Updated version available at tradesmartfxtools.online";
int updatedLabelFontSize = 12;  // Smaller font size for the updated version text
color updatedLabelColor = White;
int updatedSpaceFromBottom = 20;  // Position it below the main label

void createOrUpdateLabels()
{
    // Create the main label
    if (ObjectFind(0, labelName) == -1)
    {
        ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, labelName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, spaceFromBottom);
        ObjectSetInteger(0, labelName, OBJPROP_COLOR, labelColor);
        ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, labelFontSize);
        ObjectSetString(0, labelName, OBJPROP_TEXT, labelText);
    }

    // Create the updated version label below the main label
    if (ObjectFind(0, updatedLabelName) == -1)
    {
        ObjectCreate(0, updatedLabelName, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, updatedLabelName, OBJPROP_CORNER, CORNER_LEFT_LOWER);
        ObjectSetInteger(0, updatedLabelName, OBJPROP_XDISTANCE, 10);
        ObjectSetInteger(0, updatedLabelName, OBJPROP_YDISTANCE, updatedSpaceFromBottom);
        ObjectSetInteger(0, updatedLabelName, OBJPROP_COLOR, updatedLabelColor);
        ObjectSetInteger(0, updatedLabelName, OBJPROP_FONTSIZE, updatedLabelFontSize);
        ObjectSetString(0, updatedLabelName, OBJPROP_TEXT, updatedLabelText);
    }
}

// Function to adjust pips for 4 or 5 digit brokers
double AdjustForDigits(double value)
{
    if (Digits == 3 || Digits == 5)
    {
        return value * 10;  // Adjust for 5-digit brokers
    }
    return value;  // No adjustment needed for 4-digit brokers
}

// Function to check minimum stop level
double GetMinStopLevel()
{
    return MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    createOrUpdateLabels();
    ArrayResize(alertTriggered, OrdersTotal());  // Resize alert array to match the total number of orders
    ArrayInitialize(alertTriggered, false);      // Initialize all alerts as not triggered
    StopLossManagement();
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Adjust Stop Loss based on Moving Average                         |
//+------------------------------------------------------------------+
void StopLossManagement()
{
    double ma_value = iMA(NULL, 0, ma_period, 0, MODE_SMA, PRICE_CLOSE, 0); // Calculate MA based on global period
    double sl_diff = AdjustForDigits(sl_distance_pips) * Point; // Adjust pips for 4 or 5 digit brokers
    double minStopLevel = GetMinStopLevel(); // Get broker's minimum stop level

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
                    // Reset the alert if the condition has been met
                    alertTriggered[i] = false;
                }
                else
                {
                    // Alert for Buy Order: No SL set because price is below MA
                    if (!alertTriggered[i])  // Only trigger the alert once
                    {
                        string alert_msg = "No Stop Loss set for Buy order (Ticket: " + IntegerToString(OrderTicket()) + ") because the price is below the MA.";
                        Print(alert_msg);
                        Alert(alert_msg);
                        alertTriggered[i] = true;  // Mark that the alert has been triggered
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
                    // Reset the alert if the condition has been met
                    alertTriggered[i] = false;
                }
                else
                {
                    // Alert for Sell Order: No SL set because price is above MA
                    if (!alertTriggered[i])  // Only trigger the alert once
                    {
                        string alert_msg = "No Stop Loss set for Sell order (Ticket: " + IntegerToString(OrderTicket()) + ") because the price is above the MA.";
                        Print(alert_msg);
                        Alert(alert_msg);
                        alertTriggered[i] = true;  // Mark that the alert has been triggered
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

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    StopLossManagement();   // Manage SL for all open positions on every tick
}

//+------------------------------------------------------------------+
//| OnDeinit function to reset if needed                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ArrayFree(alertTriggered);  // Free the array on deinitialization
}
