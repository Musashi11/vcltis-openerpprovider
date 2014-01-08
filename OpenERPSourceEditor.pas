unit OpenERPSourceEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxExEdtr, dxDBTLCl, dxGrClms, DB, StdCtrls, Buttons, dxTL,
  dxDBCtrl, dxDBGrid, Provider, OpenERPProvider, DBClient, RXSplit,
  dxCntner, dxDBGridSermo, ExtCtrls,DesignIntf, DesignEditors,
  ActnList, Mask, DBCtrls;

type
  TOpenERPProviderEditor = class(TForm)
    panHaut: TPanel;
    gridmodels: TdxDBGridSermo;
    gridfields: TdxDBGridSermo;
    RxSplitter1: TRxSplitter;
    models: TClientDataSet;
    provmodels: TOpenERPProvider;
    srcmodels: TDataSource;
    gridmodelsid: TdxDBGridMaskColumn;
    gridmodelsname: TdxDBGridMaskColumn;
    gridmodelsmodel: TdxDBGridMaskColumn;
    gridmodelsinfo: TdxDBGridMaskColumn;
    edSearchModel: TEdit;
    Label1: TLabel;
    edModel: TEdit;
    edFields: TEdit;
    Label2: TLabel;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label3: TLabel;
    srcfields: TDataSource;
    modelsid: TIntegerField;
    modelsmodel: TStringField;
    modelsname: TStringField;
    modelsinfo: TMemoField;
    ActionList1: TActionList;
    Label5: TLabel;
    EdOpenERPProxyURL: TEdit;
    ActLoadModels: TAction;
    modelsmodules: TStringField;
    gridmodelsfield_id: TdxDBGridMaskColumn;
    gridmodelsmodules: TdxDBGridMaskColumn;
    fields: TClientDataSet;
    fieldsname: TStringField;
    fieldstype: TStringField;
    fieldsstring: TStringField;
    fieldsdomain: TStringField;
    fieldsrelation: TStringField;
    fieldscontext: TStringField;
    fieldshelp: TStringField;
    fieldsfunction: TStringField;
    fieldsfunc_method: TStringField;
    fieldsfnct_inv_arg: TStringField;
    fieldsfnct_search: TStringField;
    fieldsfunc_obj: TStringField;
    fieldsfnct_inv: TStringField;
    fieldsdigits: TStringField;
    fieldsselection: TMemoField;
    fieldsrelated_columns: TStringField;
    fieldsthird_table: TStringField;
    provfields: TOpenERPProvider;
    gridfieldsname: TdxDBGridMaskColumn;
    gridfieldsselectable: TdxDBGridCheckColumn;
    gridfieldstype: TdxDBGridMaskColumn;
    gridfieldsreadonly: TdxDBGridCheckColumn;
    gridfieldsselect: TdxDBGridCheckColumn;
    gridfieldsstring: TdxDBGridMaskColumn;
    gridfieldsdomain: TdxDBGridMaskColumn;
    gridfieldsrelation: TdxDBGridMaskColumn;
    gridfieldscontext: TdxDBGridMaskColumn;
    gridfieldshelp: TdxDBGridMaskColumn;
    gridfieldsfunction: TdxDBGridMaskColumn;
    gridfieldsfunc_method: TdxDBGridMaskColumn;
    gridfieldsfnct_inv_arg: TdxDBGridMaskColumn;
    gridfieldsfnct_search: TdxDBGridMaskColumn;
    gridfieldsstore: TdxDBGridCheckColumn;
    gridfieldsfunc_obj: TdxDBGridMaskColumn;
    gridfieldsfnct_inv: TdxDBGridMaskColumn;
    gridfieldsdigits: TdxDBGridMaskColumn;
    gridfieldsselection: TdxDBGridMaskColumn;
    gridfieldsrelated_columns: TdxDBGridMaskColumn;
    gridfieldsthird_table: TdxDBGridMaskColumn;
    fieldssize: TIntegerField;
    gridfieldssize: TdxDBGridMaskColumn;
    gridfieldsrequired: TdxDBGridCheckColumn;
    fieldsselectable: TStringField;
    fieldsrequired: TStringField;
    fieldsstore: TStringField;
    fieldsselect: TStringField;
    fieldsreadonly: TStringField;
    OpenERPConnection: TOpenERPConnection;
    Label4: TLabel;
    edSearchField: TEdit;
    DBMemo1: TDBMemo;
    Label6: TLabel;
    DBEdit1: TDBEdit;
    Label7: TLabel;
    DBEdit2: TDBEdit;
    Label8: TLabel;
    DBEdit3: TDBEdit;
    modelsfield_id: TMemoField;
    procedure FormShow(Sender: TObject);
    procedure gridfieldsCustomDrawCell(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; ANode: TdxTreeListNode; AColumn: TdxTreeListColumn;
      ASelected, AFocused, ANewItemRow: Boolean; var AText: String;
      var AColor: TColor; AFont: TFont; var AAlignment: TAlignment;
      var ADone: Boolean);
    procedure fieldsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure modelsFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure edSearchModelKeyPress(Sender: TObject; var Key: Char);
    procedure gridfieldsSelectedCountChange(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure gridfieldsClick(Sender: TObject);
    procedure EdOpenERPProxyURLKeyPress(Sender: TObject; var Key: Char);
    procedure ActLoadModelsExecute(Sender: TObject);
    procedure gridmodelsChangeNodeEx(Sender: TObject);
    procedure edSearchFieldKeyPress(Sender: TObject; var Key: Char);
    procedure fieldsselectionGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
    procedure modelsinfoGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);
  private
    procedure UpdateSelected(Sender: TObject);
    procedure SelectFields(list: String);
    procedure LoadFields(model: String);
    { Déclarations privées }
  public
    { Déclarations publiques }
    provider : TOpenERPProvider;
  end;

  TOpenERPProviderComponentditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  TOpenERPProviderPropertyEditor = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes;
    procedure Edit; override;
  end;


