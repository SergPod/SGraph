unit About;
{ About dialog }

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    OKButton: TButton;
    ProductName: TLabel;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    URL: TLabel;
    procedure URLClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
uses ShellAPI;
{$R *.DFM}

procedure TAboutBox.URLClick(Sender: TObject);
begin
 ShellExecute(0, nil, PChar(URL.Caption), nil, nil, SW_NORMAL);
end;

end.

