unit form_mysql_struct;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls, Menus,
  prg_config, mysql80conn, mysql50conn, SQLDB;

type

  { TfrmMysqlStruct }

  TfrmMysqlStruct = class(TForm)
    dbconn : TMySQL50Connection;
    tgrid : TStringGrid;
    Splitter1 : TSplitter;
    pnlRight : TPanel;
    pnlTableName : TPanel;
    fgrid : TStringGrid;
    sqltra : TSQLTransaction;
    query : TSQLQuery;
    tpopupmenu : TPopupMenu;
    miShowCreateTable : TMenuItem;
    procedure FormShow(Sender : TObject);
    procedure FormClose(Sender : TObject; var CloseAction : TCloseAction);
    procedure tgridDblClick(Sender : TObject);
    procedure tgridSelection(Sender : TObject; aCol, aRow : Integer);
    procedure miShowCreateTableClick(Sender : TObject);
  private

  public
    conncfg : TDbConnCfg;

    procedure ConnectTo(acfg : TDbConnCfg);

    procedure QueryStructure;
    procedure QueryTableStruc(aname : string);
  end;

var
  frmMysqlStruct : TfrmMysqlStruct;

function NewMysqlStructForm(aconncfg : TDbConnCfg) : TfrmMysqlStruct;

implementation

uses
  form_connections, form_view_memo, form_sql;

function NewMysqlStructForm(aconncfg : TDbConnCfg) : TfrmMysqlStruct;
var
  frm : TfrmMysqlStruct;
begin
  Application.CreateForm(TfrmMysqlStruct, frm);
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
  frm.QueryStructure;
  frm.Show;
  frmConnections.AddConnWindow(frm);
  result := frm;
end;

{$R *.lfm}

{ TfrmMysqlStruct }

procedure TfrmMysqlStruct.FormShow(Sender : TObject);
begin
{
SELECT
  table_name,Engine,Version,Row_format,table_rows,Avg_row_length,
  Data_length,Max_data_length,Index_length,Data_free,Auto_increment,
  Create_time,Update_time,Check_time,table_collation,Checksum,
  Create_options,table_comment
FROM
  information_schema.tables
WHERE
  table_schema = DATABASE();
}

end;

procedure TfrmMysqlStruct.FormClose(Sender : TObject; var CloseAction : TCloseAction);
begin
  CloseAction := caFree;
  frmConnections.DeleteConnWindow(self);
end;

procedure TfrmMysqlStruct.tgridDblClick(Sender : TObject);
var
  frm : TfrmSQL;
begin
  frm := NewSqlForm(self.conncfg);
  frm.msql.Text := 'select * from '+tgrid.Cells[0, tgrid.Row];
end;

procedure TfrmMysqlStruct.tgridSelection(Sender : TObject; aCol, aRow : Integer);
begin
  QueryTableStruc(tgrid.Cells[0, tgrid.row]);
end;

procedure TfrmMysqlStruct.miShowCreateTableClick(Sender : TObject);
var
  tablename : string;
begin
  tablename := tgrid.Cells[0, tgrid.row];

  query.SQL.Text := 'show create table '+tablename;
  query.Open;
  NewMemoForm(tablename+' create code', query.FieldByName('Create Table').asString);
  query.Close;
end;

procedure TfrmMysqlStruct.ConnectTo(acfg : TDbConnCfg);
begin
  conncfg := acfg;

  dbconn.HostName := conncfg.dbhost;
  dbconn.DatabaseName := conncfg.dbname;
  dbconn.UserName := conncfg.dbuser;
  dbconn.Password := conncfg.dbpass;

  dbconn.Connected := True;  // may raise and exception

  Caption := conncfg.ID+' Structure';
end;

procedure TfrmMysqlStruct.QueryStructure;
var
  s : string;
  col : integer;
begin
  s :=   'select'
    +#13+'  table_name, table_rows, Data_length, Engine'
    +#13+'from'
    +#13+'  information_schema.tables'
    +#13+'where'
    +#13+'  table_schema = DATABASE()'
    +#13+'order by'
    +#13+'  table_name'
  ;
  query.SQL.Text := s;
  query.Open;
  query.First;
  tgrid.RowCount := 1;
  while not query.Eof do
  begin
    tgrid.RowCount := tgrid.RowCount + 1;
    for col := 0 to 3 do
    begin
      tgrid.Cells[col, tgrid.rowcount-1] := query.Fields[col].AsString;
    end;
    query.Next;
  end;

  query.Close;

  tgrid.Row := 1;
  QueryTableStruc(tgrid.cells[0, tgrid.Row]);
end;

procedure TfrmMysqlStruct.QueryTableStruc(aname : string);
var
  row : integer;
  col : integer;
begin
  pnlTableName.Caption := aname;
  row := 1;
  fgrid.RowCount := row;

  try
    query.SQL.Text := 'describe '+aname;
    query.Open;
    query.First;
    while not query.Eof do
    begin
      fgrid.RowCount := row + 1;
      for col := 0 to 3 do
      begin
        fgrid.Cells[col, row] := query.Fields[col].AsString;
      end;
      query.Next;
      inc(row);
    end;
    query.Close;

    fgrid.Row := 1;
  except
    ;
  end;
end;

end.

