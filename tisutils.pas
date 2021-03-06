unit tisutils;
interface

uses
	Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,Dialogs, IniFiles;

type
  TUrlIniFile=Class(TMemIniFile)
    public
      constructor Create(const URL: string);
  end;

  TDynStringArray=Array of String;
  TDynIntArray=Array of Integer;

function Appuserinipath:String;
function GetUserName : String;
function GetApplicationName:String;
function GetPersonalFolder:String;
function GetAppdataFolder:String;
function GetApplicationVersion(FileName:String=''):String;

function httpGetString(url: string): String;
function wget(const fileURL, DestFileName: String): boolean;

function GetCmdParams(ID:String;Default:String=''):String;

//Return the content of the file as a string.
// url can be either a local file location ('p:\bin\jjj') or
// a http url : 'http://mailhost.sermo.fr/ini/data/toto.txt'
function httpget(url:String):String;

//Create a Tmemorystream or a Tfilestream with the content of the result of http URL or file location
// if the file exist (url is a local file location of type p:\bin\truc.jpg), then a filestream is created and returned in stream
// else the http protocol is used and a memorystream is returned
// IMPORTANT : stream should be freed by the caller after use !
function httpNewStream(url:String):TStream;

//remplace les variables d'environnement windows (%toto%) par leur valeur
function ExpandEnvVars(const Str: string): string;


function phonenormalize(number:String):String;
function phonenormalize2(phone:String):String;
function phonesimplify(number:String):String;
function PhoneCallCompose(phoneproxy_url,fromnumber,tonumber:String):boolean;
function EncodeURIComponent(const ASrc: string): UTF8String;

function ISODebutSem(ADate:TDateTime):TDateTime;
function ISOFinSem(ADate:TDateTime):TDateTime;

function StrSplit(St: AnsiString; Sep: Char): TDynStringArray; 
function StrSplitInt(St: AnsiString; Sep: Char): TDynIntArray;

function StrJoin(Sep: String; StrArray: TDynStringArray): String;
function StrIn(st:String;StrArray: TDynStringArray):Boolean;
function IntIn(id:Integer;IntArray: TDynIntArray):Boolean;

implementation


uses jclshell,ShlObj,wininet,jcldatetime,jclstrings,idhttp;

var
  GlobalHINET:HINTERNET;

function StrIn(st:String;StrArray: TDynStringArray):Boolean;
var
  i:integer;
begin
  for i:=low(StrArray) to high(StrArray) do
  begin
    if st = StrArray[i] then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;


function intIn(id:integer;IntArray: TDynIntArray):Boolean;
var
  i:integer;
begin
  for i:=low(IntArray) to high(IntArray) do
  begin
    if id = IntArray[i] then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function StrSplit(St: AnsiString; Sep: Char): TDynStringArray; 
var
  tok : AnsiString;
  len : integer;
begin
  len := 0;
  SetLength(Result,0);
  repeat
    tok := StrToken(St,Sep);
    if tok<>'' then
    begin
      inc(len);
      SetLength(Result,len);
      Result[len-1] := tok;
    end;
  until St='';
end;

function StrSplitInt(St: AnsiString; Sep: Char): TDynIntArray;
var
  tok : AnsiString;
  len : integer;
begin
  len := 0;
  SetLength(Result,0);
  repeat
    tok := StrToken(St,Sep);
    if tok<>'' then
    begin
      inc(len);
      SetLength(Result,len);
      Result[len-1] := StrToIntSafe(tok);
    end;
  until St='';
end;

function StrJoin(Sep: String; StrArray: TDynStringArray): String;
var
  i:integer;
begin
  Result := '';
  for i:=0 to length(StrArray)-1 do
  begin
    Result:=Result+StrArray[i];
    if i<length(StrArray)-1 then
      Result := Result+Sep;
  end;
end;


function GetCmdParams(ID:String;Default:String=''):String;
var
	i:integer;
	S:String;
  found:Boolean;
