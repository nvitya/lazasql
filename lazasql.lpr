program lazasql;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  SysUtils, DateUtils,
  Forms, prg_config, form_main, form_connections, form_conn_edit, form_sql
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;


  DefaultFormatSettings.DateSeparator := '-';
  DefaultFormatSettings.ShortDateFormat := 'yyyy-mm-dd';

  prgconfig.Load('lazasql.json');

  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmConnections, frmConnections);
  Application.Run;
end.

