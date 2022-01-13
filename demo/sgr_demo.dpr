program sgr_demo;

uses
  Forms,
  SysUtils,
  About in 'About.pas' {AboutBox},
  DemoMain in 'DemoMain.pas' {FsgrDemoMain},
  AxisLmtsDlg in 'AxisLmtsDlg.pas' {FAxisLmtsDlg},
  sgr_sprint in 'sgr_sprint.pas' {MFPrintDlg},
  AxisPrptsDlg in 'AxisPrptsDlg.pas' {FAxisPrptsDlg};

{$R *.RES}


begin
  Application.Initialize;
  Application.CreateForm(TFsgrDemoMain, FsgrDemoMain);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TFAxisLmtsDlg, FAxisLmtsDlg);
  Application.CreateForm(TMFPrintDlg, MFPrintDlg);
  Application.CreateForm(TFAxisPrptsDlg, FAxisPrptsDlg);
  Application.Run;
end.


