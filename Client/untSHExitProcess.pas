unit untSHExitProcess;

interface
uses
  windows,
  untUtils;

procedure pExitProcess(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
procedure pExitProcess_END();

implementation

procedure pExitProcess(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
var
  strExitProcess:Array[0..11] of Char;
  xExitProcess:procedure(uExitCode: UINT); stdcall;
begin
  strExitProcess[0] := 'E';
  strExitProcess[1] := 'x';
  strExitProcess[2] := 'i';
  strExitProcess[3] := 't';
  strExitProcess[4] := 'P';
  strExitProcess[5] := 'r';
  strExitProcess[6] := 'o';
  strExitProcess[7] := 'c';
  strExitProcess[8] := 'e';
  strExitProcess[9] := 's';
  strExitProcess[10] := 's';
  strExitProcess[11] := #0;
  @xExitProcess := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strExitProcess[0]);
  xExitProcess(0);
end;
procedure pExitProcess_END();begin end;
end.
