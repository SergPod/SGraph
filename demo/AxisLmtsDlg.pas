unit AxisLmtsDlg;
{(c) S.P.Pod'yachev 1998-1999}
{***************************************************}
{   Set axis limits dialog with autocalc            }
{***************************************************}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, sgr_def, Spin;

type
  TFAxisLmtsDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    GroupBox1: TGroupBox;
    cbAutoY: TCheckBox;
    GroupBox2: TGroupBox;
    cbAutoX: TCheckBox;
    rseMaxY: TSpinEdit;
    rseMinY: TSpinEdit;
    rseMaxX: TSpinEdit;
    rseMinX: TSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure cbAutoYClick(Sender: TObject);
    procedure cbAutoXClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAxisLmtsDlg: TFAxisLmtsDlg;

procedure SetPlotLimits(G:Tsp_XYPlot);

implementation

{$R *.DFM}

procedure SetPlotLimits(G:Tsp_XYPlot);
begin
// if (G=nil) or Not(G is Tsp_XYPlot) then Exit;
 with FAxisLmtsDlg do
 begin
   with G.LeftAxis do begin
     cbAutoYClick(nil);
     rseMinY.Value:=Round(Min); rseMaxY.Value:=Round(Max);
   end;
   with G.BottomAxis do begin
     cbAutoXClick(nil);
     rseMinX.Value:=Round(Min); rseMaxX.Value:=Round(Max);
   end;
   if ShowModal<>mrOk then Exit;
   with G.LeftAxis  do begin
     if cbAutoY.Checked then begin
       AutoMin:=True; AutoMax:=True;
     end else begin
       Min:=rseMinY.Value; Max:=rseMaxY.Value;
     end;
   end;
   with G.BottomAxis do begin
     if cbAutoX.Checked then begin
      AutoMin:=True; AutoMax:=True;
     end else begin
      Min:=rseMinX.Value; Max:=rseMaxX.Value;
     end;
   end;
   with G.LeftAxis do  begin
     AutoMin:=False; AutoMax:=False;
   end;
   with G.BottomAxis do  begin
     AutoMin:=False; AutoMax:=False;
   end;
 end;
end;

procedure TFAxisLmtsDlg.cbAutoYClick(Sender: TObject);
begin
 rseMinY.Enabled:=not cbAutoY.Checked;
 rseMaxY.Enabled:=rseMinY.Enabled;
end;

procedure TFAxisLmtsDlg.cbAutoXClick(Sender: TObject);
begin
 rseMinX.Enabled:=not cbAutoX.Checked;
 rseMaxX.Enabled:=rseMinX.Enabled;
end;

end.
