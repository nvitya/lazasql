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
    procedure miRunClick(Sender : TObject);
    procedure FormShow(Sender : TObject);
  private

  public
    conncfg : TConnection;

    procedure SetGridColumns;

  end;

var
  frmSQL : TfrmSQL;

implementation

{$R *.lfm}

{ TfrmSQL }

procedure TfrmSQL.FormShow(Sender : TObject);
begin
  dbconn.HostName := conncfg.dbhost;
  dbconn.DatabaseName := conncfg.dbname;
  dbconn.UserName := conncfg.dbuser;
  dbconn.Password := conncfg.dbpass;

  dbconn.Connected := True;
end;

procedure TfrmSQL.SetGridColumns;
var
  i : integer;
  fd : TFieldDef;
  gc : TGridColumn;
begin
  //grid.ColCount := query.FieldDefs.Count;
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

procedure TfrmSQL.miRunClick(Sender : TObject);
var
  drow, dcol : integer;
  //fd : TFieldDef;
begin
  query.Close;
  query.SQL.Text := memoSQL.Text;
  query.Open;
  // ShowMessage('run will be implemented.');
  SetGridColumns;
  query.Last;  // to fetch all the record and get the row count

  grid.RowCount := query.RecordCount + 1;

  // fill the data
  drow := 1;
  query.First;
  while not query.EOF do
  begin
    for dcol := 0 to query.FieldDefs.Count - 1 do
    begin
      //fd := query.FieldDefs[dcol];
      grid.Cells[dcol, drow] := query.Fields[dcol].asString;
    end;

    query.Next;
    inc(drow);
  end;

  query.Close;

end;

end.

