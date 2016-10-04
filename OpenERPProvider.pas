unit OpenERPProvider;

interface

uses
  Windows, Messages, SysUtils, Classes, Provider,superobject,dbclient,IdHTTP,IdCookieManager,db,midas,ActiveX,ComObj,MidConst;

type

  TOpenERPConnection = class(TComponent)
  private
    Fopenerp_proxyserver: String;
    Fopenerp_context: string;
    Fopenerp_password: string;
    Fopenerp_login: string;
    Fopenerp_user_id: integer;
    Fopenerp_cacheable_classes: string;
    Fuseraccount_data: ISUperObject;
    procedure Setopenerp_proxyserver(const Value: String);
    procedure Setopenerp_context(const Value: string);
    procedure Setopenerp_password(const Value: string);
    procedure Setopenerp_login(const Value: string);
    function getopenerp_user_id: integer;
    procedure Setopenerp_cacheable_classes(const Value: string);
    function Getuseraccount_data: ISUperObject;
    { Déclarations privées }
  protected
    { Déclarations protégées }
  public
    { Déclarations publiques }
    session_cookies : TidCookieManager;
    NameCache : TClientDataset;
    name_cache_timeout : integer; // minutes
    property useraccount_data:ISUperObject read Getuseraccount_data write Fuseraccount_data;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure login;
    procedure logout;

    function http_get(action_url:string;login_required:Boolean=True):String; overload;
    procedure http_get(action_url:string;Stream:TStream;login_required:Boolean=True); overload;

    function http_post(action_url:string;params:String;login_required:Boolean=True):String; overload;
    procedure http_post(action_url:string;params:String;Stream:TStream;login_required:Boolean=True); overload;


    function name_search(model, name, domain: String;limit: integer): ISuperObject; overload;
    function name_search(model,name,domain:String;limit:integer;ResultCDS:TClientdataset):integer; overload;

    //function name_get(model:String;id:integer): String;
    function Name_get(aclass:String;aID:Integer):String;
    procedure Name_cache_flush(aclass:String);

    function CallMethodSO(model,method:String;params:Array of String):ISuperObject;
    function CallMethod(model,method:String;params:Array of String):String;

  published
    { Déclarations publiées }
    property openerp_proxyserver:String read Fopenerp_proxyserver write Setopenerp_proxyserver;
    property openerp_context:string read Fopenerp_context write Setopenerp_context;
    property openerp_login:string read Fopenerp_login write Setopenerp_login;
    property openerp_user_id:integer read getopenerp_user_id;
    property openerp_password:string read Fopenerp_password write Setopenerp_password;
    property openerp_cacheable_classes:string read Fopenerp_cacheable_classes write Setopenerp_cacheable_classes;

  end;

  TOpenERPProvider = class(tbaseprovider)
  private
    Fopenerp_class: String;
    Fopenerp_proxyserver: String;
    Fopenerp_filter: string;
    Fopenerp_fieldnames: String;
    Fopenerp_ids: string;
    fmetadata : ISuperObject;
    Fopenerp_limit: integer;
    Fopenerp_connection: TOpenERPConnection;
    Fopenerp_order: string;
    procedure Setopenerp_class(const Value: String);
    procedure Setopenerp_fieldnames(const Value: String);
    procedure Setopenerp_filter(const Value: string);
    procedure Setopenerp_proxyserver(const Value: String);
    procedure CreateDataPacket(PacketOpts: TGetRecordOptions;
      ProvOpts: TProviderOptions; var RecsOut: Integer;
      var Data: OleVariant); override;
    procedure Setopenerp_ids(const Value: string);
    function LoadMetadata:ISuperObject;
    procedure CreateFields(targetdataset: TCustomClientdataset);
    function Getmetadata: ISuperObject;
    procedure Setopenerp_limit(const Value: integer);
    procedure Setopenerp_connection(const Value: TOpenERPConnection);
    procedure Notification(AComponent: TComponent; Operation: TOperation);override;
    function Get_openerpProxyserver: String;
    function Get_openerpContext: String;
    procedure Setopenerp_order(const Value: string);
    function LoadDefaults: ISuperObject;
    function CreateLookupDataset(fname: String): TClientDataset;
    procedure Setmetadata(const Value: ISuperObject);
    procedure ClearSelectionDatasets;

    procedure MemoGetText(Sender: TField; var Text: String;
      DisplayText: Boolean);


    { Déclarations privées }
  protected
    { Déclarations protégées }
    NextOffset:Integer;
    SelectionDatasets : TStringList;
  public
    errors : OleVariant;
    lastupdates_result : ISuperObject;

    { Déclarations publiques }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // crée une chaine json de delta à partir du delta d'un CDS
    function deltajson(Delta:OleVariant):String;

    //remplit l'enregistrement en cours de cds avec le dictionnaire row (object json)
    procedure JSONToDataset(row:ISuperObject;cds:TCustomClientDataset);

    //Stocke les metadata OpenERP sous forme de dictionnaire (fname)
    property metadata : ISuperObject read Getmetadata write Setmetadata;

    function InternalApplyUpdates(const Delta: OleVariant;
      MaxErrors: Integer; out ErrorCount: Integer): OleVariant; override;

    function GetIDFromLastUpdate(tmpID: Integer): integer;
    function CallMethodSO(method:String;params:Array of String):ISuperObject;
    function CallMethod(method:String;params:Array of String):String;

    function audit(id:String):String;


  published
    { Déclarations publiées }

    property openerp_connection:TOpenERPConnection read Fopenerp_connection write Setopenerp_connection;
    property openerp_proxyserver:String read Get_openerpProxyserver;
    property openerp_context:String read Get_openerpContext;
    property openerp_class:String read Fopenerp_class write Setopenerp_class;
    property openerp_fieldnames:String read Fopenerp_fieldnames write Setopenerp_fieldnames;
    property openerp_filter:string read Fopenerp_filter write Setopenerp_filter;
    property openerp_ids:string read Fopenerp_ids write Setopenerp_ids;
    property openerp_limit:integer read Fopenerp_limit write Setopenerp_limit;
    property openerp_order:string read Fopenerp_order write Setopenerp_order;

    property Options;
    property OnDataRequest;
    property OnGetData;
    property OnUpdateData;

  end;

  TFieldModEvent = Procedure(AField:TField) of Object ;

  TOpenERPClientDataset = class(TClientDataSet)
  private
    FOpenERPProvider: TOpenERPProvider;
    FModifiedList : TStringList;
    FFieldModEvent : TFieldModEvent ;

    procedure SetOpenERPProvider(const Value: TOpenERPProvider);
    function Getopenerp_connection: TOpenERPConnection;
    procedure Setopenerp_connection(const Value: TOpenERPConnection);
    function Get_openerpContext: String;
    function Get_openerpProxyserver: String;
    function Getopenerp_class: String;
    function Getopenerp_fieldnames: String;
    function Getopenerp_filter: string;
    function Getopenerp_ids: string;
    function Getopenerp_limit: integer;
    procedure Setopenerp_class(const Value: String);
    procedure Setopenerp_fieldnames(const Value: String);
    procedure Setopenerp_filter(const Value: string);
    procedure Setopenerp_ids(const Value: string);
    procedure Setopenerp_limit(const Value: integer);
    function Getopenerp_order: string;
    procedure Setopenerp_order(const Value: string);
  protected
    tmp_id:integer;
    inDataEvent:integer;

    procedure OpenCursor(InfoQuery: Boolean); override;

    //Surcharge pour gérer les valeurs par défaut
    procedure DoOnNewRecord; override;

    //Gestion Modifications Lookups
    procedure DoBeforeInsert; override;
    procedure DoBeforeEdit; override;
    procedure DataEvent(Event: TDataEvent; Info: Longint);Override ;

    procedure InternalRefresh; override;
    function GetAppServer: IAppServer; override;


  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property OpenERPProvider:TOpenERPProvider read FOpenERPProvider write SetOpenERPProvider;

    //pour gérer les valeurs précédentes des lookups
    function PreviousValue(Field:TField):Variant;
    Property ModifiedFieldList : TStringList Read FModifiedList ;
    function IsModified(F:TField):Boolean;

  published
    property Active;
    property Aggregates;
    property AggregatesActive;
    property AutoCalcFields;
    property Constraints;
    property DisableStringTrim;
    property FileName;
    property Filter;
    property Filtered;
    property FilterOptions;
    property FieldDefs;
    property IndexDefs;
    property IndexFieldNames;
    property IndexName;
    property FetchOnDemand;
    property MasterFields;
    property MasterSource;
    property ObjectView;
    property PacketRecords;
    property ReadOnly;
    property StoreDefs;
    property BeforeOpen;
    property AfterOpen;
    property BeforeClose;
    property AfterClose;
    property BeforeInsert;
    property AfterInsert;
    property BeforeEdit;
    property AfterEdit;
    property BeforePost;
    property AfterPost;
    property BeforeCancel;
    property AfterCancel;
    property BeforeDelete;
    property AfterDelete;
    property BeforeScroll;
    property AfterScroll;
    property BeforeRefresh;
    property AfterRefresh;
    property OnCalcFields;
    property OnDeleteError;
    property OnEditError;
    property OnFilterRecord;
    property OnNewRecord;
    property OnPostError;
    property OnReconcileError;
    property BeforeApplyUpdates;
    property AfterApplyUpdates;
    property BeforeGetRecords;
    property AfterGetRecords;
    property BeforeRowRequest;
    property AfterRowRequest;
    property BeforeGetParams;
    property AfterGetParams;

    property openerp_connection:TOpenERPConnection read Getopenerp_connection write Setopenerp_connection;

    property openerp_proxyserver:String read Get_openerpProxyserver;
    property openerp_context:String read Get_openerpContext;
    property openerp_class:String read Getopenerp_class write Setopenerp_class;
    property openerp_fieldnames:String read Getopenerp_fieldnames write Setopenerp_fieldnames;
    property openerp_filter:string read Getopenerp_filter write Setopenerp_filter;
    property openerp_ids:string read Getopenerp_ids write Setopenerp_ids;
    property openerp_limit:integer read Getopenerp_limit write Setopenerp_limit;
    property openerp_provider:TOpenERPProvider read FOpenERPProvider;
    property openerp_order:string read Getopenerp_order write Setopenerp_order;

    Property OnModifiedField : TFieldModEvent
             Read FFieldModEvent Write FFieldModEvent ;
  end;


