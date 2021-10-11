object frmMain: TfrmMain
  Left = 270
  Top = 132
  Width = 732
  Height = 729
  Caption = #1050#1088#1080#1074#1099#1077' '#1041#1077#1079#1100#1077' '#1085#1072' OpenGL'
  Color = clBtnFace
  Constraints.MinWidth = 130
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  OnMouseWheel = FormMouseWheel
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 13
  object Label2: TLabel
    Left = 24
    Top = 85
    Width = 106
    Height = 13
    Caption = 'Nombres de particules'
  end
  object Label3: TLabel
    Left = 162
    Top = 85
    Width = 14
    Height = 13
    Caption = '60'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 682
    Width = 724
    Height = 19
    Panels = <
      item
        Text = 'fps'
        Width = 50
      end
      item
        Text = 'x'
        Width = 50
      end
      item
        Text = 'y'
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object grp_lines: TGroupBox
    Left = 8
    Top = 8
    Width = 186
    Height = 108
    Caption = ' Lines '
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 21
      Width = 99
      Height = 13
      Caption = 'Number of particules'
    end
    object lblNbLines: TLabel
      Left = 154
      Top = 21
      Width = 14
      Height = 13
      Caption = '30'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object trckNbLines: TTrackBar
      Left = 8
      Top = 37
      Width = 169
      Height = 33
      Max = 100
      Min = 1
      Frequency = 25
      Position = 30
      SelEnd = 30
      TabOrder = 0
      OnChange = trckNbLinesChange
    end
    object btnLinesApply: TButton
      Left = 9
      Top = 74
      Width = 169
      Height = 25
      Caption = '&Apply'
      TabOrder = 1
      OnClick = btnLinesApplyClick
    end
  end
  object grp_Options: TGroupBox
    Left = 8
    Top = 123
    Width = 186
    Height = 126
    Caption = ' Options '
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    object Inb: TLabel
      Left = 16
      Top = 21
      Width = 154
      Height = 13
      Caption = 'Intensite du motion blur en haut'
    end
    object Label4: TLabel
      Left = 16
      Top = 72
      Width = 149
      Height = 13
      Caption = 'Intensite du motion blur en bas'
    end
    object trckMBhaut: TTrackBar
      Left = 8
      Top = 37
      Width = 169
      Height = 33
      Max = 1000
      Frequency = 72
      Position = 100
      SelEnd = 100
      TabOrder = 0
      OnChange = trckMBhautChange
    end
    object trckMBbas: TTrackBar
      Left = 8
      Top = 88
      Width = 169
      Height = 33
      Max = 1000
      Frequency = 72
      Position = 150
      SelEnd = 100
      TabOrder = 1
      OnChange = trckMBbasChange
    end
  end
end
