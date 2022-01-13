unit sgr_sprint;
{(c) S.P.Pod'yachev 1998-1999}
{ver. 2.11}
{***************************************************}
{        Simple dialog to print Tsp_XYplot          }
{***************************************************}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Spin, Printers, Dialogs, sgr_def;

type
  TMFPrintDlg = class(TForm)
    btPrint: TButton;
    btClose: TButton;
    PageOuter: TBevel;
    PlotImage: TImage;
    PageShape: TShape;
    btSetPrinter: TButton;
    PrinterSetupDialog: TPrinterSetupDialog;
    cbAspectSize: TComboBox;
    Label1: TLabel;
    procedure btSetPrinterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbAspectSizeChange(Sender: TObject);
  private
    pltw, plth :integer;
    DAR:TRect;
    Plot:Tsp_XYPlot;
    FitToPage:boolean;
    JustCreated:boolean;
    MM:TObject;
  protected
    procedure CalcPageRect;
    procedure CalcImageRect;
    procedure SetMetafile;
  end;

var
  MFPrintDlg: TMFPrintDlg;

procedure PrintPlot(XYplot:Tsp_XYPlot);

implementation

{$R *.DFM}

//--------move and resize image on the page--------

Const
 None=0; Moved=1; WESized=2; NSSized=3; //operation
 HotWidth=8; HotHeight=6;
 MinWidth=HotWidth*2+2; MinHeight=HotHeight*2+2;

Type

TMover=class
 private
  sx, sy:integer;
  fBRect:TRect;   //Control Bounds
  fFRect:TRect;   //focus rectangle
  fMaxRect:TRect; //constrain area
  ar:double;
  Handle:HDC;
  Cntrl:TImage;
  OldCursor:TCursor;
  NeedRestore:boolean;
  State:byte;
  function  ClntToScrnRect(CR:TRect):TRect;
  procedure DrawRect;
  procedure ChangeCursor(C:TCursor);
  procedure RestoreCursor;
  function  MoveBRect(dw,dh:integer):boolean;
  function  SizeBRect(d:integer;isw:boolean):boolean;
 protected
  procedure SetControl(C:TImage);
  procedure SetMaxRect(V:TRect);
 public
  constructor Create(aC:TImage);
  destructor Destroy; override;
  procedure MStart(Sender: TObject; Button: TMouseButton;
                   Shift: TShiftState; X, Y: Integer);
  procedure MMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  procedure MStop(Sender: TObject; Button: TMouseButton;
                   Shift: TShiftState; X, Y: Integer);
  property MaxRect:TRect read fMaxRect write SetMaxRect; //Constrain Rect
end;


function TMover.ClntToScrnRect(CR:TRect):TRect;
begin
 with Cntrl, Result do
 begin
   OffsetRect(CR, -Cntrl.Left, -Cntrl.Top);
   TopLeft:=ClientToScreen(CR.TopLeft);
   BottomRight:=ClientToScreen(CR.BottomRight);
 end;
end;

procedure TMover.DrawRect;
begin
 Windows.DrawFocusRect(Handle, fFRect);
end;

procedure TMover.ChangeCursor(C:TCursor);
begin
 with Cntrl do if Cursor<>C then begin
  if Not NeedRestore then OldCursor:=Cursor;
  NeedRestore:=True;
  Cursor:=C;
 end;
end;

procedure TMover.RestoreCursor;
begin
 if NeedRestore then with Cntrl do begin
  Cursor:=OldCursor;
  NeedRestore:=False;
 end;
end;

function TMover.MoveBRect(dw,dh:integer):boolean;
var R:TRect;
begin
 R:=fBRect;
 OffsetRect(R, dw, dh);
 with fMaxRect do begin
  if Top>R.Top then OffsetRect(R, 0, Top-R.Top);
  if Left>R.Left then OffsetRect(R, Left-R.Left, 0);
  if Bottom<R.Bottom then OffsetRect(R, 0, Bottom-R.Bottom);
  if Right<R.Right then OffsetRect(R, Right-R.Right, 0);
 end;
 Result:=Not(EqualRect(fBRect,R));
 fBRect:=R;
end;

function TMover.SizeBRect(d:integer;isw:boolean):boolean;
var R:TRect;
begin
 R:=fBRect;
 with R do
 if isw then begin
    Right:=Right+d;
    if Right>fMaxRect.Right then Right:=fMaxRect.Right;
    if (Right-Left)<MinWidth then Right:=Left+MinWidth;
    Bottom:=Top+round((Right-Left)/ar);
    if Bottom>fMaxRect.Bottom then begin
      Bottom:=fMaxRect.Bottom;
      Right:=Left+round((Bottom-Top)*ar);
    end;
 end else begin
    Bottom:=Bottom+d;
    if Bottom>fMaxRect.Bottom then Bottom:=fMaxRect.Bottom;
    if (Bottom-Top)<MinHeight then Bottom:=Top+MinHeight;
    Right:=Left+round((Bottom-Top)*ar);
    if Right>fMaxRect.Right then begin
       Right:=fMaxRect.Right;
       Bottom:=Top+round((Right-Left)/ar);
    end;
 end;
 with R do
 if (Right<=fMaxRect.Right) and (Bottom<=fMaxRect.Bottom) and
    ((Bottom-Top)>MinHeight) and ((Right-Left)>MinWidth) then
 begin
   fBRect:=R;
   Result:=True;
 end else Result:=False;
end;

constructor TMover.Create(aC:TImage);
begin
 Handle:=0;
 if aC<>nil then SetControl(aC);
 State:=None;
end;

destructor TMover.Destroy;
begin
 if Cntrl<>nil then
 with Cntrl do
 begin
  OnMouseDown:=nil;
  OnMouseMove:=nil;
  OnMouseUp:=nil;
 end;
end;

procedure TMover.MStart;
begin
 if (Shift=[ssLeft]) and (Button=mbLeft) then
 begin
  sx:=X; sy:=Y;
  with Cntrl do begin
   fBRect:=BoundsRect;
   ar:=Width/Height;
  end;
  fFRect:=ClntToScrnRect(fBRect);
  if  NeedRestore then with Cntrl do begin
     if Cursor=crSizeWE then State:=WESized else State:=NSSized
  end else State:=Moved;
  Handle := GetDC(0);
  DrawRect;
 end;
end;

procedure TMover.MMove;
 procedure DrawNewRect;
 begin
   DrawRect;
   fFRect:=ClntToScrnRect(fBRect);
   DrawRect;
   sx:=X; sy:=Y;
 end;
 procedure TreatCursor;
 begin
  with Cntrl do
  begin
   if (abs(Width-X)<HotWidth) then ChangeCursor(crSizeWE)
   else if (abs(Height-Y)<HotHeight) then ChangeCursor(crSizeNS)
   else RestoreCursor;
  end;
 end;
begin
 case State of
  None:    TreatCursor;
  Moved:   if MoveBRect(X-sx, Y-sy) then DrawNewRect;
  WESized: if SizeBRect(X-sx,True) then DrawNewRect;
  NSSized: if SizeBRect(Y-sy,False) then DrawNewRect;
 end;
end;

procedure TMover.MStop;
begin
 State:=0;
 DrawRect;
 ReleaseDC(0, Handle);
 Cntrl.BoundsRect:=fBRect;
end;

procedure TMover.SetControl(C:TImage);
begin
 Cntrl:=C;
 with Cntrl do
 begin
  OnMouseDown:=MStart;
  OnMouseMove:=MMove;
  OnMouseUp:=MStop;
 end;
end;

procedure TMover.SetMaxRect(V:TRect);
begin
// inc(V.Left); inc(V.Top);
 fMaxRect:=V;
end;



//--------size procedures---------------

const
 MinMFWidth=100;   //minimal plot image on screen
 MinMFHeight=75;   //if less then we will increase it
 //we define aspect ratio as width/height

procedure FixSmallSize(var Width, Height:integer);
//if width or height too small increase it keeping aspect ratio
var hf,f:double;
begin
 if (Width<MinMFWidth) or (Height<MinMFHeight) then
 begin
  hf:=MinMFHeight/Height;
  f:=MinMFWidth/Width;
  if hf>f then f:=hf;
  Width:=Trunc(Width*f)+1;
  Height:=Trunc(Height*f)+1;
 end
end;

procedure ChangeAspect(var Width, Height:integer; nar:double);
//change aspect ratio without loosing of resolution
begin
 if Width>Height then Height:=round(Width/nar)
 else Width:=round(Height*nar);
end;

function InsRect(tW, tH:integer; ar:double):TRect;
// return Rect with aspect ratio ar and centered
// in area with width and height
begin
 with Result do
 if round(tW/ar)>tH then //height should be base
 begin
  Top:=0;  Bottom:=tH;
  Right:=round(tH*ar);
  Left:=(tW-Right) div 2; inc(Right, Left)
 end else               //width should be base
 begin
  Left:=0; Right:=tW;
  Bottom:=round(tW/ar);
  Top:=(tH-Bottom) div 2; inc(Bottom,Top);
 end;
end;

//-----aux procedures ---------------------

procedure TMFPrintDlg.CalcPageRect;
//calculate and set page view rectangle
const
 m=4; wm=0.1; hm=0.1;    //margins

 function rmul(r:double; i:integer):integer;
 begin
  Result:=round(r*i);  if Result<1 then Result:=1;
 end;

begin
  with PageOuter, Printer  do
  begin
    DAR:=InsRect(Width-2*m, Height-2*m, PageWidth/PageHeight);
    OffsetRect(DAR, Left+m, Top+m);
  end;
  TMover(MM).MaxRect:=DAR;
  with PageShape do
  begin
    BoundsRect:=DAR;
    InflateRect(DAR, -rmul(wm,Width), -rmul(hm,Height));
  end;
end;

procedure TMFPrintDlg.CalcImageRect;
//calculate image view rectangle
var R:TRect;
begin
  if FitToPage then R:=DAR
  else with DAR do begin
    R:=InsRect(Right-Left, Bottom-Top, pltw/plth);
    OffsetRect(R, Left, Top);
  end;
  PlotImage.BoundsRect:=R;
end;

procedure TMFPrintDlg.SetMetafile;
//create & set plot metafile to  Iamge component
var w, h :integer;
    emf:TMetafile;

 procedure CreateMetafile;
 var MC:TMetafileCanvas; OBS:Tsp_BorderStyle;
 begin
   emf := TMetafile.Create;
   with Plot do begin
     emf.Width:=w;    emf.Height:=h;
     OBS:=BorderStyle;
     MC:=TMetafileCanvas.Create(emf, Canvas.Handle);
     try
       BorderStyle:=bs_None; // !!! get out border
       DrawPlot(MC, w, h);
     finally
       MC.Free;
       BorderStyle:=OBS;
     end;
   end;
 end;

begin
 w:=pltw; h:=plth;
 if FitToPage then
 begin
  with DAR do ChangeAspect(w, h, (Right-Left)/(Bottom-Top));
 end;
 CreateMetafile;
 try
   PlotImage.Picture.Metafile:=emf;
 finally
   emf.free;
 end;
end;

//---events------

procedure TMFPrintDlg.FormCreate(Sender: TObject);
begin
 MM:=TMover.Create(PlotImage);
 JustCreated:=True;
 FitToPage:=False;
 cbAspectSize.ItemIndex:=0;
end;

procedure TMFPrintDlg.FormDestroy(Sender: TObject);
begin
 MM.Free;
end;


procedure TMFPrintDlg.cbAspectSizeChange(Sender: TObject);
//var FTP:boolean;
begin
 with cbAspectSize do FitToPage:=(ItemIndex=1);
 CalcImageRect;
 SetMetafile;
end;


procedure TMFPrintDlg.btSetPrinterClick(Sender: TObject);
var OPW,OPH:integer;
begin
 with Printer do
 begin
  OPW:=PageWidth;
  OPH:=PageHeight;
  if PrinterSetupDialog.Execute then
  begin
    Caption:=Printers[PrinterIndex];
    CalcPageRect;
    if (OPW<>PageWidth) and (OPH<>PageHeight) then
    begin
      CalcImageRect;
      if FitToPage then SetMetafile;
    end;
  end;
 end;
end;

//******** at last print procedures **********

procedure PrintPlot(XYplot:Tsp_XYPlot);
var R:TRect;  L,T,W,H:integer;
begin
    if Printer.Printers.Count < 1 then begin
       raise Exception.Create('There is no any printer');// ???
    end;
  with MFPrintDlg, Printer do begin
    Caption:=Printers[PrinterIndex];   //dialog caption
    Plot:=XYPlot;                      //link to plot
    W:=pltw;  H:=plth;
    pltw:=Plot.Width;                  //store iriginal size
    plth:=Plot.Height;
    FixSmallSize(pltw, plth);
    if JustCreated then
    begin
      if pltw>plth then Printer.Orientation:=poLandscape
      else Printer.Orientation:=poPortrait;
    end;
    if JustCreated or
       (Not(FitTopage) and (abs(pltw*H/plth/W-1)>0.02)) then
    begin
     CalcPageRect;
     CalcImageRect;
     JustCreated:=False;
    end;
    SetMetafile;
  end;
  if MFPrintDlg.ShowModal=mrOk then
  begin
    with MFPrintDlg.PageShape do
    begin
      L:=Left;  T:=Top;
      W:=Width; H:=Height;
    end;
    with MFPrintDlg.PlotImage, Printer do
    begin
      R.Left:=0;     R.Top:=0;
      R.Right :=round((Width/W)*PageWidth);
      R.Bottom:=round((Height/H)*PageHeight);
      OffsetRect(R, round( ((Left-L)/W)*PageWidth ),
                    round( ((Top -T)/H)*PageHeight) );
      BeginDoc;
      Canvas.StretchDraw(R, Picture.Metafile);
      EndDoc;
    end;
  end;
end;



end.