{ TOpenERPAppServer }

  TOpenERPAppServer = class(TInterfacedObject, IAppServer{$IFDEF MSWINDOWS}, ISupportErrorInfo{$ENDIF})
  private
    FProvider: TCustomProvider;
    FProviderCreated: Boolean;
    procedure SetProvider(const Value: TCustomProvider);
  protected
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    { IAppServer }
    function AS_ApplyUpdates(const ProviderName: WideString; Delta: OleVariant; MaxErrors: Integer;
                             out ErrorCount: Integer; var OwnerData: OleVariant): OleVariant; safecall;
    function AS_GetRecords(const ProviderName: WideString; Count: Integer; out RecsOut: Integer;
                           Options: Integer; const CommandText: WideString;
                           var Params: OleVariant; var OwnerData: OleVariant): OleVariant; safecall;
    function AS_DataRequest(const ProviderName: WideString; Data: OleVariant): OleVariant; safecall;
    function AS_GetProviderNames: OleVariant; safecall;
    function AS_GetParams(const ProviderName: WideString; var OwnerData: OleVariant): OleVariant; safecall;
    function AS_RowRequest(const ProviderName: WideString; Row: OleVariant; RequestType: Integer;
                           var OwnerData: OleVariant): OleVariant; safecall;
    procedure AS_Execute(const ProviderName: WideString;  const CommandText: WideString;
                         var Params, OwnerData: OleVariant); safecall;
    { ISupportErrorInfo }
    function InterfaceSupportsErrorInfo(const iid: TGUID): HResult; stdcall;
  public
    constructor Create(AProvider: TCustomProvider); overload;
    destructor Destroy; override;
    function SafeCallException(ExceptObject: TObject;
      ExceptAddr: Pointer): HResult; override;
    property Provider:TCustomProvider read FProvider write SetProvider;
  end;



procedure Register;

function OERPDateToDateTime(adatetime:String):TDateTime;
function DateTimeToOERPDateTime(adatetime:TDateTime):String;
function DateTimeToOERPDate(adatetime:TDateTime):String;
function DateTimeToOERPTime(adatetime:TDateTime):String;


implementation
uses Variants,jclStrings,dsintf,uLoginDlg, Forms,Controls,tisutils;

procedure Register;
begin
  RegisterComponents('OpenERP', [TOpenERPProvider,TOpenERPConnection,TOpenERPClientdataset]);
end;

{ TOpenERPProvider }
function TOpenERPProvider.LoadMetadata:ISuperObject;
var
  St:TMemoryStream;
  url : String;

begin
  try
    st := TMemoryStream.Create;
    url := '/object/'+openerp_class+'/fields_get?context='+EncodeURIComponent(openerp_context);
    if openerp_fieldnames<>'' then
      url := url + '&fields='+EncodeURIComponent(openerp_fieldnames);
    openerp_connection.http_get(url,st);
    result := TSuperObject.ParseStream(st,false);
  finally
    St.Free;
  end;
end;

function TOpenERPProvider.LoadDefaults:ISuperObject;
var
  St:TMemoryStream;
  url : String;

begin
  try
    st := TMemoryStream.Create;
    url := '/object/'+openerp_class+'/default_get?context='+EncodeURIComponent(openerp_context);
    if openerp_fieldnames<>'' then
      url := url + '&fields='+EncodeURIComponent(openerp_fieldnames);
    openerp_connection.http_get(url,st);
    result := TSuperObject.ParseStream(st,false);
    if (result['error']<>Nil) and (result['message']<>Nil) then
      Raise Exception.Create(result.AsString);
  finally
    St.Free;
  end;
end;

function TOpenERPProvider.CreateLookupDataset(fname:String):TClientDataset;
var
  i:integer;
  fmeta : ISuperObject;
  sel : ISuperObject;
  selSt:WideString;
  fd:TStringField;
begin
  i := SelectionDatasets.IndexOf(fname);
  if i>=0 then
    Result := TClientDataset(SelectionDatasets.Objects[i])
  else
  begin
    Result := TClientDataset.Create(Nil);
    Result.Name := fname;
    SelectionDatasets.AddObject(fname,Result);
    fd := TStringField.Create(Result);
    fd.FieldName := 'id';
    fd.Size := 255;
    fd.DataSet := Result;
    fd.DisplayWidth := 10;

    fd := TStringField.Create(Result);
    fd.FieldName := 'name';
    fd.Size := 255;
    fd.DataSet := Result;
    fd.DisplayWidth := 15;

    Result.CreateDataSet;
    Result.LogChanges:=False;

    //remplir avec le tableau (('code','value'),..)
    fmeta := metadata[fname];
    selSt := fmeta.S['selection'];
    selSt := StrReplaceChar(selSt,'(','[');
    selSt := StrReplaceChar(selSt,')',']');
    Sel := TSuperObject.ParseString(PWideChar(SelSt),False);
    for i:=0 to Sel.asArray.Length-1 do
      result.AppendRecord([Sel.AsArray.O[i].AsArray.S[0],Sel.AsArray.O[i].AsArray.S[1]]);
  end;
end;


procedure TOpenERPProvider.CreateFields(targetdataset:TCustomClientdataset);
var
  i:integer;
  fd : ISuperObject;
  dsf : tfield;
  fname,ftype,fdescription : String;
  fmaxlen,fwidth : integer;

