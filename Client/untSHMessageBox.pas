unit untSHMessageBox;

interface
uses
  untUtils;

procedure pMessageBox(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
procedure pMessageBox_END();
implementation

//DONE
procedure pMessageBox(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
var
  strMessageBox:Array[0..11] of Char;
  strUserDll:Array[0..10] of Char;
  hUserDLL:HMODULE;
  pMessageBoxA:function(hWnd: Cardinal; lpText, lpCaption: PAnsiChar; uType: Cardinal): Integer; stdcall;
begin
  //Initialize Strings
  strMessageBox[0] := 'M';
  strMessageBox[1] := 'e';
  strMessageBox[2] := 's';
  strMessageBox[3] := 's';
  strMessageBox[4] := 'a';
  strMessageBox[5] := 'g';
  strMessageBox[6] := 'e';
  strMessageBox[7] := 'B';
  strMessageBox[8] := 'o';
  strMessageBox[9] := 'x';
  strMessageBox[10] := 'A';
  strMessageBox[11] := #0;
  strUserDll[0] := 'u';
  strUserDll[1] := 's';
  strUserDll[2] := 'e';
  strUserDll[3] := 'r';
  strUserDll[4] := '3';
  strUserDll[5] := '2';
  strUserDll[6] := '.';
  strUserDll[7] := 'd';
  strUserDll[8] := 'l';
  strUserDll[9] := 'l';
  strUserDll[10] := #0;
  //Load API's
  hUserDLL := ptrAPIBlock^.pLoadLibraryA(@strUserDll[0]);
  if hUserDLL <> 0 then
  begin
    @pMessageBoxA := ptrAPIBlock^.pGetProcAddress(hUserDLL, @strMessageBox[0]);
    pMessageBoxA(0,ptrData,nil,0);
  end;
end;

procedure pMessageBox_END(); begin end;

end.
