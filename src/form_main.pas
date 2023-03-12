unit form_main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, prg_config;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    mainmenu : TMainMenu;
    menuConnection : TMenuItem;
    miConnections : TMenuItem;
    procedure miConnectionsClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
  private

  public

  end;

var
  frmMain : TfrmMain;

implementation

uses
  form_connections;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.miConnectionsClick(Sender : TObject);
begin
  Application.CreateForm(TfrmConnections, frmConnections);
  frmConnections.ShowModal;
end;

procedure TfrmMain.FormCreate(Sender : TObject);
begin
  prgconfig.Load('lazasql.json');
end;

end.

