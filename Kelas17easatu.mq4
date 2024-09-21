int init() {
    Print("Hello World");
    return(0);
}

void OnTick() {
    Print("Ini adalah Tick : ", TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS));
    Print("RSI : ", rsiA());
}
double rsiA() {
    return iRSI(NULL, PERIOD_M15, 14, PRICE_CLOSE, 3);
}
/*

OrderSend()
OrderClose()
OrderModify()
MarketInfo()
Symbol()
Ask
Bid
iMA()
iBands
iStoch
iRSI
iMACD
iSAR
iAO
iATR
iCCI
iADX
iADX

*/
void OnDeinit(const int reason) {

    Print("EA Telah Di Hancurkan");
}

/*
1. Entry? Condition/Syarat Entry RSI OB/OS
2. Exit TakeProfit, StopLoss. | opposite | Overall Profit >= $1
3. Risk | LotSize
*/