begin
	Result:='';
  found:=False;
	for i:=1 to ParamCount do
	begin
		S:=ParamStr(i);
		if
			(AnsiCompareText(Copy(S, 1, Length(ID)+2), '/'+ID+'=') = 0) or
			(AnsiCompareText(Copy(S, 1, Length(ID)+2), '-'+ID+'=') = 0) then
		begin
      found:=True;
			Result:=Copy(S,Length(ID)+2+1,MaxInt);
			Break;
		end;
	end;
  if not Found then
    Result:=Default;
end;

function ExpandEnvVars(const Str: string): string;
var
  BufSize: Integer; // size of expanded string
begin
  // Get required buffer size
  BufSize := ExpandEnvironmentStrings(
    PChar(Str), nil, 0);
  if BufSize > 0 then
  begin
    // Read expanded string into result string
    SetLength(Result, BufSize);
    ExpandEnvironmentStrings(PChar(Str),
      PChar(Result), BufSize);
    Result:=PChar(Result);
  end
  else
    // Trying to expand empty string
    Result := '';
end;

function httpGetString(
    url: string): String;
var
  hFile: HINTERNET;
  localFile: File;
  buffer: array[1..1024] of byte;
  bytesRead: DWORD;
  pos:integer;
  dwindex,dwcodelen,dwread,dwNumber: cardinal;
  dwcode : array[1..20] of char;
  res    : pchar;

begin
  result := '';
  if not Assigned(GlobalhInet) then
    GlobalhInet := InternetOpen('tisutils',
      INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  hFile := InternetOpenURL(GlobalhInet,PChar(url),nil,0,
    INTERNET_FLAG_IGNORE_CERT_CN_INVALID or INTERNET_FLAG_NO_CACHE_WRITE
    or INTERNET_FLAG_PRAGMA_NOCACHE or INTERNET_FLAG_RELOAD+INTERNET_FLAG_KEEP_CONNECTION ,0);
  if Assigned(hFile) then
  try
    dwIndex  := 0;
    dwCodeLen := 10;
    HttpQueryInfo(hFile, HTTP_QUERY_STATUS_CODE, @dwcode, dwcodeLen, dwIndex);
    res := pchar(@dwcode);
    dwNumber := sizeof(Buffer)-1;
    if (res ='200') or (res ='302') then
    begin
      Result:='';
      pos:=1;
      repeat
        FillChar(buffer,SizeOf(buffer),0);
        InternetReadFile(hFile,@buffer,SizeOf(buffer),bytesRead);
        SetLength(Result,Length(result)+bytesRead+1);
        Move(Buffer,Result[pos],bytesRead);
        inc(pos,bytesRead);
      until bytesRead = 0;
    end
    else
       raise Exception.Create('Unable to download: "'+URL+'", HTTP Status:'+res);
  finally
    InternetCloseHandle(hFile);
  end;
end;

function wget(const fileURL, DestFileName: String): boolean;
 const
   BufferSize = 1024;
 var
   hSession, hURL: HInternet;
   Buffer: array[1..BufferSize] of Byte;
   BufferLen: DWORD;
   f: File;
   sAppName: string;
   Size: Integer;
   dwindex,dwcodelen,dwread,dwNumber: cardinal;
   dwcode : array[1..20] of char;
   res    : pchar;
   Str    : pchar;

begin
  result := false;
  sAppName := ExtractFileName(ParamStr(0)) ;
  hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;
  try
    hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0, INTERNET_FLAG_IGNORE_CERT_CN_INVALID+INTERNET_FLAG_RELOAD+INTERNET_FLAG_PRAGMA_NOCACHE, 0) ;
    if assigned(hURL) then
    try
      dwIndex  := 0;
      dwCodeLen := 10;
      HttpQueryInfo(hURL, HTTP_QUERY_STATUS_CODE, @dwcode, dwcodeLen, dwIndex);
      res := pchar(@dwcode);
      dwNumber := sizeof(Buffer)-1;
      if (res ='200') or (res ='302') then
      begin
        Size:=0;
        AssignFile(f, utf8Toansi(DestFileName)) ;
        Rewrite(f,1) ;
        repeat
          BufferLen:= 0;
          if InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) then
          begin
            inc(Size,BufferLen);
            BlockWrite(f, Buffer, BufferLen)
          end;
        until BufferLen = 0;
        CloseFile(f) ;
        result := (Size>0);
      end
      else
        raise Exception.Create('Unable to download: "'+fileURL+'", HTTP Status:'+res);
    finally
      InternetCloseHandle(hURL)
    end
  finally
    InternetCloseHandle(hSession)
  end
