unit oerpclientDataSet;

interface

uses
  Windows, Messages, SysUtils, Classes, DB , DBClient;

type
  TOERPClientDataSet = class(tclientDataSet)
  private
    Fopenerp_class: String;
    Fopenerp_proxyserver: String;
    Fopenerp_filter: string;
    Fopenerp_fieldnames: String;
    procedure Setopenerp_class(const Value: String);
    procedure Setopenerp_filter(const Value: string);
    procedure Setopenerp_proxyserver(const Value: String);
    procedure Setopenerp_fieldnames(const Value: String);
    function DoGetRecords(Count: Integer; out RecsOut: Integer;
      Options: Integer; const CommandText: WideString;
      Params: OleVariant): OleVariant; override;
    { Déclarations privées }
  protected
    { Déclarations protégées }
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent); override;
  published
    { Déclarations publiées }
    property openerp_proxyserver:String read Fopenerp_proxyserver write Setopenerp_proxyserver;
    property openerp_class:String read Fopenerp_class write Setopenerp_class;
    property openerp_fieldnames:String read Fopenerp_fieldnames write Setopenerp_fieldnames;
    property openerp_filter:string read Fopenerp_filter write Setopenerp_filter;
  end;

procedure Register;

function EncodeURIComponent(const ASrc: string): UTF8String;

implementation
uses Variants,superobject,jclStrings,IdHTTP,dsintf;

procedure Register;
begin
  RegisterComponents('AccèsBD', [toerpclientDataSet]);
end;

{ toerpclientDataSet }


function EncodeURIComponent(const ASrc: string): UTF8String;
const
  HexMap: UTF8String = '0123456789ABCDEF';

      function IsSafeChar(ch: Integer): Boolean;
      begin
        if (ch >= 48) and (ch <= 57) then Result := True    // 0-9
        else if (ch >= 65) and (ch <= 90) then Result := True  // A-Z
        else if (ch >= 97) and (ch <= 122) then Result := True  // a-z
        else if (ch = 33) then Result := True // !
        else if (ch >= 39) and (ch <= 42) then Result := True // '()*
        else if (ch >= 45) and (ch <= 46) then Result := True // -.
        else if (ch = 95) then Result := True // _
        else if (ch = 126) then Result := True // ~
        else Result := False;
      end;
var
  I, J: Integer;
  ASrcUTF8: UTF8String;
begin
  Result := '';    {Do not Localize}

  ASrcUTF8 := UTF8Encode(ASrc);
    // UTF8Encode call not strictly necessary but 
    // prevents implicit conversion warning

  I := 1; J := 1;
  SetLength(Result, Length(ASrcUTF8) * 3); // space to %xx encode every byte
  while I <= Length(ASrcUTF8) do
  begin
    if IsSafeChar(Ord(ASrcUTF8[I])) then
    begin
      Result[J] := ASrcUTF8[I];
      Inc(J);
    end
    else if ASrcUTF8[I] = ' ' then
    begin
      Result[J] := '+';
      Inc(J);
    end
    else
    begin
      Result[J] := '%';
      Result[J+1] := HexMap[(Ord(ASrcUTF8[I]) shr 4) + 1];
      Result[J+2] := HexMap[(Ord(ASrcUTF8[I]) and 15) + 1];
      Inc(J,3);
    end;
    Inc(I);
  end;

  SetLength(Result, J-1);
end;


procedure toerpclientDataSet.Setopenerp_class(const Value: String);
begin
  data := Null;
  Fopenerp_class := Value;
end;

procedure toerpclientDataSet.Setopenerp_filter(const Value: string);
begin
  if Active then
    EmptyDataSet;
  Fopenerp_filter := Value;
end;

procedure toerpclientDataSet.Setopenerp_proxyserver(const Value: String);
begin
  data := NULL;
  Fopenerp_proxyserver := Value;
end;

procedure TOERPClientDataSet.Setopenerp_fieldnames(const Value: String);
begin
  data := Null;
  Fopenerp_fieldnames := Value;
end;

procedure LoadOERPFields(dataset:TClientdataset;openerp_proxyserver,openerp_class,openerp_fieldnames:String);
var
  St:TMemoryStream;
  i:integer;
  fd : ISuperObject;
  fn : String;
  dsf : tfield;
  meta : ISuperObject;
  url,fname,ftype,fdescription : String;
  fmaxlen,fwidth : integer;
  http:TIdHTTP;

