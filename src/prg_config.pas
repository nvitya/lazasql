unit prg_config;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, fgl, JsonTools;

type
  TConnDbType = (dbtMySql, dbtSQLite);

  { TDbConnCfg }

  TDbConnCfg = class
  public
    id       : string;
    dbtype   : TConnDbType;

    // MySQL / Mariadb
    dbhost   : string;
    dbname   : string;
    dbuser   : string;
    dbpass   : string;
    dbport   : integer;

    // SQLite
    dbpath   : string;

    constructor Create(aid : string);

    function GetInfoStr : string;
  end;

  TConnList = specialize TFPGObjectList<TDbConnCfg>;

  { TPrgConfig }

  TPrgConfig = class
  protected
    jroot : TJsonNode;
  public

    filename : string;
    connlist : TConnList;

    constructor Create;
    destructor Destroy; override;

    procedure Load(afilename : string);
    procedure Save;
  end;

var
  prgconfig : TPrgConfig;

function GetDbTypeName(ct : TConnDbType) : string;

implementation

function GetDbTypeName(ct : TConnDbType) : string;
begin
  if      ct = dbtMySql then result := 'MySQL'
  else if ct = dbtMySql then result := 'SQLite3'
  else result := '?';
end;

{ TDbConnCfg }

constructor TDbConnCfg.Create(aid : string);
begin
  id       := aid;
  dbtype := dbtMySql;

  dbhost   := '';
  dbname   := '';
  dbuser   := '';
  dbpass   := '';
  dbport   := 0;

  dbpath   := '';
end;

function TDbConnCfg.GetInfoStr : string;
begin
  if dbtype = dbtSQLite then
  begin
    result := dbpath;
  end
  else
  begin
    result := dbname + ' @ ' +dbhost;
  end;
end;

{ TPrgConfig }

constructor TPrgConfig.Create;
begin
  connlist := TConnList.Create(True);
  jroot := TJsonNode.Create;
end;

destructor TPrgConfig.Destroy;
begin
  connlist.Free;
  jroot.Free;
  inherited Destroy;
end;

procedure TPrgConfig.Load(afilename : string);
var
  jnarr, jn, jv : TJsonNode;
  item : TDbConnCfg;
  i : integer;
begin
  filename := afilename;
  try
    jroot.LoadFromFile(filename);
  except
    EXIT;
  end;

  connlist.Clear;
  if jroot.Find('CONNLIST', jnarr) then
  begin
    for i := 0 to jnarr.Count - 1 do
    begin
      jn := jnarr.Child(i);
      if jn.Find('ID', jv) then
      begin
        item := TDbConnCfg.Create(jv.AsString);
        if jn.Find('DBTYPE', jv) then item.dbtype := TConnDbType(trunc(jv.AsNumber));

        if item.dbtype = dbtSQLite then
        begin
          if jn.Find('DBPATH', jv) then item.dbpath := jv.AsString;
        end
        else // mysql
        begin
          if jn.Find('DBHOST', jv) then item.dbhost := jv.AsString;
          if jn.Find('DBPORT', jv) then item.dbport := trunc(jv.AsNumber);
          if jn.Find('DBNAME', jv) then item.dbname := jv.AsString;
          if jn.Find('DBUSER', jv) then item.dbuser := jv.AsString;
          if jn.Find('DBPASS', jv) then item.dbpass := jv.AsString;
        end;

        connlist.Add(item);
      end;
    end;
  end;
end;

procedure TPrgConfig.Save;
var
  jnarr, jn : TJsonNode;
  item : TDbConnCfg;
begin
  jnarr := jroot.Add('CONNLIST', nkArray);
  jnarr.Clear;
  for item in connlist do
  begin
    jn := jnarr.Add();
    jn.Add('ID', item.id);
    jn.Add('DBTYPE', ord(item.dbtype));
    if item.dbtype = dbtSQLite then
    begin
      jn.Add('DBPATH', item.dbpath);
    end
    else  // MySQL
    begin
      jn.Add('DBHOST', item.dbhost);
      jn.Add('DBPORT', item.dbport);
      jn.Add('DBNAME', item.dbname);
      jn.Add('DBUSER', item.dbuser);
      jn.Add('DBPASS', item.dbpass);
    end;
  end;

  jroot.SaveToFile(filename);
end;


initialization
begin
  prgconfig := TPrgConfig.Create;
end;

end.

