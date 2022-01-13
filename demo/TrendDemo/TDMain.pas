unit TDMain;
{(c) S.P.Pod'yachev 1999}
{****************************************************}
{ Example of Ternd plot using Tsp_xyPlot & Tsp_XYLine}
{ it is not right way to do that but can be do       }
{****************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, sgr_def, sgr_data;

type
  TForm1 = class(TForm)
    XYPlot: Tsp_XYPlot;
    Line1: Tsp_XYLine;
    btStart: TButton;
    btStop: TButton;
    Timer1: TTimer;
    PntCount: TLabel;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure btStartClick(Sender: TObject);
    procedure btStopClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    //xmin,xmax,
    x:double;
  public
    { Public declarations }
   procedure AddNext;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

Const
 //horizontal axis view interval
 TrendWindow=2*pi; //we show sin function and selest appropriate interval
 //number points are visible on this interval
 TrenPointsCount=20;
 //we shift points data in memory by portion
 TrenPointsStep=round(TrenPointsCount*0.3);
 //so we should alllocate memory for total points number
 TrendCapacity= TrenPointsCount+TrenPointsStep;
 //this is step of x value
 TrendXstep=TrendWindow/TrenPointsCount;

//add nex point to plot
procedure TForm1.AddNext;
begin
 with Line1 do begin
   LockInvalidate:=True;             //we must stop plot redrawn while add data
   if Count>=TrendCapacity then      //if all alocated memory was filled
     DeleteRange(0,TrenPointsStep-1);//then delte from begin
   PntCount.Caption:=IntToStr(Count);//show number points
   AddXY(x, sin(x));                 //add next points
   with XYPlot.BottomAxis do         //shift trend window if need
     if x>Max then XYPlot.BottomAxis.MoveMinMax(x-Max);
   LockInvalidate:=False;            //redraw plot
 end;
 x:=x+TrendXstep;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 try
  AddNext;
 except
  Timer1.Enabled:=False;
  raise;
 end;
end;

procedure TForm1.btStartClick(Sender: TObject);
begin
 x:=0;
 XYPlot.BottomAxis.SetMinMax(0,(TrendCapacity-TrenPointsStep)*TrendXstep);
 Line1.Clear;
 AddNext;
 Timer1.Enabled:=True;
end;

procedure TForm1.btStopClick(Sender: TObject);
begin
 Timer1.Enabled:=False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 Line1.SetCapacity(TrendCapacity);
 XYPlot.BottomAxis.SetMinMax(0,(TrendCapacity-TrenPointsStep)*TrendXstep);
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 Timer1.Enabled:=False;
end;

{check Delete, InsertXY and ReplaceXY
procedure TForm1.Button1Click(Sender: TObject);
begin
 Line1.Delete(10);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 Line1.InsertXY(10,pi,1.8);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 Line1.ReplaceXY(10,pi,-1.8);
end;
}
end.
