object VisOpenERPLookupName: TVisOpenERPLookupName
  Left = 528
  Top = 354
  Width = 416
  Height = 302
  Caption = 'Recherche'
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 408
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      408
      37)
    object Label2: TLabel
      Left = 263
      Top = 10
      Width = 56
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Nb r'#233'sultats'
    end
    object EdSearch: TEdit
      Left = 8
      Top = 6
      Width = 176
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnKeyDown = EdSearchKeyDown
    end
    object cbLimit: TComboBox
      Left = 323
      Top = 6
      Width = 81
      Height = 21
      Anchors = [akTop, akRight]
      ItemHeight = 13
      TabOrder = 1
      Text = 'Illimit'#233
      Items.Strings = (
        ''
        '50'
        '100'
        '200')
    end
    object Button1: TButton
      Left = 187
      Top = 4
      Width = 65
      Height = 25
      Action = ActSearch
      Anchors = [akTop, akRight]
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 233
    Width = 408
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      408
      41)
    object EdCount: TLabel
      Left = 4
      Top = 12
      Width = 41
      Height = 13
      Caption = 'EdCount'
    end
    object BitBtn1: TBitBtn
      Left = 249
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      NumGlyphs = 2
    end
    object BitBtn2: TBitBtn
      Left = 330
      Top = 8
      Width = 74
      Height = 25
      Anchors = [akTop, akRight]
      TabOrder = 1
      Kind = bkCancel
    end
  end
  object gridlookup: TdxDBGridSermo
    Left = 0
    Top = 37
    Width = 408
    Height = 196
    Bands = <
      item
      end>
    DefaultLayout = True
    HeaderPanelRowCount = 1
    KeyField = 'id'
    SummaryGroups = <>
    SummarySeparator = ', '
    Align = alClient
    TabOrder = 1
    OnDblClick = gridlookupDblClick
    OnKeyDown = gridlookupKeyDown
    CustomizingRowCount = 25
    DataSource = srcLookupCDS
    Filter.Criteria = {00000000}
    LookAndFeel = lfFlat
    OptionsBehavior = [edgoAutoSort, edgoDragScroll, edgoMultiSort, edgoTabs, edgoTabThrough, edgoVertThrough]
    OptionsDB = [edgoCancelOnExit, edgoCanNavigation, edgoConfirmDelete, edgoLoadAllRecords, edgoUseBookmarks]
    OptionsView = [edgoAutoWidth, edgoBandHeaderWidth, edgoIndicator, edgoUseBitmap]
    SimpleCustomizeBox = True
    OnCustomDrawCell = gridlookupCustomDrawCell
    XLSDialog = True
    StandardDraw = False
    OnCancelling = False
    object gridlookupid: TdxDBGridMaskColumn
      MinWidth = 28
      Sizing = False
      Sorted = csUp
      Width = 28
      BandIndex = 0
      RowIndex = 0
      FieldName = 'id'
    end
    object gridlookupname: TdxDBGridMaskColumn
      Width = 495
      BandIndex = 0
      RowIndex = 0
      FieldName = 'name'
    end
  end
  object srcLookupCDS: TDataSource
    DataSet = LookupCDS
    Left = 116
    Top = 148
  end
  object LookupCDS: TClientDataSet
    Aggregates = <>
    PacketRecords = 10
    Params = <>
    Left = 116
    Top = 96
    object LookupCDSid: TIntegerField
      DisplayLabel = 'Id'
      FieldName = 'id'
    end
    object LookupCDSname: TStringField
      DisplayLabel = 'Name'
      FieldName = 'name'
      Size = 255
    end
  end
  object ActionList1: TActionList
    Left = 376
    Top = 16
    object ActSearch: TAction
      Caption = 'Rechercher'
      OnExecute = ActSearchExecute
      OnUpdate = ActSearchUpdate
    end
  end
end
