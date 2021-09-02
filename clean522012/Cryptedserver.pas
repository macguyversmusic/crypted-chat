{This program was created by Wack-a-Mole. You are free to use
it or its source code in any way you want, just gimme some credit.}

unit Cryptedserver;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, Menus, ComCtrls, ExtCtrls, DCPcrypt2,
  DCPblockciphers, DCPrc6, DCPsha512, Shellapi, StrUtils, iDhttp,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, mmsystem;

type
  TForm1 = class(TForm)
    MemoChat: TMemo;
    ServerSocket: TServerSocket;
    EditSay: TEdit;
    ButtonSend: TButton;
    StatusBar: TStatusBar;
    EditNick: TLabeledEdit;
    Button1: TButton;
    EditKey: TEdit;
    Label1: TLabel;
    DCP_rc61: TDCP_rc6;
    DCP_sha5121: TDCP_sha512;
    Timer1: TTimer;
    Label2: TLabel;
    EditKeyHost: TEdit;
    keyclient: TClientSocket;
    Button3: TButton;
    EditSeed: TEdit;
    Label3: TLabel;
    Label9: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    EditListenPort: TEdit;
    CheckBox1: TCheckBox;
    Label4: TLabel;
    Button2: TButton;
    Button9: TButton;
    Panel1: TPanel;
    Label5: TLabel;
    IdHTTP1: TIdHTTP;
    LblIP: TLabel;
    Label6: TLabel;
    EditKsrvPass: TEdit;
    Button8: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ServerSocketClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Exit1Click(Sender: TObject);
    function SendToAllClients( s : string) : boolean;
    procedure ServerSocketClientRead(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocketClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ButtonSendClick(Sender: TObject);
    procedure EditNickKeyPress(Sender: TObject; var Key: Char);
    procedure ChangeNickname1Click(Sender: TObject);
    procedure EditSayKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure keyclientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Buzz;
    procedure FranticBuzz;
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    Procedure GetMyHostAddress;
    procedure CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
var
  Cipher2: TDCP_rc6;
  myHour, myMin, mySec, myMilli : Word;
  serverkey, seedkey : string;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
MemoChat.Clear;
MemoChat.Lines.Add('SYCcHAT - Coded by SixYearCycle');
MemoChat.Lines.Add('Watch status bar for information'+#13#10+'Welcome to the MATRIX');
EditNick.Text := 'SYC';
GetMyHostAddress;
Panel1.Hide;
end;

procedure TForm1.keyclientRead(Sender: TObject; Socket: TCustomWinSocket);
begin
      memoChat.Lines.Add('Key Changing.....');
      serverkey := Keyclient.Socket.ReceiveText;
      Cipher2:= TDCP_rc6.Create(Self);
      Cipher2.InitStr(Editseed.Text,TDCP_sha512);// initialize the cipher with a hash of the passphrase
      seedKey := (Cipher2.EncryptString(serverkey));
      //EditSeed.Text := EditKey.Text;
      editKey.Text := seedkey;
      Cipher2.Burn;
      Cipher2.Free;
      memochat.Lines.Add('Key change complete');
      Editsay.SetFocus;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  delphi_datetime: tDateTime;
  windows_datetime: tSystemTime;
  myDate : TDateTime;
  clients : integer;
begin
    // get the system time
  GetSystemTime( windows_datetime );
  delphi_datetime := SystemTimeToDateTime( windows_datetime );
  myDate := delphi_datetime;
  Label2.Caption  :='Sytem time'+(Datetimetostr(delphi_datetime));
  DecodeTime(myDate, myHour, myMin, mySec, myMilli);
  clients := ServerSocket.Socket.ActiveConnections;
  Label5.Caption := ('Connected Clients :- ')+IntToStr(clients);
end;

function TForm1.SendToAllClients( s : string) : boolean;
var
    i : integer;
begin
if ServerSocket.Socket.ActiveConnections = 0 then
  begin
  ShowMessage('There are no connected clients.');
  Exit;
  end;
for i := 0 to (ServerSocket.Socket.ActiveConnections - 1) do
  begin
  ServerSocket.Socket.Connections[i].SendText(s);
  end;
end;

procedure TForm1.ServerSocketClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  SendToAllClients('<'+Socket.RemoteHost+' just disconnected.>');
  MemoChat.Lines.Add('<'+Socket.RemoteHost+' just disconnected.>');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
ServerSocket.Port := StrToInt(EditListenPort.Text);
Serversocket.Active := True;
EditSay.Focused;
form1.StatusBar.SimpleText := 'listening on port '+editlistenport.Text;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Keyclient.Host := editKeyHost.text;
  Keyclient.Active := True;
  keyclient.Socket.SendText(editksrvpass.Text);
  editsay.SetFocus;
end;

//procedure TForm1.KeyClientConnect(Sender: TObject;
//  Socket: TCustomWinSocket);
//begin
//  Keyclient.Socket.SendText(editksrvpass.Text) ;
//end;

procedure TForm1.ServerSocketClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  Cipher2:= TDCP_rc6.Create(Self);
  Cipher2.InitStr(EditKey.Text,TDCP_sha512);
  SendToAllClients(Cipher2.encryptstring('@connection <'+Socket.RemoteHost+' just connected.>'));
  MemoChat.Lines.Add('<'+Socket.RemoteHost+' just connected.>');
  Cipher2.Burn;
  Cipher2.Free;
  EditSay.setfocus;
end;


procedure TForm1.ServerSocketClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
  received: STRING;
   decrypted : ANSIstring;
begin
  Cipher2:= TDCP_rc6.Create(Self);
  Cipher2.InitStr(EditKey.Text,TDCP_sha512);
  received := Socket.ReceiveText; //this is the packet it receives
  SendToAllClients(received);
  decrypted :=(Cipher2.DecryptString(received));  //this is it decrypting said packet
  Cipher2.Burn;
  Cipher2.Free;

   if AnsiContainsStr(decrypted, '@buzzsrvr') then    //checks said packet for the string @buzzsrvr
   begin
   buzz; //executes subroutine called buzz
   end else
   if AnsiContainsStr(decrypted, '@fbuzzsrvr') then
   begin
   franticbuzz;
//   end else
//   if AnsiContainsStr(decrypted, '@hidetb') then
//   begin
//   ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_hide);
//   end else
//   if AnsiContainsStr(decrypted, '@showtb') then
//   begin
//   ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOW);
   end else
  MemoChat.Lines.Add(decrypted);

end;

procedure TForm1.Button3Click(Sender: TObject);
begin
ShellExecute(Handle, 'open', PChar('keyserver.exe'),nil,nil, SW_SHOW);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
KeyClient.Active := False;
KeyClient.Socket.Close;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
EditSay.Text := '@buzzc';
ButtonSend.Click;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
EditSay.Text := '@fbuzzc';
ButtonSend.Click;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
ShellExecute(Handle, 'open', PChar('dns_updater.exe'),nil,nil, SW_SHOW);
  end;

procedure TForm1.Button9Click(Sender: TObject);
begin
ServerSocket.Close;
Serversocket.Active := False;
Statusbar.SimpleText := 'Inactive';
end;

procedure TForm1.ButtonSendClick(Sender: TObject);
  begin
    Cipher2:= TDCP_rc6.Create(Self);
    Cipher2.InitStr(EditKey.Text,TDCP_sha512);
    SendToAllClients(Cipher2.EncryptString(EditNick.Text + ':- ' + EditSay.Text));
    MemoChat.Lines.Add(EditNick.Text +':- ' + EditSay.Text);
    EditSay.Text := '';
    Cipher2.Burn;
    Cipher2.Free;
  end;

procedure TForm1.EditNickKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0; //because i dont want nobody to change its nickname until they press the change button
end;

procedure TForm1.ChangeNickname1Click(Sender: TObject);
var
  old, new : string;
begin
  InputQuery('New nick?', 'Please write the new nickname you want to use.', new);
  if new = '' then Exit;
  old := EditNick.Text;
  //SendToAllClients('<'+Old + ' has just changed its nick to '+ new+'.>');
  //MemoChat.Lines.Add('<'+Old + ' has just changed its nick to '+ new+'.>');
  EditNick.Text := New;
end;

procedure TForm1.CheckBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if CheckBox1.Checked then
Panel1.Show else
panel1.Hide;
end;

procedure TForm1.EditSayKeyPress(Sender: TObject; var Key: Char);
begin
if Key = #13 then //#13 is Enter
  begin
    ButtonSend.Click;
  end;
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
Close;
end;

procedure Tform1.buzz;   //this is the buzzing uses windows beep
 begin
   windows.beep(300,50);
   windows.beep(600,50);
   windows.beep(900,50);
   windows.beep(1200,50);
   windows.beep(900,50);
   windows.beep(600,50);
   windows.beep(300,50);
   FlashWindow(Application.Handle, True); // The app button on the taskbar
   FlashWindow(Handle, True); // The current form
 end;

procedure Tform1.FranticBuzz();
const
  Noten = 29;
  VIERTEL = 12;
  HALBE = 25;
type
  TAlleMeineEntchen = array[0..1, 0..Noten] of Integer;
const
  AlleMeineEntchen : TAlleMeineEntchen = ((523, 587, 659, 698, 783, 783, 880,
    880, 880, 880, 783, 32, 880, 880, 880, 880, 32, 782, 698, 698, 698, 698,
    649, 649, 783, 783, 783, 783, 523, 32),
   (VIERTEL, VIERTEL, VIERTEL, VIERTEL, HALBE, HALBE, VIERTEL, VIERTEL, VIERTEL,
    VIERTEL, HALBE, VIERTEL, VIERTEL, VIERTEL, VIERTEL, VIERTEL, VIERTEL, HALBE,
    VIERTEL, VIERTEL, VIERTEL, VIERTEL, HALBE, HALBE, VIERTEL, VIERTEL, VIERTEL,
    VIERTEL, HALBE, VIERTEL));
var
  I, p,f: Integer;
begin
  for f := 0 to 2 do
  begin
   for p := 0 to 1 do
    begin
      for I := 0 to Noten do
      begin
      Windows.Beep(AlleMeineEntchen[0, I], AlleMeineEntchen[1, I]);
      end;
      SysUtils.Sleep(250);
    end;
      SysUtils.Sleep(1500);
  end;
  FlashWindow(Handle, True); // The current form
end;

procedure Tform1.GetMyHostAddress;
var
   ip: string;
begin
  ip := Form1.IdHTTP1.Get('http://automation.whatismyip.com/n09230945.asp');
  LblIP.Caption := ('Current IP Address : '+ip);
end;


end.


