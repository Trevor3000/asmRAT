object Form2: TForm2
  Left = 811
  Top = 257
  Width = 514
  Height = 426
  Caption = 'Form2'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object edtPath: TEdit
    Left = 160
    Top = 8
    Width = 345
    Height = 21
    TabOrder = 0
  end
  object ListView1: TListView
    Left = 8
    Top = 32
    Width = 497
    Height = 361
    Columns = <
      item
        AutoSize = True
        Caption = 'Name'
      end
      item
        AutoSize = True
        Caption = 'Size'
        MaxWidth = 100
      end>
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListView1DblClick
  end
  object ComboBox1: TComboBoxEx
    Left = 3
    Top = 3
    Width = 150
    Height = 22
    ItemsEx = <>
    Style = csExDropDownList
    ItemHeight = 16
    TabOrder = 2
    OnChange = ComboBox1Change
    DropDownCount = 8
  end
end
