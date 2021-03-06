//+------------------------------------------------------------------+
//|                                             hatyusamurai_zero.mq4 |
//|                                                          busitya |
//|                    https://sites.google.com/site/memomemoru/home |
//+------------------------------------------------------------------+
// 改版履歴
// 0.1版　新規作成
//+------------------------------------------------------------------+
#property copyright "busitya"
#property link      "https://sites.google.com/site/memomemoru/home"
#property strict

// 共通関数呼び出し
#include <bushido_commonutils.mqh>
#include <bushido_trailing.mqh>
#include <mt4gui2.mqh>
#include <WinUser32.mqh>
#import "user32.dll"
int GetAncestor(int,int);
#import

// Declare global variables
int hwnd=0;
int buyBtn,sellBtn,closeBtn,chartBtn,timeBtn;
int moveUpBtn,moveRightBtn,moveDownBtn,moveLeftBtn,trailBtn;
int loginHeader,loginBody,loginTrade;
int lotsLabelField,spreadLabelField,spLabelField,limitLabelField,stopLabelField,
chartLabelField,trailLabelField,posLabelField,aveRateLabelField,totalPIPSLabelField,totalProfitLabelField,timeLabelField;
int spText,limitText,stopText,buyText,sellText,buyPosText,sellPosText,buyAveRateText,sellAveRateText,buyTotalPIPSText,sellTotalPIPSText,
buyTotalProfitText,sellTotalProfitText;
int lotsList,spreadList,chartList,timeList;
int gUIXPosition,gUIYPosition;
int authenticationFail=0;
int chartData=0;

double version=0.8;

