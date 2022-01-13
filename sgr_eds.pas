unit sgr_eds;
{(c) S.P.Pod'yachev 1998-1999}
{ver. 2.3 23.10.1999}
{***************************************************}
{ Experimental line of series for Tsp_xyPlot        }
{                                                   }
{***************************************************}
interface
uses
  Windows, SysUtils,  Classes,  Graphics,
  sgr_scale,  sgr_def,  sgr_data;

Type

Tsp_DrawPoints=class;
//event to draw custom points
TDrawCustomPointEvent=procedure
(const DS:Tsp_DrawPoints; const xv,yv :double; x, y: Integer) of object;

{*** Tsp_LP ***}

//draw data as points and/or chain of line segments
Tsp_DrawPoints=class(Tsp_DataSeries)
protected
  fCanvas:TCanvas;
  fPA:Tsp_PointAttr;      //point attribute
  fLineAttr:Tsp_LineAttr; //line attribute
  fDLM:boolean;           //DrawingLegendMarker
  DrawPointProc:TDrawPointProc;
  fOnDrawCustomPoint:TDrawCustomPointEvent;
  dsnx,dsny:double;
  procedure DrawRect(const x, y: Integer);
  procedure DrawEllipse(const x, y: Integer);
  procedure DrawDiamond(const x, y: Integer);
  procedure DrawCross(const x, y: Integer);
  procedure DrawTriangle(const x, y: Integer);
  procedure DrawDownTriangle(const x, y: Integer);

  procedure AtrributeChanged(V:TObject); virtual;
  procedure SetPointAttr(const V:Tsp_PointAttr);
  procedure SetLineAttr(const V:Tsp_LineAttr);

public
  constructor Create(AOwner:TComponent); override;
  destructor Destroy; override;
  //Draw if csDesigning in ComponentState
  procedure Draw; override;
  //implements series draw marker procedure
  procedure DrawLegendMarker(const LCanvas:TCanvas; MR:TRect); override;
  //for custom draw procedures
  property Canvas:TCanvas read fCanvas;
  //true when DrawLegendMarker
  property DrawingLegendMarker:boolean read fDLM;

published
  //defines is draw & how lines points marker
  property PointAttr:Tsp_PointAttr read fPA write SetPointAttr;
  //defines is draw & how lines segments between points
  property LineAttr:Tsp_LineAttr read fLineAttr write SetLineAttr;
  //if assigned caled to draw point with Kind=ptCustom
  property OnDrawCustomPoint:TDrawCustomPointEvent read fOnDrawCustomPoint
                                                   write fOnDrawCustomPoint;
  //if True then series is visible and taken into account in AutoMin & AutoMax
  property Active default True;
end;

{*** Tsp_ndsXYLine ***}
{this data series has not data storage and get it from external storage
 by using callback procedures (events)
}
Tsp_ndsXYLine=class;

TspGetXYCountEvent=procedure(DS:Tsp_ndsXYLine) of object;
TspGetXYEvent=procedure(DS:Tsp_ndsXYLine; idx:integer) of object;
TspGetMinMaxEvent=function(DS:Tsp_ndsXYLine; var V:double):boolean of object;


Tsp_ndsXYLine=class(Tsp_DrawPoints)
protected
  fOnGetXYCount:TspGetXYCountEvent; //before draw call to find number of points
  fOnGetXY:TspGetXYEvent; //before draw next point
  fOnGetXMin, fOnGetXMax,
  fOnGetYMin, fOnGetYMax:TspGetMinMaxEvent;
  PX,PY:double;
public
  Count:integer; //set it when OnGetXYCount
  XV, YV :double;  //set it when OnGetXY
  //next 4 functions must be implemented for any series
  function GetXMin(var V:double):boolean; override;
  function GetXMax(var V:double):boolean; override;
  function GetYMin(var V:double):boolean; override;
  function GetYMax(var V:double):boolean; override;

  procedure DrawPoint(const XV, YV : double); //draw poin don't check Visible
  procedure Draw; override;
published
  property OnGetXYCount:TspGetXYCountEvent read FOnGetXYCount write FOnGetXYCount;
  property OnGetXY:TspGetXYEvent read fOnGetXY write fOnGetXY;
  property OnGetXMin: TspGetMinMaxEvent read fOnGetXMin write fOnGetXMin;
  property OnGetXMax: TspGetMinMaxEvent read fOnGetXMax write fOnGetXMax;
  property OnGetYMin: TspGetMinMaxEvent read fOnGetYMin write fOnGetYMin;
  property OnGetYMax: TspGetMinMaxEvent read fOnGetYMax write fOnGetYMax;
end;

procedure Register;

IMPLEMENTATION

procedure Register;
begin
 RegisterComponents('Samples', [Tsp_ndsXYLine]);
end;


constructor Tsp_DrawPoints.Create(AOwner:TComponent);
begin
 inherited Create(AOwner);
 DrawPointProc:=DrawRect;
 fPA:=Tsp_PointAttr.Create;
 fLineAttr:=Tsp_LineAttr.Create;
 fLineAttr.OnChange:=AtrributeChanged;
 fPA.OnChange:=AtrributeChanged;
 dsnx:=Random;
 dsny:=Random;
 fActive:=True;
end;

destructor Tsp_DrawPoints.Destroy;
begin
 if Assigned(FPA) then begin
   FPA.OnChange:=nil;
   FPA.Free;
 end;
 if Assigned(fLineAttr) then begin
   fLineAttr.OnChange:=nil;
   fLineAttr.Free
 end;
 inherited;
end;

procedure Tsp_DrawPoints.AtrributeChanged(V:TObject);
begin
 if V=fPA then
 case fPA.Kind of
   ptRectangle: DrawPointProc:=DrawRect;
   ptEllipse:   DrawPointProc:=DrawEllipse;
   ptDiamond:   DrawPointProc:=DrawDiamond;
   ptCross:     DrawPointProc:=DrawCross;
   ptCustom:    DrawPointProc:=DrawRect; //DrawCustom;
   ptTriangle:  DrawPointProc:=DrawTriangle;
   ptDownTriangle: DrawPointProc:=DrawDownTriangle;
   else         DrawPointProc:=DrawRect;
 end;
 InvalidatePlot(rsAttrChanged);
end;

procedure Tsp_DrawPoints.SetPointAttr(const V:Tsp_PointAttr);
begin
 fPA.Assign(V);
end;

procedure Tsp_DrawPoints.SetLineAttr(const V:Tsp_LineAttr);
begin
 if Not fLineAttr.IsSame(V) then
   fLineAttr.Assign(V);
end;

procedure Tsp_DrawPoints.DrawRect(const x, y: Integer);
begin
 with fPA do
  fCanvas.Rectangle(x-eHSize, y-eVSize, x+oHSize, y+eVSize+1);
end;

procedure Tsp_DrawPoints.DrawEllipse(const x, y: Integer);
begin
 with fPA do
  fCanvas.Ellipse(x-eHSize, y-eVSize, x+oHSize, y+oVSize);
end;

procedure Tsp_DrawPoints.DrawDiamond(const x, y: Integer);
begin
 with fPA do
  fCanvas.Polygon([Point(x, y - eVSize), Point(x + eHSize, y),
                         Point(x, y + eVSize), Point(x - eHSize, y)]);
end;

procedure Tsp_DrawPoints.DrawCross(const x, y: Integer);
begin
 with fCanvas, fPA do
 begin
   MoveTo(x - eHSize, y);
   LineTo(x + oHSize, y);
   MoveTo(x, y - eVSize);
   LineTo(x, y + oVSize);
 end;
end;

procedure Tsp_DrawPoints.DrawTriangle(const x, y: Integer);
begin
 with fPA do
  fCanvas.Polygon([Point(x, y - eVSize), Point(x + eHSize, y + eVSize),
                   Point(x - eHSize, y + eVSize)]);
end;

procedure Tsp_DrawPoints.DrawDownTriangle(const x, y: Integer);
begin
 with fPA do
  fCanvas.Polygon([Point(x-eHSize, y-eVSize), Point(x+eHSize, y-eVSize),
                   Point(x, y + eVSize)]);
end;

procedure Tsp_DrawPoints.DrawLegendMarker(const LCanvas:TCanvas; MR:TRect);
var OP:TPen; OB:TBrush; x,y:integer;
begin
 if (fLineAttr.Visible or fPA.Visible) then
 begin
   fDLM:=True;          //note that drawing legend marker
   fCanvas:=LCanvas;
   OP:=TPen.Create;   OP.Assign(fCanvas.Pen); //save pen
   OB:=TBrush.Create; OB.Assign(fCanvas.Brush); //save brush
   with MR do y:=(Bottom+Top) div 2;
   if fLineAttr.Visible then with fCanvas do begin
     fLineAttr.SetPenAttr(fCanvas.Pen);
     Brush.Style:=bsClear;
     with MR do PolyLine([Point(Left+1, y), Point(Right, y)]);
   end;
   if fPA.Visible then with fCanvas do begin
     fPA.SetPenAttr(Pen);
     Brush.Assign(fPA);
     with MR do x:=(Left+Right) div 2;
     if (fPA.Kind=ptCustom) and Assigned(fOnDrawCustomPoint) then
        fOnDrawCustomPoint(Self, 0,0, x,y)
     else DrawPointProc(x,y);
   end;
   fCanvas.Brush.Assign(OB); OB.Free;  //restore brush
   fCanvas.Pen.Assign(OP); OP.Free; //restore pen
   fDLM:=False;
 end;
end;

procedure Tsp_DrawPoints.Draw;
var R:TRect;
begin
 if not((csDesigning in ComponentState) and Assigned(fPlot)) then Exit;
 if not((fLineAttr.Visible and (fLineAttr.Style<>psClear)) or fPA.Visible)
 then Exit;
 with Plot do begin
   fCanvas:=DCanvas;    //assign canvas to where draw
   R:=FieldRect;
   with FieldRect do
    InflateRect(R,-1-round(abs(Bottom-Top)*(dsnx*0.35)),
                  -1-round(abs(Right-Left)*(dsny*0.35)))
 end;
 with fCanvas do
 begin
   if fLineAttr.Visible and (fLineAttr.Style<>psClear) then
   begin
     fLineAttr.SetPenAttr(Pen);
     Brush.Style:=bsClear;
     with R do PolyLine([TopLeft, BottomRight]);
   end;
   if fPA.Visible then  begin
     fPA.SetPenAttr(Pen);
     Brush.Assign(fPA);
     with R do begin
      DrawPointProc(Left,Top); DrawPointProc(Right,Bottom);
     end;
   end;
 end;
end;

{*** Tsp_ndsXYLine ***}

function Tsp_ndsXYLine.GetXMin;
begin
 Result:=Assigned(fOnGetXMin);
 if Result then Result:=fOnGetXMin(Self, V);
end;

function Tsp_ndsXYLine.GetXMax;
begin
 Result:=Assigned(fOnGetXMax);
 if Result then Result:=fOnGetXMax(Self, V);
end;

function Tsp_ndsXYLine.GetYMin;
begin
 Result:=Assigned(fOnGetYMin);
 if Result then Result:=fOnGetYMin(Self, V);
end;

function Tsp_ndsXYLine.GetYMax;
begin
 Result:=Assigned(fOnGetYMax);
 if Result then Result:=fOnGetYMax(Self, V);
end;


procedure Tsp_ndsXYLine.DrawPoint(const XV, YV : double);
var
     i,a : double; p:Tpoint;
     XA, YA : Tsp_Axis;
begin
  with Plot do begin
    fCanvas:=DCanvas;    //assign canvas to where draw
    if XAxis=dsxBottom then XA:=BottomAxis else XA:=TopAxis;
    if GetXMin(i) and GetXMax(a) then
      if (i>XA.Max) or (a<XA.Min) then Exit;
    if YAxis=dsyLeft then YA:=LeftAxis else YA:=RightAxis;
    if GetYMin(i) and GetYMax(a) then
      if (i>YA.Max) or (a<YA.Min) then Exit;
  end;
  with fCanvas, YA, p  do
   begin
     fPA.SetPenAttr(Pen);
     Brush.Assign(fPA);
     x:=XA.V2P(XV); y:=V2P(YV);
//    if PtInRect(fPlot.FieldRect, p) then
     if (fPA.Kind=ptCustom) and Assigned(fOnDrawCustomPoint) then
           fOnDrawCustomPoint(Self,XV,YV,x,y)
      else
          DrawPointProc(x,y);
   end;
end; //DrawPoint



procedure Tsp_ndsXYLine.Draw;
const
     ep_Out=1; op_Out=2; Both_Out=op_Out or ep_Out;
var
     i,a : double;
     XA, YA : Tsp_Axis;

 procedure DrawLines(const XA, YA : Tsp_Axis);
 var
    j:integer;  pa:array [0..1] of TPoint;   is_out:word;
 begin
   with fCanvas, YA  do
   begin
     fLineAttr.SetPenAttr(Pen);
     Brush.Style:=bsClear;
     with pa[0] do
     begin
       OnGetXY(Self, 0);
       x:=XA.V2P(XV); y:=V2P(YV);
       if (x<-16000) or (y<-16000) or (x>16000) or (y>16000) then is_out:=op_out
       else is_out:=0;
     end;
     for j:=1 to Count-1 do
     begin
       with pa[1] do
       begin
         OnGetXY(Self, j);
         x:=XA.V2P(XV); y:=V2P(YV);
         if (x<-16000) or (y<-16000) or (x>16000) or (y>16000) then
         is_out:=is_out or ep_out;
       end;
       //draw line if at least one point inside
       if (is_out and both_out)<>both_out then PolyLine(pa);
       is_out:=is_out shl 1;
       pa[0]:=pa[1];
     end;
   end;
 end; //DrawLines

 procedure DrawPoints(const XA, YA : Tsp_Axis);
 var
    j:integer; p:TPoint;
 begin
    with fCanvas, YA  do
    begin
     fPA.SetPenAttr(Pen);
     Brush.Assign(fPA);
     if (fPA.Kind=ptCustom) then begin
       if Assigned(fOnDrawCustomPoint) then
       for j:=0 to Count-1 do with p do
       begin
         OnGetXY(Self, j);
         x:=XA.V2P(XV); y:=V2P(YV);
         if PtInRect(fPlot.FieldRect, p) then
            fOnDrawCustomPoint(Self,XV,YV,x,y);
       end;
     end else
       for j:=0 to Count-1 do with p do
       begin
         OnGetXY(Self, j);
         x:=XA.V2P(XV); y:=V2P(YV);
         if PtInRect(fPlot.FieldRect, p) then DrawPointProc(x,y);
       end;
    end;
 end; //DrawPoints

begin  //Draw
 if csDesigning in ComponentState then inherited;
 if not(Assigned(fOnGetXYCount) and Assigned(fOnGetXY) and Assigned(fPlot))
   then Exit;
 fOnGetXYCount(Self);
 if (Count<1) or Not(fPA.Visible or ((fLineAttr.Visible) and (Count>1)))
   then Exit;
 with Plot do begin
   fCanvas:=DCanvas;    //assign canvas to where draw
   if XAxis=dsxBottom then XA:=BottomAxis else XA:=TopAxis;
   if GetXMin(i) and GetXMax(a) then
      if (i>XA.Max) or (a<XA.Min) then Exit;
   if YAxis=dsyLeft then YA:=LeftAxis else YA:=RightAxis;
   if GetYMin(i) and GetYMax(a) then
      if (i>YA.Max) or (a<YA.Min) then Exit;
 end;
 if (Count>1) and fLineAttr.Visible and (fLineAttr.Style<>psClear)
  then DrawLines(XA,YA);
 if fPA.Visible then DrawPoints(XA,YA);
end;  //Tsp_ndsXYLine.Draw;


END.

