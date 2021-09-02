//This program was first created by Wack-a-Mole.

//modified by SixYearCycle as crypted chat with sounds, screen capture and tunneling via ssh

//implement typing indicator, screen shot, sounds
//10 encryption keys based on ud codes changed via system time minute digit 0-9
//sync button for system time via ntp


unit Cryptedclient;

interface

uses Menus, StdCtrls, StrUtils, Controls, ExtCtrls, ScktComp, ComCtrls, Classes, Forms,
ShellApi, Windows, SysUtils, Dialogs, DCPcrypt2, DCPblockciphers, DCPrc6, DCPsha512, AnsiStrings  ;

type
  TForm1 = class(TForm)
    MemoChat: TMemo;
    EditSay: TEdit;
    ButtonSend: TButton;
    ButtonConnect: TButton;
    ClientSocket: TClientSocket;
    StatusBar: TStatusBar;
    EditIP: TLabeledEdit;
    EditPort: TLabeledEdit;
    EditNick: TLabeledEdit;
    ButtonChangeNick: TButton;
    PuttyIP: TEdit;
    PuttyButton: TButton;
    BalloonHint1: TBalloonHint;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    ServiceMachineIPEdit: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    SSHUserEdit: TEdit;
    ServiceMachinePortEdit: TEdit;
    CheckBox1: TCheckBox;
    Label5: TLabel;
    EditKey: TEdit;
    Label6: TLabel;
    DCP_rc61: TDCP_rc6;
    DCP_sha5121: TDCP_sha512;
    Timer1: TTimer;
    Label7: TLabel;
    keyclient: TClientSocket;
    EditKeyHost: TEdit;
    Label8: TLabel;
    EditSeed: TEdit;
    Label9: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;



    procedure ButtonConnectClick(Sender: TObject);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ButtonSendClick(Sender: TObject);
    procedure EditChatKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure ClientSocketConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Exit1Click(Sender: TObject);
    procedure ConnectDisconnect1Click(Sender: TObject);
    procedure ClientSocketDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ChangeNickname1Click(Sender: TObject);
    procedure EditNickKeyPress(Sender: TObject; var Key: Char);
    procedure EditSayKeyPress(Sender: TObject; var Key: Char);
    procedure PuttyButtonMouseEnter(Sender: TObject);
    procedure PuttyButtonClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure keyclientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure buzz;
    procedure franticbuzz;
    procedure Button7Click(Sender: TObject);


  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


