unit uOpenERPLookupName;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, dxExEdtr, dxTL, dxDBCtrl, dxDBGrid, DB,
  OpenERPProvider, DBClient, dxCntner, dxDBGridSermo, StdCtrls, Buttons,
  ActnList,dxDBTLCl,dxEdLib, dxDBELib;

type
  TVisOpenERPLookupName = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    EdSearch: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    gridlookup: TdxDBGridSermo;
    srcLookupCDS: TDataSource;
    gridlookupid: TdxDBGridMaskColumn;
    gridlookupname: TdxDBGridMaskColumn;
    LookupCDS: TClientDataSet;
    LookupCDSid: TIntegerField;
    LookupCDSname: TStringField;
    ActionList1: TActionList;
    ActSearch: TAction;
    cbLimit: TComboBox;
    Label2: TLabel;
    Button1: TButton;
    EdCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ActSearchUpdate(Sender: TObject);
    procedure ActSearchExecute(Sender: TObject);
    procedure gridlookupCustomDrawCell(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; ANode: TdxTreeListNode; AColumn: TdxTreeListColumn;
      ASelected, AFocused, ANewItemRow: Boolean; var AText: String;
      var AColor: TColor; AFont: TFont; var AAlignment: TAlignment;
      var ADone: Boolean);
    procedure gridlookupDblClick(Sender: TObject);
    procedure gridlookupKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EdSearchKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    OpenERPConnection: TOpenERPConnection;
    model,
    domain:String;
    limit:integer;
  end;

  TdxOpenERPDBButtonEdit = class(TdxDBButtonEdit)

  end;

  TdxOpenERPDBGridButtonColumn = class(TdxDBTreeListButtonColumn)

  end;

var
  VisOpenERPLookupName: TVisOpenERPLookupName;

function SearchNameDialog(var aid:integer;var aname:String; AOpenERPConnection: TOpenERPConnection;Amodel,Adomain:String;
  Alimit:integer=-1;ShowAlwaysDialog:Boolean=False):Boolean;

function DBLookupValidate(AOpenERPConnection:TOpenERPConnection;editingtext:String;IDField:TIntegerField;NameField:TStringField;amodel:String;adomain:String;
  ShowAlwaysDialog:Boolean=False):Boolean;
function DXDBButtonEdit(Sender:TdxDBButtonEdit;ShowAlwaysDialog:Boolean=True;adomain:String=''):Boolean; overload;
function DXDBButtonEdit(Sender:TdxDBTreeListButtonColumn;ShowAlwaysDialog:Boolean=True;adomain:String=''):Boolean; overload;
function DBStringFieldLookupValidate(LibField:TStringField):Boolean;

procedure Register;


implementation

{$R *.dfm}

procedure Register;
begin
  RegisterComponents('OpenERP', [TdxOpenERPDBButtonEdit,TdxOpenERPDBGridButtonColumn]);
end;

function DBLookupValidate(AOpenERPConnection:TOpenERPConnection;editingtext:String;IDField:TIntegerField;NameField:TStringField;amodel:String;adomain:String;ShowAlwaysDialog:Boolean=False):Boolean;
var
  Aid:integer;
  Aname:String;
begin
  Aid := idfield.Value;
  Aname := EditingText;
  if adomain='' then
    adomain :='[]';
  Result := SearchNameDialog(Aid,Aname,AOpenERPConnection,amodel,adomain,-1,showalwaysdialog);
  if Result then
  begin
    if not (IDField.DataSet.state in dsEditModes) then
      IDField.DataSet.Edit;
    IdField.Value := Aid;
    NameField.Value := Aname;
  end;
end;


function DBStringFieldLookupValidate(LibField:TStringField):Boolean;
var
  idfn,libfn,lib:String;
  model : String;
  ds : TOpenERPClientDataset;
  idfield:TIntegerField;
begin
  libfn := LibField.FieldName;
  idfn := copy(libfn,1,length(libfn)-length('_lib'));
  ds := TOpenERPClientDataset(LibField.dataset);
  idfield := TIntegerField(ds.fieldbyname(idfn));
  model :=  ds.OpenERPProvider.metadata.O[idfn].O['relation'].AsString;
  if (ds.IsModified(Idfield) and idfield.IsNull) or (ds.IsModified(LibField) and (LibField.Text='')) then
  begin
    Result := True;
    if not (ds.state in dsEditModes) then
      ds.Edit;
    idfield.Clear;
    LibField.Clear;
  end
  else
  begin
    if idfield.Value>0 then
      lib := ds.openerp_connection.name_get(model,idfield.value)
    else
      lib := libField.Text;
    // on a changé le libellé sans changer l'ID, le valider et modifier l'ID
    if (not ds.IsModified(idField) and ds.IsModified(LibField)) then
      result := DBLookupValidate(ds.OpenERPProvider.openerp_connection,
        LibField.Text,
        idfield,
        LibField,
        model,'')
    else
    // on a changé l'ID, modifier le lib
    if ds.isModified(idField) and (idfield.Value>0) then
    begin
      LibField.AsString := lib;
      Result := True;
    end
  end;
end;


function DXDBButtonEdit(Sender:TdxDBButtonEdit;ShowAlwaysDialog:Boolean=True;adomain:String=''):Boolean;
var
  idfn,libfn:String;
  model : String;
  ds : TOpenERPClientDataset;
