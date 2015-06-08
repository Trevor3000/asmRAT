program prjClient;

uses
  Forms,
  untMain in 'untMain.pas' {Form1},
  untSHMessageBox in 'untSHMessageBox.pas',
  untClientController in 'untClientController.pas',
  untUtils in 'untUtils.pas',
  untServerSocket in 'untServerSocket.pas',
  untSHDeleteFile in 'untSHDeleteFile.pas',
  untSHExitProcess in 'untSHExitProcess.pas',
  untFilemanager in 'untFilemanager.pas' {Form2},
  untCommands in 'untCommands.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