end;


function GetUserName : String;
var
	 pcUser   : PChar;
	 dwUSize : DWORD;
begin
  Result :='';
	 dwUSize := 21; // user name can be up to 20 characters
	 GetMem( pcUser, dwUSize ); // allocate memory for the string
	 try
			if Windows.GetUserName( pcUser, dwUSize ) then
				 Result := pcUser
	 finally
			FreeMem( pcUser ); // now free the memory allocated for the string
	 end;
end;


function GetApplicationName:String;
begin
  //Result := Application.Name;
  Result := ChangeFileExt(ExtractFileName(ParamStr(0)),'');
end;

function GetPersonalFolder:String;
begin
  result := GetSpecialFolderLocation(CSIDL_PERSONAL)
end;

function GetAppdataFolder:String;
begin
  result :=  GetSpecialFolderLocation(CSIDL_APPDATA);
end;

function Appuserinipath:String;
var
  dir : String;
begin
  dir := IncludeTrailingPathDelimiter(GetAppdataFolder)+'tisapps';
  if not DirectoryExists(dir) then
    MkDir(dir);
  Result:=IncludeTrailingPathDelimiter(dir)+GetApplicationName+'.ini';
end;

type
PFixedFileInfo = ^TFixedFileInfo;
TFixedFileInfo = record
   dwSignature       : DWORD;
   dwStrucVersion    : DWORD;
   wFileVersionMS    : WORD;  // Minor Version
   wFileVersionLS    : WORD;  // Major Version
   wProductVersionMS : WORD;  // Build Number
   wProductVersionLS : WORD;  // Release Version
   dwFileFlagsMask   : DWORD;
   dwFileFlags       : DWORD;
   dwFileOS          : DWORD;
   dwFileType        : DWORD;
   dwFileSubtype     : DWORD;
   dwFileDateMS      : DWORD;
   dwFileDateLS      : DWORD;
end; // TFixedFileInfo

function GetApplicationVersion(Filename:String=''): String;
var
  dwHandle, dwVersionSize : DWORD;
  strSubBlock             : String;
  pTemp                   : Pointer;
  pData                   : Pointer;
begin
  Result:='';
  if Filename='' then
    FileName:=ParamStr(0);
   strSubBlock := '\';

   // get version information values
   dwVersionSize := GetFileVersionInfoSize( PChar( FileName ), // pointer to filename string
                                            dwHandle );        // pointer to variable to receive zero

   // if GetFileVersionInfoSize is successful
   if dwVersionSize <> 0 then
   begin
      GetMem( pTemp, dwVersionSize );
      try
         if GetFileVersionInfo( PChar( FileName ),             // pointer to filename string
                                dwHandle,                      // ignored
                                dwVersionSize,                 // size of buffer
                                pTemp ) then                   // pointer to buffer to receive file-version info.

            if VerQueryValue( pTemp,                           // pBlock     - address of buffer for version resource
                              PChar( strSubBlock ),            // lpSubBlock - address of value to retrieve
                              pData,                           // lplpBuffer - address of buffer for version pointer
                              dwVersionSize ) then             // puLen      - address of version-value length buffer
               with PFixedFileInfo( pData )^ do
                Result:=IntToSTr(wFileVersionLS)+'.'+IntToSTr(wFileVersionMS)+
                      '.'+IntToStr(wProductVersionLS);
      finally
         FreeMem( pTemp );
      end; // try
   end; // if dwVersionSize