begin
  libfn := (Sender as TdxDBButtonEdit).DataField;
  idfn := copy(libfn,1,length(libfn)-length('_lib'));
  ds := TOpenERPClientDataset((Sender as TdxDBButtonEdit).datasource.dataset);
  model :=  ds.OpenERPProvider.metadata.O[idfn].O['relation'].AsString;
  if ((Sender as TdxDBButtonEdit).EditText='') and  not showalwaysdialog  then
  begin
    Result := True;
    if not (ds.state in dsEditModes) then
      ds.Edit;
    ds.fieldbyname(idfn).Clear;
    ds.fieldbyname(libfn).Clear;
  end
  else
    result := DBLookupValidate(ds.OpenERPProvider.openerp_connection,
      (Sender as TdxDBButtonEdit).EditText,
      ds.fieldbyname(idfn) as TIntegerField,
      ds.fieldbyname(libfn) as TStringField,
      model,adomain,
      ShowAlwaysDialog);
  if result then
    (Sender as TdxDBButtonEdit).EditText := (ds.fieldbyname(libfn) as TStringField).Value

end;

function DXDBButtonEdit(Sender:TdxDBTreeListButtonColumn;ShowAlwaysDialog:Boolean=True;adomain:String=''):Boolean;
var
  idfn,libfn:String;
  model : String;
  ds : TOpenERPClientDataset;
  grid : Tdxdbgrid;
begin
  grid := (sender.treelist) as Tdxdbgrid;
  libfn := (Sender as TdxDBTreeListButtonColumn).FieldName;
  idfn := copy(libfn,1,length(libfn)-length('_lib'));
  ds := TOpenERPClientDataset((Sender as TdxDBTreeListButtonColumn).Field.DataSet);
  model :=  ds.OpenERPProvider.metadata.O[idfn].O['relation'].AsString;
  if (grid.EditingText='') and  not showalwaysdialog then
  begin
    Result := True;
    if not (ds.state in dsEditModes) then
      ds.Edit;
    ds.fieldbyname(idfn).Clear;
    ds.fieldbyname(libfn).Clear;
  end
  else
    result := DBLookupValidate(ds.OpenERPProvider.openerp_connection,
      grid.EditingText,
      ds.fieldbyname(idfn) as TIntegerField,
      ds.fieldbyname(libfn) as TStringField,
      model,adomain,
      ShowAlwaysDialog);
  if result then
    grid.EditingText := (ds.fieldbyname(libfn) as TStringField).Value

end;


function SearchNameDialog(var aid:integer;var aname:String; AOpenERPConnection: TOpenERPConnection;Amodel,Adomain:String;
  Alimit:integer=-1;ShowAlwaysDialog:Boolean=False):Boolean;
begin
  with TVisOpenERPLookupName.Create(Application) do
  try
    Caption := 'Recherche de '+Amodel;
    OpenERPConnection := AOpenERPConnection;
    EdSearch.Text := aname;
    model := Amodel;
    limit := Alimit;
    domain := Adomain;
    if ActSearch.Enabled then
    begin
      ActSearch.Execute;
      if LookupCDS.Active then
        if not LookupCDS.Locate('id',aid,[]) then
          LookupCDS.Locate('name',aname,[]);
    end;
    if ((LookupCDS.Active and (LookupCDS.RecordCount=1) and not LookupCDSid.IsNull) and not ShowAlwaysDialog)
     or (ShowModal = mrOK) then
    begin
      aname := LookupCDSname.Value;
      aId := LookupCDSid.Value;
      Result := not LookupCDSid.IsNull;
    end;
  finally
    Free;
  end;
end;

procedure TVisOpenERPLookupName.FormCreate(Sender: TObject);
begin
  model := 'res.users';
  limit:=-1;
  domain:='[]';
end;

procedure TVisOpenERPLookupName.ActSearchUpdate(Sender: TObject);
begin
  ActSearch.Enabled := (OpenERPConnection<>Nil);
end;

procedure TVisOpenERPLookupName.ActSearchExecute(Sender: TObject);
begin
  if cbLimit.ItemIndex<=0 then
    limit := -1
  else
    limit := StrToInt(cbLimit.Text);
  OpenERPConnection.name_search(model,EdSearch.Text,domain,limit,LookupCDS);
  if LookupCDS.Active then
    EdCount.Caption := IntToStr(LookupCDS.RecordCount)+' résultats';
end;

procedure TVisOpenERPLookupName.gridlookupCustomDrawCell(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; ANode: TdxTreeListNode;
  AColumn: TdxTreeListColumn; ASelected, AFocused, ANewItemRow: Boolean;
  var AText: String; var AColor: TColor; AFont: TFont;
  var AAlignment: TAlignment; var ADone: Boolean);
begin
  AText:=Atext;
end;

procedure TVisOpenERPLookupName.gridlookupDblClick(Sender: TObject);
begin
  if LookupCDS.Active and (not LookupCDSid.IsNull) then
    ModalResult := mrOK;
end;

procedure TVisOpenERPLookupName.gridlookupKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (key = vk_return)  and LookupCDS.Active and (not LookupCDSid.IsNull) then
    ModalResult := mrOK;
  if key=vk_escape then
  begin
    key := 0;
    EdSearch.SetFocus;
    EdSearch.SelectAll;
  end;
end;

procedure TVisOpenERPLookupName.EdSearchKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if key=vk_return then
  begin
    EdSearch.SelectAll;
    ActSearch.Execute;
    if LookupCDS.RecordCount=1 then
      ModalResult := mrOk;
  end
  else
  if (key=vk_down) or (key=vk_up) or (key=vk_prior) or (key=vk_next) then
    gridlookup.SetFocus;


end;

end.