begin
  dataset.data := Null;
  dataset.FieldDefs.Clear;
  dataset.Fields.Clear;
  try
    try
      st := TMemoryStream.Create;
      http:=TIdHTTP.Create(Nil);
      url := openerp_proxyserver+'/object/'+openerp_class+'/fields_get?context='+EncodeURIComponent('{"lang":"fr_FR"}');
      if openerp_fieldnames<>'' then
        url := url + '&fields='+EncodeURIComponent(openerp_fieldnames);
      http.Get(url,st);

      //ID hardcoded.
      dsf :=  TIntegerField.Create(dataset);
      dsf.FieldName := 'id';
      dsf.DisplayWidth := 6;
      dsf.Dataset := dataset;

      meta := TSuperObject.ParseStream(st,false);
      if meta <> Nil then
      begin
        for i:=0 to meta.AsObject.GetNames.AsArray.Length-1 do
        begin
          dsf := Nil;
          fmaxlen := 255;
          fwidth := 10;
          fname := meta.AsObject.GetNames.AsArray[i].AsString;
          fd := meta.AsObject.O[fname];
          ftype := fd['type'].AsString;
          if ftype='integer' then
            dsf :=  TIntegerField.Create(dataset)
          else if ftype='string' then
          begin
            try
              fmaxlen := fd['size'].AsInteger;
            except
            end;
            dsf := TStringField.Create(dataset);
            with dsf as TStringField do
            begin
              Size := fmaxlen;
            end;
          end else if ftype='float' then
            dsf := TFloatField.Create(dataset)
          else if ftype='boolean' then
            dsf := TBooleanField.Create(dataset)
          else if ftype='date' then
          begin
            dsf := TStringField.Create(dataset);
            with dsf as TStringField do Size := 10;
          end
          else if ftype='datetime' then
          begin
            dsf := TStringField.Create(dataset);
            with dsf as TStringField do Size := 20;
          end
          else if ftype='time' then
          begin
            dsf := TStringField.Create(dataset);
            with dsf as TStringField do Size := 8;
          end
          else if ftype='many2one' then
          begin
            // creer un champ id et un champ libellé
            dsf := TStringField.Create(dataset);
            dsf.FieldName := copy(fname,1,31-4)+'_lib';
            dsf.DisplayLabel := fd['string'].AsString;
            if fwidth<fmaxlen then
              dsf.DisplayWidth := fwidth
            else
              dsf.DisplayWidth := fmaxlen;
            dsf.FieldKind := fkInternalCalc;
            dsf.Dataset := dataset;

            dsf := TIntegerField.Create(dataset);
            dsf.Visible := False;
            if fd['string']<>Nil then
              fd.S['string'] :=  'ID '+fd['string'].AsString;
          end
          else
          begin
            dsf := TStringField.Create(dataset);
            with dsf as TStringField do Size := 255;
          end;
          if dsf<>Nil then
          begin
            dsf.Origin := fname;
            dsf.FieldName := copy(fname,1,31);
            if fd['string']<>Nil then
              dsf.DisplayLabel := fd['string'].AsString;
            if fwidth<fmaxlen then
              dsf.DisplayWidth := fwidth
            else
              dsf.DisplayWidth := fmaxlen;
            dsf.FieldKind := fkData;
            dsf.DataSet := dataset;
          end;
        end;
      end;
    finally
      http.Free;
      St.Free;
    end;
  except
    dataset.Fields.Clear;
    dataset.FieldDefs.Clear;
    raise;
  end;
end;


function LoadOERPRecords(openerp_proxyserver,openerp_class,openerp_fieldnames,openerp_filter:String;out recsout:integer):OleVariant;
var
  St:TMemoryStream;
  so:ISuperObject;
  i,j,k:integer;
  row,rows,r,f,value:ISuperObject;
  fd,names : ISuperObject;
  fn : String;
  dsf : tfield;
  meta : ISuperObject;
  fname,ftype,fdescription : String;
  fmaxlen : integer;
  http: TIdhttp;
  cds : TClientDataset;

begin
  recsout := 0;
  result := Null;
  try
    cds := TClientDataset.Create(Nil);
    LoadOERPFields(cds,openerp_proxyserver,openerp_class,openerp_fieldnames);
    cds.CreateDataSet;
    cds.LogChanges := False;

    st := TMemoryStream.Create;
    http:=TIdHTTP.Create(Nil);
    http.Get(openerp_proxyserver+'/object/'+openerp_class+'/select?'+
      'domain='+EncodeURIComponent(openerp_filter)+
      '&fields='+EncodeURIComponent(openerp_fieldnames),st);
    rows := TSuperObject.ParseStream(st,false);
    if rows <> Nil then
    begin
      for i:= 0 to rows.AsArray.Length-1 do
      begin
        cds.Append;
        row := rows.AsArray[i];
        names := row.AsObject.GetNames;
        for j := 0 to names.AsArray.Length-1 do
        begin
          fn := names.AsArray[j].AsString;
          try
            dsf := cds.FieldByName(fn);
            value := row.O[fn];
            case value.DataType of
              stNull : dsf.clear;
              stBoolean : if dsf.DataType = ftBoolean then dsf.AsBoolean := value.AsBoolean else dsf.Clear;
              stDouble,stCurrency  : dsf.AsFloat := value.AsDouble;
              stInt : dsf.AsInteger := value.AsInteger;
              stArray :
                begin
                  dsf.AsString := row.A[fn][0].AsString;
                  cds.FieldByName(fn+'_lib').AsString := row.A[fn][1].AsString;
                end;
              stObject,
              stString : dsf.AsString := value.AsString ;
            else
              dsf.AsString := value.AsString ;
            end;
          except
          end;
        end;
        cds.Post;
        inc(recsout);
      end;
      result := cds.Data;
    end;
  finally
    St.Free;
    Cds.Free;
  end;
end;


function toerpclientDataSet.DoGetRecords(Count: Integer; out RecsOut: Integer;
  Options: Integer; const CommandText: WideString; Params: OleVariant): OleVariant;
var
  OwnerData: OleVariant;
begin
  DoBeforeGetRecords(OwnerData);
  {if Fields.Count=0 then
    LoadOERPFields(self,openerp_proxyserver, openerp_class,openerp_fieldnames);}
  result := LoadOERPRecords(openerp_proxyserver,  openerp_class,openerp_fieldnames,openerp_filter,recsout);
  //UnPackParams(Params, Self.Params);
  DoAfterGetRecords(OwnerData);
end;


constructor TOERPClientDataSet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Fopenerp_class := 'res.users';
  Fopenerp_filter := '[]';
  Fopenerp_fieldnames := 'name';
end;

end.
