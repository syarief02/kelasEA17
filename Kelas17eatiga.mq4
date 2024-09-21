void OnTick()
{

    double stochMain = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_MAIN, 1);
    double stochSignal = iStochastic(NULL, 0, 5, 3, 3, MODE_SMA, 0, MODE_SIGNAL, 1);
    double rsiValue = iRSI(NULL, 0, 3, PRICE_CLOSE, 1);

    // Entry conditions
    if (OrdersTotal() == 0)
    {
        if (stochMain > stochSignal && rsiValue < 30)
        {
            // Buy condition
            int ticket = OrderSend(Symbol(), OP_BUY, 0.01, Ask, 2, 0, 0, "Buy Order", 0, 0, clrGreen);
            if (ticket > 0)
            {
                Print("Buy order placed with ticket number: ", ticket);
            }
            else
            {
                Print("Failed to place buy order");
            }
        }
        else if (stochMain < stochSignal && rsiValue > 70)
        {

            // Sell condition
            ticket = OrderSend(Symbol(), OP_SELL, 0.01, Bid, 2, 0, 0, "Sell Order", 0, 0, clrRed);
            if (ticket > 0)
            {
                Print("Sell order placed with ticket number: ", ticket);
            }
            else
            {
                Print("Failed to place sell order");
            }
        }
    }
    // Exit conditions
    // Assuming you have a way to track open orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS))
        {
            double stopLoss = OrderOpenPrice() + 200 * Point;   // For Sell
            double takeProfit = OrderOpenPrice() - 500 * Point; // For Sell
            // Adjust for Buy orders
            if (OrderType() == OP_BUY)
            {
                stopLoss = OrderOpenPrice() - 200 * Point;
                takeProfit = OrderOpenPrice() + 500 * Point;
            }
            stopLoss = NormalizeDouble(stopLoss, Digits);
            takeProfit = NormalizeDouble(takeProfit, Digits);
            if (OrderStopLoss() != stopLoss && OrderTakeProfit() != takeProfit)
            {
                // Modify order with SL and TP
                bool mod = OrderModify(OrderTicket(), OrderOpenPrice(), stopLoss, takeProfit, 0, clrYellow);

                if (!mod)
                {
                    Print("Failed to modify order with ticket number: ", OrderTicket());
                }
                else
                {
                    Print("Order modified with ticket number: ", OrderTicket());
                }
            }
        }
    }
}