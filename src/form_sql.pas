unit form_sql;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  StdCtrls, Menus, prg_config, DB, SQLDB,
  strparseobj;

type

  { TfrmSQL }

  TfrmSQL = class(TForm)
    miConnections : TMenuItem;
    nbBottom : TNotebook;
    pageGrid : TPage;
    grid : TStringGrid;
    pnlSQL : TPanel;
    msql : TMemo;
    Splitter1 : TSplitter;
    sqlMenu : TPopupMenu;
    miRun : TMenuItem;
    query : TSQLQuery;
    sqltra : TSQLTransaction;
    miCloneWindow : TMenuItem;
    Separator1 : TMenuItem;
    pageLog : TPage;
    mlog : TMemo;
    miShowLog : TMenuItem;
    miViewField : TMenuItem;
    Separator2 : TMenuItem;
    miDbStruct : TMenuItem;
    procedure miConnectionsClick(Sender : TObject);
    procedure miRunClick(Sender : TObject);
    procedure miCloneWindowClick(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure miShowLogClick(Sender : TObject);
    procedure miViewFieldClick(Sender : TObject);
    procedure miDbStructClick(Sender : TObject);
  private

  public
    dbconn : TSQLConnection;

    conncfg : TDbConnCfg;

    colcount    : integer;
    maxcolchars : array of integer;

    sp : TStrParseObj;

    sqls : array of string;

    procedure SetGridColumns;
    procedure FillGridData;

    procedure ConnectTo(acfg : TDbConnCfg);

    procedure ShowGrid(ashow : boolean);

    procedure ParseSqls;
    procedure ClearSqls;

    procedure RunSQLs;
    procedure SetTitle(atitle : string);
  end;

var
  frmSQL : TfrmSQL;

function NewSqlForm(aconncfg : TDbConnCfg) : TfrmSQL;

implementation

uses
  form_connections, form_view_memo, form_mysql_struct;

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
      MessageDlg('Connect Error',
         'Error Connecting to database "'+aconncfg.GetInfoStr+'":'#13+e.Message,
         mtError, [mbAbort], 0);

      frm.Free;
      result := nil;
      EXIT;
    end;
  end;
  frm.Show;
  frmConnections.AddConnWindow(frm);
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

procedure TfrmSQL.SetTitle(atitle : string);
var
  s : string;
begin
  s := conncfg.id+' SQL';
  if atitle <> '' then s += ': '+atitle;
  Caption := s;
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
    cw := round(maxcolchars[dcol] * 9);
    if cw > 200 then cw := 200;
    if cw <  30 then cw := 30;

    gc := grid.Columns[dcol];
    gc.Width := cw;
  end;

end;

procedure TfrmSQL.ConnectTo(acfg : TDbConnCfg);
begin
  conncfg := acfg;

  dbconn := frmConnections.CreateSqlConn(self, conncfg);
  query.DataBase := dbconn;
  sqltra.DataBase := dbconn;

  dbconn.Connected := True;  // may raise and exception

  SetTitle('');
end;

procedure TfrmSQL.ShowGrid(ashow : boolean);
begin
  if not ashow then nbBottom.PageIndex := 1
               else nbBottom.PageIndex := 0;
end;

procedure TfrmSQL.ParseSqls;
var
  instring : boolean;
  mtext : string;
  c : char;
  s : string;
begin
  ClearSqls;

  mtext := msql.Lines.Text;  // copy the string first

  sp.Init( mtext );

  instring  := false;
  s := '';
  while sp.readptr < sp.bufend do
  begin
    c := sp.readptr^;

    if not instring then
    begin
      if (c = '-') and (RightStr(s, 1) = '-') then  // comment
      begin
        delete(s, length(s), 1);
        sp.ReadLine();
        continue;
      end
      else if (c = ';') and not instring then
      begin
        insert(s, sqls, length(sqls) + 1);
        s := '';

        Inc(sp.ReadPtr);
        sp.SkipSpaces;
        continue;
      end;
    end;

    if c = '''' then
    begin
      if instring and (RightStr(s, 1) <> '\') then instring := false
      else if not instring then instring := true;
    end;

    if c <> #0 then s := s + c;

    Inc(sp.ReadPtr);
  end;

  if s <> '' then
  begin
    insert(s, sqls, length(sqls) + 1);
  end;
end;

procedure TfrmSQL.ClearSqls;
begin
  sqls := [];
end;

procedure TfrmSQL.RunSQLs;
var
  n : integer;
  sqltext : string;
  t1,t2 : TDateTime;

  function GetRunTime(tstart, tend : TDateTime) : string;
  begin
    result := '('+FormatFloat('#####0.000',(tend-tstart)*24*60*60)+' s)';
  end;

begin
  ParseSqls;

  mlog.Append('');
  mlog.Append('-- RUNNING SQLs');

  for n:= 0 to length(sqls)-1 do
  begin
    mlog.Append('-- SQL '+IntToStr(n+1)+':');
    sqltext := sqls[n];
    mlog.Append(sqltext);

    query.Close;
    query.SQL.Text := sqltext;

    sp.Init(sqltext);
    sp.ReadIdentifier();

    try
      if sp.UCComparePrev('SELECT') or sp.UCComparePrev('SHOW') or sp.UCComparePrev('DESCRIBE') then
      begin
        // query with results
        t1 := now;
        query.Open;
        SetGridColumns;
        query.Last;  // to fetch all the record and get the row count
        grid.RowCount := query.RecordCount + 1;
        FillGridData;
        t2 := now;
        mlog.Append('-- '+GetRunTime(t1,t2)+' returned rows: '+IntToStr(query.RecordCount));
        SetTitle(IntToStr(query.RecordCount)+' rows');
        query.Close;

        ShowGrid(true);
      end
      else
      begin
        // query without results
        t1 := now;
        query.ExecSql;
        t2 := now;
        mlog.Append('-- '+GetRunTime(t1,t2)+' rows affected: '+IntToStr(query.RowsAffected));
        SetTitle('');
        ShowGrid(false);
      end;

    except
      on e : Exception do
      begin
        mlog.Append('-- error: '+e.Message);
        SetTitle('');
        ShowGrid(false);
      end;
    end;

    mlog.Append('');

  end; // for
end;

procedure TfrmSQL.miRunClick(Sender : TObject);
begin
  RunSQLs;
end;

procedure TfrmSQL.miCloneWindowClick(Sender : TObject);
var
  frm : TfrmSQL;
begin
  frm := NewSqlForm(self.conncfg);
  if frm <> nil then
  begin
    frm.msql.Text := self.msql.Text;
    frm.Show;
    frm.msql.SetFocus;
    frm.Top := self.Top + 20;
    frm.Left := self.Left + 20;
  end;
end;

procedure TfrmSQL.miConnectionsClick(Sender : TObject);
begin
  frmConnections.Show;
end;

procedure TfrmSQL.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  CloseAction := caFree;
  frmConnections.DeleteConnWindow(self);
end;

procedure TfrmSQL.miShowLogClick(Sender : TObject);
begin
  ShowGrid(nbBottom.PageIndex <> 0);
  if not msql.Focused then
  begin
    if grid.Visible then grid.SetFocus;
    if mlog.Visible then mlog.SetFocus;
  end;
end;

procedure TfrmSQL.miViewFieldClick(Sender : TObject);
begin
  if nbBottom.PageIndex = 0 then
  begin
    NewMemoForm('Field: '+grid.Columns[grid.Col].Title.Caption, grid.Cells[grid.Col, grid.row]);
  end;
end;

procedure TfrmSQL.miDbStructClick(Sender : TObject);
begin
  NewMysqlStructForm(self.conncfg);
end;

end.

