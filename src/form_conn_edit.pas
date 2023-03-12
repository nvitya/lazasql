unit form_conn_edit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, prg_config;

type

  { TfrmConnEdit }

  TfrmConnEdit = class(TForm)
    Label1 : TLabel;
    edID : TEdit;
    Label2 : TLabel;
    cbDbType : TComboBox;
    nbDbType : TNotebook;
    pnlBot : TPanel;
    Bevel1 : TBevel;
    btnOK : TBitBtn;
    btnCancel : TBitBtn;
    pageMysql : TPage;
    pageSqLite : TPage;
    Label3 : TLabel;
    edHost : TEdit;
    Label4 : TLabel;
    Label5 : TLabel;
    edUser : TEdit;
    edPassword : TEdit;
    Label6 : TLabel;
    edPort : TEdit;
    Label7 : TLabel;
    edDatabase : TEdit;
    Label8 : TLabel;
    edSqliteFile : TEdit;
    btnBrowseSqlite : TButton;
    odSqlite : TOpenDialog;
    procedure btnOKClick(Sender : TObject);
    procedure cbDbTypeChange(Sender : TObject);
  private

  public

    item : TConnection;

    procedure Load(aitem : TConnection);

  end;

var
  frmConnEdit : TfrmConnEdit;

implementation

{$R *.lfm}

{ TfrmConnEdit }

procedure TfrmConnEdit.btnOKClick(Sender : TObject);
begin
  ModalResult := mrNone;

  if item = nil then
  begin
    item := TConnection.Create(edID.Text);
    prgconfig.connlist.Add(item);
  end;

  item.id       := edID.Text;
  item.dbtype   := TConnDbType(cbDbType.ItemIndex);
  item.dbhost   := edHost.Text;
  item.dbname   := edDatabase.Text;
  item.dbuser   := edUser.Text;
  item.dbpass   := edPassword.Text;
  item.dbport   := StrToIntDef(edPort.Text, 3306);
  item.dbpath   := edSqliteFile.Text;

  ModalResult := mrOK;
end;

procedure TfrmConnEdit.cbDbTypeChange(Sender : TObject);
begin
  nbDbType.PageIndex := cbDbType.ItemIndex;
end;

procedure TfrmConnEdit.Load(aitem : TConnection);
begin
  item := aitem;
  if item = nil then Exit;

  edID.Text          := item.id;
  cbDbType.ItemIndex := ord(item.dbtype);
  edHost.Text        := item.dbhost;
  edDatabase.Text    := item.dbname;
  edUser.Text        := item.dbuser;
  edPassword.Text    := item.dbpass;
  edPort.Text        := IntToStr(item.dbport);
  edSqliteFile.Text  := item.dbpath;
end;

end.

