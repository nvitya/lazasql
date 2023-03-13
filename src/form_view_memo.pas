unit form_view_memo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TfrmViewMemo }

  TfrmViewMemo = class(TForm)
    memo : TMemo;
    procedure memoKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
  private

  public

  end;

var
  frmViewMemo : TfrmViewMemo;

procedure NewMemoForm(atitle, atext : string);

implementation

uses
  LCLType, form_connections;

procedure NewMemoForm(atitle, atext : string);
var
  frm : TfrmViewMemo;
begin
  Application.CreateForm(TfrmViewMemo, frm);
  frm.memo.Lines.Text := atext;
  frm.Caption := atitle;
  frm.Show;
  frmConnections.AddConnWindow(frm);
end;

{$R *.lfm}

{ TfrmViewMemo }

procedure TfrmViewMemo.memoKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
begin
  if (Key = ord('A')) and (ssCtrl in Shift) then
  begin
    memo.SelectAll;
  end
  else if (key = VK_ESCAPE) then
  begin
    Close;
  end;
end;

procedure TfrmViewMemo.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  CloseAction := caFree;
  frmConnections.DeleteConnWindow(self);
end;

end.

