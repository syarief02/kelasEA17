// Entry BUY : RSI >= 70 | Exit BUY : RSI < 50 | Prev cs1
// Entry SELL : RSI <= 30 | Exit SELL : RSI > 50 | Prev cs1
#property strict

extern int MagicNumber = 123;
extern double LotSize = 0.01;

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