begin
  targetdataset.data := Null;
  targetdataset.FieldDefs.Clear;
  targetdataset.Fields.Clear;
  try
    // Creation des champs du CDS
    if metadata <> Nil then
    begin
      //ID hardcoded.
      dsf :=  TIntegerField.Create(targetdataset);
      dsf.FieldName := 'id';
      dsf.DisplayWidth := 6;
      dsf.dataset := targetdataset;
      dsf.Visible := False;
      dsf.ProviderFlags :=  [pfInKey,pfInWhere,pfInUpdate];

      for i:=0 to metadata.AsObject.GetNames.AsArray.Length-1 do
      begin
        dsf := Nil;
        fmaxlen := 255;
        fwidth := 10;
        fname := metadata.AsObject.GetNames.AsArray[i].AsString;

        if fname <> 'id' then
        begin
          fd := metadata.O[fname];
          ftype := fd['type'].AsString;
          if fd['string']<>Nil then
            fdescription := fd['string'].AsString
          else
            fdescription := fname;
          if ftype='integer' then
            dsf :=  TIntegerField.Create(targetdataset)
          else if (ftype='string') or (ftype='char') then
          begin
            try
              if fd.AsObject.Exists('size') then
                fmaxlen := fd['size'].AsInteger
              else
                fmaxlen := 8000;
            except
            end;
            dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do
            begin
              Size := fmaxlen;
            end;
          end else if ftype='float' then
          begin
            dsf := TFloatField.Create(targetdataset);
            (dsf as TFloatField).DisplayFormat := '#,##0.00';
          end
          else if ftype='boolean' then
          begin
            dsf := TBooleanField.Create(targetdataset);
            (dsf as TBooleanField).DisplayValues := 'True;False';
          end
          else if ftype='date' then
          begin
            dsf := TDateField.Create(targetdataset);
            //dsf := TStringField.Create(targetdataset);
            //with dsf as TStringField do Size := 10;
          end
          else if ftype='datetime' then
          begin
            dsf := TDateTimeField.Create(targetdataset);

            //dsf := TStringField.Create(targetdataset);
            //with dsf as TStringField do Size := 20;
          end
          else if ftype='time' then
          begin
            dsf := TTimeField.Create(targetdataset);
            //dsf := TStringField.Create(targetdataset);
            //with dsf as TStringField do Size := 8;
          end
          else if ftype='many2one' then
          begin
            // creer un champ id et un champ libellé
            dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do Size := 255;
            dsf.FieldName := copy(fname,1,31-4)+'_lib';
            dsf.ProviderFlags := dsf.ProviderFlags - [pfInwhere,pfInUpdate];
            dsf.DisplayLabel := fdescription;
            if strleft(dsf.DisplayLabel,3)='ID ' then
              dsf.DisplayLabel := copy(dsf.DisplayLabel,4,255);
            if fwidth<fmaxlen then
              dsf.DisplayWidth := fwidth
            else
              dsf.DisplayWidth := fmaxlen;
            dsf.dataset := targetdataset;

            dsf := TIntegerField.Create(targetdataset);
            dsf.Visible := False;
            if (StrLeft(fdescription,2)<>'ID') then
              fdescription :=  'ID '+fdescription;
          end
          else if ftype='selection' then
          begin
            // creer un champ libellé
            dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do Size := 255;
            dsf.FieldName := copy(fname,1,31-4)+'_lu';
            dsf.ProviderFlags := dsf.ProviderFlags - [pfInwhere,pfInUpdate];
            dsf.DisplayLabel := fdescription;
            if fwidth<fmaxlen then
              dsf.DisplayWidth := fwidth
            else
              dsf.DisplayWidth := fmaxlen;
            dsf.dataset := targetdataset;

            dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do Size := 255;
            dsf.Visible := False;
            if (StrLeft(fdescription,2)<>'ID') then
              fdescription :=  'ID '+fdescription;
          end
          else if ftype='one2many' then
          begin
            dsf := TMemoField.Create(targetdataset);
            fwidth := 20;
          end
          else if ftype='text' then
          begin
            {dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do Size := 10000;}
            dsf := TMemoField.Create(targetdataset);
            fwidth := 50;
          end
          else
          begin
            dsf := TStringField.Create(targetdataset);
            with dsf as TStringField do Size := 255;
          end;
          if dsf<>Nil then
          begin
            // par défaut par dans le Where. (on pousse tous les champs pfInWhere dans le delta même si pas modidiés)
            // user_id dans project.task.work doit être pfInWhere (bug OERP ?)
            dsf.ProviderFlags := dsf.ProviderFlags - [pfInWhere];
            dsf.Origin := fname;
            dsf.FieldName := copy(fname,1,31);
            if (fd['required']<>Nil) and (fd.S['required'] = 'true') then
              dsf.Required := true;
            dsf.DisplayLabel := fdescription;
            if fwidth<fmaxlen then
              dsf.DisplayWidth := fwidth
            else
              dsf.DisplayWidth := fmaxlen;
            dsf.FieldKind := fkData;
            dsf.dataset := targetdataset;
          end;
        end;
      end;
    end;
  except
    targetdataset.Fields.Clear;
    targetdataset.FieldDefs.Clear;
    raise;
  end;
end;

//2012-07-31 10:39:49
function OERPDateToDateTime(adatetime:String):TDateTime;
var
  year,month,day:integer;
  time:String;
begin
  if pos('-',adatetime)>0 then
  begin
    year := strtoint(copy(adatetime,1,4));
    month := strtoint(copy(adatetime,6,2));
    day := strtoint(copy(adatetime,9,2));
    if copy(adatetime,12,8)<>'' then
      time := copy(adatetime,12,8)
    else
      time := '00:00:00';
    result := EncodeDate(year,month,day) + StrToTime(time);
  end
  else
    raise Exception.create(adatetime+' is not a valid openerp date')
end;

function DateTimeToOERPTime(adatetime:TDateTime):String;
begin
  Result := FormatDateTime('hh:nn:ss',adatetime);
end;

function DateTimeToOERPDate(adatetime:TDateTime):String;
begin
  Result := FormatDateTime('yyyy-mm-dd',adatetime);
end;

function DateTimeToOERPDateTime(adatetime:TDateTime):String;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss',adatetime);
end;


constructor TOpenERPProvider.Create(AOwner: TComponent);
begin
  inherited create(AOwner);
  Fopenerp_class := 'res.users';
  Fopenerp_filter := '';
  Fopenerp_fieldnames := '';
  Fopenerp_limit := -1;
  fmetadata := Nil;
  Options := Options + [poIncFieldProps];
  SelectionDatasets := TStringList.Create;
end;

procedure TOpenERPProvider.JSONToDataset(row:ISuperObject;cds:TCustomClientDataset);
var
  j:integer;
  value:ISuperObject;
  names : ISuperObject;
  dsf : tfield;
  fname,ftype,fvalue : String;
  fmaxlen : integer;
