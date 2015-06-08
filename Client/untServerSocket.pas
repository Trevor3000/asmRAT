unit untServerSocket;

interface
uses
  WinSock, SysUtils, classes, untClientController;
const
  ERROR_LISTEN          = 04;
  ERROR_ACCEPT          = 05;
  ERROR_BIND            = 08;
  SUCCESS_ACCEPT        = 11;

var
  WSA         :TWSAData;

type
  TMyThread = class(TThread)
  private
  protected
    procedure Execute; override;
    procedure AcceptNew(iSock: Integer);
  public
    Sock        :Integer;
    ListenPort  :Integer;
    constructor Create(CreateSuspended: Boolean);
    procedure Listen;
    procedure CleanUp;
  end;
  
implementation
constructor TMyThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  ListenPort := 0;
  FreeOnTerminate := True;
end;

procedure TMyThread.Execute;
begin
  Listen;
  CleanUp;
end;

procedure TMyThread.AcceptNew(iSock: Integer);
var
  ClientThread:TClientThread;
Begin
  ClientThread := TClientThread.Create(True);
  ClientThread.mySocket := iSock;
  ClientThread.Resume;
End;

procedure TMyThread.CleanUp;
begin

end;

procedure TMyThread.Listen;
var
  Addr        :TSockAddrIn;
  Remote      :TSockAddr;
  Len         :Integer;
  TempSock    :TSocket;
Begin
  Sock := Socket(AF_INET, SOCK_STREAM, 0);
  Addr.sin_family := AF_INET;
  Addr.sin_port := hTons(ListenPort);
  Addr.sin_addr.S_addr := INADDR_ANY;
  If (Bind(Sock, Addr, SizeOf(Addr)) <> 0) Then
  Begin
    CleanUp;
    Exit;
  End;
  If (Winsock.listen(Sock, SOMAXCONN) <> 0) Then
  Begin
    CleanUp;
    Exit;
  End;
  Len := SizeOf(Remote);
  Repeat
    TempSock := Accept(Sock, @Remote, @Len);
    If (TempSock = INVALID_SOCKET) or (Sock = INVALID_SOCKET) Then
    Begin
      CleanUp;
      Exit;
    End;
    AcceptNew(TempSock);
  Until False;
End;

initialization
  WSAStartUp($0101, WSA);
  
end.
