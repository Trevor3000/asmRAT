unit untClientController;

interface
uses
  SysUtils,
  SyncObjs,
  Menus,
  winsock,
  Windows,
  ComCtrls,
  untFilemanager,
  Classes;

type
   TGUI = class
    lstItem               :TListItem;
    frmFilemanager        :TForm2;
   end;

type
  TClientThread = class(TThread)
  private
    mRecvBuffer           :array[0..4095] of Char;
    procedure Cleanup;
    procedure GetPacket;
    procedure Termination(Sender: TObject);
    procedure ParsePacket(mBuff:Pointer; dwLen:Integer; bCMD:Byte);
    procedure ProcessGUI;
  protected
    procedure Execute; override;
  public
    GUI :TGUI;
    mySocket:Integer;
    fBuff:Pointer;
    currOp:Byte;
    constructor Create(CreateSuspended: Boolean);
  end;
  
implementation

uses
  untMain;
  
function RecvBuffer(hSocket: Integer; lpszBuffer: PChar; iBufferLen: Integer): Integer; stdcall;
var
  lpTempBuffer: PChar;
begin
  Result := 0;
  FillChar(lpszBuffer^, iBufferLen, 0);
  lpTempBuffer := lpszBuffer;
  while (iBufferLen > 0) do
  begin
    Result := recv(hSocket, lpTempBuffer^, iBufferLen, 0);
    if (Result = SOCKET_ERROR) or (Result = 0) then
    begin
      Result := 0;
      Break;
    end;
    lpTempBuffer := PChar(DWORD(lpTempBuffer) + DWORD(Result));
    iBufferLen := iBufferLen - Result;
  end;
end;

Function Explode(sDelimiter: String; sSource: String): TStringList;
Var
  c: Word;
Begin
  Result := TStringList.Create;
  C := 0;
  While sSource <> '' Do
  Begin
    If Pos(sDelimiter, sSource) > 0 Then
    Begin
      Result.Add(Copy(sSource, 1, Pos(sDelimiter, sSource) - 1 ));
      Delete(sSource, 1, Length(Result[c]) + Length(sDelimiter));
    End
    Else
    Begin
      Result.Add(sSource);
      sSource := ''
    End;
    Inc(c);
  End;
End;

procedure TClientThread.ProcessGUI;
var
  lstTokens:TStringList;
  i:integer;
  plstItem:TListItem;
begin
  case currOp of
    0:
      begin
        GUI.lstItem := Form1.ListView1.Items.Add;
        GUI.lstItem.Caption := 'localhost';
        GUI.lstItem.SubItems.Add(PChar(fBuff));
        GUI.lstItem.SubItems.Objects[0] := Self;
      end;
    2:
      begin
        lstTokens := Explode('|' , PChar(fBuff));
        if Assigned(GUI.frmFilemanager) then
        begin
          GUI.frmFilemanager.ComboBox1.Clear;
          for i := 0 to lstTokens.Count -1 do
          begin
            GUI.frmFilemanager.ComboBox1.AddItem(lstTokens[i],nil);
          end;
        end;
      end;
    3:
      begin
        if Assigned(GUI.frmFilemanager) then
        begin
          GUI.frmFilemanager.ListView1.Clear;
          GUI.frmFilemanager.ListView1.Items.BeginUpdate;
        end;
      end;
    5:
      begin
        if Assigned(GUI.frmFilemanager) then
        begin
          lstTokens := Explode('|' , PChar(fBuff));
          for i := 0 to lstTokens.Count -1 do
          begin
            plstItem := GUI.frmFilemanager.ListView1.Items.Add;
            plstItem.Caption := lstTokens[i];
          end;
        end;
      end;
    6:
      begin
        if Assigned(GUI.frmFilemanager) then
        begin
          GUI.frmFilemanager.ListView1.Items.EndUpdate;
        end;
      end;
  end;
end;

procedure TClientThread.ParsePacket(mBuff:Pointer; dwLen:Integer; bCMD:Byte);
begin
  fBuff := mBuff;
  currOp := bCMD;
  Synchronize(ProcessGUI);
end;

procedure TClientThread.GetPacket;
var
  iResult: Integer;
  dwBufferLen: Cardinal;
  bCommand:Byte;
begin
  while True do
  begin
    iResult := RecvBuffer(mySocket, @dwBufferLen, SizeOf(DWORD));
    if (iResult = 0) then
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
    ZeroMemory(@mRecvBuffer[0], 4096);
    iResult := RecvBuffer(mySocket, @mRecvBuffer[0], dwBufferLen - 1);
    if (iResult = 0) or (iResult = SOCKET_ERROR) then
    begin
      Break;
    end;
    //Parse Packet
    ParsePacket(@mRecvBuffer[0], dwBufferLen - 1, bCommand);
  end;
end;

procedure TClientThread.Execute;
begin
  GetPacket;
end;

procedure TClientThread.Cleanup;
begin
  if Assigned(GUI.lstItem) then begin
    GUI.lstItem.Delete;
  end;
end;

procedure TClientThread.Termination(Sender: TObject);
begin
  Synchronize(CleanUp);
end;

constructor TClientThread.Create(CreateSuspended: Boolean);
begin
  inherited;
  GUI := TGUI.Create;
  mySocket := 0;
  FreeOnTerminate := True;
  OnTerminate := Termination;
end;

end.
