unit RandomKeyServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ScktComp, ExtCtrls, Math, StrUtils, shellapi, Menus ;

type
    TKEYSERVER_FORM_ = class(TForm)
    ServerSocket1: TServerSocket;
    Timer1: TTimer;
    RANDOMLY_GENERATED_CODE_TEXTBOX_: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    START_SERVER_BUTTON_: TButton;
    STOP_SERVER_BUTTON_: TButton;
    PASSCODE_TEXTBOX_: TEdit;
    INFOBOX_: TMemo;
    CHANGE_CODE_BUTTON_: TButton;
    PopupMenu1: TPopupMenu;
    MINIMISE_BUTTON_: TButton;
    function SendToAllClients( s : string) : boolean;
    procedure Timer1Timer(Sender: TObject);
    procedure ServerSocket1ClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ServerSocket1ClientDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure START_SERVER_BUTTON_Click(Sender: TObject);
    procedure STOP_SERVER_BUTTON_Click(Sender: TObject);
    procedure CHANGE_CODE_BUTTON_Click(Sender: TObject);
    procedure sleepawhile;
    procedure FormCreate(Sender: TObject);
    procedure MINIMISE_BUTTON_Click(Sender: TObject);
    private
    IconData: TNotifyIconData;
    procedure CreateTrayIcon;
    procedure MinimizeToTray;
    procedure RestoreFromTray;
    procedure ExitClick(Sender: TObject);
    procedure RestoreClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  public
procedure WndProc(var Msg : TMessage); override;
  end;

var
  KEYSERVER_FORM_: TKEYSERVER_FORM_;

implementation
var
MyString : string;
clients : integer;

{$R *.dfm}

procedure TKEYSERVER_FORM_.START_SERVER_BUTTON_Click(Sender: TObject);
begin
ServerSocket1.Active := True;
INFOBOX_.Lines.Add('listening on port '+IntToStr(serversocket1.Port));
end;



procedure TKEYSERVER_FORM_.STOP_SERVER_BUTTON_Click(Sender: TObject);
begin
  Serversocket1.Active := False;
  ServerSocket1.Close;
end;




function TKEYSERVER_FORM_.SendToAllClients( s : string) : boolean;
var
    i : integer;
begin
if ServerSocket1.Socket.ActiveConnections = 0 then
  begin
  //
  Exit ;
  end;
for i := 0 to (ServerSocket1.Socket.ActiveConnections - 1) do
  begin
  ServerSocket1.Socket.Connections[i].SendText(s);
  end;
end;



procedure TKEYSERVER_FORM_.ServerSocket1ClientDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
clients := clients - 1;
label2.Caption := IntToStr(clients) ;
end;



function StringToHexStr(const value: string): string;
begin
  SetLength(Result, Length(value) *2);
  if Length(value) > 0 then
    BinToHex(PChar(value), PChar(Result), Length(value));
end;



procedure TKEYSERVER_FORM_.sleepawhile;
begin
  sysutils.Sleep(1000);
end;




procedure TKEYSERVER_FORM_.Timer1Timer(Sender: TObject);
var
numa : integer;
begin
      Randomize;
  numa := RandomRange(+1000000000000000, +9999999999999999);
  MyString := IntToStr(numa);
  numa := numa+StrToInt(MyString);
  MyString  := IntToStr(numa+numa)+'F'+'x'+'/';
  RANDOMLY_GENERATED_CODE_TEXTBOX_.Text := StringToHexStr(MyString);
  try
  SendToAllClients(RANDOMLY_GENERATED_CODE_TEXTBOX_.Text);
  except
    on E : Exception do
     // ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;




procedure TKEYSERVER_FORM_.CHANGE_CODE_BUTTON_Click(Sender: TObject);
var
numa : integer;
begin
      Randomize;
  numa := RandomRange(+1000000000000000, +9999999999999999);
  MyString := IntToStr(numa);
  numa := numa+StrToInt(MyString);
  MyString  := IntToStr(numa+numa)+'F'+'x'+'/';
  RANDOMLY_GENERATED_CODE_TEXTBOX_.Text := StringToHexStr(MyString);
  try
  SendToAllClients(RANDOMLY_GENERATED_CODE_TEXTBOX_.Text);
  except
    on E : Exception do
     // ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;
