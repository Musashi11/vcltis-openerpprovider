object OpenERPProviderEditor: TOpenERPProviderEditor
  Left = 637
  Top = 175
  Width = 754
  Height = 521
  Caption = 'OpenERPProviderEditor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object panHaut: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 77
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 52
      Width = 65
      Height = 13
      Caption = 'Search model'
    end
    object Label2: TLabel
      Left = 6
      Top = 27
      Width = 29
      Height = 13
      Caption = 'Model'
    end
    object Label3: TLabel
      Left = 208
      Top = 27
      Width = 42
      Height = 13
      Caption = 'Fields list'
    end
    object Label5: TLabel
      Left = 5
      Top = 3
      Width = 31
      Height = 13
      Caption = 'Server'
    end
    object Label4: TLabel
      Left = 336
      Top = 52
      Width = 56
      Height = 13
      Caption = 'Search field'
    end
    object edSearchModel: TEdit
      Left = 80
      Top = 48
      Width = 101
      Height = 21
      TabOrder = 4
      OnKeyPress = edSearchModelKeyPress
    end
    object edModel: TEdit
      Left = 40
      Top = 24
      Width = 149
      Height = 21
      TabOrder = 1
    end
    object edFields: TEdit
      Left = 256
      Top = 24
      Width = 321
      Height = 21
      TabOrder = 2
    end
    object EdOpenERPProxyURL: TEdit
      Left = 40
      Top = 0
      Width = 321
      Height = 21
      TabOrder = 3
      OnKeyPress = EdOpenERPProxyURLKeyPress
    end
    object edSearchField: TEdit
      Left = 396
      Top = 48
      Width = 101
      Height = 21
      TabOrder = 0
      OnKeyPress = edSearchFieldKeyPress
    end
  end
  object gridmodels: TdxDBGridSermo
    Left = 0
    Top = 77
    Width = 334
    Height = 326
    Bands = <
      item
      end>
    DefaultLayout = True
    HeaderPanelRowCount = 1
    KeyField = 'id'
    SummaryGroups = <>
    SummarySeparator = ', '
    Align = alLeft
    TabOrder = 1
    CustomizingRowCount = 25
    DataSource = srcmodels
    Filter.Criteria = {00000000}
    LookAndFeel = lfFlat
    OptionsBehavior = [edgoAutoSort, edgoDragScroll, edgoEditing, edgoEnterShowEditor, edgoMultiSort, edgoTabs, edgoTabThrough, edgoVertThrough]
    OptionsDB = [edgoCanAppend, edgoCancelOnExit, edgoCanDelete, edgoCanInsert, edgoCanNavigation, edgoConfirmDelete, edgoLoadAllRecords, edgoUseBookmarks]
    OptionsView = [edgoBandHeaderWidth, edgoIndicator, edgoUseBitmap]
    SimpleCustomizeBox = True
    OnChangeNodeEx = gridmodelsChangeNodeEx
    XLSDialog = True
    StandardDraw = False
    OnCancelling = False
    object gridmodelsid: TdxDBGridMaskColumn
      Visible = False
      Width = 133
      BandIndex = 0
      RowIndex = 0
      FieldName = 'id'
    end
    object gridmodelsname: TdxDBGridMaskColumn
      Sorted = csUp
      Width = 173
      BandIndex = 0
      RowIndex = 0
      FieldName = 'name'
    end
    object gridmodelsmodel: TdxDBGridMaskColumn
      Width = 128
      BandIndex = 0
      RowIndex = 0
      FieldName = 'model'
    end
    object gridmodelsinfo: TdxDBGridMaskColumn
      Width = 100
      BandIndex = 0
      RowIndex = 0
      FieldName = 'info'
    end
    object gridmodelsfield_id: TdxDBGridMaskColumn
      Visible = False
      BandIndex = 0
      RowIndex = 0
      FieldName = 'field_id'
    end
    object gridmodelsmodules: TdxDBGridMaskColumn
      Visible = False
      BandIndex = 0
      RowIndex = 0
      FieldName = 'modules'
    end
  end
  object gridfields: TdxDBGridSermo
    Left = 337
    Top = 77
    Width = 409
    Height = 326
    Bands = <
      item
      end>
    DefaultLayout = True
    HeaderPanelRowCount = 1
    KeyField = 'name'
    SummaryGroups = <>
    SummarySeparator = ', '
    Align = alClient
    TabOrder = 2
    OnClick = gridfieldsClick
    CustomizingRowCount = 25
    DataSource = srcfields
    Filter.Criteria = {00000000}
    LookAndFeel = lfFlat
    OptionsBehavior = [edgoAutoSort, edgoDragScroll, edgoEditing, edgoEnterShowEditor, edgoMultiSelect, edgoMultiSort, edgoTabs, edgoTabThrough, edgoVertThrough]
    OptionsDB = [edgoCanAppend, edgoCancelOnExit, edgoCanDelete, edgoCanInsert, edgoCanNavigation, edgoConfirmDelete, edgoLoadAllRecords, edgoUseBookmarks]
    OptionsView = [edgoBandHeaderWidth, edgoIndicator, edgoUseBitmap]
    SimpleCustomizeBox = True
    OnCustomDrawCell = gridfieldsCustomDrawCell
    OnSelectedCountChange = gridfieldsSelectedCountChange
    XLSDialog = True
    StandardDraw = False
    OnCancelling = False
    object gridfieldsname: TdxDBGridMaskColumn
      Caption = 'Nom champs'
      Width = 133
      BandIndex = 0
      RowIndex = 0
      FieldName = 'name'
    end
    object gridfieldsstring: TdxDBGridMaskColumn
      Width = 108
      BandIndex = 0
      RowIndex = 0
      FieldName = 'string'
    end
    object gridfieldstype: TdxDBGridMaskColumn
      Width = 78
      BandIndex = 0
      RowIndex = 0
      FieldName = 'type'
    end
    object gridfieldssize: TdxDBGridMaskColumn
      Width = 41
      BandIndex = 0
      RowIndex = 0
      FieldName = 'size'
    end
    object gridfieldshelp: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'help'
    end
    object gridfieldsreadonly: TdxDBGridCheckColumn
      Visible = False
      Width = 63
      BandIndex = 0
      RowIndex = 0
      FieldName = 'readonly'
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object gridfieldsselect: TdxDBGridCheckColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'select'
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object gridfieldsselectable: TdxDBGridCheckColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'selectable'
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object gridfieldsdomain: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'domain'
    end
    object gridfieldsrelation: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'relation'
    end
    object gridfieldscontext: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'context'
    end
    object gridfieldsfunction: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'function'
    end
    object gridfieldsfunc_method: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'func_method'
    end
    object gridfieldsfnct_inv_arg: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'fnct_inv_arg'
    end
    object gridfieldsfnct_search: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'fnct_search'
    end
    object gridfieldsstore: TdxDBGridCheckColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'store'
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
    object gridfieldsfunc_obj: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'func_obj'
    end
    object gridfieldsfnct_inv: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'fnct_inv'
    end
    object gridfieldsdigits: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'digits'
    end
    object gridfieldsselection: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'selection'
    end
    object gridfieldsrelated_columns: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'related_columns'
    end
    object gridfieldsthird_table: TdxDBGridMaskColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'third_table'
    end
    object gridfieldsrequired: TdxDBGridCheckColumn
      Visible = False
      Width = 92
      BandIndex = 0
      RowIndex = 0
      FieldName = 'required'
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
  end
  object RxSplitter1: TRxSplitter
    Left = 334
    Top = 77
    Width = 3
    Height = 326
    ControlFirst = gridmodels
    Align = alLeft
  end
  object Panel1: TPanel
    Left = 0
    Top = 403
    Width = 746
    Height = 91
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      746
      91)
    object Label6: TLabel
      Left = 552
      Top = 4
      Width = 34
      Height = 13
      Caption = 'relation'
      FocusControl = DBEdit1
    end
    object Label7: TLabel
      Left = 356
      Top = 4
      Width = 82
      Height = 13
      Caption = 'Liste de s'#233'lection'
      FocusControl = DBEdit2
    end
    object Label8: TLabel
      Left = 4
      Top = 52
      Width = 39
      Height = 13
      Caption = 'modules'
      FocusControl = DBEdit3
    end
    object BitBtn1: TBitBtn
      Left = 587
      Top = 65
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = BitBtn1Click
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
      Left = 671
      Top = 65
      Width = 74
      Height = 25
      Anchors = [akTop, akRight]
      TabOrder = 1
      Kind = bkCancel
    end
    object DBMemo1: TDBMemo
      Left = 0
      Top = 0
      Width = 333
      Height = 49
      DataField = 'help'
      DataSource = srcfields
      TabOrder = 2
    end
    object DBEdit1: TDBEdit
      Left = 552
      Top = 20
      Width = 134
      Height = 21
      DataField = 'relation'
      DataSource = srcfields
      TabOrder = 3
    end
    object DBEdit2: TDBEdit
      Left = 356
      Top = 20
      Width = 189
      Height = 21
      DataField = 'selection'
      DataSource = srcfields
      TabOrder = 4
    end
    object DBEdit3: TDBEdit
      Left = 4
      Top = 68
      Width = 325
      Height = 21
      DataField = 'modules'
      DataSource = srcmodels
      TabOrder = 5
    end
  end
  object models: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'provmodels'
    OnFilterRecord = modelsFilterRecord
    Left = 72
    Top = 164
    object modelsid: TIntegerField
      DisplayWidth = 6
      FieldName = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Visible = False
    end
    object modelsmodel: TStringField
      DisplayLabel = 'Objet'
      DisplayWidth = 10
      FieldName = 'model'
      Origin = 'model'
      ProviderFlags = [pfInUpdate]
      Size = 255
    end
    object modelsname: TStringField
      DisplayLabel = 'Nom de l'#39'objet'
      DisplayWidth = 10
      FieldName = 'name'
      Origin = 'name'
      ProviderFlags = [pfInUpdate]
      Size = 255
    end
    object modelsinfo: TMemoField
      DisplayLabel = 'Information'
      DisplayWidth = 50
      FieldName = 'info'
      Origin = 'info'
      ProviderFlags = [pfInUpdate]
      OnGetText = modelsinfoGetText
      BlobType = ftMemo
    end
    object modelsfield_id: TMemoField
      DisplayLabel = 'Champs'
      DisplayWidth = 20
      FieldName = 'field_id'
      Origin = 'field_id'
      ProviderFlags = [pfInUpdate]
      BlobType = ftMemo
    end
    object modelsmodules: TStringField
      DisplayLabel = 'In modules'
      DisplayWidth = 10
      FieldName = 'modules'
      Origin = 'modules'
      ProviderFlags = [pfInUpdate]
      Visible = False
      Size = 255
    end
  end
  object provmodels: TOpenERPProvider
    openerp_connection = OpenERPConnection
    openerp_class = 'ir.model'
    openerp_fieldnames = 'field_id,info,model,modules,name'
    openerp_filter = '[]'
    openerp_limit = -1
    Options = [poIncFieldProps]
    Left = 72
    Top = 112
  end
  object srcmodels: TDataSource
    DataSet = models
    Left = 72
    Top = 212
  end
  object srcfields: TDataSource
    DataSet = fields
    Left = 292
    Top = 228
  end
  object ActionList1: TActionList
    Left = 196
    Top = 24
    object ActLoadFields: TAction
      Caption = 'ActLoadFields'
    end
    object ActLoadModels: TAction
      Caption = 'Load models'
      OnExecute = ActLoadModelsExecute
    end
  end
  object fields: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 292
    Top = 168
    object fieldsname: TStringField
      DisplayLabel = 'Nom de champ'
      DisplayWidth = 10
      FieldName = 'name'
      Size = 255
    end
    object fieldstype: TStringField
      DisplayLabel = 'Type'
      DisplayWidth = 10
      FieldName = 'type'
    end
    object fieldssize: TIntegerField
      DisplayLabel = 'Taille'
      FieldName = 'size'
    end
    object fieldsstring: TStringField
      DisplayLabel = 'Description'
      DisplayWidth = 10
      FieldName = 'string'
      Size = 255
    end
    object fieldshelp: TStringField
      DisplayWidth = 10
      FieldName = 'help'
      Size = 255
    end
    object fieldsreadonly: TStringField
      DisplayLabel = 'Lecture seule'
      FieldName = 'readonly'
      Size = 10
    end
    object fieldsrequired: TStringField
      DisplayLabel = 'Obligatoire'
      FieldName = 'required'
      Size = 10
    end
    object fieldsselectable: TStringField
      FieldName = 'selectable'
      Size = 10
    end
    object fieldsselection: TMemoField
      DisplayLabel = 'Liste de s'#233'lection'
      DisplayWidth = 10
      FieldName = 'selection'
      OnGetText = fieldsselectionGetText
      BlobType = ftMemo
    end
    object fieldsdomain: TStringField
      DisplayWidth = 10
      FieldName = 'domain'
      Size = 255
    end
    object fieldsrelation: TStringField
      DisplayWidth = 10
      FieldName = 'relation'
      Size = 255
    end
    object fieldscontext: TStringField
      DisplayWidth = 10
      FieldName = 'context'
      Size = 255
    end
    object fieldsfunction: TStringField
      DisplayWidth = 10
      FieldName = 'function'
      Size = 255
    end
    object fieldsfunc_method: TStringField
      DisplayWidth = 10
      FieldName = 'func_method'
      Size = 255
    end
    object fieldsfnct_inv_arg: TStringField
      DisplayWidth = 10
      FieldName = 'fnct_inv_arg'
      Size = 255
    end
    object fieldsfnct_search: TStringField
      DisplayWidth = 10
      FieldName = 'fnct_search'
      Size = 255
    end
    object fieldsfunc_obj: TStringField
      DisplayWidth = 10
      FieldName = 'func_obj'
      Size = 255
    end
    object fieldsfnct_inv: TStringField
      DisplayWidth = 10
      FieldName = 'fnct_inv'
      Size = 255
    end
    object fieldsdigits: TStringField
      DisplayWidth = 10
      FieldName = 'digits'
    end
    object fieldsrelated_columns: TStringField
      DisplayWidth = 10
      FieldName = 'related_columns'
      Size = 255
    end
    object fieldsthird_table: TStringField
      DisplayWidth = 10
      FieldName = 'third_table'
      Size = 255
    end
    object fieldsstore: TStringField
      FieldName = 'store'
      Size = 10
    end
    object fieldsselect: TStringField
      FieldName = 'select'
      Size = 10
    end
  end
  object provfields: TOpenERPProvider
    openerp_connection = OpenERPConnection
    openerp_class = 'ir.model'
    openerp_limit = -1
    Options = [poIncFieldProps]
    Left = 292
    Top = 116
  end
  object OpenERPConnection: TOpenERPConnection
    openerp_proxyserver = 'http://srvopenerp6-prod:8000'
    openerp_context = '{"lang":"fr_FR"}'
    openerp_login = 'admin'
    openerp_password = '2010enProd'
    openerp_cacheable_classes = 'res.users;res.partner;res.partner.address;'
    Left = 288
    Top = 64
  end
end