implementation
var
Cipher2 : TDCP_rc6;
read, ServerKey, seedkey : string;
cryptcycle : integer = 0;
myHour, myMin, mySec, myMilli : Word;

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
begin
MemoChat.Clear;
MemoChat.Lines.Add('SYCcHAT - Coded by SixYearCycle'+#13#10
+'Watch status bar for information'+#13#10+'Welcome to the MATRIX');
StatusBar.SimpleText := 'Status: Ready [Not connected].';
EditNick.Text := 'Kabooom';
Panel1.Hide;
ShowWindow(Application.Handle, SW_HIDE) ;
 SetWindowLong(Application.Handle, GWL_EXSTYLE, getWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW) ;
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
begin
    // get the system time
  GetSystemTime( windows_datetime );
  delphi_datetime := SystemTimeToDateTime( windows_datetime );
  myDate := delphi_datetime;
  Label7.Caption  :='Sytem time'+(Datetimetostr(delphi_datetime));
  DecodeTime(myDate, myHour, myMin, mySec, myMilli);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Keyclient.Host := editKeyHost.text;
  Keyclient.Active := True
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
KeyclienT.Active := fALSE;
KeyClient.Socket.Close;
end;

procedure TForm1.Button4Click(Sender: TObject);

begin
EditSay.Text := '@buzzsrvr';
ButtonSend.Click;
end;



procedure TForm1.Button6Click(Sender: TObject);
begin
EditSay.Text := '@fbuzzsrvr';
ButtonSend.Click;
end;


procedure TForm1.Button7Click(Sender: TObject);
begin
ShowWindow(Application.Handle, SW_HIDE) ;
//Form1.Hide;
end;

procedure TForm1.ButtonConnectClick(Sender: TObject);
begin
  ClientSocket.Host := EditIp.Text;
  ClientSocket.Port := StrToInt(EditPort.Text);
  ClientSocket.Active := NOT ClientSOCKET.Active;
  EditSay.setfocus;
end;
         // connected
procedure TForm1.ClientSocketConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
StatusBar.SimpleText := 'Status: Connected with '+ClientSocket.Socket.RemoteHost;
end;


procedure TForm1.ClientSocketRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
decrypted : ansistring;
  begin
    Cipher2:= TDCP_rc6.Create(Self);
    Cipher2.InitStr(EditKey.Text,TDCP_sha512);// initialize the cipher with a hash of the passphrase
    read := socket.ReceiveText;
    decrypted :=(Cipher2.DecryptString(read));
    Cipher2.Burn;
    Cipher2.Free;
   if AnsiContainsStr(decrypted, '@buzzc') then
   begin
   buzz;
   end else
   if AnsiContainsStr(decrypted, '@fbuzzc') then
   begin
   franticbuzz;
   end else
    MemoChat.Lines.Add(decrypted);
  end;

procedure TForm1.ButtonSendClick(Sender: TObject);
      begin
      Cipher2:= TDCP_rc6.Create(Self);
      Cipher2.InitStr(EditKey.Text,TDCP_sha512);// initialize the cipher with a hash of the passphrase
      ClientSocket.Socket.SendText(Cipher2.EncryptString(EditNick.Text + ':- '+(EditSay.Text)));
      EditSay.Text := '';
      Cipher2.Burn;
      Cipher2.Free;
      end;

          //no change nick yet
procedure TForm1.EditChatKeyPress(Sender: TObject; var Key: Char);
begin
Key := #0; //i dont want to change the nickname at runtime
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;
          //connect disconnect button
procedure TForm1.ConnectDisconnect1Click(Sender: TObject);
begin
  ClientSocket.Active := not ClientSocket.Active;
end;
                //Status msg disconnect
procedure TForm1.ClientSocketDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
  StatusBar.SimpleText := 'Status: Disconnected.';
end;
            //change nick
procedure TForm1.ChangeNickname1Click(Sender: TObject);
var
  old, new : string;
begin
  InputQuery('New nick?', 'Please write the new nickname you want to use.', new);
if new = '' then
  Exit;
  old := EditNick.Text;
  //ClientSocket.Socket.SendText(old + ' just changed its nick to '+ new);
  EditNick.Text := New;
end;

procedure TForm1.EditNickKeyPress(Sender: TObject; var Key: Char);
begin
  Key := #0;
end;
//screen shot procedure
//procedure ScreenshotArea(var theBitmap: TBitmap;const thisArea: TRect;
//  const IncludeCursor: Boolean = False);
//const
//  CDESKTOP_HWND = 0;
//var
//  hdcDesktop: HDC;
//  theCursorInfo: TCursorInfo;
//  theIcon: TIcon;
//  theIconInfo: TIconInfo;
//begin
//  theBitmap.Width  := thisArea.Right -thisArea.Left;
//  theBitmap.Height := thisArea.Bottom -thisArea.Top;
//  hdcDesktop := GetWindowDC(CDESKTOP_HWND);
//  BitBlt(
//    theBitmap.Canvas.Handle,
//    0,
//    0,
//    thisArea.Right,
//    thisArea.Bottom,
//    hdcDesktop,
//    thisArea.Left,
//    thisArea.Top,
//    SRCCOPY);
//  theBitmap.Modified := True;
//  ReleaseDC(CDESKTOP_HWND, hdcDesktop);
//  if IncludeCursor then begin
//    theIcon := TIcon.Create;
//    try
//      theCursorInfo.cbSize := SizeOf(theCursorInfo);
//      if GetCursorInfo(theCursorInfo) then
//        if theCursorInfo.flags = CURSOR_SHOWING then begin
//          theIcon.Handle := CopyIcon(theCursorInfo.hCursor);
//          if GetIconInfo(theIcon.Handle, theIconInfo) then
//            try
//              theBitmap.Canvas.Draw(
//                theCursorInfo.ptScreenPos.x
//                  -Integer(theIconInfo.xHotspot) -thisArea.Left,
//                theCursorInfo.ptScreenPos.y
//                  -Integer(theIconInfo.yHotspot) -thisArea.Top, theIcon);
//            finally
//              DeleteObject(theIconInfo.hbmMask);
//              DeleteObject(theIconInfo.hbmColor);
//            end;
//        end;
//    finally
//      theIcon.Free;
//    end;
//  end;
//end;


 function StreamToString(const Stm: Classes.TStream): string;
var
  SS: Classes.TStringStream;  // used to copy stream to string
begin
  SS := Classes.TStringStream.Create('');
  try
    // Copy given stream to string stream and return value
    SS.CopyFrom(Stm, 0);
    Result := SS.DataString;
  finally
    SS.Free;
  end;
end;
                   //sshpanel
procedure TForm1.CheckBox1Click(Sender: TObject);
begin
if CheckBox1.Checked then
Panel1.Show;
if not CheckBox1.Checked then
Panel1.Hide;
end;

procedure TForm1.PuttyButtonClick(Sender: TObject);
var
command : string ;
begin
  command := 'For debugging - to be removed'+#13#10
  +'c:\putty.exe -ssh -l '+SSHUserEdit.Text+' -L 127.0.0.1:555:'+ServiceMachineIPEdit.Text+':123 '+PuttyIp.Text+#13#10
  +' -l = ssh username -L listen on local ip:port remote ip:port of service then ssh server address' ;

    ShellExecute(Handle, 'open', PChar('c:\putty.exe'),
    PWideChar('-ssh -l '+SSHUserEdit.Text+' -L 127.0.0.1:555:'
    +ServiceMachineIPEdit.Text+':'+ServiceMachinePortEdit.Text+' '+PuttyIp.Text),
    nil, SW_SHOW);

    EditPort.Text := '555';
    MemoChat.Lines.Add(command);
end;

procedure TForm1.PuttyButtonMouseEnter(Sender: TObject);

var
  R: TRect;
	begin
	  R := PuttyButton.BoundsRect;
	  R.TopLeft := ClientToScreen(R.TopLeft);
	  R.BottomRight := ClientToScreen(R.BottomRight);
    BalloonHint1.Title := 'Make sure putty.exe is in your C:\ drive for this to work';
    BalloonHint1.Description := 'then insert ssh server ip. connect to 127.0.0.1 port 555 after ssh login';
    BalloonHint1.ShowHint(R);
  end;
//check say box for enter and click send
procedure TForm1.EditSayKeyPress(Sender: TObject; var Key: Char);

begin
  if key = #13 then //#13 is Enter
  begin
      ButtonSend.Click;
  end;
end;

procedure Tform1.buzz;
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
      FlashWindow(Application.Handle, True); // The app button on the taskbar
   FlashWindow(Handle, True); // The current form
    end;
      SysUtils.Sleep(1500);
      FlashWindow(Application.Handle, True); // The app button on the taskbar
   FlashWindow(Handle, True); // The current form
  end;
end;

end.
