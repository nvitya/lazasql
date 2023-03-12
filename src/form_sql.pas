unit form_sql;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  StdCtrls, Menus, prg_config, mysql50conn, mysql80conn, DB, SQLDB;

type

  { TfrmSQL }

  TfrmSQL = class(TForm)
    nbBottom : TNotebook;
    pageGrid : TPage;
    grid : TStringGrid;
    pnlSQL : TPanel;
    memoSQL : TMemo;
    Splitter1 : TSplitter;
    sqlMenu : TPopupMenu;
    miRun : TMenuItem;
    query : TSQLQuery;
    sqltra : TSQLTransaction;
    dbconn : TMySQL80Connection;
    miCloneWindow : TMenuItem;
    Separator1 : TMenuItem;
    procedure miRunClick(Sender : TObject);
    procedure miCloneWindowClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
  private

  public
    conncfg : TDbConnCfg;

    colcount    : integer;
    maxcolchars : array of integer;

    procedure SetGridColumns;
    procedure FillGridData;

    procedure ConnectTo(acfg : TDbConnCfg);

  end;

var
  frmSQL : TfrmSQL;

function NewSqlForm(aconncfg : TDbConnCfg) : TfrmSQL;

implementation

uses
  form_connections;

function NewSqlForm(aconncfg : TDbConnCfg) : TfrmSQL;
var
  frm : TfrmSQL;
begin
  Application.CreateForm(TfrmSQL, frm);
  try
    frm.ConnectTo(aconncfg);
  except
    on e : Exception do
    begin
      MessageDlg('Connect Error', 'Error Connecting to database "'+aconncfg.GetInfoStr+'"', mtError, [mbAbort], 0);
      frm.Free;
      result := nil;
      EXIT;
    end;
  end;
  frm.Show;
  frmConnections.sqlfrmlist.Add(frm);
  result := frm;
end;

{$R *.lfm}

{ TfrmSQL }

procedure TfrmSQL.SetGridColumns;
var
  i : integer;
  fd : TFieldDef;
  gc : TGridColumn;
begin
  //grid.ColCount := query.FieldDefs.Count;

  colcount := query.FieldDefs.Count;
  grid.Columns.Clear;
  for i := 0 to query.FieldDefs.Count - 1 do
  begin
    fd := query.FieldDefs[i];
    gc := grid.Columns.Add;

    gc.Width := 80;
    gc.Title.Caption := fd.name;
    if fd.DataType in [ftSmallint, ftAutoinc, ftInteger, ftWord, ftFloat, ftCurrency, ftLargeInt] then
    begin
      gc.Alignment := taRightJustify;
    end;
  end;
end;

procedure TfrmSQL.FillGridData;
var
  drow, dcol : integer;
  s : string;
  cw : integer;
  gc : TGridColumn;
  //fd : TFieldDef;
begin

  SetLength(maxcolchars, colcount);
  for dcol := 0 to colcount - 1 do
  begin
    maxcolchars[dcol] := length(grid.Columns[dcol].Title.Caption);
  end;

  // fill the data
  drow := 1;
  query.First;
  while not query.EOF do
  begin
    for dcol := 0 to colcount - 1 do
    begin
      //fd := query.FieldDefs[dcol];
      s := query.Fields[dcol].asString;
      grid.Cells[dcol, drow] := s;
      if length(s) > maxcolchars[dcol] then maxcolchars[dcol] := length(s);
    end;

    query.Next;
    inc(drow);
  end;

  // adjust maximal column width
  for dcol := 0 to colcount - 1 do
  begin
    cw := maxcolchars[dcol] * 9;
    if cw > 200 then cw := 200;
    if cw <  30 then cw := 30;

    gc := grid.Columns[dcol];
    gc.Width := cw;
  end;

end;

procedure TfrmSQL.ConnectTo(acfg : TDbConnCfg);
begin
  conncfg := acfg;

  dbconn.HostName := conncfg.dbhost;
  dbconn.DatabaseName := conncfg.dbname;
  dbconn.UserName := conncfg.dbuser;
  dbconn.Password := conncfg.dbpass;

  dbconn.Connected := True;  // may raise and exception

  Caption := conncfg.GetInfoStr;
end;

procedure TfrmSQL.miRunClick(Sender : TObject);
begin
  query.Close;
  query.SQL.Text := memoSQL.Text;
  query.Open;

  SetGridColumns;
  query.Last;  // to fetch all the record and get the row count

  grid.RowCount := query.RecordCount + 1;

  FillGridData;

  query.Close;
end;

procedure TfrmSQL.miCloneWindowClick(Sender : TObject);
var
  frm : TfrmSQL;
begin
  frm := NewSqlForm(self.conncfg);
  if frm <> nil then
  begin
    frm.memoSQL.Text := self.memoSQL.Text;
    frm.Show;
    frm.memoSQL.SetFocus;
    frm.Top := self.Top + 20;
    frm.Left := self.Left + 20;
  end;
end;

procedure TfrmSQL.FormClose(Sender : TObject; var CloseAction : TCloseAction);
var
  i : integer;
begin
  CloseAction := caFree;

  i := frmConnections.sqlfrmlist.IndexOf(self);
  if i >= 0 then
  begin
    frmConnections.sqlfrmlist.Delete(i);
    if frmConnections.sqlfrmlist.Count <= 0 then
    begin
      Application.Terminate;
    end;
  end;
end;

end.

