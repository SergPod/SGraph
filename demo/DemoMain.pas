unit DemoMain;
{(c) S.P.Pod'yachev 1998-1999}
{***************************************************}
{ Main Form for demo program of  Tsp_xyPlot         }
{***************************************************}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, ComCtrls, Printers,
  sgr_def, sgr_data, sgr_sprint,
  MMSystem, Spin, sgr_mark, ImgList;

{Const
 WM_DANI=WM_USER+2;}

Type
  TFsgrDemoMain = class(TForm)
    MainMenu1: TMainMenu;
    mbFile: TMenuItem;
    mbCopy: TMenuItem;
    mCopyPlotDIB: TMenuItem;
    mExit: TMenuItem;
    mbHelp: TMenuItem;
    mAbout: TMenuItem;
    N3: TMenuItem;
    mAbortScan: TMenuItem;
    N7: TMenuItem;
    mCopyPlotMF: TMenuItem;
    StatusBar: TStatusBar;
    mbView: TMenuItem;
    mSetLimits: TMenuItem;
    N1: TMenuItem;
    mBufferedDisplay: TMenuItem;
    mOnDrawEnd: TMenuItem;
    mOnFieldDraw: TMenuItem;
    mbZoom: TMenuItem;
    mZH: TMenuItem;
    mZV: TMenuItem;
    mZB: TMenuItem;
    mZN: TMenuItem;
    mShowpoints: TMenuItem;
    mShowlines: TMenuItem;
    N2: TMenuItem;
    mPrint: TMenuItem;
    SLine: Tsp_XYLine;
    QLine: Tsp_XYLine;
    Timer1: TTimer;
    mAxisproperties: TMenuItem;
    XYPlot: Tsp_XYPlot;
    BGImage: TImage;
    mSRecord: TMenuItem;
    mQARecord: TMenuItem;
    PointImageList: TImageList;
    mCustomdrawpoint: TMenuItem;
    mChangeborder: TMenuItem;
    sp_ImageMarker1: Tsp_ImageMarker;
    X0LineMarker: Tsp_LineMarker;
    YOLineMarker: Tsp_LineMarker;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure XYPlotDrawEnd(Sender: TObject);
    procedure XYPlotMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure XYPlotAxisZoom(Sender: Tsp_Axis; var min, max: Double;
      var CanZoom: Boolean);
    procedure XYPlotFieldDraw(Sender: TObject);

    procedure mPrintClick(Sender: TObject);
    procedure mExitClick(Sender: TObject);

    procedure mCopyPlotMFClick(Sender: TObject);
    procedure mCopyPlotDIBClick(Sender: TObject);

    procedure mSetLimitsClick(Sender: TObject);
    procedure mBufferedDisplayClick(Sender: TObject);
    procedure mShowpointsClick(Sender: TObject);
    procedure mShowlinesClick(Sender: TObject);

    procedure mOnDrawEndClick(Sender: TObject);
    procedure mOnFieldDrawClick(Sender: TObject);
    procedure mAbortScanClick(Sender: TObject);

    procedure mZVClick(Sender: TObject);
    procedure mZHClick(Sender: TObject);
    procedure mZBClick(Sender: TObject);
    procedure mZNClick(Sender: TObject);

    procedure Timer1Timer(Sender: TObject);
    procedure mAxispropertiesClick(Sender: TObject);
    procedure mSRecordClick(Sender: TObject);
    procedure mQARecordClick(Sender: TObject);

    procedure mAboutClick(Sender: TObject);
    procedure QLineDrawCustomPoint(const XYLine: Tsp_XYLine; const xv,
      yv: Double; x, y: Integer);
    procedure mCustomdrawpointClick(Sender: TObject);
    procedure mChangeborderClick(Sender: TObject);
  private
    { Private declarations }
  protected
    { Public declarations }
   Scrolling, AbortScroll:boolean;
   procedure StopRecord;
   procedure NewRecord;
   procedure ShowHint(Sender: TObject);
   procedure DrawLegendTable;   //example how draw legend
{   procedure StartScan;}
  end;

var
  FsgrDemoMain: TFsgrDemoMain;

IMPLEMENTATION

uses AxisLmtsDlg, AxisPrptsDlg, About;

{$R *.DFM}

function decsin(x:double):double;
begin
 result:=9*(sin(x)+1.02)/(x+1);
end;

function rsin(x:double):double;
begin
 result:=(sin(x*3)+4.6+0.08*x);
end;

//procedure for quasi scan
var
 Cntr:integer;

const
 SN=300;  sd=5.0/SN;
 QAN=30; qad=10.0/QAN;

procedure TFsgrDemoMain.NewRecord;
var  j:integer;
begin
 StatusBar.Panels[0].Text:='';   // ??
 mSRecord.Enabled:=False;
 mQARecord.Enabled:=False;
 mbView.Enabled:=False;
 XYPlot.LeftAxis.SetMinMax(0,10);
 if Scrolling then
 begin
   QLine.Active:=False;
   XYPlot.BottomAxis.SetMinMax(0,5);
   AbortScroll:=False;
   for j:=0 to SN do
   begin
    XYPlot.BottomAxis.MoveMinMax(sd);
    Application.ProcessMessages;
    if AbortScroll then break;
   end;
   StopRecord;
 end
 else
 begin
   SLine.Active:=False;
   XYPlot.BottomAxis.SetMinMax(0,10);
   QLine.Clear;
   Cntr:=QAN;
   Timer1.Enabled:=True;
 end;
end;


procedure TFsgrDemoMain.StopRecord;
begin
 Timer1.Enabled:=False;
 AbortScroll:=True;
 QLine.Active:=True;
 SLine.Active:=True;
 mSRecord.Enabled:=True;
 mQARecord.Enabled:=True;
 mbView.Enabled:=True;
 XYPlot.BottomAxis.SetMinMax(0,10);
end;


procedure TFsgrDemoMain.Timer1Timer(Sender: TObject);
var x:double;
begin
 try
   x:=qad*(QAN-Cntr);
   QLine.QuickAddXY(x,decsin(x));
   dec(Cntr);
   if Cntr<=0 then StopRecord;
 except
   StopRecord;
   raise;
 end;
end;


procedure TFsgrDemoMain.FormCreate(Sender: TObject);
var j:integer; x,d:double;
begin //FormCreate
 Application.OnHint := ShowHint;
 with QLine do
 begin
   for j:=0 to QAN-1 do begin
    x:=qad*j;
    AddXY(x, decsin(x));
   end;
 end;
 with SLine do
 begin
   d:=9.9/90;
   for j:=0 to 89 do begin
    x:=d*j;
    AddXY(x, rsin(x));
   end;
 end;
end;  //FormCreate

procedure TFsgrDemoMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 //stop scan on exit
 if Timer1.Enabled then  mAbortScanClick(Sender);
end;

procedure TFsgrDemoMain.ShowHint(Sender: TObject);
begin
 StatusBar.Panels[1].Text:=GetLongHint(Application.Hint);
end;


//click mouse on plot to see points values
procedure TFsgrDemoMain.XYPlotMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 with StatusBar, XYPlot do
  Panels[0].Text:=Format(' X=%3.1f  Y=%3.1f',
  [BottomAxis.P2V(X), LeftAxis.P2V(Y)])
end;


// Example how to draw legend, this procedure draw legend on plot
// this procedure called by OnDrawEnd handler
procedure TFsgrDemoMain.DrawLegendTable;
var R:TRect; i, sc, lsh,lwh:integer;
const ds=6;
begin
  //first calculate legend table rectangle size
  lwh:=0; sc:=0;
  with XYPlot.DCanvas do //in reality you can draw on another canvas
  begin
    Font:=XYPlot.Font;   //set axis font as legend font
    //find biggest width of legend text & calc number of legend
    for i:=0 to XYPlot.SeriesCount-1 do with XYPlot.Series[i] do
    begin
      if Active then begin
       lsh:=TextWidth(Legend);
       if lsh>lwh then lwh:=lsh;
       inc(sc);
      end;
    end;
    if sc<1 then Exit; //no one active series
    lsh:=TextHeight('|')+2;      //one legend string height
    inc(lwh, lsh+lsh div 2 +1  + 2 + 3 +2); //legend string height+gap+2border
    with XYPlot do with FieldRect do begin  //place rect in field
      R:=Rect(Right-ds-lwh,top+ds,Right-ds,top+ds+lsh*sc);
      if (R.Left<Left-2) or (R.Bottom>Bottom-2) then Exit; //field size too small
    end;
    lwh:=lsh+lsh div 2 +1;    //legend picture width
    //draw legend table background rect & calc picture rect
    Brush.Color:=clWhite;
    Brush.Style:=bsSolid;
    with Pen do begin Color:=clBlack; Width:=1 end;
    with R do begin
      Rectangle(Left,Top,Right,Bottom);
      inc(Left,1); inc(Top,1); Right:=Left+lwh; Bottom:=Top+lsh-2;
    end;
    //draw legends
    for i:=0 to XYPlot.SeriesCount-1 do with XYPlot.Series[i] do
    begin
      if Active then begin
        DrawLegendMarker(XYPlot.DCanvas,R);
        if Brush.Style<>bsClear then Brush.Style:=bsClear;
        TextOut(R.Right+2,R.Top,Legend);
        OffsetRect(R,0,lsh);
      end;
    end;
  end;
end;


var sparse:byte;
//
// Example of Draw customs points
procedure TFsgrDemoMain.QLineDrawCustomPoint(const XYLine: Tsp_XYLine;
  const xv, yv: Double; x, y: Integer);
var xe,ye:integer;
begin
 with XYLine do begin
   with PointImageList do
    Draw(XYLine.Canvas, x-width div 2, y-height div 2, 0);
   if not(DrawingLegendMarker) then begin
     inc(sparse);
     if sparse>3 then with XYLine.Canvas do
     begin
       sparse:=0;
       Font:=Plot.Font;
       xe:=x-1;
       ye:=y-PointAttr.VSize-6;
       MoveTo(x-1,y-1); LineTo(xe,ye);
       dec(ye,abs(Font.Height));
       TextOut(xe-2, ye, Format('%2.1f',[yv]));
     end;
   end;
 end;
end;

const
 EDS='Title is drawn by OnDrawEnd Event Handler';


procedure TFsgrDemoMain.XYPlotFieldDraw(Sender: TObject);
//OnFieldDraw handler draws bitmap texture
var BGBMP:TBitmap; w,h:integer;
begin
  sparse:=0; //it is for custom points draw
  if Not mOnFieldDraw.Checked then Exit;
  BGBMP:=BGImage.Picture.Bitmap;
  with Sender as Tsp_xyPlot do
  with DCanvas, FieldRect do
  begin
      h:=Top;
      repeat
        w:=Left;
        repeat
          Draw(w,h, BGBMP);
          inc(w, BGBMP.Width);
        until w>Right;
        inc(h, BGBMP.Height);
      until h>Bottom
  end
end;


procedure TFsgrDemoMain.XYPlotDrawEnd(Sender: TObject);
//OnDrawEnd handler draws Title and legend table
begin
 if Not mOnDrawEnd.Checked then Exit;
 with Sender as Tsp_xyPlot do
  with DCanvas do
  begin
    Brush.Style:=bsClear;
    Font.Color:=clNavy;
    Font.Size:=10;
    Font.Style:=[fsBold];
    TextOut((Width-TextWidth(EDS))div 2,
             (TopAxis.Margin-TextHeight(EDS))div 2  , EDS);
  end;
  DrawLegendTable;
end;

//disable zoom RightAxis and TopAxis - we don't use them
procedure TFsgrDemoMain.XYPlotAxisZoom(Sender: Tsp_Axis; var min, max: Double;
  var CanZoom: Boolean);
begin
 with XYPlot do
  if (Sender=RightAxis) or (Sender=TopAxis) then CanZoom:=False;
end;

{* Menu handlers *}

//File

procedure TFsgrDemoMain.mPrintClick(Sender: TObject);
begin
 PrintPlot(XYPlot);
end;

procedure TFsgrDemoMain.mExitClick(Sender: TObject);
begin
 Close;
end;

//Copy

procedure TFsgrDemoMain.mCopyPlotMFClick(Sender: TObject);
begin
 XYPlot.CopyToClipboardMetafile;
end;

procedure TFsgrDemoMain.mCopyPlotDIBClick(Sender: TObject);
begin
 XYPlot.CopyToClipboardBitmap;
end;

//View

procedure TFsgrDemoMain.mSetLimitsClick(Sender: TObject);
begin
 SetPlotLimits(XYPlot);
end;

procedure TFsgrDemoMain.mAxispropertiesClick(Sender: TObject);
begin
 SetAxisProperties(XYPlot);
end;

procedure TFsgrDemoMain.mOnFieldDrawClick(Sender: TObject);
begin
 mOnFieldDraw.Checked:=Not mOnFieldDraw.Checked;
 XYPlot.Invalidate;
end;

procedure TFsgrDemoMain.mShowpointsClick(Sender: TObject);
var pon:boolean; j:integer;
begin
 pon:=not(Sender as TMenuItem).Checked;
 (Sender as TMenuItem).Checked:=pon;
 for j:=0 to XYPlot.SeriesCount-1 do
   with XYPlot.Series[j] as Tsp_XYLine do PointAttr.Visible:=pon;
end;

procedure TFsgrDemoMain.mShowlinesClick(Sender: TObject);
var pon:boolean; j:integer;
begin
 pon:=not(Sender as TMenuItem).Checked;
 (Sender as TMenuItem).Checked:=pon;
 for j:=0 to XYPlot.SeriesCount-1 do
   with XYPlot.Series[j] as Tsp_XYLine do LineAttr.Visible:=pon;
end;

procedure TFsgrDemoMain.mCustomdrawpointClick(Sender: TObject);
begin
  mCustomdrawpoint.Checked:=not mCustomdrawpoint.Checked;
  if mCustomdrawpoint.Checked then QLine.PointAttr.Kind:=ptCustom
  else QLine.PointAttr.Kind:=ptEllipse;
end;

procedure TFsgrDemoMain.mChangeborderClick(Sender: TObject);
begin
 if XYPlot.BorderStyle=High(Tsp_BorderStyle) then
    XYPlot.BorderStyle:=Low(Tsp_BorderStyle)
 else
    XYPlot.BorderStyle:=Succ(XYPlot.BorderStyle);
end;

procedure TFsgrDemoMain.mBufferedDisplayClick(Sender: TObject);
begin
 mBufferedDisplay.Checked:=Not mBufferedDisplay.Checked;
 XYPlot.BufferedDisplay:=mBufferedDisplay.Checked;
end;

procedure TFsgrDemoMain.mOnDrawEndClick(Sender: TObject);
begin
 mOnDrawEnd.Checked:=Not mOnDrawEnd.Checked;
 XYPlot.Invalidate;
end;

//Zoom

procedure TFsgrDemoMain.mZNClick(Sender: TObject);
begin
 mZN.Checked :=True;
 if mZN.Checked then XYPlot.Zoom:=zpdNone;
end;

procedure TFsgrDemoMain.mZHClick(Sender: TObject);
begin
 mZH.Checked:=True;
 if mZH.Checked then XYPlot.Zoom:=zpdHorizontal;
end;

procedure TFsgrDemoMain.mZVClick(Sender: TObject);
begin
 mZV.Checked:=True;
 if mZV.Checked then XYPlot.Zoom:=zpdVertical
end;

procedure TFsgrDemoMain.mZBClick(Sender: TObject);
begin
 mZB.Checked:=True;
 if mZB.Checked then XYPlot.Zoom:=zpdBoth;
end;

//Record
procedure TFsgrDemoMain.mSRecordClick(Sender: TObject);
begin
 Scrolling:=True;
 NewRecord;
end;

procedure TFsgrDemoMain.mQARecordClick(Sender: TObject);
begin
 Scrolling:=False;
 NewRecord;
end;

procedure TFsgrDemoMain.mAbortScanClick(Sender: TObject);
begin
 StopRecord;
end;


//?
procedure TFsgrDemoMain.mAboutClick(Sender: TObject);
begin
 AboutBox.ShowModal;
end;




END.