extern string msg="ポジション マジックナンバー";
extern double MAGIC=83983948;
//extern string trail_msg="HLBandの期間(トレールで使用）";
//extern double HLBAND_PERIOD=40;
extern string trail_msg2="保有ポジションをチャート表示（実装中）";
extern bool displayPosition=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   hwnd=WindowHandle(Symbol(),Period());
   guiRemoveAll(hwnd);

   gUIXPosition = 50;
   gUIYPosition = 50;

   BuildInterface();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   if(hwnd>0)
     {
      guiRemoveAll(hwnd);
     }
   guiCleanup(hwnd);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick() 
  {
   ManageEvents();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ManageEvents()
  {
   string limit= guiGetText(hwnd,limitText);
   string stop = guiGetText(hwnd, stopText);
   string lots = guiGetText(hwnd, lotsList);
   string spread= guiGetText(hwnd,spreadList);
   string chart = guiGetText(hwnd,chartList);
   string time=guiGetText(hwnd,timeList);

// 売り注文
   if(guiIsClicked(hwnd,sellBtn))
     {
      double limitpips;
      if(StringToDouble(limit)!=0)
        {
         limitpips=SellTakeProfit(Symbol(),StringToDouble(limit));
        }
      else
        {
         Print("Limit set 0. limit="+limit);
         limitpips=0;
        }

      double stoppips;
      if(StringToDouble(stop)!=0)
        {
         stoppips=SellStopLoss(Symbol(),StringToDouble(stop));
        }
      else
        {
         Print("Stop set 0. stop="+stop);
         stoppips=0;
        }

      Print("★★　売り注文 lots:"+lots+"　Slippage:"+spread+
            " Limit:"+limitpips+" Stop:"+stoppips);

      OpenSellOrderWithLimitStop(Symbol(),StrToDouble(lots),StrToDouble(spread),stoppips,
                                 limitpips,MAGIC,"Sell bushido Order");
     }

// 買い注文
   if(guiIsClicked(hwnd,buyBtn))
     {
      double limitpips;
      if(StringToDouble(limit)!=0)
        {
         limitpips=BuyTakeProfit(Symbol(),StringToDouble(limit));
        }
      else
        {
         Print("Limit set 0. limit="+limit);
         limitpips=0;
        }

      double stoppips;
      if(StringToDouble(stop)!=0)
        {
         stoppips=BuyStopLoss(Symbol(),StringToDouble(stop));
        }
      else
        {
         Print("Stop set 0.  stop="+stop);
         stoppips=0;
        }

      Print("★★　買い注文 lots:"+lots+"　Slippage:"+spread+
            " Limit:"+limitpips+" Stop:"+stoppips);

      OpenBuyOrderWithLimitStop(Symbol(),StrToDouble(lots),StrToDouble(spread),stoppips,
                                limitpips,MAGIC,"Buy bushido Order");
     }

// 全決済
   if(guiIsClicked(hwnd,closeBtn))
     {
      Print("★★　全決済 　Slippage:"+spread);

      // close positions for 3 times
      CloseAllOrders(Symbol(),MAGIC,StrToDouble(spread));
      CloseAllOrders(Symbol(),MAGIC,StrToDouble(spread));
      CloseAllOrders(Symbol(),MAGIC,StrToDouble(spread));
     }

// SP更新
   double sp=MarketInfo(Symbol(),MODE_SPREAD)/10;
   guiSetText(hwnd,spText,DoubleToStr(sp),15,"Arial Bold");

// BUYレート更新
   guiSetTextColor(hwnd,buyText,Orange);
   double buy=MarketInfo(Symbol(),MODE_BID);
   guiSetText(hwnd,buyText,DoubleToStr(buy),15,"Arial Bold");
   guiSetTextColor(hwnd,buyText,Red);

// SELLレート更新
   guiSetTextColor(hwnd,sellText,Orange);
   double sell=MarketInfo(Symbol(),MODE_ASK);
   guiSetText(hwnd,sellText,DoubleToStr(sell),15,"Arial Bold");
   guiSetTextColor(hwnd,sellText,Red);

// 合計ロット更新
   double buyPos=GetBuyTotalLots(Symbol(),MAGIC);
   double sellPos=GetSellTotalLots(Symbol(),MAGIC);
   guiSetText(hwnd,buyPosText,DoubleToStr(buyPos),15,"Arial Bold");
   guiSetText(hwnd,sellPosText,DoubleToStr(sellPos),15,"Arial Bold");

// 平均レート更新
   double buyAveRate=GetBuyAverateRate(Symbol(),MAGIC);
   double sellAveRate=GetSellAverateRate(Symbol(),MAGIC);
   guiSetText(hwnd,buyAveRateText,DoubleToStr(buyAveRate),15,"Arial Bold");
   guiSetText(hwnd,sellAveRateText,DoubleToStr(sellAveRate),15,"Arial Bold");

// 損益PIPS更新
   double buyTotalPIPS=GetBuyTotalPIPS(Symbol(),MAGIC);
   double sellTotalPIPS=GetSellTotalPIPS(Symbol(),MAGIC);
   guiSetText(hwnd,buyTotalPIPSText,DoubleToStr(buyTotalPIPS),15,"Arial Bold");
   guiSetText(hwnd,sellTotalPIPSText,DoubleToStr(sellTotalPIPS),15,"Arial Bold");

// 損益更新
   double buyTotalProfit=GetBuyTotalProfit(Symbol(),MAGIC);
   double sellTotalProfit=GetSellTotalProfit(Symbol(),MAGIC);
   guiSetText(hwnd,buyTotalProfitText,DoubleToStr(buyTotalProfit),15,"Arial Bold");
   guiSetText(hwnd,sellTotalProfitText,DoubleToStr(sellTotalProfit),15,"Arial Bold");

   string timeInt=DoubleToStr(Period(),0);
   bool timeOn = guiIsClicked(hwnd,timeBtn);
   bool chartOn = guiIsClicked(hwnd,chartBtn);
   if(timeOn == true)
     {
      // 通貨選択
      if(StringCompare("M1",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_M1,0);
        }
      else if(StringCompare("M5",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_M5,0);;
        }
      else if(StringCompare("M15",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_M15,0);;
        }
      else if(StringCompare("M30",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_M30,0);;
        }
      else if(StringCompare("H1",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_H1,0);;
        }
      else if(StringCompare("H4",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_H4,0);;
        }
      else if(StringCompare("D1",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_D1,0);;
        }
      else if(StringCompare("W1",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_W1,0);;
        }
      else if(StringCompare("MN1",time)==0)
        {
         timeInt=DoubleToStr(PERIOD_MN1,0);;
        }
     }
   if(chartOn==false)
     {
      chart=Symbol();
     }

   if(chartOn==true
      || timeOn==true)
     {
      Print("★通貨/時間軸切り替え:"+chart+","+timeInt);
      guiChangeSymbol(hwnd,chart+","+timeInt);
     }

   if(guiIsClicked(hwnd,moveUpBtn))
     {
      gUIYPosition=gUIYPosition-10;
      guiRemoveAll(hwnd);
      BuildInterface();
     }
   if(guiIsClicked(hwnd,moveRightBtn))
     {
      gUIXPosition=gUIXPosition+10;
      guiRemoveAll(hwnd);
      BuildInterface();
     }
   if(guiIsClicked(hwnd,moveDownBtn))
     {
      gUIYPosition=gUIYPosition+10;
      guiRemoveAll(hwnd);
      BuildInterface();
     }
   if(guiIsClicked(hwnd,moveLeftBtn))
     {
      gUIXPosition=gUIXPosition-10;
      guiRemoveAll(hwnd);
      BuildInterface();
     }
/**
    * 保有ポジションのチャート表示
   */
   if(displayPosition==true)
     {
      DisplayPositionOnChart(Symbol(),MAGIC);
     }

/*
   if (guiIsChecked(hwnd,trailBtn)) 
   {
        TrailingStopWithHLBand(Symbol(), HLBAND_PERIOD, MAGIC);
   }
   */
  }
// MT4GUI functions to build Interface with labels, buttons & textfields
//+-------------------------------------------------------------------------------------------+
void BuildInterface()
  {
   loginHeader=guiAdd(hwnd,"label",gUIXPosition,gUIYPosition,190,20,"     発注侍ZERO v"+version);
   loginBody=guiAdd(hwnd,"label",gUIXPosition,gUIYPosition+20,190,250,"");
   loginTrade=guiAdd(hwnd,"label",gUIXPosition+5,gUIYPosition+121,180,125,"");
   guiSetBgColor(hwnd,loginHeader,RoyalBlue);
   guiSetTextColor(hwnd,loginHeader,White);
   guiSetBgColor(hwnd,loginBody,Lavender);
   guiSetBgColor(hwnd,loginTrade,MintCream);

// 買いボタン
   buyBtn=guiAdd(hwnd,"button",gUIXPosition+110,gUIYPosition+123,70,35,"");
   guiSetBorderColor(hwnd,buyBtn,RoyalBlue);
   guiSetBgColor(hwnd,buyBtn,Blue);
   guiSetTextColor(hwnd,buyBtn,White);
   guiSetText(hwnd,buyBtn,"BUY",25,"Arial Bold");

// 売りボタン
   sellBtn=guiAdd(hwnd,"button",gUIXPosition+10,gUIYPosition+123,70,35,"");
   guiSetBorderColor(hwnd,sellBtn,OrangeRed);
   guiSetBgColor(hwnd,sellBtn,Red);
   guiSetTextColor(hwnd,sellBtn,Black);
   guiSetText(hwnd,sellBtn,"SELL",25,"Arial Bold");

// 決済ボタン
   closeBtn=guiAdd(hwnd,"button",gUIXPosition+10,gUIYPosition+250,170,20,"");
   guiSetBorderColor(hwnd,closeBtn,OrangeRed);
   guiSetBgColor(hwnd,closeBtn,Yellow);
   guiSetTextColor(hwnd,closeBtn,Black);
   guiSetText(hwnd,closeBtn,"全決済",10,"MS 明朝");

// SP
   spLabelField=guiAdd(hwnd,"label",gUIXPosition+87,gUIYPosition+120,20,20,"SP:");
   guiSetText(hwnd,spLabelField,"SP",15,"Arial Bold");
   guiSetBgColor(hwnd,spLabelField,MintCream);
   guiSetTextColor(hwnd,spLabelField,Red);

   spText=guiAdd(hwnd,"text",gUIXPosition+84,gUIYPosition+135,23,20,"Text Field");
   double sp=MarketInfo(Symbol(),MODE_SPREAD)/10;
   guiSetText(hwnd,spText,DoubleToStr(sp),15,"Arial Bold");
   guiSetBgColor(hwnd,spText,Lavender);
   guiSetTextColor(hwnd,spText,Red);

/***********************
    /* ポジション
    /***********************/
   posLabelField=guiAdd(hwnd,"label",gUIXPosition+70,gUIYPosition+170,48,20,"Text Field");
   guiSetText(hwnd,posLabelField,"合計ロット",15,"Arial Bold");
   guiSetBgColor(hwnd,posLabelField,MintCream);
   guiSetTextColor(hwnd,posLabelField,Black);

// BUY
   buyPosText=guiAdd(hwnd,"text",gUIXPosition+130,gUIYPosition+170,47,20,"Text Field");
   double buyPos=GetBuyTotalLots(Symbol(),MAGIC);
   guiSetText(hwnd,buyPosText,DoubleToStr(buyPos),15,"Arial Bold");
   guiSetBgColor(hwnd,buyPosText,White);
   guiSetTextColor(hwnd,buyPosText,Black);

// SELL
   sellPosText=guiAdd(hwnd,"text",gUIXPosition+15,gUIYPosition+170,47,20,"Text Field");
   double sellPos=GetSellTotalLots(Symbol(),MAGIC);
   guiSetText(hwnd,sellPosText,DoubleToStr(sellPos),15,"Arial Bold");
   guiSetBgColor(hwnd,sellPosText,White);
   guiSetTextColor(hwnd,sellPosText,Black);

/**********************
    /* 平均レート
    /**********************/
   aveRateLabelField=guiAdd(hwnd,"label",gUIXPosition+70,gUIYPosition+190,52,20,"Text Field");
   guiSetText(hwnd,aveRateLabelField,"平均レート",15,"Arial Bold");
   guiSetBgColor(hwnd,aveRateLabelField,MintCream);
   guiSetTextColor(hwnd,aveRateLabelField,Black);

// BUY
   buyAveRateText=guiAdd(hwnd,"text",gUIXPosition+130,gUIYPosition+190,47,20,"Text Field");
   double buyAveRate=GetBuyAverateRate(Symbol(),MAGIC);
   guiSetText(hwnd,buyAveRateText,DoubleToStr(buyAveRate),15,"Arial Bold");
   guiSetBgColor(hwnd,buyAveRateText,White);
   guiSetTextColor(hwnd,buyAveRateText,Black);

// SELL
   sellAveRateText=guiAdd(hwnd,"text",gUIXPosition+15,gUIYPosition+190,47,20,"Text Field");
   double sellAveRate=GetSellAverateRate(Symbol(),MAGIC);
   guiSetText(hwnd,sellAveRateText,DoubleToStr(sellAveRate),15,"Arial Bold");
   guiSetBgColor(hwnd,sellAveRateText,White);
   guiSetTextColor(hwnd,sellAveRateText,Black);

/*********************
     /* 損益(PIPS)
     /*********************/
   totalPIPSLabelField=guiAdd(hwnd,"label",gUIXPosition+70,gUIYPosition+210,52,20,"Text Field");
   guiSetText(hwnd,totalPIPSLabelField,"損益PIPS",15,"Arial Bold");
   guiSetBgColor(hwnd,totalPIPSLabelField,MintCream);
   guiSetTextColor(hwnd,totalPIPSLabelField,Black);

// BUY
   buyTotalPIPSText=guiAdd(hwnd,"text",gUIXPosition+130,gUIYPosition+210,47,20,"Text Field");
   double buyTotalPIPS=GetBuyTotalPIPS(Symbol(),MAGIC);
   guiSetText(hwnd,buyTotalPIPSText,DoubleToStr(buyTotalPIPS),15,"Arial Bold");
   guiSetBgColor(hwnd,buyTotalPIPSText,White);
   guiSetTextColor(hwnd,buyTotalPIPSText,Black);

// SELL
   sellTotalPIPSText=guiAdd(hwnd,"text",gUIXPosition+15,gUIYPosition+210,47,20,"Text Field");
   double sellTotalPIPS=GetSellTotalPIPS(Symbol(),MAGIC);
   guiSetText(hwnd,sellTotalPIPSText,DoubleToStr(sellTotalPIPS),15,"Arial Bold");
   guiSetBgColor(hwnd,sellTotalPIPSText,White);
   guiSetTextColor(hwnd,sellTotalPIPSText,Black);

/*********************
    /* 損益
    /*********************/
   totalProfitLabelField=guiAdd(hwnd,"label",gUIXPosition+70,gUIYPosition+230,52,20,"Text Field");
   guiSetText(hwnd,totalProfitLabelField,"合計損益",15,"Arial Bold");
   guiSetBgColor(hwnd,totalProfitLabelField,MintCream);
   guiSetTextColor(hwnd,totalProfitLabelField,Black);

// BUY
   buyTotalProfitText=guiAdd(hwnd,"text",gUIXPosition+130,gUIYPosition+230,47,20,"Text Field");
   double buyTotalProfit=GetBuyTotalProfit(Symbol(),MAGIC);
   guiSetText(hwnd,buyTotalProfitText,DoubleToStr(buyTotalProfit),15,"Arial Bold");
   guiSetBgColor(hwnd,buyTotalProfitText,White);
   guiSetTextColor(hwnd,buyTotalProfitText,Black);

// SELL
   sellTotalProfitText=guiAdd(hwnd,"text",gUIXPosition+15,gUIYPosition+230,47,20,"Text Field");
   double sellTotalProfit=GetSellTotalProfit(Symbol(),MAGIC);
   guiSetText(hwnd,sellTotalProfitText,DoubleToStr(sellTotalProfit),15,"Arial Bold");
   guiSetBgColor(hwnd,sellTotalProfitText,White);
   guiSetTextColor(hwnd,sellTotalProfitText,Black);

// BUY RATE;
   buyText=guiAdd(hwnd,"text",gUIXPosition+15,gUIYPosition+150,53,20,"Text Field");
   double buy=MarketInfo(Symbol(),MODE_BID);
   guiSetText(hwnd,buyText,DoubleToStr(buy),15,"Arial Bold");

// SELL RATE
   sellText=guiAdd(hwnd,"text",gUIXPosition+120,gUIYPosition+150,53,20,"Text Field");
   double sell=MarketInfo(Symbol(),MODE_ASK);
   guiSetText(hwnd,sellText,DoubleToStr(sell),15,"Arial Bold");

// Limit
   limitLabelField=guiAdd(hwnd,"label",gUIXPosition+110,gUIYPosition+75,40,20,"Limit:");
   guiSetText(hwnd,limitLabelField,"Limit:",15,"Arial Bold");
   guiSetBgColor(hwnd,limitLabelField,Lavender);
   guiSetTextColor(hwnd,limitLabelField,Black);

   limitText=guiAdd(hwnd,"text",gUIXPosition+145,gUIYPosition+75,30,20,"Text Field");
   guiSetText(hwnd,limitText,IntegerToString(0),15,"Arial Bold");
   guiSetBgColor(hwnd,limitText,Lavender);
   guiSetTextColor(hwnd,limitText,Red);

// Stop
   stopLabelField=guiAdd(hwnd,"label",gUIXPosition+110,gUIYPosition+100,40,20,"Stop:");
   guiSetText(hwnd,stopLabelField,"Stop:",15,"Arial Bold");
   guiSetBgColor(hwnd,stopLabelField,Lavender);
   guiSetTextColor(hwnd,stopLabelField,Black);

   stopText=guiAdd(hwnd,"text",gUIXPosition+145,gUIYPosition+100,30,20,"Text Field");
   guiSetText(hwnd,stopText,IntegerToString(0),15,"Arial Bold");
   guiSetBgColor(hwnd,stopText,Lavender);
   guiSetTextColor(hwnd,stopText,Red);

// 移動ボタン
   moveUpBtn=guiAdd(hwnd,"button",gUIXPosition+80,gUIYPosition-20,20,20,"");
   guiSetTextColor(hwnd,moveUpBtn,White);
   guiSetBorderColor(hwnd,moveUpBtn,Black);
   guiSetBgColor(hwnd,moveUpBtn,Black);
   guiSetText(hwnd,moveUpBtn,CharToStr(217),20,"Wingdings");

   moveRightBtn=guiAdd(hwnd,"button",gUIXPosition+190,gUIYPosition+80,20,20,"");
   guiSetTextColor(hwnd,moveRightBtn,White);
   guiSetBorderColor(hwnd,moveRightBtn,Black);
   guiSetBgColor(hwnd,moveRightBtn,Black);
   guiSetText(hwnd,moveRightBtn,CharToStr(216),20,"Wingdings");

   moveDownBtn=guiAdd(hwnd,"button",gUIXPosition+80,gUIYPosition+270,20,20,"");
   guiSetTextColor(hwnd,moveDownBtn,White);
   guiSetBorderColor(hwnd,moveDownBtn,Black);
   guiSetBgColor(hwnd,moveDownBtn,Black);
   guiSetText(hwnd,moveDownBtn,CharToStr(218),20,"Wingdings");

   moveLeftBtn=guiAdd(hwnd,"button",gUIXPosition-20,gUIYPosition+80,20,20,"");
   guiSetTextColor(hwnd,moveLeftBtn,White);
   guiSetBorderColor(hwnd,moveLeftBtn,Black);
   guiSetBgColor(hwnd,moveLeftBtn,Black);
   guiSetText(hwnd,moveLeftBtn,CharToStr(215),20,"Wingdings");

/*********************
    /*　ロット切り替え
    /*********************/
   lotsLabelField=guiAdd(hwnd,"label",gUIXPosition+10,gUIYPosition+75,55,20,"Lots:");
   guiSetText(hwnd,lotsLabelField,"Lots:",15,"Arial Bold");
   guiSetBgColor(hwnd,lotsLabelField,Lavender);
   guiSetTextColor(hwnd,lotsLabelField,Black);

   lotsList=guiAdd(hwnd,"list",gUIXPosition+55,gUIYPosition+75,48,15,"Lots");
   guiSetText(hwnd,lotsList,"Lots:",13,"Arial Bold");
   guiAddListItem(hwnd,lotsList,"0.01");
   guiAddListItem(hwnd,lotsList,"0.02");
   guiAddListItem(hwnd,lotsList,"0.03");
   guiAddListItem(hwnd,lotsList,"0.04");
   guiAddListItem(hwnd,lotsList,"0.05");
   guiAddListItem(hwnd,lotsList,"0.06");
   guiAddListItem(hwnd,lotsList,"0.07");
   guiAddListItem(hwnd,lotsList,"0.08");
   guiAddListItem(hwnd,lotsList,"0.09");
   guiAddListItem(hwnd,lotsList,"0.1");
   guiAddListItem(hwnd,lotsList,"0.2");
   guiAddListItem(hwnd,lotsList,"0.3");
   guiAddListItem(hwnd,lotsList,"0.4");
   guiAddListItem(hwnd,lotsList,"0.5");
   guiAddListItem(hwnd,lotsList,"0.6");
   guiAddListItem(hwnd,lotsList,"0.7");
   guiAddListItem(hwnd,lotsList,"0.8");
   guiAddListItem(hwnd,lotsList,"0.9");
   guiAddListItem(hwnd,lotsList,"1.0");
   guiAddListItem(hwnd,lotsList,"1.5");
   guiAddListItem(hwnd,lotsList,"2.0");
   guiAddListItem(hwnd,lotsList,"2.5");
   guiAddListItem(hwnd,lotsList,"3.0");
   guiAddListItem(hwnd,lotsList,"3.5");
   guiAddListItem(hwnd,lotsList,"4.0");
   guiAddListItem(hwnd,lotsList,"4.5");
   guiAddListItem(hwnd,lotsList,"5.0");
   guiSetListSel(hwnd,lotsList,9);

/*********************
    /*　スリッページ切り替え
    /*********************/
   spreadLabelField=guiAdd(hwnd,"label",gUIXPosition+10,gUIYPosition+100,55,20,"Slippage:");
   guiSetText(hwnd,spreadLabelField,"Slippage:",15,"Arial Bold");
   guiSetBgColor(hwnd,spreadLabelField,Lavender);
   guiSetTextColor(hwnd,spreadLabelField,Black);

   spreadList=guiAdd(hwnd,"list",gUIXPosition+65,gUIYPosition+100,38,15,"Slippage");
   guiSetText(hwnd,spreadList,"Lots:",13,"Arial Bold");
   guiAddListItem(hwnd,spreadList,"1");
   guiAddListItem(hwnd,spreadList,"2");
   guiAddListItem(hwnd,spreadList,"3");
   guiAddListItem(hwnd,spreadList,"4");
   guiAddListItem(hwnd,spreadList,"5");
   guiSetListSel(hwnd,spreadList,1);

/*********************
    /* 通貨切り替えボタン
    /*********************/
   chartLabelField=guiAdd(hwnd,"label",gUIXPosition+10,gUIYPosition+25,55,20,"Slippage:");
   guiSetText(hwnd,chartLabelField,"通貨:",15,"Arial Bold");
   guiSetBgColor(hwnd,chartLabelField,Lavender);
   guiSetTextColor(hwnd,chartLabelField,Black);

   chartList=guiAdd(hwnd,"list",gUIXPosition+55,gUIYPosition+25,70,15,"Slippage");
   guiSetText(hwnd,chartList,"Lots:",13,"Arial Bold");
   guiAddListItem(hwnd,chartList,"USDJPY");
   guiAddListItem(hwnd,chartList,"USDCAD");
   guiAddListItem(hwnd,chartList,"GBPUSD");
   guiAddListItem(hwnd,chartList,"GBPJPY");
   guiAddListItem(hwnd,chartList,"EURUSD");
   guiAddListItem(hwnd,chartList,"EURJPY");
   guiAddListItem(hwnd,chartList,"AUDUSD");
   guiAddListItem(hwnd,chartList,"AUDJPY");
   guiAddListItem(hwnd,chartList,"NZDUSD");
   guiAddListItem(hwnd,chartList,"NZDJPY");
   guiAddListItem(hwnd,chartList,"OILUSD");
   guiAddListItem(hwnd,chartList,"XAUUSD");
   guiSetListSel(hwnd,chartList,0);

   chartBtn=guiAdd(hwnd,"button",gUIXPosition+130,gUIYPosition+25,50,20,"");
   guiSetBorderColor(hwnd,chartBtn,OrangeRed);
   guiSetBgColor(hwnd,chartBtn,Yellow);
   guiSetTextColor(hwnd,chartBtn,Black);
   guiSetText(hwnd,chartBtn,"通貨変更",10,"MS 明朝");

/*********************
    /* 時間軸切り替えボタン
    /*********************/
   timeLabelField=guiAdd(hwnd,"label",gUIXPosition+10,gUIYPosition+50,55,20,"Slippage:");
   guiSetText(hwnd,timeLabelField,"時間軸:",15,"Arial Bold");
   guiSetBgColor(hwnd,timeLabelField,Lavender);
   guiSetTextColor(hwnd,timeLabelField,Black);

   timeList=guiAdd(hwnd,"list",gUIXPosition+55,gUIYPosition+50,70,15,"Slippage");
   guiSetText(hwnd,timeList,"Lots:",13,"Arial Bold");
   guiAddListItem(hwnd,timeList,"M1");
   guiAddListItem(hwnd,timeList,"M5");
   guiAddListItem(hwnd,timeList,"M15");
   guiAddListItem(hwnd,timeList,"M30");
   guiAddListItem(hwnd,timeList,"H1");
   guiAddListItem(hwnd,timeList,"H4");
   guiAddListItem(hwnd,timeList,"D1");
   guiAddListItem(hwnd,timeList,"W1");
   guiAddListItem(hwnd,timeList,"MN");
   guiSetListSel(hwnd,timeList,0);

   timeBtn=guiAdd(hwnd,"button",gUIXPosition+130,gUIYPosition+50,50,20,"");
   guiSetBorderColor(hwnd,timeBtn,OrangeRed);
   guiSetBgColor(hwnd,timeBtn,Yellow);
   guiSetTextColor(hwnd,timeBtn,Black);
   guiSetText(hwnd,timeBtn,"時間軸変更",9,"MS 明朝");


// トレールボタン
/*
    trailLabelField = guiAdd(hwnd,"label",gUIXPosition+10,gUIYPosition+100,90,15,"Trail ON/OFF:");
    guiSetText(hwnd,trailLabelField,"トレール(ON/OFF):",15,"Arial Bold");
    guiSetBgColor(hwnd,trailLabelField, Lavender);
    guiSetTextColor(hwnd,trailLabelField,Black);
    
    trailBtn     = guiAdd(hwnd,"checkbox",gUIXPosition+110,gUIYPosition+100,20,15,""); 
    guiSetBgColor(hwnd,trailBtn,Lavender);
    guiSetTextColor(hwnd,trailBtn,Black);        
    */

  }
// Windows/MT4 function to exit EA (advanced)
//+-------------------------------------------------------------------------------------------+
void ExitEA()
  {
   Alert("This exits your EA");
   int hWnd=WindowHandle(Symbol(),Period());
#define MT4_WMCMD_REMOVE_EXPERT   33050 /* Remove expert advisor from chart */
   PostMessageA(hWnd,WM_COMMAND,MT4_WMCMD_REMOVE_EXPERT,0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 保有ポジションのチャート表示                                                 |
//|                                                                  |
//| 引数  symbol: 　通貨情報                  　                     |
//|       MAGICMA: マジックナンバー                                  |
//| 返値　なし                                                     |
//+------------------------------------------------------------------+
int DisplayPositionOnChart(string symbol,int MAGICMA)
  {
   int orderCount=0;

   for(int counter=0; counter<=OrdersTotal()-1;counter++)
     {
      OrderSelect(counter,SELECT_BY_POS,MODE_TRADES);
      if(OrderMagicNumber() == MAGICMA && OrderSymbol() == symbol
         && (OrderType() == OP_BUY || OrderType() == OP_SELL))
        {
         //Print("☆☆");
         guiPrintXY(OrderSymbol()+" "+(OrderType() ? "BUY" : "SELL")+" "+OrderLots(),Tomato,50,500+orderCount*50,18);
         orderCount++;
        }
     }
   return(orderCount);
  }
//+------------------------------------------------------------------+
