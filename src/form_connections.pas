unit form_connections;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, Types, prg_config;

type

  { TfrmConnections }

  TfrmConnections = class(TForm)
    pnlBottom : TPanel;
    grid : TDrawGrid;
    btnConnect : TBitBtn;
    btnNew : TBitBtn;
    btnCopy : TBitBtn;
    btnEdit : TBitBtn;
    btnDelete : TBitBtn;
    btnCancel : TBitBtn;
    procedure gridDrawCell(Sender : TObject; aCol, aRow : Integer;
      aRect : TRect; aState : TGridDrawState);
    procedure btnNewClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure btnCopyClick(Sender : TObject);
    procedure btnEditClick(Sender : TObject);
    procedure btnDeleteClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure gridDblClick(Sender : TObject);
    procedure btnConnectClick(Sender : TObject);
  private

  public

    sqlfrmlist : TList;

    connlist : TConnList;

    procedure EditItem(aitem : TDbConnCfg; acopy : TDbConnCfg = nil);

    function SelectedItem : TDbConnCfg;
    procedure UpdateGrid;

    procedure SelectItem(aitem : TDbConnCfg);

    procedure AddConnWindow(afrm : TForm);
    procedure DeleteConnWindow(afrm : TForm);

  end;

var
  frmConnections : TfrmConnections;

implementation

uses
  form_conn_edit, form_sql;

{$R *.lfm}

{ TfrmConnections }

procedure TfrmConnections.gridDrawCell(Sender : TObject; aCol, aRow : Integer;
  aRect : TRect; aState : TGridDrawState);
var
  s : string;
  item : TDbConnCfg;
  c : TCanvas;
  ts : TTextStyle;
begin
  if arow = 0 then Exit;  // keep the header as it is

  item := connlist[aRow - 1];
  if item = nil then Exit;

  // give some margins:
  Inc(arect.Left, 2);
  Dec(arect.Right, 2);

  c := grid.Canvas;
  ts := c.TextStyle;

  if      0 = acol then s := item.id
  else if 1 = acol then s := GetDbTypeName(item.dbtype)
  else if 2 = acol then s := item.GetInfoStr()
  else s := '?';

  c.TextStyle := ts;
  c.TextRect(aRect, arect.Left, arect.top, s);
end;

procedure TfrmConnections.btnNewClick(Sender : TObject);
begin
  EditItem(nil, nil);
end;

procedure TfrmConnections.FormCreate(Sender : TObject);
begin
  connlist := prgconfig.connlist;
  sqlfrmlist := TList.Create;
  UpdateGrid;
end;

procedure TfrmConnections.btnCopyClick(Sender : TObject);
begin
  EditItem(nil, SelectedItem);
end;

procedure TfrmConnections.btnEditClick(Sender : TObject);
begin
  EditItem(SelectedItem, nil);
end;

procedure TfrmConnections.btnDeleteClick(Sender : TObject);
var
  i : integer;
begin
  if MessageDlg('Are you sure to delete this item?', mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    i := connlist.IndexOf(SelectedItem);
    connlist.Delete(i);
    UpdateGrid;
  end;
end;

procedure TfrmConnections.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  prgconfig.Save;
end;

procedure TfrmConnections.gridDblClick(Sender : TObject);
begin
  btnConnect.Click;
end;

procedure TfrmConnections.btnConnectClick(Sender : TObject);
var
  frm : TfrmSQL;
  ccfg : TDbConnCfg;
begin
  if (grid.Row < 1) or (grid.Row > connlist.count) then
  begin
    ModalResult := 0;
    EXIT;
  end;

  ccfg := connlist[grid.Row - 1];

  frm := NewSqlForm(ccfg);
  if frm <> nil then
  begin
    frm.msql.SetFocus;
    Hide;
  end;
end;

procedure TfrmConnections.EditItem(aitem : TDbConnCfg; acopy : TDbConnCfg);
var
  frm : TfrmConnEdit;
begin
  Application.CreateForm(TfrmConnEdit, frm);
  if acopy <> nil then
  begin
    frm.Load(acopy);
    frm.item := nil;
    frm.Caption := 'Copy Connection';
  end
  else
  begin
    frm.Load(aitem);
  end;
  if frm.ShowModal = mrOk then
  begin
    // jump to the row
    UpdateGrid;
    SelectItem(frm.item);
  end;
  frm.Free;
end;

function TfrmConnections.SelectedItem : TDbConnCfg;
begin
  if (grid.Row > 0) and (grid.Row <= connlist.count)
  then
    result := connlist[grid.Row - 1]
  else
    result := nil;
end;

procedure TfrmConnections.UpdateGrid;
begin
  grid.RowCount := 1 + connlist.count;
end;

procedure TfrmConnections.SelectItem(aitem : TDbConnCfg);
var
  i : integer;
begin
  for i := 1 to connlist.Count do
  begin
    if connlist[i-1] = aitem then
    begin
      grid.Row := i;
      exit;
    end;
  end;
end;

procedure TfrmConnections.AddConnWindow(afrm : TForm);
begin
  sqlfrmlist.Add(afrm);
end;

procedure TfrmConnections.DeleteConnWindow(afrm : TForm);
var
  i : integer;
begin
  i := sqlfrmlist.IndexOf(afrm);
  if i >= 0 then
  begin
    sqlfrmlist.Delete(i);
    if sqlfrmlist.Count <= 0 then
    begin
      Application.Terminate;
    end;
  end;
end;

end.