procedure Register;

var
  OpenERPProviderEditor: TOpenERPProviderEditor;

implementation
uses JclStrings,SuperObject;
{$R *.dfm}

procedure Register;
begin
  RegisterComponentEditor(TOpenERPProvider,TOpenERPProviderComponentditor);
  RegisterPropertyEditor(TypeInfo(TOpenERPProvider),TOpenERPClientDataset,'openerp_provider',TOpenERPProviderPropertyEditor);
end;

{ TOpenERPProviderComponentditor }

procedure TOpenERPProviderComponentditor.ExecuteVerb(Index: Integer);
begin
  inherited;
  if index = 0 then
  with TOpenERPProviderEditor.Create(Application) do
  try
    Provider := TOpenERPProvider(Component);
    ShowModal;
  finally
    Free;
  end
end;

function TOpenERPProviderComponentditor.GetVerb(Index: Integer): string;
begin
  if index = 0 then
    Result := 'Edit OpenERP Class and Fields'
end;

function TOpenERPProviderComponentditor.GetVerbCount: Integer;
begin
  result := 1
end;

procedure TOpenERPProviderEditor.FormShow(Sender: TObject);
begin
  EdOpenERPProxyURL.Text := provider.openerp_proxyserver;
  edModel.Text := provider.openerp_class;
  edFields.Text := provider.openerp_fieldnames;
  edSearchModel.Text := edModel.Text;
  ActLoadModels.Execute;
  LoadFields(provider.openerp_class);
  SelectFields(edFields.Text);
end;

procedure TOpenERPProviderEditor.gridfieldsCustomDrawCell(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; ANode: TdxTreeListNode;
  AColumn: TdxTreeListColumn; ASelected, AFocused, ANewItemRow: Boolean;
  var AText: String; var AColor: TColor; AFont: TFont;
  var AAlignment: TAlignment; var ADone: Boolean);
var
  required:Variant;
  readonly,selectable:String;
begin
  if ANode<>Nil then
  begin
    AFont.Style := [];
    required := vartostr(ANode.Values[gridfieldsrequired.Index]);
    if LowerCase(required)='true' then
      AFont.Style := AFont.Style + [fsBold];
    readonly := VarToStr(ANode.Values[gridfieldsreadonly.Index]);
    if (LowerCase(readonly)='true') then
      AFont.Style := AFont.Style + [fsItalic];
    selectable := VarToStr(ANode.Values[gridfieldsselectable.Index]);
    {if (LowerCase(selectable)='true') then
      AFont.Style := AFont.Style + [fsunderline ];}

  end;
end;

procedure TOpenERPProviderEditor.fieldsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
       Accept := (edSearchField.text = '') or (
              (Pos(UpperCase(edSearchField.Text),uppercase(DataSet.FieldByName('name').AsString)) > 0) or
              (Pos(UpperCase(edSearchField.Text),uppercase(DataSet.FieldByName('field_description').AsString))>0));
end;

procedure TOpenERPProviderEditor.modelsFilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
begin
       Accept := (edSearchModel.text = '') or (
              (Pos(UpperCase(edSearchModel.Text),uppercase(DataSet.FieldByName('name').AsString)) > 0) or
              (Pos(UpperCase(edSearchModel.Text),uppercase(DataSet.FieldByName('model').AsString))>0));