end;

{ TUrlIniFile }

constructor TURLIniFile.Create(const URL: string);
var
  St:TStringList;
begin
  inherited Create('');
  St:=TStringList.Create;
  try
    St.Text:=httpGet(URL);
    SetStrings(St);
  finally
    St.Free;
  end;
end;

function httpget(url:String):String;
var
  f:TFileStream;
  ARes:String;
begin
  if not FileExists(URL) then
    Result:=httpGetString(url)
  else
  begin
    F:=TFileStream.Create(URL,fmOpenRead,fmShareDenyNone);
    try
      SetLength(ARes,F.Size);
      F.Seek(0,soFromBeginning);
      F.ReadBuffer(ARes[1],length(ARes));
      Result:=ARes;
    finally
      F.Free;
    end;
  end;
end;

Function httpNewStream(url:String):TStream;
var
  content:String;
begin
  if not FileExists(URL) then
  begin
    result:=TMemoryStream.Create;
    Content:=httpGetString(url);
    Result.Write(Content[1],Length(Content));
    result.Seek(0,soFromBeginning);
  end
  else
    result:=TFileStream.Create(URL,fmOpenRead,fmShareDenyNone);
end;





function ISODebutSem(ADate:TDateTime):TDateTime;
var
	D, W, Y: Integer;
begin
	W := ISOWeekNumber(ADate, Y, D);
	Result := ISOWeekToDateTime(Y, W, 1);
end;

function ISOFinSem(ADate:TDateTime):TDateTime;
var
	D, W, Y: Integer;
begin
	W := ISOWeekNumber(ADate, Y, D);
	Result := ISOWeekToDateTime(Y, W, 7);
end;

function phonesimplify(number:String):String;
var
  i:integer;
begin
  Result:='';
  for i:=1 to length(number) do
     if CharIsDigit(number[i]) or (number[i]='+') then
      Result := Result + number[i];
end;

function phonenormalize(number:String):String;
var
  i:integer;
begin
  number:=phonesimplify(number);
  if (copy(number,1,1)='+') or (length(number)<=5) then
    Result := Number
  else
  begin
    if copy(number,1,2)='00' then
      Result := '+'+ copy(number,3,255)
    else
    if (copy(number,1,1)='0') and (length(number)>=10) then
      Result := '+33'+ copy(number,2,255)
    else
      Result := number;
  end;
end;

function phonenormalize2(phone:String):String;
var
  i:integer;
begin
  Result := '';
  //supression de tout sauf digits
  for i:=1 to length(phone) do
    if CharIsDigit(Phone[i]) then
      Result := Result+phone[i];

  if copy(Result,1,4)='0033' then
    result := copy(result,5,255);

  if length(Result)>4 then
  begin
    if copy(Result,1,2)='00' then
      Result := copy(Result,1,4)+'.'+copy(Result,5,1)+'.'+copy(Result,6,2)+'.'+copy(Result,8,2)+'.'+copy(Result,10,2)+'.'+copy(Result,12,255)
    else
    begin
      //ajout un z�ro en t�te
      if result[1]<>'0'
        then result := '0'+Result;

      Result := copy(Result,1,2)+'.'+copy(Result,3,2)+'.'+copy(Result,5,2)+'.'+copy(Result,7,2)+'.'+copy(Result,9,255);
    end;
  end;
end;




function PhoneCallCompose(phoneproxy_url,fromnumber,tonumber:String):boolean;
var
  http:TIdHTTP;
  st:TMemoryStream;
  res:String;
begin
  tonumber := phonesimplify(tonumber);
  try
    screen.Cursor := crHourGlass;
    st := TMemoryStream.Create;
    http:=TIdHTTP.Create(Nil);
    res := http.Get(phoneproxy_url +'/call/'+EncodeURIComponent(fromnumber)+'/'+EncodeURIComponent(tonumber));
    Result := res = 'ok';
  finally
    screen.Cursor := crdefault;
    http.Free;
    St.Free;
  end;
end;


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



end.
