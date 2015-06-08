unit untSHDeleteFile;

interface
uses
  windows,
  untUtils;

procedure pDeleteFile(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
procedure pDeleteFile_END();

implementation

procedure pDeleteFile(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
var
  strDeleteFileA:Array[0..11] of Char;
  strFile:Array[0..8] of Char;
  pDeleteFileA:function(lpFileName: PChar): BOOL; stdcall;
begin
  strFile[0] := 'C';
  strFile[1] := ':';
  strFile[2] := '\';
  strFile[3] := 'a';
  strFile[4] := '.';
  strFile[5] := 't';
  strFile[6] := 'x';
  strFile[7] := 't';
  strFile[8] := #0;

  strDeleteFileA[0] := 'D';
  strDeleteFileA[1] := 'e';
  strDeleteFileA[2] := 'l';
  strDeleteFileA[3] := 'e';
  strDeleteFileA[4] := 't';
  strDeleteFileA[5] := 'e';
  strDeleteFileA[6] := 'F';
  strDeleteFileA[7] := 'i';
  strDeleteFileA[8] := 'l';
  strDeleteFileA[9] := 'e';
  strDeleteFileA[10] := 'A';
  strDeleteFileA[11] := #0;
  @pDeleteFileA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strDeleteFileA[0]);
  pDeleteFileA(@strFile[0]);
end;
procedure pDeleteFile_END();begin end;
end.
