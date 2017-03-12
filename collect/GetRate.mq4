//+------------------------------------------------------------------+
//|                                                      GetRate.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
    return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    datetime time = TimeCurrent();
    string date_str = TimeToStr(time, TIME_DATE);
    string datetime_str = TimeToStr(time, TIME_DATE | TIME_SECONDS);
    StringReplace(date_str, ".", "-");
    StringReplace(datetime_str, ".", "-");
    int handle = FileOpen(Symbol() + "_" + date_str + ".csv", FILE_CSV | FILE_READ | FILE_WRITE, ',');
    FileSeek(handle, 0, SEEK_END);
    FileWrite(handle, datetime_str, Symbol(), Bid, Ask);
    FileClose(handle);
  }
//+------------------------------------------------------------------+