begin
  names := row.AsObject.GetNames;
  for j := 0 to names.AsArray.Length-1 do
  begin
    fname := names.AsArray[j].AsString;
    try
      dsf := cds.FieldByName(fname);
      value := row.O[fname];
      if metadata.O[fname]<>Nil then
        ftype := metadata.O[fname].S['type']
      else
        ftype := 'char';
      case value.DataType of
        stNull : dsf.clear;
        stBoolean : if dsf.DataType = ftBoolean then
            dsf.AsBoolean := value.AsBoolean
          else
            // les champs null sont transmis avec une valeur booléenne false...
            dsf.Clear;
        stDouble,stCurrency  : dsf.AsFloat := value.AsDouble;
        stInt :
            if (dsf.DataType = ftBoolean) then
              if Value.AsInteger=1 then
                dsf.AsBoolean := True
              else
                dsf.AsBoolean := False
            else
              dsf.AsInteger := value.AsInteger;
        stArray :
              if metadata.O[fname]['type'].AsString = 'many2one' then
              begin
              //id
                dsf.AsString := row.A[fname][0].AsString;
              //libellé
                cds.FieldByName(fname+'_lib').AsString := row.A[fname][1].AsString;
              end
              else
                dsf.AsString := value.AsString;
        stObject,
        stString :
          if (ftype='date') or (ftype='datetime') or (ftype='time') then
            try
              dsf.AsDateTime := OERPDateToDateTime(value.AsString)
            except
              dsf.Clear
            end
          else
          begin
            fvalue := value.AsString;
            StrReplace(fvalue,#13#10,#13,[rfReplaceAll]);
            StrReplace(fvalue,#10,#13,[rfReplaceAll]);
            StrReplace(fvalue,#13,#13#10,[rfReplaceAll]);
            dsf.AsString := fvalue;
          end
      else
        dsf.AsString := value.AsString ;
      end;
    except
      on e:Exception do OutputDebugString(pchar(E.Message));
    end;
  end;
end;

procedure TOpenERPProvider.CreateDataPacket(PacketOpts: TGetRecordOptions;
  ProvOpts: TProviderOptions; var RecsOut: Integer; var Data: OleVariant);
var
  St:TMemoryStream;
  i,j,k:integer;
  row,rows,value:ISuperObject;
  names : ISuperObject;
  dsf : tfield;
  fname,ftype,fvalue : String;
  fmaxlen : integer;
  cds : TClientDataset;
  url:String;
  maxrec : integer;

  FDSWriter: TDataPacketWriter;
begin
  //recsout := 0;
  try
    cds := TClientDataset.Create(Nil);
    CreateFields(cds);
    cds.CreateDataSet;
    cds.LogChanges := False;

    if grReset in PacketOpts then
      NextOffset := 0;

    st := TMemoryStream.Create;
    if openerp_ids<>''  then
      url := '/object/'+openerp_class+'/read?'+
        'ids='+EncodeURIComponent(openerp_ids)
    else if openerp_filter<>'' then
      url := '/object/'+openerp_class+'/select?'+
        'domain='+EncodeURIComponent(openerp_filter)
    else
    begin
      url := '/object/'+openerp_class+'/read?'+
        'ids='+EncodeURIComponent('-1');
      //rien à renvoyer...
      RecsOut :=0;
    end;
    if openerp_fieldnames<>'' then
      url := url + '&fields='+EncodeURIComponent(openerp_fieldnames);
    if openerp_context<>'' then
      url := url + '&context='+EncodeURIComponent(openerp_context);
    if openerp_order<>'' then
      url := url + '&order='+EncodeURIComponent(openerp_order);

    if NextOffset>0 then
      url := url + '&offset='+inttostr(NextOffset);

    if RecsOut>=0 then
      url := url + '&limit='+inttostr(RecsOut)
    else
    if Fopenerp_limit>=0 then
      url := url + '&limit='+inttostr(Fopenerp_limit - NextOffset);

    if (Fopenerp_limit<>0) and (RecsOut<>0) then
    begin
      openerp_connection.http_get(url,st);
      maxrec := RecsOut;
      RecsOut := 0;
      rows := TSuperObject.ParseStream(st,false);
      if rows.DataType <> stArray then
        Raise Exception.Create(rows.AsString);
      if (rows <> Nil) and (rows.DataType = stArray) then
      begin
        for i:= 0 to rows.AsArray.Length-1 do
        begin
          if (maxrec>=0) and (RecsOut>=maxrec) then
            Break;
          inc(RecsOut);
          cds.Append;
          row := rows.AsArray[i];
          JSONToDataset(row,cds);
          cds.Post;
        end;
      end
      else
        Raise Exception.Create('Erreur proxy OpenERP : '+rows.AsString);
    end;
    
    FDSWriter := TDataPacketWriter.Create;

    //FDSWriter.Constraints := Constraints;
    //FDSWriter.OnGetParams := DoGetProviderAttributes;
    cds.First;
    //Data := cds.Data;
    FDSWriter.PacketOptions := PacketOpts;
    FDSWriter.Options := ProvOpts;
    FDSWriter.GetDataPacket(cds, RecsOut, Data);
    if maxrec>=0 then
      NextOffset := NextOffset+RecsOut;

  finally
    St.Free;
    Cds.Free;
  end;
end;

destructor TOpenERPProvider.Destroy;
begin
  ClearSelectionDatasets;
  SelectionDatasets.Free;
  inherited Destroy;
end;

procedure TOpenERPProvider.ClearSelectionDatasets;
var
  i:integer;
begin
  for i:=0 to SelectionDatasets.Count -1 do
    SelectionDatasets.objects[i].Free;
  SelectionDatasets.Clear;
end;

procedure TOpenERPProvider.Setopenerp_class(const Value: String);
begin
  metadata := Nil;
  Fopenerp_class := Value;
end;

procedure TOpenERPProvider.Setopenerp_fieldnames(const Value: String);
begin
  metadata := Nil;
  Fopenerp_fieldnames := Value;
end;

procedure TOpenERPProvider.Setopenerp_filter(const Value: string);
begin
  Fopenerp_filter := Value;
  Fopenerp_ids :='';
end;

procedure TOpenERPProvider.Setopenerp_ids(const Value: string);
var
  i:integer;
  nvalue:String;
begin
  nvalue := '';
  for i:=1 to length(value) do
    if CharIsDigit(value[i]) or (value[i]=',') or (value[i]='-') then
       nvalue := nvalue + value[i];
  Fopenerp_ids := nValue;
  Fopenerp_filter := '';
end;

procedure TOpenERPProvider.Setopenerp_proxyserver(const Value: String);
begin
  metadata := Nil;
  Fopenerp_proxyserver := Value;
end;

function TOpenERPProvider.Getmetadata: ISuperObject;
begin
  if fmetadata = Nil then
    fmetadata := LoadMetadata;
  result := fmetadata;
end;


procedure TOpenERPProvider.Setopenerp_limit(const Value: integer);
begin
  Fopenerp_limit := Value;
end;

function TOpenERPProvider.deltajson(Delta:OleVariant): String;
var
  i:integer;
  oldcds : TClientDataSet;
  newcds : TClientDataSet;

  meta,changes,rec_updates,updates : ISuperObject;
  fd : TField;

  id : integer;

  procedure setdeltavalue(fd:TField;metadata:ISuperObject;rec_updates:ISuperObject);
  var
    fname,ftype,fvalue:String;
  begin
    fname := fd.origin;
    if fname='' then
      fname := fd.FieldName;
    meta := metadata.O[fname];

    if (meta<>Nil) and not fd.ReadOnly and (pfInUpdate in fd.ProviderFlags) and (fd.FieldKind = fkData) and
      not (pfHidden in fd.ProviderFlags) and not VarIsClear(fd.NewValue) then
    begin
      ftype := meta.S['type'];
      if fd.IsNull then
        rec_updates.N[fname] := Nil
      else
      if ftype='char' then
      begin
        fvalue := fd.AsString;
        StrReplace(fvalue,#13#10,#13,[rfReplaceAll]);
        rec_updates.S[fname] := fvalue;
      end
      else if ftype='text' then
      begin
        fvalue := fd.AsString;
        StrReplace(fvalue,#13#10,#13,[rfReplaceAll]);
        rec_updates.S[fname] := fvalue;
      end
      else if ftype='boolean' then
      begin
          rec_updates.B[fname] := fd.AsBoolean
      end
      else if (ftype='integer') or (ftype='many2one') then
        rec_updates.I[fname] := fd.AsInteger
      else if (ftype='one2many') then
        rec_updates.S[fname] := deltajson(TClientDataSet(fd).Delta)
      else if ftype='float' then
        rec_updates.D[fname] := fd.AsFloat
      else if ftype='datetime' then
        rec_updates.S[fname] := DateTimeToOERPDateTime(fd.AsDateTime)
      else if ftype='date' then
        rec_updates.S[fname] := DateTimeToOERPDate(fd.AsDateTime)
      else if ftype='time' then
        rec_updates.S[fname] := DateTimeToOERPtime(fd.AsDateTime)
      else
        rec_updates.S[fname] := fd.AsString;
    end;

  end;

begin
  try
    oldcds:=TClientDataSet.Create(Nil);
    oldcds.Data := Delta;

    newcds:=TClientDataSet.Create(Nil);
    newcds.CloneCursor(oldcds,True,false);

    updates := TSuperObject.Create(stArray);
    oldcds.First;
    while not oldcds.Eof do
    begin

      //{'fieldname':value}
      rec_updates := TSuperObject.Create(stObject);

      // si 0 : insertion, sinon update ou effacement si seulement la clé id.
      id := oldcds.fieldbyname('id').AsInteger;
      rec_updates.I['id'] := id;

      if oldcds.UpdateStatus = usInserted then
      begin
        for i:=0 to oldcds.Fields.Count-1 do
        begin
          fd := oldcds.Fields[i];
          setdeltavalue(fd,metadata,rec_updates);
        end;
      end
      else
      if oldcds.UpdateStatus = usunModified then
      begin
        // les nouvelles valeurs sont dans l'enregistrement suivant
        newcds.RecNo := oldcds.RecNo;
        // on mete certaines anciennes valeurs dans le delat
        for i:=0 to oldcds.Fields.Count-1 do
        begin
          fd := oldcds.Fields[i];
          //méchant hack pour le problème de project.task.work qui veut user_id même si'l n'est pas modifié
          if (pfInWhere in fd.providerflags) or (fd.FieldName ='user_id') then
            setdeltavalue(fd,metadata,rec_updates);
        end;

        newcds.Next;
        for i:=0 to oldcds.Fields.Count-1 do
        begin
          fd := newcds.Fields[i];
          setdeltavalue(fd,metadata,rec_updates);
        end;

        oldcds.Next;
        // Pas de modification, on n'enregistre pas de delta
        if rec_updates.AsObject.GetNames.AsArray.Length<=1 then
          rec_updates:=Nil;
      end
      else
      if oldcds.UpdateStatus = usDeleted then
      begin

      end;

      if rec_updates<>Nil then
        updates.AsArray.Add(rec_updates);

      oldcds.Next;
    end;
    result := updates.AsJSon;

  finally
    oldcds.Free;
    newcds.Free;
  end;
end;

type thackcds = class(TCustomClientDataset) end;

function TOpenERPProvider.InternalApplyUpdates(const Delta: OleVariant; MaxErrors: Integer;
  out ErrorCount: Integer): OleVariant;
var
  fname,ftype:String;
  st : TMemoryStream;
  url,resultStr:String;

  i,id,j:integer;
  updates,error:ISuperObject;

  deltads,errords : TPacketDataSet;
  fd : TField;

  TempBase: IDSBase;

  TrueRecNo: DWord;
  CurVal: Variant;

  CurCDS : TOpenERPClientDataset;

  params:String;

begin
  result :=Null;
  try
    st := TMemoryStream.Create;

    //to get updated values
    curCDS := TOpenERPClientDataset.Create(Nil);
    curCDS.openerp_connection := Self.openerp_connection;
    curcds.openerp_class := self.openerp_class;
    curcds.openerp_fieldnames := self.openerp_fieldnames;

    url := '/object/'+openerp_class+'/apply_updates';
    params := 'delta='+
          EncodeURIComponent(deltajson(Delta));
    openerp_connection.http_post(url,params,St);
    updates := TSuperObject.ParseStream(St,False);
    lastupdates_result := updates;

    if updates.DataType<>stArray then
      raise Exception.Create(updates.AsString);

    deltads := TPacketDataSet.Create(Nil);
    deltads.Data := Delta;
    deltads.LogChanges := False;

    errords := TPacketDataSet.Create(Nil);
    errords.CreateFromDelta(deltads);
    errords.LogChanges := False;
    thackcds(errords).DSBase.SetProp(DSProp(dspropAUTOINC_DISABLED), Integer(True));

    ErrorCount := 0;
    for i:=0 to updates.AsArray.Length-1 do
    begin
      id := updates.AsArray[i].AsArray[0].AsInteger;
      error := updates.AsArray[i].AsArray[1];
      // recherche de l'enregistrement en erreur dans le delta
      if deltads.Locate('id',id,[]) then
      begin
        //InitErrorPacket
        Deltads.UpdateCursorPos;
        thackcds(Deltads).DSCursor.GetRecordNumber(TrueRecNo);

        if not errords.Locate('ERROR_RECORDNO', Integer(TrueRecNo), []) then
          errords.Append else
          errords.Edit;
        if not (error.DataType = stObject) then
          errords.SetFields([TrueRecNo, 0, '', '', 0, 0])
        else
        begin
          //Enregistrement rrAbort
          errords.SetFields([TrueRecNo, ord(rrAbort)+1, error.S['message'], '', 1, 1]);
          inc(ErrorCount);
        end;

        if (poPropogateChanges in Options) and Deltads.NewValuesModified and (error.DataType = stInt) then
        begin
          //nouvel ID
          CurCDS.openerp_ids :=  inttostr(updates.AsArray[i].AsArray[1].AsInteger);
          Deltads.AssignCurValues(CurCDS);
          Deltads.Open;
        end;

        //LogUpdateError
        if Deltads.HasCurValues then
          for j := 0 to Deltads.FieldCount - 1 do
          begin
            { Blobs, Bytes and VarBytes are not included in result packet }
            if (Deltads.Fields[j].IsBlob) or
               (Deltads.Fields[j].DataType in [ftBytes, ftVarBytes]) then
              continue;
            CurVal := Deltads.Fields[j].NewValue;
            if not VarIsClear(CurVal) then
              ErrorDS.FieldByName(Deltads.Fields[j].FieldName).Value := CurVal;
          end;
        errords.Post;
      end;
    end;
    if ErrorCount>0 then
      result := errords.Data;
  finally
    curcds.Free;
    deltads.free;
    errords.free;
    st.Free;
    // flusher le cache car on a changé des objets
    openerp_connection.Name_cache_flush(openerp_class);
  end;
end;


procedure TOpenERPProvider.Setopenerp_connection(
  const Value: TOpenERPConnection);
begin
{  if Assigned(Fopenerp_connection) then
    Fopenerp_connection.RemoveFreeNotification(Self);}
  Fopenerp_connection := Value;
{  if Assigned(Fopenerp_connection) then
    Fopenerp_connection.FreeNotification(Self);}
end;

procedure TOpenERPProvider.Notification(AComponent : TComponent;
  Operation : TOperation);
begin
  inherited;
  if (Operation = opRemove) and
     (AComponent = Fopenerp_connection) then
    Fopenerp_connection := Nil;
end;

function TOpenERPProvider.Get_openerpProxyserver: String;
begin
  if not assigned(Fopenerp_connection) then
    raise Exception.Create('Please connect to a OpenERPConnection component first');
  result := Fopenerp_connection.openerp_proxyserver;
end;

function TOpenERPProvider.Get_openerpContext: String;
begin
  if not assigned(Fopenerp_connection) then
    raise Exception.Create('Please connect to a OpenERPConnection component first');
  result := Fopenerp_connection.openerp_context;

end;

procedure TOpenERPProvider.Setopenerp_order(const Value: string);
begin
  Fopenerp_order := Value;
end;

function TOpenERPProvider.CallMethodSO(method: String;
  params: array of String): ISuperObject;
var
  St:TMemoryStream;
  url,paramsStr : String;
  i : integer;
begin
  try
    st := TMemoryStream.Create;
    url := '/object/'+openerp_class+'/'+method+'?args=';
    paramsStr := '';
    for i:=low(params) to high(params) do
    begin
      if paramsStr<>'' then
        paramsStr := paramsStr+',';
      paramsStr := paramsStr+Params[i];
    end;
    paramsStr := EncodeURIComponent('['+paramsStr+']');
    url := url+paramsStr;
    openerp_connection.http_get(url,st);
    result := TSuperObject.ParseStream(st,false);
  finally
    St.Free;
  end;
end;

function TOpenERPProvider.CallMethod(method: String;
  params: array of String): String;
var
  url,paramsStr : String;
  i : integer;
begin
  url := '/object/'+openerp_class+'/'+method+'?args=';
  paramsStr := '';
  for i:=low(params) to high(params) do
  begin
    if paramsStr<>'' then
      paramsStr := paramsStr+',';
    paramsStr := paramsStr+Params[i];
  end;
  paramsStr := EncodeURIComponent('['+paramsStr+']');
  url := url+paramsStr;
  Result := openerp_connection.http_get(url);
end;


function TOpenERPProvider.audit(id: String): String;
var
  so : ISuperObject;
begin
  Result := '';
  //so := CallMethodSO('perm_read',['['+id+']','null','true']);
  {if so.AsArray.Length>0 then
  begin
    so := so.AsArray[0];
    if so<>Nil then
      result :=
        'Créé le '+ copy(so['create_date'].AsString,1,16)+' par '+so['create_uid'].asArray[1].AsString+
        ', modifié le '+copy(so['write_date'].AsString,1,16)+' par '+so['write_uid'].asArray[1].AsString;
  end}
end;

procedure TOpenERPProvider.Setmetadata(const Value: ISuperObject);
begin
  ClearSelectiondatasets;
  fmetadata := Value;
end;

procedure TOpenERPProvider.MemoGetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
begin
  If Sender.IsNull then
    Text :=''
  else
    Text := TMemoField(Sender).AsString;
end;

{ TOpenERPConnection }

constructor TOpenERPConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  session_cookies := TIdCookieManager.Create(Self);
  Fopenerp_context := '{"lang":"fr_FR"}';
  name_cache_timeout := 10;
  openerp_cacheable_classes :='res.users;res.partner;res.partner.address;';
end;

destructor TOpenERPConnection.Destroy;
begin
  session_cookies.Free;
  if Assigned(NameCache) then
    NameCache.Free;
  inherited;
end;

function TOpenERPConnection.http_get(action_url: string;login_required:Boolean=True): String;
var
  St:TMemoryStream;
  url : String;
  http:TIdHTTP;

begin
  try
    http := Nil;
    if login_required and (Fopenerp_user_id <=0) then
      login;
    http:=TIdHTTP.Create(Nil);
    http.AllowCookies := True;
    http.CookieManager := session_cookies;

    if action_url[1]<>'/' then
      action_url := '/'+action_url;
    url := openerp_proxyserver+action_url;
    result := http.Get(url);
  finally
    http.DisconnectNotifyPeer;
    if http<>Nil then
      http.Free;
  end;
end;

function TOpenERPConnection.getopenerp_user_id: integer;
begin
  if Fopenerp_user_id=0 then
    login;
  Result := Fopenerp_user_id;
end;

procedure TOpenERPConnection.http_get(action_url: string; Stream: TStream;
  login_required: Boolean);
var
  St:TMemoryStream;
  url : String;
  http:TIdHTTP;

begin
  try
    http := Nil;
    if login_required and (Fopenerp_user_id <=0) then
      login;
    http:=TIdHTTP.Create(Nil);
    http.AllowCookies := True;
    http.CookieManager := session_cookies;

    if action_url[1]<>'/' then
      action_url := '/'+action_url;
    url := openerp_proxyserver+action_url;
    {if data<>'' then
    try
      st := TMemoryStream.Create;
      http.post(url,Stream);
    finally
      st.Free;
    end
    else}
      http.get(url,Stream);
  finally
    http.DisconnectNotifyPeer;
    if http<>Nil then
      http.Free;
  end;
end;

procedure TOpenERPConnection.login;
var
  res:Integer;
  nbtry:integer;
begin
  res := mrCancel;
  nbtry := 4;
  repeat
    if ((Fopenerp_user_id<=0) or (openerp_login='') or (openerp_password='')) and (nbtry>0) then
    with TLoginDlg.Create(Application) do
    try
      EdLoginId.Text := openerp_login;
      EdPwd.Text := openerp_password;
      res := ShowModal;
      if res=mrCancel then
      begin
        nbtry := 0;
        Break;
      end;
      openerp_login := EdLoginId.Text;
      openerp_password := EdPwd.Text;

    finally
      Free;
    end;
    Fopenerp_user_id := strtoint(http_post('login','openerp_login='+EncodeURIComponent(Fopenerp_login)+'&openerp_password='+EncodeURIComponent(Fopenerp_password),False));
    //Fopenerp_user_id := strtoint(http_get('login?openerp_login='+EncodeURIComponent(Fopenerp_login)+'&openerp_password='+EncodeURIComponent(Fopenerp_password),False));
    dec(nbtry);
  until (Fopenerp_user_id>0) or (nbtry<=0);
  if Fopenerp_user_id<=0 then
    raise Exception.Create('Authentification incorrecte');
end;

procedure TOpenERPConnection.logout;
begin
  http_get('logout',False);
  Fopenerp_user_id := -1;
  Fuseraccount_data := Nil;
end;

procedure TOpenERPConnection.Setopenerp_context(const Value: string);
begin
  Fopenerp_context := Value;
end;

procedure TOpenERPConnection.Setopenerp_login(const Value: string);
begin
  Fopenerp_login := Value;
  Fopenerp_user_id := -1;
end;

procedure TOpenERPConnection.Setopenerp_password(const Value: string);
begin
  Fopenerp_password := Value;
  Fopenerp_user_id := -1;
end;

procedure TOpenERPConnection.Setopenerp_proxyserver(const Value: String);
begin
  Fopenerp_proxyserver:=Value;
  Fopenerp_user_id := -1;
end;

function TOpenERPConnection.name_search(model, name, domain: String;
  limit: integer): ISuperObject;
var
  names: ISUperObject;
  St:TMemoryStream;
  url : String;

begin
  try
    if pos(',',name)>0 then
      name := copy(name,1,pos(',',name)-1);
    st := TMemoryStream.Create;
    url := '/object/'+model+'/name_search?'+
        'name='+EncodeURIComponent(name);
    if domain<>'' then
      url := url + '&domain='+EncodeURIComponent(domain);
    if openerp_context<>'' then
      url := url + '&context='+EncodeURIComponent(openerp_context);
    if limit>=0 then
      url := url + '&limit='+inttostr(limit);
    http_get(url,st);
    result := TSuperObject.ParseStream(st,false);
  finally
    St.Free;
  end;
end;

function TOpenERPConnection.name_search(model, name, domain: String;
  limit: integer; ResultCDS: TClientdataset): integer;
var
  names,item : ISuperObject;
  fd:TField;
  i:integer;
  currid : integer;
begin
  names := name_search(model,name,domain,limit);
  if names.DataType = stArray then
  begin
    if ResultCDS.Fields.Count<=0 then
    begin
      fd := TIntegerField.Create(ResultCDS);
      fd.FieldName := 'id';
      fd.DisplayLabel := 'Id';
      fd.DataSet := ResultCDS;

      fd := TStringField.Create(ResultCDS);
      fd.FieldName := 'name';
      fd.DisplayLabel := 'Name';
      fd.DataSet := ResultCDS;
      fd.Size := 255;
    end;
    if not ResultCDS.Active then
      ResultCDS.CreateDataSet;
    currid := ResultCDS.fieldbyname('id').AsInteger;
    ResultCDS.EmptyDataSet;
    ResultCDS.LogChanges := False;
    try
      ResultCDS.DisableControls;
      for i:=0 to names.AsArray.Length-1 do
      begin
        item := names.AsArray[i];
        ResultCDS.Append;
        ResultCDS.FieldByName('id').AsInteger := item.AsArray[0].AsInteger;
        ResultCDS.FieldByName('name').AsString :=  item.AsArray[1].AsString;
        ResultCDS.Post;
      end;
    finally
      ResultCDS.EnableControls;
      resultCDS.locate('id',currid,[]);
    end;
  end
  else
    Raise Exception.Create(names.AsString);
end;


{function TOpenERPConnection.name_get(model: String; id: integer): String;
var
  names: ISUperObject;
  St:TMemoryStream;
  url : String;
  so : ISuperObject;

begin
  if id<=0 then
    Result := ''
  else
  try
    st := TMemoryStream.Create;
    url := '/object/'+model+'/name_get?'+
        'ids='+intToStr(id);
    http_get(url,st);
    so := TSuperObject.ParseStream(st,false);
    if (so.DataType<> stArray) then
      raise Exception.Create(so.AsString);
    if (so.AsArray.Length<>1) then
      raise Exception.create('ID '+intToStr(id)+' not found in '+model+' table');
    result :=so.AsArray[0].AsArray[1].AsString;
  finally
    St.Free;
  end;
end;
}

function TOpenERPConnection.Name_get(aclass: String; aID: Integer): String;
var
  so,item : ISuperObject;
  fd:TField;
  tok:String;
  cacheable : Boolean;
begin
  if NameCache = Nil then
    NameCache := TClientDataSet.Create(Nil);
  if not NameCache.Active then
  begin
    fd := TStringField.Create(NameCache);
    fd.FieldName := 'class';
    fd.Size := 255;
    fd.DataSet := NameCache;

    fd := TIntegerField.Create(NameCache);
    fd.FieldName := 'id';
    fd.DataSet := NameCache;

    fd := TStringField.Create(NameCache);
    fd.FieldName := 'name';
    fd.Size := 800;
    fd.DataSet := NameCache;

    fd := TDateTimeField.Create(NameCache);
    fd.FieldName := 'datecreat';
    fd.DataSet := NameCache;

    NameCache.CreateDataSet;
    NameCache.LogChanges := False;
    NameCache.IndexFieldNames := 'class;id';
  end;

  cacheable := False;
  tok := openerp_cacheable_classes;
  repeat
    if StrToken(tok,';') = aclass then
    begin
      cacheable := True;
      Break;
    end;
  until tok='';

  if not cacheable or not NameCache.FindKey([aclass,aID]) or (NameCache['datecreat']< Now-(1/(24*60))*name_cache_timeout )  then
  begin
    so := CallMethodSO(aClass,'name_get',['['+intToStr(aID)+']']);
    if (so.DataType = stArray) and (so.AsArray.Length=1) then
    begin
      item := so.AsArray[0].AsArray[1];
      if (item.DataType = stBoolean) or (item.AsString='False') then
      begin
        Result := '';
        cacheable := False;
      end
      else
        result := item.AsString;
    end
    else
      raise Exception.create('ID '+intToStr(aid)+' not found in '+aclass+' table');

    //Effacer entrée périmée
    if not NameCache.eof and (NameCache['class'] = aClass) and (NameCache['id'] = aID)  then
      NameCache.Delete;

    if Cacheable then
    begin
      NameCache.Append;
      NameCache['datecreat'] := Now;
      NameCache['class'] := aclass;
      NameCache['id'] := aID;
      NameCache['name'] := Result;
      NameCache.Post;
    end;
  end
  else
    Result:= NameCache['name'];
end;


function TOpenERPConnection.http_post(action_url: string;Params:String;
  login_required: Boolean): String;
var
  St:TMemoryStream;
  url : String;
  http:TIdHTTP;
  paramsStream:TStringStream;
begin
  try
    http := Nil;
    paramsStream := Nil;
    if login_required and (Fopenerp_user_id <=0) then
      login;
    http:=TIdHTTP.Create(Nil);
    paramsStream := TStringStream.Create(Params);
    HTTP.Request.ContentType := 'application/x-www-form-urlencoded';
    http.AllowCookies := True;
    http.CookieManager := session_cookies;

    if action_url[1]<>'/' then
      action_url := '/'+action_url;
    url := openerp_proxyserver+action_url;
    result := http.Post(url,paramsStream);
  finally
    if paramsStream<>Nil then
      paramsStream.Free;
    http.DisconnectNotifyPeer;
    if http<>Nil then
      http.Free;
  end;
end;

procedure TOpenERPConnection.http_post(action_url: string;Params:String;
  Stream:TStream;login_required: Boolean);
var
  St:TMemoryStream;
  url : String;
  http:TIdHTTP;
  paramsStream:TStringStream;
begin
  try
    http := Nil;
    paramsStream := Nil;
    if login_required and (Fopenerp_user_id <=0) then
      login;
    http:=TIdHTTP.Create(Nil);
    paramsStream := TStringStream.Create(Params);
    HTTP.Request.ContentType := 'application/x-www-form-urlencoded';
    http.AllowCookies := True;
    http.CookieManager := session_cookies;

    if action_url[1]<>'/' then
      action_url := '/'+action_url;
    url := openerp_proxyserver+action_url;
    http.Post(url,paramsStream,Stream);
  finally
    if paramsStream<>Nil then
      paramsStream.Free;
    if http<>Nil then
      http.Free;
  end;
end;


function TOpenERPConnection.CallMethodSO(model,method: String;
  params: array of String): ISuperObject;
var
  St:TMemoryStream;
  url,paramsStr : String;
  i : integer;
begin
  try
    st := TMemoryStream.Create;
    url := '/object/'+model+'/'+method+'?args=';
    paramsStr := '';
    for i:=low(params) to high(params) do
    begin
      if paramsStr<>'' then
        paramsStr := paramsStr+',';
      paramsStr := paramsStr+Params[i];
    end;
    paramsStr := EncodeURIComponent('['+paramsStr+']');
    url := url+paramsStr;
    http_get(url,st);
    result := TSuperObject.ParseStream(st,false);
  finally
    St.Free;
  end;
end;

function TOpenERPConnection.CallMethod(model,method: String;
  params: array of String): String;
var
  url,paramsStr : String;
  i : integer;
begin
  url := '/object/'+model+'/'+method+'?args=';
  paramsStr := '';
  for i:=low(params) to high(params) do
  begin
    if paramsStr<>'' then
      paramsStr := paramsStr+',';
    paramsStr := paramsStr+Params[i];
  end;
  paramsStr := EncodeURIComponent('['+paramsStr+']');
  url := url+paramsStr;
  Result := http_get(url);
end;

procedure TOpenERPConnection.Name_cache_flush(aclass: String);
begin
  if Assigned(NameCache) and NameCache.Active then
  begin
    NameCache.SetRange([aclass],[aclass]);
    try
      NameCaChe.First;
      While not NameCache.Eof do
        NameCache.Delete;
    finally
      NameCache.CancelRange;
    end;
  end;
end;

procedure TOpenERPConnection.Setopenerp_cacheable_classes(
  const Value: string);
begin
  Fopenerp_cacheable_classes := Value;
  if (NameCache<>Nil) and NameCache.Active then
    NameCache.EmptyDataSet;
end;

function TOpenERPConnection.Getuseraccount_data: ISUperObject;
begin
  if Fuseraccount_data = Nil then
    Fuseraccount_data := CallMethodSO('hr.analytic.timesheet','on_change_user_id',['[]',intToStr(openerp_user_id)]);
  Result := Fuseraccount_data;
end;

{ TOpenERPClientDataset }

constructor TOpenERPClientDataset.Create(AOwner: TComponent);
begin
  inherited;
  OpenERPProvider := TOpenERPProvider.Create(Self);
  OpenERPProvider.Name := 'internal';
  //SetProvider(FOpenERPProvider);
  FModifiedList := TStringList.Create ;

end;

procedure TOpenERPClientDataset.DoOnNewRecord;
var
  I: Integer;
  defaults : ISuperObject;

begin
  //init default values
  if Assigned(FOpenERPProvider) and Assigned(FOpenERPProvider.metadata) then
  begin
    defaults :=  FOpenERPProvider.LoadDefaults;
    FOpenERPProvider.JSONToDataset(defaults,Self);
    dec(tmp_id);
    FieldByName('id').AsInteger := tmp_id;
  end;
  inherited DoOnNewRecord;
end;


destructor TOpenERPClientDataset.Destroy;
begin
  FOpenERPProvider.Free;
  FModifiedList.Free ;
  inherited;
end;

function TOpenERPClientDataset.Getopenerp_connection: TOpenERPConnection;
begin
  Result := FOpenERPProvider.openerp_connection;
end;

function TOpenERPClientDataset.Get_openerpContext: String;
begin
  Result := FOpenERPProvider.openerp_context;
end;

function TOpenERPClientDataset.Get_openerpProxyserver: String;
begin
  Result := FOpenERPProvider.openerp_proxyserver;

end;

function TOpenERPClientDataset.Getopenerp_class: String;
begin
  Result := FOpenERPProvider.openerp_class;
end;

function TOpenERPClientDataset.Getopenerp_fieldnames: String;
begin
  Result := FOpenERPProvider.Fopenerp_fieldnames;
end;

function TOpenERPClientDataset.Getopenerp_filter: string;
begin
  Result := FOpenERPProvider.Fopenerp_filter;
end;

function TOpenERPClientDataset.Getopenerp_ids: string;
begin
  Result := FOpenERPProvider.Fopenerp_ids;
end;

function TOpenERPClientDataset.Getopenerp_limit: integer;
begin
  Result := FOpenERPProvider.Fopenerp_limit;
end;

procedure TOpenERPClientDataset.Setopenerp_connection(
  const Value: TOpenERPConnection);
begin
  Close;
  FOpenERPProvider.openerp_connection := Value;
end;

procedure TOpenERPClientDataset.SetOpenERPProvider(
  const Value: TOpenERPProvider);
begin
  Close;
  AppServer := TOpenERPAppServer.Create(TCustomProvider(value));
  FOpenERPProvider := Value;
end;

procedure TOpenERPClientDataset.Setopenerp_class(const Value: String);
begin
  Close;
  //On reforce
  ////SetProvider(FOpenERPProvider);
  FOpenERPProvider.Setopenerp_class(Value);
end;

procedure TOpenERPClientDataset.Setopenerp_fieldnames(const Value: String);
begin
  Close;
  //On reforce
  ////SetProvider(FOpenERPProvider);
  FOpenERPProvider.Setopenerp_fieldnames(Value);

end;

procedure TOpenERPClientDataset.Setopenerp_filter(const Value: string);
begin
  Close;
  ////SetProvider(FOpenERPProvider);
  FOpenERPProvider.Setopenerp_filter(Value);

end;

procedure TOpenERPClientDataset.Setopenerp_ids(const Value: string);
begin
  Close;
  ////SetProvider(FOpenERPProvider);
  FOpenERPProvider.Setopenerp_ids(Value);

end;

procedure TOpenERPClientDataset.Setopenerp_limit(const Value: integer);
begin
  ////SetProvider(FOpenERPProvider);
  FOpenERPProvider.Setopenerp_limit(Value);

end;

procedure TOpenERPClientDataset.OpenCursor(InfoQuery: Boolean);
var
  i:integer;
  fd : ISuperObject;
  fname,ftype: String;
  dsf:TField;
begin
  //On reforce
  //SetProvider(FOpenERPProvider);

  // on remet les propriétés lookup many2one
  If Assigned(FOpenERPProvider) then
  begin
    for i:=0 to OpenERPProvider.metadata.AsObject.GetNames.AsArray.Length-1 do
    begin
      fname := OpenERPProvider.metadata.AsObject.GetNames.AsArray[i].AsString;
      fd := OpenERPProvider.metadata[fname];
      ftype := fd['type'].AsString;
      if  ftype = 'many2one' then
      begin
        if FindField(fname)<>Nil then FieldByName(fname).LookupResultField := copy(fname,1,31-4)+'_lib';
        if FindField(copy(fname,1,31-4)+'_lib')<>Nil then FieldByName(copy(fname,1,31-4)+'_lib').LookupKeyFields := fname;
      end
      else
      if fd['type'].AsString = 'one2many' then
      begin
        dsf := FindField(fname);
        if (dsf <> Nil) and (not Assigned(TMemoField(dsf).OnGetText)) then
          TMemoField(dsf).OnGetText := FOpenERPProvider.MemoGetText;
      end
      else if fd['type'].AsString = 'text' then
      begin
        dsf := FindField(fname);
        if (dsf <> Nil) and (not Assigned(TMemoField(dsf).OnGetText)) then
          TMemoField(dsf).OnGetText := FOpenERPProvider.MemoGetText;
      end
      else if fd['type'].AsString='selection' then
      begin
        // creer un champ libellé de type lookup si il n'existe pas...
        dsf := FindField(copy(fname,1,31-4)+'_lu');
        if dsf <> Nil then
        begin
          {dsf := TStringField.Create(Self.Owner);
          dsf.FieldName := copy(fname,1,31-4)+'_lu';
          dsf.Name:=Self.Name+dsf.FieldName;
          with dsf as TStringField do Size := 255;
          dsf.dataset := Self;}
        //end;
          dsf.ProviderFlags := dsf.ProviderFlags - [pfInwhere,pfInUpdate];
          dsf.KeyFields := fname;
          dsf.LookupKeyFields := 'id';
          dsf.LookupResultField := 'name';
          dsf.LookupDataSet := OpenERPProvider.CreateLookupDataset(fname);
          dsf.FieldKind := fkLookup;
          if fd['string']<>Nil then
            dsf.DisplayLabel := fd.S['string'];
          dsf.DisplayWidth := 15;
        end;
      end
    end;
  end;
  inherited;
end;

function TOpenERPClientDataset.Getopenerp_order: string;
begin
  result := FOpenERPProvider.openerp_order;
end;

procedure TOpenERPClientDataset.Setopenerp_order(const Value: string);
begin
  FOpenERPProvider.openerp_order := Value;
end;


function TOpenERPProvider.GetIDFromLastUpdate(tmpID: Integer): integer;
var
  i:integer;
begin
  Result := -1;
  if Assigned( lastupdates_result) and (lastupdates_result.DataType=stArray) then
  begin
    // le retour du internal applyupdat est un tablea  [[idtemp,id definitif],..]
    for i:=0 to lastupdates_result.asArray.Length-1 do
    begin
      if lastupdates_result.AsArray[i].AsArray.I[0]=tmpID then
      begin
        Result := lastupdates_result.AsArray[i].AsArray.I[1];
        Break;
      end;
    end;
    // si pas trouvé mais pas temporaire
    if tmpID>0 then
      Result := tmpID;
  end
  else
  if tmpID>0 then
    Result := tmpID;
end;

//type tcdshack = class( TCustomClientdataset);

function TOpenERPClientDataset.PreviousValue(Field: TField): Variant;
begin
  Result := GetStateFieldValue(dsOldValue, Field);
end;

procedure TOpenERPClientDataset.DoBeforeEdit;
begin
  // Clear old values
  FModifiedList.Clear ;
  inherited;
end;

procedure TOpenERPClientDataset.DataEvent(Event: TDataEvent;
  Info: Integer);
var
  Fld : TField ;
  so : ISuperObject;
  idnotfound:Boolean;

  procedure AddToList(AFld:TField);
  var i : Integer ;
  begin
    i := FModifiedList.IndexOf(AFld.FieldName);
    if (i < 0) Then FModifiedList.AddObject(AFld.FieldName,AFld);
  end;

begin
   inherited ;
   Fld := TField(Info);
   Case Event Of
      deFieldChange:
         try
            inc(inDataEvent);
            if (Fld <> Nil) then
            begin
              AddToList(Fld);
              If Assigned(FFieldModEvent) and (InDataEvent=1) then
                FFieldModEvent(Fld);
              if (InDataEvent=1) and not Fld.Lookup  then
                if (Fld.LookupResultField <> '') then
                // calcul libellé à partir code
                begin
                  if FindField(Fld.LookupResultField)<>Nil then
                    if (Fld.AsInteger>0) then
                      // recherche la table à interroger
                      FieldByName(Fld.LookupResultField).AsString := openerp_connection.name_get(
                        OpenERPProvider.metadata[fld.FieldName].S['relation'],Fld.AsInteger)
                    else
                      FieldByName(Fld.LookupResultField).Clear;

                end
                else
                if (Fld.LookupKeyFields <> '') then
                // calcul code à partir du libellé
                begin
                  if FindField(Fld.LookupKeyFields)<>Nil then
                    if (Fld.AsString<>'') then
                    begin
                      idnotfound := True;
                      // si la chaine une un entier, on considère un ID en premier :
                      if StrIsDigit(Fld.AsString) then
                      try
                        FieldByName(Fld.LookupKeyFields).Asinteger := Fld.AsInteger;
                        Fld.AsString := openerp_connection.name_get(OpenERPProvider.metadata[Fld.LookupKeyFields].S['relation'],Fld.AsInteger);
                        idnotfound := False;
                      except
                        idnotfound := True;
                      end;
                      if idnotfound then
                      begin
                        // recherche la table à interroger
                        so := openerp_connection.name_search(OpenERPProvider.metadata[Fld.LookupKeyFields].S['relation'],Fld.AsString,'',-1);
                        // si on trouve une correspondance et une seule...
                        if (so.DataType = stArray) and (so.AsArray.Length=1) then
                        begin
                          FieldByName(Fld.LookupKeyFields).Asinteger := so.AsArray[0].AsArray[0].AsInteger;
                          Fld.AsString := so.AsArray[0].AsArray[1].AsString;
                        end;
                      end;
                    end
                    else
                      FieldByName(Fld.LookupKeyFields).Clear;
                end;
            end;
         finally
            dec(inDataEvent);
         end;
   end;
end;


function TOpenERPClientDataset.IsModified(F: TField): Boolean;
begin
  Result := FModifiedList.IndexOfObject(F)>=0;
end;

procedure TOpenERPClientDataset.DoBeforeInsert;
begin
  // Clear old values
  FModifiedList.Clear ;
  inherited;
end;

procedure TOpenERPClientDataset.InternalRefresh;
begin
  //SetProvider(FOpenERPProvider);
  inherited;

end;


function TOpenERPClientDataSet.GetAppServer: IAppServer;
var
  ProvComp: TComponent;
  DS: TObject;
begin
  if not HasAppServer then
  begin
    if Assigned(FOpenERPProvider) then
    begin
      DS := GetObjectProperty(FOpenERPProvider, 'DataSet');
      if Assigned(DS) and (DS = Self) then
        DatabaseError(SNoCircularReference, Self);
      AppServer := TOpenERPAppServer.Create(TCustomProvider(FOpenERPProvider));
    end;
    if not HasAppServer then
      DatabaseError(SNoDataProvider, Self);
  end;
  Result := inherited GetAppServer;
end;



{ TOpenERPAppServer }

constructor TOpenERPAppServer.Create(AProvider: TCustomProvider);
begin
  inherited Create;
  FProvider := AProvider;
end;

destructor TOpenERPAppServer.Destroy;
begin
  if FProviderCreated then FProvider.Free;
  inherited Destroy;
end;

function TOpenERPAppServer.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOpenERPAppServer.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOpenERPAppServer.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOpenERPAppServer.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOpenERPAppServer.AS_ApplyUpdates(const ProviderName: WideString;
  Delta: OleVariant; MaxErrors: Integer; out ErrorCount: Integer;
  var OwnerData: OleVariant): OleVariant;
begin
  Result := FProvider.ApplyUpdates(Delta, MaxErrors, ErrorCount, OwnerData);
end;

function TOpenERPAppServer.AS_GetRecords(const ProviderName: WideString; Count: Integer;
  out RecsOut: Integer; Options: Integer; const CommandText: WideString;
  var Params, OwnerData: OleVariant): OleVariant;
begin
  Result := FProvider.GetRecords(Count, RecsOut, Options, CommandText, Params,
    OwnerData);
end;

function TOpenERPAppServer.AS_GetProviderNames: OleVariant;
begin
  Result := NULL;
end;

function TOpenERPAppServer.AS_DataRequest(const ProviderName: WideString;
  Data: OleVariant): OleVariant;
begin
  Result := FProvider.DataRequest(Data);
end;

function TOpenERPAppServer.AS_GetParams(const ProviderName: WideString;
  var OwnerData: OleVariant): OleVariant;
begin
  Result := FProvider.GetParams(OwnerData);
end;

function TOpenERPAppServer.AS_RowRequest(const ProviderName: WideString;
  Row: OleVariant; RequestType: Integer; var OwnerData: OleVariant): OleVariant;
begin
  Result := FProvider.RowRequest(Row, RequestType, OwnerData);
end;

procedure TOpenERPAppServer.AS_Execute(const ProviderName: WideString;
   const CommandText: WideString; var Params, OwnerData: OleVariant);
begin
  FProvider.Execute(CommandText, Params, OwnerData);
end;

function TOpenERPAppServer.InterfaceSupportsErrorInfo(const iid: TGUID): HResult;
begin
  if IsEqualGUID(IAppServer, iid) then
    Result := S_OK else
    Result := S_FALSE;
end;

function TOpenERPAppServer.SafeCallException(ExceptObject: TObject;
  ExceptAddr: Pointer): HResult;
begin
{$IFDEF MSWINDOWS}
  Result := HandleSafeCallException(ExceptObject, ExceptAddr, IAppServer, '', '');
{$ENDIF}
{$IFDEF LINUX}
	if ExceptObject is Exception then
	begin
		SetSafeCallExceptionMsg(Exception(ExceptObject).Message);
		SetSafeCallExceptionAddr(ExceptAddr);
		Result := HResult($8000FFFF);
	end
	else
    Result := inherited SafeCallException(ExceptObject, ExceptAddr);
{$ENDIF}
end;

procedure TOpenERPAppServer.SetProvider(const Value: TCustomProvider);
begin
  FProvider := Value;
end;

end.