end;

procedure TOpenERPProviderEditor.edSearchModelKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key=#13 then
  begin
    models.Filtered := False;
    models.Filtered := True;
  end;
end;


procedure TOpenERPProviderEditor.gridfieldsSelectedCountChange(
  Sender: TObject);
begin
  UpdateSelected(Sender);
end;

procedure TOpenERPProviderEditor.UpdateSelected(Sender: TObject);
var
  list:String;
  i:integer;
begin
  for i:=0 to gridfields.SelectedCount-1 do
  begin
    list:=list+gridfields.SelectedNodes[i].Values[gridfieldsname.index]+',';
  end;
  edFields.Text := copy(list,1,length(list)-1);
end;


procedure TOpenERPProviderEditor.BitBtn1Click(Sender: TObject);
begin

  provider.openerp_connection.openerp_proxyserver := EdOpenERPProxyURL.Text;
  provider.openerp_class := edModel.Text;
  provider.openerp_fieldnames := edFields.Text;

end;

procedure TOpenERPProviderEditor.gridfieldsClick(Sender: TObject);
begin
  UpdateSelected(Sender);
end;

procedure TOpenERPProviderEditor.SelectFields(list:String);
var
  i:integer;
  lst : TStringList;
begin
  lst := TStringList.Create;
  try
    gridfields.ClearSelection;
    gridfields.BeginSelection;
    StrToStrings(edFields.Text,',',lst);
    for i:=0 to lst.count-1 do
    begin
      if fields.Locate('name',lst[i],[]) then
        gridfields.FocusedNode.Selected := True;
    end;
    edFields.Text := copy(list,1,length(list)-1);
  finally
    gridfields.EndSelection;
    lst.free;
  end;
end;


procedure TOpenERPProviderEditor.EdOpenERPProxyURLKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = #13 then
    ActLoadModels.Execute;
end;

procedure TOpenERPProviderEditor.ActLoadModelsExecute(Sender: TObject);
begin
  Models.Close;
  Fields.Close;
  OpenERPConnection.openerp_proxyserver := EdOpenERPProxyURL.Text;

  Models.Open;
  Models.Filtered := False;
  Models.Filtered := True;
end;

procedure TOpenERPProviderEditor.LoadFields(model:String);
var
  i,j:integer;
  fd : ISuperObject;
  dsf : tfield;
  fname,paramname,paramvalue : String;
  fmaxlen,fwidth : integer;
begin
  try
    fields.DisableControls;
    if not fields.Active then
      fields.CreateDataSet;
    fields.EmptyDataSet;
    fields.LogChanges := False;

    provfields.openerp_class := model;
    for i:=0 to provfields.metadata.AsObject.GetNames.AsArray.Length-1 do
    begin
      fields.Append;
      fname := provfields.metadata.AsObject.GetNames.AsArray[i].AsString;
      fieldsname.Value := fname;
      fd := provfields.metadata.O[fname];
      // tous les paramètre du champ
      for j:=0 to fd.AsObject.GetNames.AsArray.Length-1 do
      begin
        paramname := fd.AsObject.GetNames.AsArray[j].AsString;
        paramvalue := fd.O[paramname].AsString;
        dsf := fields.FindField(paramname);
        if dsf <> Nil then
          dsf.AsString := paramvalue;
      end;
      fields.Post;
    end;
  finally
    fields.EnableControls;
  end;
end;

procedure TOpenERPProviderEditor.gridmodelsChangeNodeEx(Sender: TObject);
begin
  edModel.Text := modelsmodel.Value;
  LoadFields(modelsmodel.Value);

end;

procedure TOpenERPProviderEditor.edSearchFieldKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key=#13 then
  begin
    fields.Filtered := False;
    fields.Filtered := True;
  end;

end;

{ TOpenERPProviderPropertyEditor }

procedure TOpenERPProviderPropertyEditor.Edit;
var
  I: Integer;
  J: Integer;
begin
  inherited;
    With TOpenERPProviderEditor.Create(Application) do
    try
      provider := TOpenERPProvider(GetOrdValue);
      ShowModal;
    finally
      Free;
    end;
end;

function TOpenERPProviderPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  result :=  inherited GetAttributes+[paDialog];
end;

procedure TOpenERPProviderEditor.fieldsselectionGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
begin
  If Sender.IsNull then
    Text :=''
  else
    Text := TMemoField(Sender).AsString;
end;

procedure TOpenERPProviderEditor.modelsinfoGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
begin
  If Sender.IsNull then
    Text :=''
  else
    Text := TMemoField(Sender).AsString;

end;

end.
