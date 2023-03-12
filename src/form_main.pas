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
    procedure FormShow(Sender : TObject);
  private

  public
    firstshow : boolean;
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
  //Application.CreateForm(TfrmConnections, frmConnections);
  frmConnections.ShowModal;
end;

procedure TfrmMain.FormCreate(Sender : TObject);
begin
  firstshow := true;
end;

procedure TfrmMain.FormShow(Sender : TObject);
begin
  if firstshow then
  begin
    //miConnectionsClick(nil);
    firstshow := false;
  end;
end;

end.

