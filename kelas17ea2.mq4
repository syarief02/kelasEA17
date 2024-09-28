// Entry BUY : RSI >= 70 | Exit BUY : RSI < 50 | Prev cs1
// Entry SELL : RSI <= 30 | Exit SELL : RSI > 50 | Prev cs1
#property strict

extern int MagicNumber = 123;
extern double LotSize = 0.01;
input int RSIPeriod = 14; // RSI period
input double RSIBuy = 70; // RSI buy threshold
input double RSISell = 30; // RSI sell threshold

int entry_semasa = -1;

int init()
{
    return (INIT_SUCCEEDED);
}
void OnTick()
{
    if (OrdersTotal() == 0)
    {
        if (bolehSellKe())
        {
            BukaEntrySell();
        }
        if (bolehBuyKe())
        {
            BukaEntryBuy();
        }
    }
    else
    {
        if (entry_semasa == OP_SELL)
        {
            if (bolehExitSell())
            {
                TutupEntrySell();
            }
        }
        if (entry_semasa == OP_BUY)
        {
            if (bolehExitBuy())
            {
                TutupEntryBuy();
            }
        }
    }

    // Add pattern detection logic
    if (newbar())
    {
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
void OnDeinit(const int reason)
{
    Print("EA Telah Di Hancurkan");
}

bool bolehSellKe()
{
    return iRSI(Symbol(), Period(), 3, PRICE_CLOSE, 1) <= 30;
}
bool bolehBuyKe()
{
    return iRSI(Symbol(), Period(), 3, PRICE_CLOSE, 1) >= 70;
}
bool bolehExitSell()
{
    return iRSI(Symbol(), Period(), 3, PRICE_CLOSE, 1) > 50;
}
bool bolehExitBuy()
{
    return iRSI(Symbol(), Period(), 3, PRICE_CLOSE, 1) < 50;
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

void BukaEntrySell()
{
    int ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 0, 0, 0, "EA Power", MagicNumber, 0, clrNONE);
    if (ticket < 0)
    {
        Print("Gagal Membuka Order Sell");
    }
    else
    {
        Print("Berhasil Membuka Order Sell");
        entry_semasa = OP_SELL;
    }
}
void BukaEntryBuy()
{
    int ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 0, 0, 0, "EA Power", MagicNumber, 0, clrNONE);
    if (ticket < 0)
    {
        Print("Gagal Membuka Order Buy");
    }
    else
    {
        Print("Berhasil Membuka Order Buy");
        entry_semasa = OP_BUY;
    }
}

void TutupEntrySell()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
            {
                bool tutup = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 0, clrNONE);
                if (tutup)
                {
                    Print("Berhasil Menutup Order Sell");
                    entry_semasa = -1;
                }
            }
        }
    }
}

void TutupEntryBuy()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
            {
                bool tutup = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 0, clrNONE);
                if (tutup)
                {
                    Print("Berhasil Menutup Order Buy");
                    entry_semasa = -1;
                }
            }
        }
    }
}

// Function to check if a new bar has formed
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