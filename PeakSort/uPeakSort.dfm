object Form1: TForm1
  Left = 269
  Top = 62
  Width = 772
  Height = 602
  Caption = 'PeakSort'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020000000000000A80800001600000028000000200000004000
    0000010008000000000080040000000000000000000000010000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C000C0DC
    C000F0CAA600CCFFFF0099FFFF0066FFFF0033FFFF00FFCCFF00CCCCFF0099CC
    FF0066CCFF0033CCFF0000CCFF00FF99FF00CC99FF009999FF006699FF003399
    FF000099FF00FF66FF00CC66FF009966FF006666FF003366FF000066FF00FF33
    FF00CC33FF009933FF006633FF003333FF000033FF00CC00FF009900FF006600
    FF003300FF00FFFFCC00CCFFCC0099FFCC0066FFCC0066FFCC0033FFCC0000FF
    CC00FFCCCC00CCCCCC0099CCCC0066CCCC0033CCCC0000CCCC00FF99CC00CC99
    CC009999CC006699CC003399CC000099CC00FF66CC00CC66CC009966CC006666
    CC003366CC000066CC00FF33CC00CC33CC009933CC006633CC003333CC000033
    CC00FF00CC00CC00CC009900CC006600CC003300CC000000CC00FFFF9900CCFF
    990099FF990066FF990033FF990000FF9900FFCC9900CCCC990099CC990066CC
    990033CC990000CC9900FF999900CC9999009999990066999900339999000099
    9900FF669900CC66990099669900666699003366990000669900FF339900CC33
    990099339900663399003333990000339900FF009900CC009900990099006600
    99003300990000009900FFFF6600CCFF660099FF660066FF660033FF660000FF
    6600FFCC6600CCCC660099CC660066CC660033CC660000CC6600FF996600CC99
    660099996600669966003399660000996600FF666600CC666600996666006666
    66003366660000666600FF336600CC3366009933660066336600333366000033
    6600FF006600CC00660099006600660066003300660000006600FFFF3300CCFF
    330099FF330066FF330033FF330000FF3300FFCC3300CCCC330099CC330066CC
    330033CC330000CC3300FF993300CC9933009999330066993300339933000099
    3300FF663300CC66330099663300666633003366330000663300FF333300CC33
    330099333300663333003333330000333300FF003300CC003300990033006600
    33003300330000003300CCFF000099FF000066FF000033FF0000FFCC0000CCCC
    000099CC000066CC000033CC000000CC0000FF990000CC990000999900006699
    00003399000000990000FF660000CC6600009966000066660000006600003366
    0000FF330000CC33000099330000663300003333000000330000CC0000009900
    000066000000330000000000DD000000BB000000AA0000008800000077000000
    5500000044000000220000DD000000BB000000AA000000880000007700000055
    00000044000000220000DDDDDD00555555007777770077777700444444002222
    22001111110077000000550000004400000022000000F0FBFF00A4A0A0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    00000000000000000000000000000000000000000000000000000000000000CB
    CBCBCBCBCBCBCBCBC5CB00F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F90000CB
    CBCBCBCBCBCBCBCBCBC500F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F90000CB
    CBCBCBCBCBCBCBCBCBC5D3E0F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F90000CB
    CBCBCBCBCBCBCBCBCBCBC500F9F9F9DEDF96DBF9F9F9F9F9F9F9F9F9F90000CB
    CBCBCBCBCBCBCBCBCBCBC5CC00F9E2F4CCCC004E72000000DFF9F9F9F90000A3
    CBCBCBCBCBCBCBCBCBCBCBC5CCDACCC5C5C5C5F5D4C5C5C5D4DEF9F9F900002A
    4FD1D1CBCBCBCBCBCBCBCBCBC5C5C5CBCBCBCBC5C5CBD2C5D3004EF9F90000A3
    2AA3A3CBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBC5D500D5C5D5DEF90000CB
    D12A2ACBD1CBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBCBC5CBA64F00F90000FF
    D1A3FFA3A3A3CBCBCBCBCBCBCBCBC5CBC5C5CBCBCBD1CBCB0007D54EF9000079
    FFCBCB55557FD1CBCBCBCBCBCBCD00C5CBD9C5D17F55552AFFCDBAF9F9000000
    79FFA37F7979CBCBCBCBCBCBCBC5CD00BAE0F29DFF4F4F73D5E2F9F9F90000F9
    00A4FF557F5579D1CBCBCBCBC5D3F4F3FBFBDA2AF50000E2DEF9F9F9F90000F9
    F900D44F2A7931A3D1CBCBCBCBC5CDCDE2E2D24FE2F9F9F9F9F9F9F9F90000F9
    F9F9DF00C64F792A79D1CBCBCBCB0000D9D9FFA4E2F9F9F9F9F9F9F9F90000F9
    F9F9F9F996F5EFACA9C5C5CBC5CBCBCBC5BFAB00F9F9F9F9F9F9F9F9F90000F9
    F9F9F9F9F9F90000F5CD00C500FFFFC5C50000F9F9F9F9F9F9F9F9F9F90000F9
    F9F9F9DDE2009D4FE2D4C500E2FFFFF400EDCEDBF9F9F9F9F9F9F9F9F90000F9
    F9F9F9DF00E2F1D5C6C500B45CFFFF00EBFFD5DFF9F9F9F9F9F9F9F9F90000F9
    F9F9F9F9F9F9F9F9DDF900B2EDFFFFB35D31AC00F9F9F9F9F9F9F9F9F90000F9
    F9F9F9E2000000E2BAE2F087F7FFFFED5DFFEDB20000000000E0F9F9F90000F9
    F90000F5DA8181AB81815CF7FFFFFFF000FFFF32315C8181ABF500F9F90000F9
    00F032FFFFFFFFFFFFFFFFFFFFFF2A00DFF52AFFFFFFFFFFFFFFF5E1F90000DC
    00FFFFFF5681A556FFFFFFFFFF2A00F9F9DE00000000000056FFFF00F90000DD
    A5FFFF00E2DFDFBA00CEACACF500DBF9F9F9F9F9F9F9F9DC00EAFFA5DD0000DD
    81FFAC00F9F9F9F9F9DBDD4EF9F9F9F9F9F9F9F9F9F9F9F9F9E2EB4FDE0000DD
    CEFFEDE2F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9DF4FF5F90000F9
    0050FF00F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F996F5E1F90000F9
    F90000F5E0F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9BA00BAF9F90000F9
    F9F9F94EDBF9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9DCDBF9F9F9000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 112
    Width = 151
    Height = 13
    Caption = 'Berekende binnenwaterstanden'
  end
  object Label2: TLabel
    Left = 32
    Top = 200
    Width = 109
    Height = 13
    Caption = 'Berekende toestroming'
  end
  object Buitenwaterstanden: TLabel
    Left = 32
    Top = 288
    Width = 94
    Height = 13
    Caption = 'Buitenwaterstanden'
  end
  object Label3: TLabel
    Left = 32
    Top = 24
    Width = 147
    Height = 13
    Caption = 'Gewenste binnenwaterstanden'
  end
  object EditBerekendeBinnenwaterstanden: TEdit
    Left = 32
    Top = 128
    Width = 593
    Height = 21
    Enabled = False
    TabOrder = 0
    Text = 'DSmodel201.out'
  end
  object ButtonSelectBerekendeGrondwaterstanden: TButton
    Left = 552
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Select'
    TabOrder = 1
    OnClick = ButtonSelectBerekendeGrondwaterstandenClick
  end
  object EditBerekendeToestroming: TEdit
    Left = 32
    Top = 216
    Width = 593
    Height = 21
    Enabled = False
    TabOrder = 2
    Text = 'DSmodel202.out'
  end
  object ButtonBerekendeToestroming: TButton
    Left = 552
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Select'
    TabOrder = 3
    OnClick = ButtonBerekendeToestromingClick
  end
  object EditBuitenwaterstanden: TEdit
    Left = 32
    Top = 304
    Width = 593
    Height = 21
    Enabled = False
    TabOrder = 4
    Text = 'xDep201_0.tb0'
  end
  object ButtonSelectBuitenwaterstanden: TButton
    Left = 552
    Top = 336
    Width = 75
    Height = 25
    Caption = 'Select'
    TabOrder = 5
    OnClick = ButtonSelectBuitenwaterstandenClick
  end
  object ButtonWritePeaks: TButton
    Left = 664
    Top = 512
    Width = 75
    Height = 25
    Caption = 'Go'
    TabOrder = 6
    OnClick = ButtonWritePeaksClick
  end
  object EditGewensteBinnenwaterstand: TEdit
    Left = 32
    Top = 40
    Width = 593
    Height = 21
    Enabled = False
    TabOrder = 7
    Text = 'xDep202_4.tb1'
  end
  object ButtonSelectBinnenwaterstanden: TButton
    Left = 552
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Select'
    TabOrder = 8
    OnClick = ButtonSelectBinnenwaterstandenClick
  end
  object PanelRefIsBinnenwaterstand: TPanel
    Left = 24
    Top = 488
    Width = 473
    Height = 49
    TabOrder = 9
    object Label4: TLabel
      Left = 9
      Top = 20
      Width = 304
      Height = 13
      Caption = 'Piek als binnenwaterst. XXX cm boven gewenste binnenwaterst.'
    end
    object SpinEditCMbovenGem: TSpinEdit
      Left = 336
      Top = 15
      Width = 121
      Height = 22
      Hint = 
        'Er is sprake v.e. piek als de binnenwaterstand ... cm boven de g' +
        'ewenste binnenwaterstand is'
      Increment = 5
      MaxValue = 1000
      MinValue = 0
      TabOrder = 0
      Value = 0
    end
  end
  object PanelRefIsFixed: TPanel
    Left = 24
    Top = 424
    Width = 473
    Height = 41
    TabOrder = 10
    Visible = False
    object Label5: TLabel
      Left = 8
      Top = 16
      Width = 103
      Height = 13
      Caption = 'Ref . niveau (m+NAP)'
    end
    object SpinFloatEditFixedLevel: TSpinFloatEdit
      Left = 344
      Top = 8
      Width = 121
      Height = 22
      Decimals = 2
      Increment = 0.01
      TabOrder = 0
    end
  end
  object CheckBoxFixedRefLevel: TCheckBox
    Left = 32
    Top = 360
    Width = 233
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Piek t.o.v. vast opgegeven ref. niveau'
    TabOrder = 11
    OnClick = CheckBoxFixedRefLevelClick
  end
  object OpenDialogSelectBerekendeGrondwaterstanden: TOpenDialog
    DefaultExt = '*.out'
    FileName = 'DSmodel201.out'
    Filter = 'DSmodel201.out|DSmodel201.out'
    Title = 'Select DSmodel201.out'
    Left = 544
    Top = 128
  end
  object DoubleMatrixBinnenwaterstanden: TDoubleMatrix
    Left = 512
    Top = 128
  end
  object OpenDialogBerekendeToestroming: TOpenDialog
    DefaultExt = '*.out'
    FileName = 'DSmodel202.out'
    Filter = 'DSmodel202.out|DSmodel202.out'
    Title = 'Select DSmodel202.out'
    Left = 544
    Top = 216
  end
  object DoubleMatrixBerekendeToestroming: TDoubleMatrix
    Left = 512
    Top = 216
  end
  object OpenDialogBuitenwaterstanden: TOpenDialog
    DefaultExt = '*.tb0'
    FileName = 'xDep201_0.tb0'
    Filter = 'xDep201_0.tb0|xDep201_0.tb0'
    Title = 'Select xDep201_0.tb0'
    Left = 544
    Top = 304
  end
  object xyTableBuitenwaterstanden: TxyTable
    Left = 504
    Top = 304
  end
  object DoubleMatrixResult: TDoubleMatrix
    Left = 648
    Top = 8
  end
  object SaveDialogPeaks: TSaveDialog
    DefaultExt = '*.out'
    FileName = 'PeakSort.out'
    Filter = '*.out|*.out'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Specify output file'
    Left = 608
    Top = 8
  end
  object LargeRealArrayMaxBWSincident: TLargeRealArray
    Left = 552
    Top = 8
  end
  object OpenDialogGewensteBinnenwaterstanden: TOpenDialog
    DefaultExt = '*.tb1'
    FileName = 'xDep202_4.tb1'
    Filter = 'xDep202_4.tb1|xDep202_4.tb1'
    Title = 'Select xDep202_4.tb1'
    Left = 552
    Top = 40
  end
  object xyTableGewensteBinnenwaterstanden: TxyTable
    Left = 496
    Top = 32
  end
end