end;





procedure TKEYSERVER_FORM_.MINIMISE_BUTTON_Click(Sender: TObject);
begin
  MinimizeToTray;
end;




procedure TKEYSERVER_FORM_.FormCreate(Sender: TObject);
var
  MenuItem: TMenuItem;
begin
  MenuItem := TMenuItem.Create(self);
  MenuItem.Caption := '&Restore';
  MenuItem.OnClick := RestoreClick;
  PopupMenu1.Items.Add(MenuItem);
  MenuItem := TMenuItem.Create(self);
  MenuItem.Caption := 'E&xit';
  MenuItem.OnClick := ExitClick;
  PopupMenu1.Items.Add(MenuItem);
  KEYSERVER_FORM_.OnDestroy := FormDestroy;
  CreateTrayIcon;
end;



procedure TKEYSERVER_FORM_.WndProc(var Msg : TMessage); // Handle TrayIcon Events
var
  p : TPoint;
begin
  case Msg.Msg of
    WM_USER + 1:       // This is our TrayIcon
    case Msg.lParam of
      WM_RBUTTONDOWN: begin  // User has RightClicked on TrayIcon
         GetCursorPos(p);    // Get Cursor Position
         PopupMenu1.Popup(p.x, p.y);  // Display Menu
      end;
      WM_LBUTTONDBLCLK: RestoreFromTray;  // User has DblClicked on TrayIcon
    end;
  end;
  inherited;  // Continue to do the usual WndProc
end;




procedure TKEYSERVER_FORM_.CreateTrayIcon;
begin
  IconData.cbSize := sizeof(IconData);
  IconData.Wnd := Handle;  // Handle to our Form
  IconData.uID := 100;
  IconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  IconData.uCallbackMessage := WM_USER + 1;  // Our Callback ID
  IconData.hIcon := Application.Icon.Handle;  // Use our application Icon
  StrPCopy(IconData.szTip, Application.Title);
end;




procedure TKEYSERVER_FORM_.MinimizeToTray;
begin
  Shell_NotifyIcon(NIM_ADD, @IconData);  // Add Tray Icon here
  KEYSERVER_FORM_.Hide;  // Hide our Form...
  ShowWindow(Application.Handle, SW_HIDE);  // ...and hide application from TaskBar.
end;




procedure TKEYSERVER_FORM_.RestoreFromTray;
begin
  Shell_NotifyIcon(NIM_DELETE, @IconData);  // Delete TrayIcon
  ShowWindow(Application.Handle, SW_SHOW);  // Show app on taskbar
  KEYSERVER_FORM_.Show;  // Show Form
  Application.BringToFront;
end;




procedure TKEYSERVER_FORM_.ExitClick(Sender: TObject);
begin
  Close;
end;




procedure TKEYSERVER_FORM_.RestoreClick(Sender: TObject);
begin
  RestoreFromTray;
end;




procedure TKEYSERVER_FORM_.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @IconData);
end;



procedure TKEYSERVER_FORM_.ServerSocket1ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
numa : integer;
begin
  INFOBOX_.Lines.Add('client connected');
  clients := clients + 1;
  label2.Caption := IntToStr(clients);
  Randomize;
  numa := RandomRange(+10000000000000, +99999999999999);
  MyString := IntToStr(numa);
  numa := numa+StrToInt(MyString);
  MyString  := IntToStr(numa+numa)+'F'+'x'+'/';
  RANDOMLY_GENERATED_CODE_TEXTBOX_.Text := StringToHexStr(MyString);
  try
  SendToAllClients(RANDOMLY_GENERATED_CODE_TEXTBOX_.Text);
  except
    on E : Exception do
     // ShowMessage(E.ClassName+' error raised, with message : '+E.Message);
  end;

end;

end.
