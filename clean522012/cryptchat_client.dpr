program cryptchat_client;





uses
  Forms,
  Cryptedclient in 'Cryptedclient.pas' {Form1},
  DCPcrypt2 in 'DCPcrypt2.pas',
  DCPconst in 'DCPconst.pas',
  DCPbase64 in 'DCPbase64.pas',
  DCPblockciphers in 'DCPblockciphers.pas',
  DCPrc6 in 'DCPrc6.pas',
  DCPsha512 in 'DCPsha512.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
