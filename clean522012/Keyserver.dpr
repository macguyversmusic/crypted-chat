program Keyserver;

uses
  Forms,
  RandomKeyServer in 'RandomKeyServer.pas' {KEYSERVER_FORM_};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TKEYSERVER_FORM_, KEYSERVER_FORM_);
  Application.Run;
end.
