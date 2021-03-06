unit soutils;
{ -----------------------------------------------------------------------
#    This file is part of WAPT
#    Copyright (C) 2013  Tranquil IT Systems http://www.tranquil.it
#    WAPT aims to help Windows systems administrators to deploy
#    setup and update applications on users PC.
#
#    Part of this file is based on JEDI JCL library
#
#    WAPT is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    WAPT is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WAPT.  If not, see <http://www.gnu.org/licenses/>.
#
# -----------------------------------------------------------------------
}
interface

uses
  Classes, SysUtils,SuperObject;

function StringList2SuperObject(St:TStringList):ISuperObject;
function SplitLines(const St:String):ISuperObject;
function Split(const St: String; Sep: String): ISuperObject;
function Join(const Sep: String; Arr:ISuperObject):String;
function StrIn(const St: String; List:ISuperObject): Boolean;
function DynArr2SuperObject(const items: Array of String):ISuperObject;
function StrToken(var S: string; Separator: String): string;
function ExtractField(SOList:ISuperObject;fieldname:String):ISuperObject;

function csv2SO(csv:UTF8String;Sep:Char=#0):ISuperObject;

type TSOCompare=function (SOArray:ISuperObject;idx1,idx2:integer):integer;
function DefaultSOCompareFunc(SOArray:ISuperObject;idx1,idx2:integer):integer;
procedure Sort(SOArray: ISuperObject;CompareFunc: TSOCompare);

procedure SortByFields(SOArray: ISuperObject;Fields:array of string);

function SOArrayFindFirst(AnObject, List: ISuperObject; keys: array of String): ISuperobject;

implementation

uses StrUtils,jclStrings;

function StrToken(var S: string; Separator: String): string;
var
  I: Integer;
begin
  I := Pos(Separator, S);
  if I <> 0 then
  begin
    Result := Copy(S, 1, I - 1);
    Delete(S, 1, I+Length(Separator)-1);
  end
  else
  begin
    Result := S;
    S := '';
  end;
end;

function DynArr2SuperObject(const items: Array of String):ISuperObject;
var
  i:integer;
begin
  Result := TSuperObject.Create(stArray);
  for i:=low(items) to High(items) do
    Result.AsArray.Add(items[i]);

end;


function StringList2SuperObject(St: TStringList): ISuperObject;
var
  i:integer;
begin
  Result := TSuperObject.Create(stArray);
  for i:=0 to st.Count-1 do
    Result.AsArray.Add(st[i]);
end;


function SplitLines(const St: String): ISuperObject;
var
  tok : String;
  St2:String;
begin
  Result := TSuperObject.Create(stArray);
  st2 := StringReplace(St,#13#10,#13,[rfReplaceAll]);
  st2 := StringReplace(St2,#10#13,#13,[rfReplaceAll]);
  st2 := StringReplace(St2,#10,#13,[rfReplaceAll]);
  while St2<>'' do
  begin
    tok := StrToken(St2,#13);
    Result.AsArray.Add(tok);
  end;
end;

function Split(const St: String; Sep: String): ISuperObject;
var
  tok : String;
  St2:String;
begin
  Result := TSuperObject.Create(stArray);
  St2 := St;
  while St2<>'' do
  begin
    tok := StrToken(St2,Sep);
    Result.AsArray.Add(tok);
  end;
end;

function ExtractField(SOList:ISuperObject;fieldname:String):ISuperObject;
var
  item:ISuperObject;
  i:integer;
begin
  if (SOList<>Nil) and (SOList.AsArray<>Nil) then
  begin
    Result := TSuperObject.Create(stArray);
    for i:=0 to SOList.AsArray.Length-1 do
    begin
      item := SOList.AsArray[i];
      Result.AsArray.Add(item[fieldname]);
    end;
  end
  else
    Result := Nil;
end;

function Join(const Sep: String; Arr: ISuperObject): String;
var
  item:ISuperObject;
  i:integer;
begin
  result := '';
  if Arr<>Nil then
  begin
    if Arr.DataType=stArray then
      for i:=0 to Arr.AsArray.length-1 do
      begin
        item := Arr.AsArray[i];
        if Result<>'' then
          Result:=Result+Sep;
        Result:=Result+item.AsString;
      end
    else
      Result := Arr.AsString;
  end;
end;

// return True if St is in the List list of string
function StrIn(const St: String; List: ISuperObject): Boolean;
var
  it:ISuperObject;
  st1,st2:String;
  i:integer;
begin
  if List <>Nil then
    for i:=0 to list.AsArray.Length-1 do
    begin
      it := List.AsArray[i];
      if (it.DataType=stString) and (it.AsString=St) then
      begin
        result := True;
        Exit;
      end;
    end;
  result := False;
end;

function csv2SO(csv: UTF8String;Sep:Char=#0): ISuperObject;
var
  r,col,maxcol:integer;
  row : String;
  Lines,header,values,newrec:ISuperObject;
begin
  lines := SplitLines(csv);
  row := lines.AsArray.S[0];
  if Sep=#0 then
  begin
    if pos(#9,row)>0 then
      Sep := #9
    else
    if pos(';',row)>0 then
      Sep := ';'
    else
    if pos(',',row)>0 then
      Sep := ',';
  end;

  header := Split(row,Sep);
  result := TSuperObject.Create(stArray);
  if Lines.AsArray.Length>1 then
    for r:=1 to lines.AsArray.Length-1 do
    begin
      row := lines.AsArray.S[r];
      values :=Split(row,sep);
      Newrec := TSuperObject.Create;
      result.AsArray.Add(newrec);
      maxcol := values.AsArray.Length;
      if maxcol > header.AsArray.Length then
        maxcol := header.AsArray.Length;

      for col := 0 to maxcol-1 do
        newrec.S[header.AsArray.S[col]] := UTF8Decode(values.AsArray.S[col]);
    end
  else
  begin
    Newrec := TSuperObject.Create;
    result.AsArray.Add(newrec);
    for col := 0 to header.AsArray.Length-1 do
      newrec.S[header.AsArray.S[col]] := '';
  end;
end;

function DefaultSOCompareFunc(SOArray:ISuperObject;idx1,idx2:integer):integer;
var
  compresult : TSuperCompareResult;
  SO1,SO2:ISuperObject;

begin
  SO1 := SOArray.AsArray[idx1];
  SO2 := SOArray.AsArray[idx2];
  compresult := SO1.Compare(SO2);
  case compresult of
    cpLess : Result := -1;
    cpEqu  : Result := 0;
    cpGreat : Result := 1;
    cpError :  Result := CompareStr(SO1.AsString,SO2.AsString);
  end;
end;

procedure Sort(SOArray: ISuperObject;CompareFunc: TSOCompare);
  procedure QuickSort(L, R: integer;CompareFunc: TSOCompare);
  var
    I, J, P: Integer;
    item1,item2:ISuperObject;
  begin
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while CompareFunc(SOArray, I, P) < 0 do Inc(I);
        while CompareFunc(SOArray,J, P) > 0 do Dec(J);
        if I <= J then
        begin
          //exchange items
          item1 := SOArray.AsArray[I];
          item2 := SOArray.AsArray[J];
          SOArray.AsArray[I] := item2;
          SOArray.AsArray[J] := item1;
          if P = I then
            P := J
          else if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSort(L, J, CompareFunc);
      L := I;
    until I >= R;
  end;

begin
  If not Assigned(CompareFunc) then
     CompareFunc :=  @DefaultSOCompareFunc;
  if (SOArray.AsArray<>Nil) and (SOArray.AsArray.Length>1) then
    QuickSort(0,SOArray.AsArray.Length-1,CompareFunc);
end;

procedure SortByFields(SOArray: ISuperObject;Fields:array of string);
  function SOCompareFields(SOArray:ISuperObject;idx1,idx2:integer):integer;
  var
    compresult : TSuperCompareResult;
    SO1,SO2,F1,F2:ISuperObject;
    i:integer;
  begin
    SO1 := SOArray.AsArray[idx1];
    SO2 := SOArray.AsArray[idx2];
    for i:=low(Fields) to high(fields) do
    begin
      F1 := SO1[Fields[i]];
      F2 := SO2[Fields[i]];
      compresult := SO1.Compare(SO2);
      case compresult of
        cpLess : Result := -1;
        cpEqu  : Result := 0;
        cpGreat : Result := 1;
        cpError :  Result := CompareStr(F1.AsString,F2.AsString);
      end;
      if Result<>0 then
        Break;
    end;
  end;

  procedure QuickSort(L, R: integer);
  var
    I, J, P: Integer;
    item1,item2:ISuperObject;
  begin
    repeat
      I := L;
      J := R;
      P := (L + R) shr 1;
      repeat
        while SOCompareFields(SOArray, I, P) < 0 do Inc(I);
        while SOCompareFields(SOArray,J, P) > 0 do Dec(J);
        if I <= J then
        begin
          //exchange items
          item1 := SOArray.AsArray[I];
          item2 := SOArray.AsArray[J];
          SOArray.AsArray[I] := item2;
          SOArray.AsArray[J] := item1;
          if P = I then
            P := J
          else if P = J then
            P := I;
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then QuickSort(L, J);
      L := I;
    until I >= R;
  end;

begin
  if (SOArray.AsArray<>Nil) and (SOArray.AsArray.Length>1) then
    QuickSort(0,SOArray.AsArray.Length-1);
end;

function SOArrayFindFirst(AnObject, List: ISuperObject; keys: array of String
  ): ISuperobject;
var
  item: ISuperObject;
  key:String;
  i,j:integer;
begin
  Result := Nil;
  for i:=0 to List.AsArray.Length-1 do
  begin
    item := List.AsArray[i];
    if length(keys) =0 then
    begin
      if item.Compare(AnObject) = cpEqu then
      begin
        Result := item;
        exit;
      end;
    end
    else
    begin
      for j:= low(keys) to high(keys) do
      begin
        key := keys[j];
        if item[key].Compare(AnObject[key]) <> cpEqu then
          break;
      end;
      if item[key].Compare(AnObject[key]) = cpEqu then
      begin
        Result := item;
        exit;
      end;
    end;
  end;
end;

end.


